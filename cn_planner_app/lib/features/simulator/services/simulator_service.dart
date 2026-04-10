import 'dart:convert';
import 'package:cn_planner_app/services/api_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/course_model.dart';
import '../models/term_model.dart';
import 'simulation_result_model.dart';

class SimulatorService {
  // static const String _baseUrl = 'http://10.0.2.2:5001/cn-planner-app/asia-southeast1/api/v1';
  static final String _baseUrl = "${Config.baseUrl}/v1";

  // ─── Outcome / status helpers ──────────────────────────────────────────────

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

  // ─── Build payloads for the simulate endpoint ──────────────────────────────

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

  // ─── Save Simulation Plan → Supabase (simulatorplan table) ───────────────
  //
  // บันทึกแผนของหน้า Simulator เท่านั้น (ไม่กระทบ roadmap)
  // บันทึก **ทุกวิชาทุก term** เพื่อให้ restore add/drop ได้ถูกต้อง:
  //   - 'pass' / 'fail'  → วิชาที่ตั้ง outcome แล้ว
  //   - 'enrolled'       → วิชาที่อยู่ใน term แต่ยังไม่ตัดสิน
  //                        (รวมถึงวิชาที่ user add เข้ามาใหม่)
  // วิชาที่ user drop ออกไปจะไม่ถูกบันทึก → โหลดกลับมาก็จะไม่ปรากฏ
  // ─────────────────────────────────────────────────────────────────────────

  static Future<void> saveSimulation({required List<TermModel> terms}) async {
    final supabase = Supabase.instance.client;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) throw Exception('User not logged in');

    // สร้าง rows จากทุกวิชาทุก term
    final rows = <Map<String, dynamic>>[];

    for (final term in terms) {
      for (final course in term.courses) {
        // map outcome → status string ที่บันทึกลง DB
        final String status;
        if (course.outcome == CourseOutcome.pass) {
          status = 'pass';
        } else if (course.outcome == CourseOutcome.fail) {
          status = 'fail';
        } else {
          // notSet / withdraw → ถือว่า enrolled (อยู่ใน term นี้)
          status = 'enrolled';
        }

        rows.add({
          'user_id': uid,
          'year': term.year,
          'semester': term.term,
          'subject_id': course.subjectId ?? 0,
          'subject_code': course.code,
          'status': status,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    }

    // ลบแผนเก่าของ user แล้ว insert ใหม่ทั้งหมด
    await supabase.from('simulatorplan').delete().eq('user_id', uid);

    if (rows.isNotEmpty) {
      await supabase.from('simulatorplan').insert(rows);
    }
  }

  // ─── Load Simulation Plan ← Supabase (simulatorplan table) ───────────────
  //
  // คืนค่า Map<'year_semester', SimulatorTermPlan> เพื่อให้ _loadData()
  // นำไป:
  //   1. ตัดวิชาที่ไม่อยู่ใน plan ออก (วิชาที่ user drop)
  //   2. เพิ่มวิชาที่อยู่ใน plan แต่ไม่มีใน roadmap term นั้น (วิชาที่ user add)
  //   3. apply outcomes (pass / fail)
  // ─────────────────────────────────────────────────────────────────────────

  static Future<Map<String, SimulatorTermPlan>> loadSimulationPlan() async {
    final supabase = Supabase.instance.client;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return {};

    final data = await supabase
        .from('simulatorplan')
        .select('year, semester, subject_code, status')
        .eq('user_id', uid);

    if ((data as List).isEmpty) return {};

    // จัด group ตาม "year_semester"
    final Map<String, SimulatorTermPlan> planByTerm = {};

    for (final row in data) {
      final year = row['year'] as int;
      final semester = row['semester'] as int;
      final code = row['subject_code'] as String? ?? '';
      final status = row['status'] as String? ?? '';

      if (code.isEmpty) continue;

      final key = '${year}_$semester';
      planByTerm.putIfAbsent(key, () => SimulatorTermPlan());

      final plan = planByTerm[key]!;

      // เพิ่ม code เข้า set ของ term นี้ (enrolled / pass / fail ล้วน "อยู่ใน term")
      plan.codes.add(code);

      // map outcome สำหรับ pass / fail เท่านั้น
      if (status == 'pass') {
        plan.outcomes[code] = CourseOutcome.pass;
      } else if (status == 'fail') {
        plan.outcomes[code] = CourseOutcome.fail;
      }
      // 'enrolled' → ไม่ต้อง set outcome (คงเป็น notSet ตามปกติ)
    }

    return planByTerm;
  }
}

// ─── Helper model สำหรับข้อมูลต่อ term ───────────────────────────────────────
class SimulatorTermPlan {
  /// รหัสวิชาทั้งหมดที่ควรอยู่ใน term นี้ (ไม่รวมที่ dropped)
  final Set<String> codes = {};

  /// outcome ของวิชาที่มีผล (pass / fail เท่านั้น)
  final Map<String, CourseOutcome> outcomes = {};
}
