import 'package:cn_planner_app/features/roadmap/data/static_roamap_data.dart';
import 'package:cn_planner_app/features/roadmap/models/subject_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'course_model.dart';
import 'term_model.dart';

class CurriculumData {
  static const String programName = 'Computer Engineering';
  static const int totalProgramCredits = 146;
  static const int minCreditsPerTerm = 9;
  static const int maxCreditsPerTerm = 21;
  static const int maxSupportedYear = 8;

  static int _termOrder(int year, int semester) => (year - 1) * 10 + semester;

  static CourseOutcome _gradeToOutcome(String? grade, String? status) {
    if (grade == 'F') return CourseOutcome.fail;
    if (grade == 'W') return CourseOutcome.withdraw;
    if (grade != null && grade != '-' && grade.isNotEmpty) {
      return CourseOutcome.pass;
    }
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
    required Map<String, dynamic>? roadmapRow,
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

  // ─── Load from STATIC ROADMAP TEMPLATE ────────────────────────────────────
  // ✅ [#2] รับ planType จากภายนอก (ส่งมาจาก roadmap page)
  //        ถ้าไม่ส่งมา จะ fallback ไป detect จาก UserRoadmap เหมือนเดิม
  // ✅ [#1] เทอม passed → ดึง grade จาก UserRoadmap:
  //        - ไม่มี F/W = pass (fixed, ไม่ toggle ได้)
  //        - มี F หรือ W = fail/withdraw (fixed, ไม่ toggle ได้)
  //   เทอม current → default fail (toggle ได้)
  //   เทอม upcoming → notSet (locked)

  static Future<
    ({
      List<TermModel> terms,
      int currentYear,
      int currentSemester,
      Map<String, CourseModel> catalogByCode,
      String detectedPlanType,
    })
  >
  loadFromStaticData({String? planType}) async {
    final supabase = Supabase.instance.client;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('User not logged in');

    final results = await Future.wait<dynamic>([
      supabase
          .from('profiles')
          .select('current_year, current_semester, max_year')
          .eq('user_id', uid)
          .single(),
      supabase
          .from('Subjects')
          .select(
            'subjectId, subjectCode, subjectName, credits, require, corequisite, offeredSemester',
          ),
      supabase
          .from('ClassSchedules')
          .select('subject_code, section, day, start_time, end_time'),
      supabase
          .from('UserRoadmap')
          .select('subject_code, year, semester, grade, status')
          .eq('user_id', uid),
    ]);

    final profile = results[0] as Map<String, dynamic>;
    final subjectList = (results[1] as List).cast<Map<String, dynamic>>();
    final scheduleList = (results[2] as List).cast<Map<String, dynamic>>();
    final roadmapList = (results[3] as List).cast<Map<String, dynamic>>();

    final int currentYear = (profile['current_year'] as num?)?.toInt() ?? 1;
    final int currentSem = (profile['current_semester'] as num?)?.toInt() ?? 1;
    final int currentIdx = _termOrder(currentYear, currentSem);

    final subjectByCode = <String, Map<String, dynamic>>{};
    for (final s in subjectList) {
      final code = s['subjectCode'] as String?;
      if (code != null) subjectByCode[code] = s;
    }

    // Historical grade lookup (latest per code, from UserRoadmap)
    final roadmapGrade = <String, Map<String, dynamic>>{};
    for (final r in roadmapList) {
      final code = r['subject_code'] as String?;
      if (code != null) roadmapGrade[code] = r;
    }

    // ✅ [#2] ถ้าส่ง planType มา ใช้เลย; ถ้าไม่ส่ง detect จาก UserRoadmap
    String selectedPlan = planType ?? RoadmapTemplate.PLAN_INTERNSHIP;
    if (planType == null) {
      for (final r in roadmapList) {
        final code = r['subject_code'] as String?;
        if (code == 'CN403' || code == 'CN404') {
          selectedPlan = RoadmapTemplate.PLAN_COOP;
          break;
        }
        if (code == 'CN471' || code == 'CN472' || code == 'CN473') {
          selectedPlan = RoadmapTemplate.PLAN_RESEARCH;
          break;
        }
      }
    }

    final allSubjectModels = subjectList
        .map(
          (s) => SubjectModel(
            subjectId: (s['subjectId'] as num?)?.toInt() ?? 0,
            subjectCode: s['subjectCode'] as String? ?? '',
            subjectName: s['subjectName'] as String? ?? '',
            credits: ((s['credits'] ?? 0) as num).toDouble(),
            require: (s['require'] as List?)?.map((e) => e.toString()).toList(),
            su_grade: s['su_grade'] as bool? ?? false,
          ),
        )
        .toList();

    final templateItems = RoadmapTemplate.getPlanForUser(
      selectedPlan: selectedPlan,
      allSubjects: allSubjectModels,
    );

    final termItemsMap = <String, List<Map<String, dynamic>>>{};
    for (final item in templateItems) {
      termItemsMap
          .putIfAbsent('${item['year']}_${item['semester']}', () => [])
          .add(item);
    }

    final sortedKeys = termItemsMap.keys.toList()
      ..sort((a, b) {
        final pa = a.split('_').map(int.parse).toList();
        final pb = b.split('_').map(int.parse).toList();
        return _termOrder(pa[0], pa[1]).compareTo(_termOrder(pb[0], pb[1]));
      });

    final terms = <TermModel>[];

    for (final key in sortedKeys) {
      final parts = key.split('_').map(int.parse).toList();
      final y = parts[0];
      final s = parts[1];
      final termIdx = _termOrder(y, s);

      final termStatus = termIdx < currentIdx
          ? TermStatus.passed
          : termIdx == currentIdx
          ? TermStatus.current
          : TermStatus.upcoming;
      final courseStatus = termIdx < currentIdx
          ? CourseStatus.passed
          : termIdx == currentIdx
          ? CourseStatus.current
          : CourseStatus.upcoming;

      final termCourses = <CourseModel>[];
      for (final item in termItemsMap[key]!) {
        final code = item['subject_code'] as String;
        final templateCredits = (item['credit'] as num).toInt();
        final displayName = item['display_name'] as String? ?? code;

        if (code.contains('X')) {
          // Elective placeholder
          // ✅ [#1] passed term: pass fixed; current: default fail; upcoming: notSet
          final outcome = termStatus == TermStatus.passed
              ? CourseOutcome.pass
              : termStatus == TermStatus.current
              ? CourseOutcome.fail
              : CourseOutcome.notSet;
          termCourses.add(
            CourseModel(
              code: code,
              name: displayName,
              credits: templateCredits,
              status: courseStatus,
              outcome: outcome,
            ),
          );
          continue;
        }

        final subRow = subjectByCode[code];
        CourseOutcome outcome;

        if (termStatus == TermStatus.passed) {
          // ✅ [#1] ดึงจาก UserRoadmap จริง ๆ
          final grade = roadmapGrade[code]?['grade'] as String?;
          final rmStatus = roadmapGrade[code]?['status'] as String?;
          outcome = _gradeToOutcome(grade, rmStatus);
          // ถ้าไม่มีใน UserRoadmap เลย → ถือว่า pass
          if (outcome == CourseOutcome.notSet) outcome = CourseOutcome.pass;
        } else if (termStatus == TermStatus.current) {
          outcome = CourseOutcome.fail; // default F for current term
        } else {
          outcome = CourseOutcome.notSet;
        }

        final prereqs =
            (subRow?['require'] as List?)?.map((e) => e.toString()).toList() ??
            [];
        final offered =
            (subRow?['offeredSemester'] as List?)
                ?.map((e) => (e as num).toInt())
                .toList() ??
            [1, 2];

        termCourses.add(
          CourseModel(
            code: code,
            name: subRow != null
                ? (subRow['subjectName'] as String? ?? displayName)
                : displayName,
            credits: subRow != null
                ? ((subRow['credits'] ?? templateCredits) as num).toInt()
                : templateCredits,
            prerequisites: prereqs,
            availableTerms: offered,
            schedule: _slotsFor(code, scheduleList),
            status: courseStatus,
            outcome: outcome,
            subjectId: (subRow?['subjectId'] as num?)?.toInt(),
          ),
        );
      }

      terms.add(
        TermModel(year: y, term: s, status: termStatus, courses: termCourses),
      );
    }

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
      detectedPlanType: selectedPlan,
    );
  }

