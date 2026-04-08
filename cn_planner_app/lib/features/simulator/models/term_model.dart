import 'course_model.dart';

enum TermStatus { passed, current, upcoming }

class TermModel {
  final int year;
  final int term;
  final List<CourseModel> courses;
  TermStatus status;

  TermModel({
    required this.year,
    required this.term,
    required this.courses,
    this.status = TermStatus.upcoming,
  });

  String get label => 'Year $year / Term $term';
  String get shortLabel => 'Y$year T$term';

  int get totalCredits => courses.fold(0, (sum, c) => sum + c.credits);

  int get earnedCredits => courses
      .where((c) => c.outcome == CourseOutcome.pass)
      .fold(0, (sum, c) => sum + c.credits);

  bool get allPassed =>
      courses.isNotEmpty &&
      courses.every((c) => c.outcome == CourseOutcome.pass);
}
