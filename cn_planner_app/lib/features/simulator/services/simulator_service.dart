import 'dart:convert';
import 'package:cn_planner_app/services/api_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/course_model.dart';
import '../models/term_model.dart';
import 'simulation_result_model.dart';

class SimulatorService {
  static final String _baseUrl = "${Config.baseUrl}/v1";

  static String _outcomeToString(CourseOutcome o) => switch (o) {
    CourseOutcome.pass => 'pass',
    CourseOutcome.fail => 'fail',
    CourseOutcome.withdraw => 'withdraw',
    CourseOutcome.notSet => 'notSet',
  };

  static String _statusToString(TermStatus status) => switch (status) {
    TermStatus.passed => 'passed',
    TermStatus.current => 'current',
    TermStatus.upcoming => 'upcoming',
  };

  static Map<String, String> _buildOutcomes(List<TermModel> terms) {
    final map = <String, String>{};
    for (final term in terms) {
      for (final course in term.courses) {
        if (course.outcome != CourseOutcome.notSet) {
          map[course.code] = _outcomeToString(course.outcome);
        }
      }
    }
    return map;
  }

  static bool _termHasAtLeastOnePass(List<CourseModel> courses) =>
      courses.any((c) => c.outcome == CourseOutcome.pass);

  static Map<String, int>? _buildSimulatedCurrentTerm(List<TermModel> terms) {
    TermModel? latestWithPass;
    for (final term in terms) {
      if (_termHasAtLeastOnePass(term.courses)) {
        if (latestWithPass == null ||
            term.year > latestWithPass.year ||
            (term.year == latestWithPass.year &&
                term.term > latestWithPass.term)) {
          latestWithPass = term;
        }
      }
    }
    if (latestWithPass == null) {
      final actualCurrent =
          terms.where((t) => t.status == TermStatus.current).toList()
            ..sort((a, b) {
              final yc = a.year.compareTo(b.year);
              return yc != 0 ? yc : a.term.compareTo(b.term);
            });
      if (actualCurrent.isEmpty) return null;
      latestWithPass = actualCurrent.last;
    }
    return {'year': latestWithPass.year, 'term': latestWithPass.term};
  }

  static List<Map<String, dynamic>> _buildSimulatedTerms(
    List<TermModel> terms,
  ) {
    return terms
        .map(
          (t) => {
            'year': t.year,
            'term': t.term,
            'status': _statusToString(t.status),
            'courses': t.courses
                .map(
                  (c) => {
                    'code': c.code,
                    'outcome': _outcomeToString(c.outcome),
                  },
                )
                .toList(),
          },
        )
        .toList();
  }

  static Map<String, dynamic> _buildCustomCourses(List<TermModel> terms) {
    final map = <String, dynamic>{};
    for (final term in terms) {
      for (final course in term.courses) {
        if (course.isCustom) {
          map[course.code] = {
            'code': course.code,
            'name': course.name,
            'credits': course.credits,
            'availableTerms': course.availableTerms,
            if (course.category != null) 'category': course.category,
            'schedule': course.schedule
                .map((s) => {'day': s.day, 'start': s.start, 'end': s.end})
                .toList(),
          };
        }
      }
    }
    return map;
  }

  // ─── Check if saved plan exists for a specific planType ──────────────────

  static Future<bool> hasSavedPlanForType(String planType) async {
    final supabase = Supabase.instance.client;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;
    final data = await supabase
        .from('simulatorplan')
        .select('id')
        .eq('user_id', uid)
        .eq('plan_type', planType)
        .limit(1);
    return (data as List).isNotEmpty;
  }

  static Future<bool> hasSavedPlan() async {
    final supabase = Supabase.instance.client;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;
    final data = await supabase
        .from('simulatorplan')
        .select('id')
        .eq('user_id', uid)
        .limit(1);
    return (data as List).isNotEmpty;
  }

  // ─── Simulate (calls backend) ─────────────────────────────────────────────

