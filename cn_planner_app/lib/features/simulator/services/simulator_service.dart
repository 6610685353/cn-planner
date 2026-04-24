import 'dart:convert';
import 'package:flutter/foundation.dart';
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

  static Future<void> saveSimulation({
    required List<TermModel> terms,
    String planType = 'Internship',
  }) async {
    final supabase = Supabase.instance.client;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('User not logged in');

    final validPlanTypes = ['Internship', 'Coop', 'Research'];
    final normalizedPlanType = planType.trim();
    if (!validPlanTypes.contains(normalizedPlanType)) {
      throw Exception(
        'Invalid plan type: $normalizedPlanType. Must be one of: ${validPlanTypes.join(", ")}',
      );
    }

    final rows = <Map<String, dynamic>>[];

    for (final term in terms) {
      final seenCodes = <String>{};
      final seenElectives = <String>{};

      for (final course in term.courses) {
        final String status;
        if (course.outcome == CourseOutcome.pass) {
          status = 'pass';
        } else if (course.outcome == CourseOutcome.fail ||
            course.outcome == CourseOutcome.withdraw) {
          status = 'fail';
        } else if (course.outcome == CourseOutcome.notSet &&
            (term.status == TermStatus.upcoming ||
                term.status == TermStatus.current)) {
          status = 'enrolled';
        } else {
          continue;
        }

        final subjectId = course.subjectId;
        final key = '${course.code}|${term.year}|${term.term}';

        if (subjectId != null && subjectId > 0) {
          if (seenCodes.contains(key)) continue;
          seenCodes.add(key);
        } else {
          if (seenElectives.contains(course.code)) continue;
          seenElectives.add(course.code);
        }

        rows.add({
          'user_id': uid,
          'year': term.year,
          'semester': term.term,
          'subject_id': (subjectId != null && subjectId > 0) ? subjectId : null,
          'subject_code': course.code,
          'subject_name': course.name,
          'credits': course.credits,
          'status': status,
          'plan_type': normalizedPlanType,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    }

    if (rows.isEmpty) {
      return;
    }

    try {
      await supabase
          .from('simulatorplan')
          .delete()
          .eq('user_id', uid)
          .eq('plan_type', normalizedPlanType);
    } catch (e) {
      rethrow;
    }

    const batchSize = 50;
    int totalInserted = 0;

    for (var i = 0; i < rows.length; i += batchSize) {
      final batch = rows.sublist(i, (i + batchSize).clamp(0, rows.length));
      final batchNum = (i ~/ batchSize) + 1;

      try {
        await supabase.from('simulatorplan').insert(batch);
        totalInserted += batch.length;
      } catch (e) {
        rethrow;
      }
    }
  }

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

      if (status == 'pass') {
        planOutcomes[code] = CourseOutcome.pass;
      } else if (status == 'fail') {
        planOutcomes[code] = CourseOutcome.fail;
      }
    }
    return (outcomes: planOutcomes, planType: planType);
  }

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

      final isEnrolled = status == 'enrolled';
      final isFail = status == 'fail';
      return {
        'subject_code': row['subject_code'] as String? ?? '',
        'subject_name': row['subject_name'] as String? ?? '',
        'credit': row['credits'] as int? ?? 0,
        'year': row['year'] as int? ?? 1,
        'semester': row['semester'] as int? ?? 1,
        'plan': planType,

        'sim_status': isEnrolled ? null : status,
        'status': isEnrolled ? 'planned' : (isFail ? 'failed' : 'passed'),
        'grade': isEnrolled ? null : (isFail ? 'F' : 'S'),
      };
    }).toList();
  }

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
