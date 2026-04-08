import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/course_model.dart';
import '../models/term_model.dart';
import 'simulation_result_model.dart';

class SimulatorService {
  static const String _baseUrl =
      'http://10.0.2.2:5001/cn-planner-app/asia-southeast1/api/v1';

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
  // บันทึกแผนที่ผู้ใช้ตั้งไว้ก่อนกด Simulate:
  //   - แต่ละเทอม + แต่ละวิชา + status ที่ผู้ใช้เลือก (pass / fail)
  //   - วิชาที่ยัง notSet ข้ามไป
  //
  // ใช้ subjectId จาก CourseModel.subjectId ถ้ามี
  // ถ้าไม่มีจะ fallback เป็น 0 (backend / DB constraint ต้องรองรับ)
  // ─────────────────────────────────────────────────────────────────────────

  static Future<void> saveSimulation({required List<TermModel> terms}) async {
    final supabase = Supabase.instance.client;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) throw Exception('User not logged in');

    // 1. สร้าง rows จากทุกวิชาที่มี outcome = pass หรือ fail
    final rows = <Map<String, dynamic>>[];

    for (final term in terms) {
      for (final course in term.courses) {
        if (course.outcome == CourseOutcome.pass ||
            course.outcome == CourseOutcome.fail) {
          rows.add({
            'user_id': uid,
            'year': term.year,
            'semester': term.term,
            'subject_id': course.subjectId ?? 0,
            'subject_code': course.code,
            'status': _outcomeToString(course.outcome), // 'pass' | 'fail'
            'updated_at': DateTime.now().toIso8601String(),
          });
        }
      }
    }

    // 2. ลบแผนเก่าของ user
    await supabase.from('simulatorplan').delete().eq('user_id', uid);

    // 3. Insert แผนใหม่ (ถ้ามีข้อมูล)
    if (rows.isNotEmpty) {
      await supabase.from('simulatorplan').insert(rows);
    }
  }

  // ─── Load Simulation Plan ← Supabase (simulatorplan table) ───────────────
  //
  // คืนค่า Map<'subjectCode', CourseOutcome> เพื่อให้ _loadData()
  // นำไป apply ทับ outcome ของแต่ละวิชาหลังโหลด curriculum
  // ─────────────────────────────────────────────────────────────────────────

  static Future<Map<String, CourseOutcome>> loadSimulationPlan() async {
    final supabase = Supabase.instance.client;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return {};

    final data = await supabase
        .from('simulatorplan')
        .select('subject_code, status')
        .eq('user_id', uid);

    final result = <String, CourseOutcome>{};
    for (final row in data as List) {
      final code = row['subject_code'] as String?;
      final status = row['status'] as String?;
      if (code == null || status == null) continue;
      result[code] = switch (status) {
        'pass' => CourseOutcome.pass,
        'fail' => CourseOutcome.fail,
        'withdraw' => CourseOutcome.withdraw,
        _ => CourseOutcome.notSet,
      };
    }
    return result;
  }
}