  // ─── Load from UserRoadmap (Original) ─────────────────────────────────────

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

    final results = await Future.wait<dynamic>([
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
    final int currentIdx = _termOrder(currentYear, currentSem);

    final subjectByCode = <String, Map<String, dynamic>>{};
    for (final s in subjectList) {
      final code = s['subjectCode'] as String?;
      if (code != null) subjectByCode[code] = s;
    }

    final termKeys = <String, ({int year, int semester})>{};
    for (final r in roadmapList) {
      final y = (r['year'] as num).toInt();
      final s = (r['semester'] as num).toInt();
      termKeys['${y}_${s}'] = (year: y, semester: s);
    }
    for (var y = 1; y <= maxYear; y++) {
      for (var s = 1; s <= 2; s++) {
        termKeys['${y}_${s}'] ??= (year: y, semester: s);
      }
    }

    final sortedKeys = termKeys.values.toList()
      ..sort(
        (a, b) => _termOrder(
          a.year,
          a.semester,
        ).compareTo(_termOrder(b.year, b.semester)),
      );

    final terms = <TermModel>[];
    for (final tk in sortedKeys) {
      final termIdx = _termOrder(tk.year, tk.semester);
      final termStatus = termIdx < currentIdx
          ? TermStatus.passed
          : termIdx == currentIdx
          ? TermStatus.current
          : TermStatus.upcoming;
      final courseStatus = termIdx < currentIdx
          ? CourseStatus.passed
          : termIdx == currentIdx
          ? CourseStatus.current
          : CourseStatus.upcoming;

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

  static List<TermModel> getEmptyYearTerms(int year) => [
    TermModel(year: year, term: 1, courses: []),
    TermModel(year: year, term: 2, courses: []),
  ];
}
