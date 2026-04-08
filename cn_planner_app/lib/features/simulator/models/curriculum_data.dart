import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'course_model.dart';
import 'term_model.dart';

/// CurriculumData
///
/// ดึงข้อมูลหลักสูตรจาก Supabase แทน hardcode:
///   - profiles       → current_year, current_semester
///   - UserRoadmap    → วิชาของ user แต่ละเทอม + grade/status
///   - Subjects       → ชื่อ, credits, prerequisites, offeredSemester
///   - ClassSchedules → ตารางเรียน
///
/// Static constants (ไม่เปลี่ยน) ยังคงอยู่เพื่อใช้กับ logic ส่วนอื่น.
class CurriculumData {
  static const String programName = 'Computer Engineering';
  static const int totalProgramCredits = 146;
  static const int minCreditsPerTerm = 9;
  static const int maxCreditsPerTerm = 21;
  static const int maxSupportedYear = 8;

  // ─── Build CourseModel from Supabase rows ─────────────────────────────────

  static CourseOutcome _gradeToOutcome(String? grade, String? status) {
    if (grade == 'F') return CourseOutcome.fail;
    if (grade == 'W') return CourseOutcome.withdraw;
    if (grade != null && grade != '-' && grade.isNotEmpty)
      return CourseOutcome.pass;
    if (status == 'passed') return CourseOutcome.pass;
    if (status == 'not_pass') return CourseOutcome.fail;
    return CourseOutcome.notSet;
  }

  static List<TimeSlot> _slotsFor(
    String code,
    List<Map<String, dynamic>> scheduleRows,
  ) {
    return scheduleRows
        .where((r) => r['subject_code'] == code)
        .map(
          (r) => TimeSlot(
            day: r['day'] as String,
            start: r['start_time'] as String,
            end: r['end_time'] as String,
          ),
        )
        .toList();
  }

  static CourseModel _buildCourse({
    required Map<String, dynamic> subjectRow,
    required Map<String, dynamic>? roadmapRow, // null = not in user roadmap
    required List<Map<String, dynamic>> scheduleRows,
    required CourseStatus courseStatus,
  }) {
    final code = subjectRow['subjectCode'] as String? ?? '';
    final name = subjectRow['subjectName'] as String? ?? code;
    final credits = ((subjectRow['credits'] ?? 0) as num).toInt();

    final prereqs =
        (subjectRow['require'] as List?)?.map((e) => e.toString()).toList() ??
        [];

    final offered =
        (subjectRow['offeredSemester'] as List?)
            ?.map((e) => (e as num).toInt())
            .toList() ??
        [1, 2];

    final grade = roadmapRow?['grade'] as String?;
    final status = roadmapRow?['status'] as String?;
    final outcome = _gradeToOutcome(grade, status);

    return CourseModel(
      code: code,
      name: name,
      credits: credits,
      prerequisites: prereqs,
      availableTerms: offered,
      schedule: _slotsFor(code, scheduleRows),
      status: courseStatus,
      outcome: outcome,
      grade: grade,
      subjectId: (subjectRow['subjectId'] as num?)?.toInt(),
    );
  }

  // ─── Main loader ──────────────────────────────────────────────────────────

