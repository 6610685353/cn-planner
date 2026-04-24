class SubjectModel {
  final String subjectCode;
  final String subjectName;
  final String? instructor;
  final double credits;
  final List<String>? require; // สำหรับ text[] ใน Supabase
  final List<String>? corequisite;
  final List<int>? offeredSemester; // สำหรับ int4[]
  final int subjectId;
  final bool
  su_grade; // 🔥 เพิ่มฟิลด์นี้เพื่อเก็บข้อมูลว่าเป็น SU grade หรือไม่

  SubjectModel({
    required this.subjectCode,
    required this.subjectName,
    this.instructor,
    required this.credits,
    this.require,
    this.corequisite,
    this.offeredSemester,
    required this.subjectId,
    required this.su_grade,
  });

  // ฟังก์ชันแปลง JSON จาก Supabase มาเป็น Object
  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      subjectCode: json['subjectCode'] ?? '',
      subjectName: json['subjectName'] ?? '',
      instructor: json['instructor'],
      // Supabase อาจส่ง numeric มาเป็น int หรือ double ต้องระวังการ cast
      credits: (json['credits'] ?? 0).toDouble(),
      // การดึงข้อมูลที่เป็น Array ใน Supabase
      require: json['require'] != null
          ? List<String>.from(json['require'])
          : null,
      corequisite: json['corequisite'] != null
          ? List<String>.from(json['corequisite'])
          : null,
      offeredSemester: json['offeredSemester'] != null
          ? List<int>.from(json['offeredSemester'])
          : null,
      subjectId: json['subjectId'] ?? 0,
      su_grade: json['su_grade'] ?? false, // 🔥 ดึงข้อมูล SU grade จาก JSON
    );
  }
}
