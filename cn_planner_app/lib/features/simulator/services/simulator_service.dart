// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/course_model.dart';
// import '../models/term_model.dart';
// import 'simulation_result_model.dart';

// class SimulatorService {
//   static const String _baseUrl =
//       'http://10.0.2.2:5001/cn-planner-app/asia-southeast1/api/v1';

//   static Map<String, String> _buildOutcomes(List<TermModel> terms) {
//     final map = <String, String>{};
//     for (final term in terms) {
//       for (final course in term.courses) {
//         if (course.outcome != CourseOutcome.notSet) {
//           map[course.code] = _outcomeToString(course.outcome);
//         }
//       }
//     }
//     return map;
//   }

//   static String _outcomeToString(CourseOutcome o) => switch (o) {
//     CourseOutcome.pass => 'pass',
//     CourseOutcome.fail => 'fail',
//     CourseOutcome.withdraw => 'withdraw',
//     CourseOutcome.notSet => 'notSet',
//   };

//   static String _statusToString(TermStatus status) => switch (status) {
//     TermStatus.passed => 'passed',
//     TermStatus.current => 'current',
//     TermStatus.upcoming => 'upcoming',
//   };

//   static bool _isUpcomingSimulatedCurrent(TermModel term) {
//     if (term.status != TermStatus.upcoming) return false;
//     return term.courses.any((c) => c.outcome == CourseOutcome.pass);
//   }

//   static Set<int> _buildSimulatedCurrentYears(List<TermModel> terms) {
//     final years = <int>{};
//     for (final term in terms) {
//       if (term.status == TermStatus.current) {
//         years.add(term.year);
//       } else if (_isUpcomingSimulatedCurrent(term)) {
//         years.add(term.year);
//       }
//     }
//     return years;
//   }

//   static List<Map<String, dynamic>> _buildSimulatedTerms(
//     List<TermModel> terms,
//   ) {
//     return terms
//         .map(
//           (t) => {
//             'year': t.year,
//             'term': t.term,
//             'status': _statusToString(t.status),
//             'courses': t.courses.map((c) => c.code).toList(),
//           },
//         )
//         .toList();
//   }

//   static Map<String, dynamic> _buildCustomCourses(List<TermModel> terms) {
//     final map = <String, dynamic>{};
//     for (final term in terms) {
//       for (final course in term.courses) {
//         if (course.isCustom) {
//           map[course.code] = {
//             'code': course.code,
//             'name': course.name,
//             'credits': course.credits,
//             'availableTerms': course.availableTerms,
//             if (course.category != null) 'category': course.category,
//             'schedule': course.schedule
//                 .map((s) => {'day': s.day, 'start': s.start, 'end': s.end})
//                 .toList(),
//           };
//         }
//       }
//     }
//     return map;
//   }

//   static Future<SimulationResult> simulate(List<TermModel> terms) async {
//     final outcomes = _buildOutcomes(terms);
//     final simulatedTerms = _buildSimulatedTerms(terms);
//     final simulatedCurrentYears = _buildSimulatedCurrentYears(terms).toList()
//       ..sort();
//     final customCourses = _buildCustomCourses(terms);

//     final response = await http
//         .post(
//           Uri.parse('$_baseUrl/simulate'),
//           headers: {'Content-Type': 'application/json'},
//           body: jsonEncode({
//             'outcomes': outcomes,
//             'simulatedTerms': simulatedTerms,
//             'simulatedCurrentYears': simulatedCurrentYears,
//             if (customCourses.isNotEmpty) 'customCourses': customCourses,
//           }),
//         )
//         .timeout(const Duration(seconds: 15));

//     if (response.statusCode != 200) {
//       throw Exception('Simulate failed: ${response.statusCode}');
//     }

//     return SimulationResult.fromJson(jsonDecode(response.body));
//   }

//   static Future<({int id, String name})> saveSimulation({
//     required List<TermModel> terms,
//     String? name,
//     String notes = '',
//   }) async {
//     final outcomes = _buildOutcomes(terms);
//     final response = await http
//         .post(
//           Uri.parse('$_baseUrl/simulate/save'),
//           headers: {'Content-Type': 'application/json'},
//           body: jsonEncode({
//             'outcomes': outcomes,
//             'name': name,
//             'notes': notes,
//           }),
//         )
//         .timeout(const Duration(seconds: 15));

//     if (response.statusCode != 200) {
//       throw Exception('Save failed: ${response.statusCode}');
//     }

//     final data = jsonDecode(response.body)['data'] as Map<String, dynamic>;
//     return (id: data['id'] as int, name: data['name'] as String);
//   }
// }
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/course_model.dart';
import '../models/term_model.dart';
import 'simulation_result_model.dart';

class SimulatorService {
  static const String _baseUrl =
      'http://10.0.2.2:5001/cn-planner-app/asia-southeast1/api/v1';

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

  static bool _termHasAtLeastOnePass(List<CourseModel> courses) {
    return courses.any((c) => c.outcome == CourseOutcome.pass);
  }

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
              final yearCompare = a.year.compareTo(b.year);
              if (yearCompare != 0) return yearCompare;
              return a.term.compareTo(b.term);
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

  static Future<({int id, String name})> saveSimulation({
    required List<TermModel> terms,
    String? name,
    String notes = '',
  }) async {
    final outcomes = _buildOutcomes(terms);
    final response = await http
        .post(
          Uri.parse('$_baseUrl/simulate/save'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'outcomes': outcomes,
            'name': name,
            'notes': notes,
          }),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Save failed: ${response.statusCode}');
    }

    final data = jsonDecode(response.body)['data'] as Map<String, dynamic>;
    return (id: data['id'] as int, name: data['name'] as String);
  }
}