  static Future<SimulationResult> simulate(List<TermModel> terms) async {
    final outcomes = _buildOutcomes(terms);
    final simulatedTerms = _buildSimulatedTerms(terms);
    final simulatedCurrentTerm = _buildSimulatedCurrentTerm(terms);
    final customCourses = _buildCustomCourses(terms);

    final response = await http
        .post(
          Uri.parse('$_baseUrl/simulate'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'outcomes': outcomes,
            'simulatedTerms': simulatedTerms,
            if (simulatedCurrentTerm != null)
              'simulatedCurrentTerm': simulatedCurrentTerm,
            if (customCourses.isNotEmpty) 'customCourses': customCourses,
          }),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Simulate failed: ${response.statusCode}');
    }
    return SimulationResult.fromJson(jsonDecode(response.body));
  }

  // ─── Save Simulation Plan → Supabase ─────────────────────────────────────
  // [#2 FIX] บันทึกวิชาที่ไม่มี subjectId (custom/elective) ด้วย
  //          โดยใช้ subject_id = null (DB schema ต้อง nullable)
  // [#1 FIX] ลบเฉพาะ plan_type นี้ก่อน insert ใหม่

  static Future<void> saveSimulation({
    required List<TermModel> terms,
    String planType = 'Internship',
  }) async {
    final supabase = Supabase.instance.client;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('User not logged in');

    final rows = <Map<String, dynamic>>[];

    for (final term in terms) {
      final seenCodes = <String>{};

      for (final course in term.courses) {
        final String status;
        if (course.outcome == CourseOutcome.pass) {
          status = 'pass';
        } else if (course.outcome == CourseOutcome.fail ||
            course.outcome == CourseOutcome.withdraw) {
          status = 'fail';
        } else if (course.outcome == CourseOutcome.notSet &&
            term.status == TermStatus.upcoming) {
          // บันทึกวิชา upcoming ที่ user add มาด้วย status = 'enrolled'
          // (วิชาที่มาจาก static template จะมี notSet เหมือนกัน
          //  ต้องเช็คว่าเป็นวิชาที่ add เพิ่มมาจริงๆ — ตรวจจาก subjectId ก็ได้
          //  แต่ง่ายกว่าคือ save ทั้งหมดแล้วกรองตอน load)
          status = 'enrolled';
        } else {
          continue; // skip notSet ของ current term (default F ที่ไม่ได้ตั้ง)
        }

        final key = course.code;
        if (seenCodes.contains(key)) continue;
        seenCodes.add(key);

        final subjectId = course.subjectId;

        rows.add({
          'user_id': uid,
          'year': term.year,
          'semester': term.term,
          // [#2 FIX] null ถ้าไม่มี subjectId (custom/elective)
          'subject_id': (subjectId != null && subjectId > 0) ? subjectId : null,
          'subject_code': course.code,
          'subject_name': course.name, // [#2 FIX] เก็บชื่อวิชาด้วยสำหรับ custom
          'credits': course.credits, // [#2 FIX] เก็บ credits ด้วย
          'status': status,
          'plan_type': planType,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    }

    // ลบเฉพาะ plan_type นี้ ไม่กระทบ plan อื่น
    await supabase
        .from('simulatorplan')
        .delete()
        .eq('user_id', uid)
        .eq('plan_type', planType);

    if (rows.isNotEmpty) {
      await supabase.from('simulatorplan').insert(rows);
    }
  }

  // ─── Load outcomes for a specific planType ────────────────────────────────
  // [#1 FIX] โหลดเฉพาะ plan_type ที่ตรงกัน
  // [#1 FIX] match ด้วย subject_code ด้วย (ไม่ใช่แค่ subject_id)

  static Future<({Map<String, CourseOutcome> outcomes, String planType})>
  loadSimulationPlanWithType(String planType) async {
    final supabase = Supabase.instance.client;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return (outcomes: <String, CourseOutcome>{}, planType: planType);
    }

    final data = await supabase
        .from('simulatorplan')
        .select('subject_code, status, plan_type')
        .eq('user_id', uid)
        .eq('plan_type', planType);

    if ((data as List).isEmpty) {
      return (outcomes: <String, CourseOutcome>{}, planType: planType);
    }

    final Map<String, CourseOutcome> planOutcomes = {};
    for (final row in data) {
      final code = row['subject_code'] as String? ?? '';
      final status = row['status'] as String? ?? '';
      if (code.isEmpty) continue;
      // [#1 FIX] key คือ subject_code เสมอ (ใช้ได้กับทั้งวิชา DB และ custom)
      if (status == 'pass') {
        planOutcomes[code] = CourseOutcome.pass;
      } else if (status == 'fail') {
        planOutcomes[code] = CourseOutcome.fail;
      }
    }
    return (outcomes: planOutcomes, planType: planType);
  }

  // ─── Load as roadmap format for RoadmapPage ───────────────────────────────
  // [#2 NEW] โหลดข้อมูลจาก simulatorplan ในรูปแบบที่ RoadmapPage ใช้ได้
  // คืนค่า List<Map> เหมือน roadmapPlan ใน RoadmapPage
  // พร้อม 'sim_status': 'pass' | 'fail' สำหรับแสดงกรอบแดงใน roadmap

  static Future<List<Map<String, dynamic>>> loadAsRoadmapPlan(
    String planType,
  ) async {
    final supabase = Supabase.instance.client;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    final data = await supabase
        .from('simulatorplan')
        .select(
          'subject_code, subject_name, credits, year, semester, status, plan_type',
        )
        .eq('user_id', uid)
        .eq('plan_type', planType);

    if ((data as List).isEmpty) return [];

    return data.map<Map<String, dynamic>>((row) {
      final status = row['status'] as String? ?? 'pass';
      // enrolled = upcoming ที่ user add มา → แสดงเป็น planned (Pending Enrollment)
      final isEnrolled = status == 'enrolled';
      final isFail = status == 'fail';
      return {
        'subject_code': row['subject_code'] as String? ?? '',
        'subject_name': row['subject_name'] as String? ?? '',
        'credit': row['credits'] as int? ?? 0,
        'year': row['year'] as int? ?? 1,
        'semester': row['semester'] as int? ?? 1,
        'plan': planType,
        // sim_status: enrolled → null (ไม่แสดงกรอบแดง), fail/pass → ใช้ปกติ
        'sim_status': isEnrolled ? null : status,
        'status': isEnrolled ? 'planned' : (isFail ? 'failed' : 'passed'),
        'grade': isEnrolled ? null : (isFail ? 'F' : 'S'),
      };
    }).toList();
  }

  // ─── backward compat ────────────────────────────────────────────────────
  static Future<Map<String, CourseOutcome>> loadSimulationPlan() async {
    final supabase = Supabase.instance.client;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return {};
    final data = await supabase
        .from('simulatorplan')
        .select('subject_code, status')
        .eq('user_id', uid);
    if ((data as List).isEmpty) return {};
    final Map<String, CourseOutcome> planOutcomes = {};
    for (final row in data) {
      final code = row['subject_code'] as String? ?? '';
      final status = row['status'] as String? ?? '';
      if (code.isEmpty) continue;
      if (status == 'pass')
        planOutcomes[code] = CourseOutcome.pass;
      else if (status == 'fail')
        planOutcomes[code] = CourseOutcome.fail;
    }
    return planOutcomes;
  }
}