  /// ดึงข้อมูลทั้งหมดจาก Supabase แล้วสร้าง List<TermModel>
  /// พร้อม currentYear/currentSemester จาก profiles
  static Future<
    ({
      List<TermModel> terms,
      int currentYear,
      int currentSemester,
      Map<String, CourseModel> catalogByCode,
    })
  >
  loadFromSupabase() async {
    final supabase = Supabase.instance.client;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('User not logged in');

    // Parallel fetch
    final results = await Future.wait([
      supabase
          .from('profiles')
          .select('current_year, current_semester, max_year')
          .eq('user_id', uid)
          .single(),
      supabase
          .from('UserRoadmap')
          .select(
            'subject_code, subjectId, year, semester, grade, status, section',
          )
          .eq('user_id', uid)
          .order('year')
          .order('semester'),
      supabase
          .from('Subjects')
          .select(
            'subjectId, subjectCode, subjectName, credits, require, corequisite, offeredSemester',
          ),
      supabase
          .from('ClassSchedules')
          .select('subject_code, section, day, start_time, end_time'),
    ]);

    final profile = results[0] as Map<String, dynamic>;
    final roadmapList = (results[1] as List).cast<Map<String, dynamic>>();
    final subjectList = (results[2] as List).cast<Map<String, dynamic>>();
    final scheduleList = (results[3] as List).cast<Map<String, dynamic>>();

    final int currentYear = (profile['current_year'] as num?)?.toInt() ?? 1;
    final int currentSem = (profile['current_semester'] as num?)?.toInt() ?? 1;
    final int maxYear = (profile['max_year'] as num?)?.toInt() ?? 4;
    final int currentIdx = (currentYear - 1) * 2 + currentSem;

    // Build quick-lookup maps
    final subjectByCode = <String, Map<String, dynamic>>{};
    for (final s in subjectList) {
      final code = s['subjectCode'] as String?;
      if (code != null) subjectByCode[code] = s;
    }

    // Build roadmap lookup: 'code_year_sem' → row
    final roadmapByKey = <String, Map<String, dynamic>>{};
    for (final r in roadmapList) {
      final key = '${r['subject_code']}_${r['year']}_${r['semester']}';
      roadmapByKey[key] = r;
    }

    // Group roadmap by (year, semester)
    final termKeys = <String, ({int year, int semester})>{};
    for (final r in roadmapList) {
      final y = (r['year'] as num).toInt();
      final s = (r['semester'] as num).toInt();
      termKeys['${y}_${s}'] = (year: y, semester: s);
    }

    // Ensure Y4S1 and Y4S2 always exist (and up to maxYear)
    for (var y = 1; y <= maxYear; y++) {
      for (var s = 1; s <= 2; s++) {
        termKeys['${y}_${s}'] ??= (year: y, semester: s);
      }
    }

    final sortedKeys = termKeys.values.toList()
      ..sort((a, b) {
        final ia = (a.year - 1) * 2 + a.semester;
        final ib = (b.year - 1) * 2 + b.semester;
        return ia.compareTo(ib);
      });

    // Build TermModel list
    final terms = <TermModel>[];
    for (final tk in sortedKeys) {
      final termIdx = (tk.year - 1) * 2 + tk.semester;

      final TermStatus termStatus;
      if (termIdx < currentIdx) {
        termStatus = TermStatus.passed;
      } else if (termIdx == currentIdx) {
        termStatus = TermStatus.current;
      } else {
        termStatus = TermStatus.upcoming;
      }

      final CourseStatus courseStatus;
      if (termIdx < currentIdx) {
        courseStatus = CourseStatus.passed;
      } else if (termIdx == currentIdx) {
        courseStatus = CourseStatus.current;
      } else {
        courseStatus = CourseStatus.upcoming;
      }

      // Find courses for this term (from UserRoadmap)
      final termCourses = roadmapList
          .where(
            (r) =>
                (r['year'] as num).toInt() == tk.year &&
                (r['semester'] as num).toInt() == tk.semester,
          )
          .map((r) {
            final code = r['subject_code'] as String;
            final subRow =
                subjectByCode[code] ??
                {'subjectCode': code, 'subjectName': code, 'credits': 0};
            return _buildCourse(
              subjectRow: subRow,
              roadmapRow: r,
              scheduleRows: scheduleList,
              courseStatus: courseStatus,
            );
          })
          .toList();

      terms.add(
        TermModel(
          year: tk.year,
          term: tk.semester,
          status: termStatus,
          courses: termCourses,
        ),
      );
    }

    // Build catalog (all subjects from DB)
    final catalogByCode = <String, CourseModel>{};
    for (final s in subjectList) {
      final code = s['subjectCode'] as String? ?? '';
      if (code.isEmpty) continue;
      catalogByCode[code] = _buildCourse(
        subjectRow: s,
        roadmapRow: null,
        scheduleRows: scheduleList,
        courseStatus: CourseStatus.upcoming,
      );
    }

    return (
      terms: terms,
      currentYear: currentYear,
      currentSemester: currentSem,
      catalogByCode: catalogByCode,
    );
  }

  // ─── Static helpers (unchanged) ───────────────────────────────────────────

  static List<TermModel> getEmptyYearTerms(int year) => [
    TermModel(year: year, term: 1, courses: []),
    TermModel(year: year, term: 2, courses: []),
  ];
}
