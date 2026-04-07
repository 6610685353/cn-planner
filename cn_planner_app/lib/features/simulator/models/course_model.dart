enum CourseOutcome { pass, fail, withdraw, notSet }

enum CourseStatus { passed, current, upcoming }

class TimeSlot {
  final String day;
  final String start;
  final String end;

  const TimeSlot({required this.day, required this.start, required this.end});

  String get display => '$day $start-$end';
}

class CourseModel {
  final String code;
  final String name;
  final int credits;
  final List<String> prerequisites;
  final List<int> availableTerms;
  final bool isCustom;
  final List<TimeSlot> schedule;
  final String? category;

  CourseStatus status;
  CourseOutcome outcome;
  String? grade;

  CourseModel({
    required this.code,
    required this.name,
    required this.credits,
    this.prerequisites = const [],
    this.availableTerms = const [1, 2],
    this.isCustom = false,
    this.schedule = const [],
    this.category,
    this.status = CourseStatus.upcoming,
    this.outcome = CourseOutcome.notSet,
    this.grade,
  });

  bool get prereqMet => prerequisites.isEmpty;
  bool get isCompleted => outcome == CourseOutcome.pass;

  String get availableTermsText {
    if (availableTerms.isEmpty) return 'Available every term';
    if (availableTerms.length == 1) {
      return 'Available in Term ${availableTerms.first} only';
    }
    return 'Available in Terms ${availableTerms.join(", ")}';
  }

  CourseModel copyWith({
    CourseStatus? status,
    CourseOutcome? outcome,
    String? grade,
    String? category,
  }) {
    return CourseModel(
      code: code,
      name: name,
      credits: credits,
      prerequisites: prerequisites,
      availableTerms: availableTerms,
      isCustom: isCustom,
      schedule: schedule,
      category: category ?? this.category,
      status: status ?? this.status,
      outcome: outcome ?? this.outcome,
      grade: grade ?? this.grade,
    );
  }
}
