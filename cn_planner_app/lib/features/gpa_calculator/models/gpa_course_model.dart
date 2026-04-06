class GPACourseModel {
  final String id;
  final String code;
  final String name;
  final double credits;
  String grade;

  GPACourseModel({
    required this.id,
    required this.code,
    required this.name,
    required this.credits,
    required this.grade,
  });

  factory GPACourseModel.fromMap(Map<String, dynamic> map, {required String id}) {
    return GPACourseModel(
      id: id,
      code: map['code'] ?? '',
      name: map['name'] ?? '',
      credits: (map['credit'] ?? 3.0).toDouble(),
      grade: map['grade'] ?? 'A',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'name': name,
      'credit': credits,
      'grade': grade,
    };
  }

  // Generate a random ID for manually added sandbox courses
  factory GPACourseModel.createSandbox({
    required String code,
    required String name,
    required double credits,
    String grade = 'A',
  }) {
    return GPACourseModel(
      id: "sandbox_\${DateTime.now().millisecondsSinceEpoch}_\$code",
      code: code,
      name: name,
      credits: credits,
      grade: grade,
    );
  }
}
