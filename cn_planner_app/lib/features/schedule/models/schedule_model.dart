class ScheduleModel {
  String? id; // ไอดีจาก Firebase
  final String subjectCode; // เช่น TU100
  final String subjectName; // เช่น Civic Education
  final String room; // เช่น SC3-201
  final int dayOfWeek; // 1 = จันทร์, 2 = อังคาร ... 7 = อาทิตย์
  final String startTime; // รูปแบบ "09:30"
  final String endTime; // รูปแบบ "11:00"

  ScheduleModel({
    this.id,
    required this.subjectCode,
    required this.subjectName,
    required this.room,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  // แปลงข้อมูลที่ดึงมาจาก Firebase (Map) ให้กลายเป็น Object
  factory ScheduleModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ScheduleModel(
      id: documentId,
      subjectCode: map['subjectCode'] ?? '',
      subjectName: map['subjectName'] ?? '',
      room: map['room'] ?? '',
      dayOfWeek: map['dayOfWeek'] ?? 1,
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
    );
  }

  // แปลง Object ให้เป็น Map เพื่อเตรียมส่งขึ้น Firebase
  Map<String, dynamic> toMap() {
    return {
      'subjectCode': subjectCode,
      'subjectName': subjectName,
      'room': room,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}
