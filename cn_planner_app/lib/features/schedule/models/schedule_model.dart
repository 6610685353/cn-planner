class ScheduleModel {
  String? id;
  final String subjectCode;
  final String subjectName;
  final String room;
  final int dayOfWeek;
  final String startTime;
  final String endTime;

  ScheduleModel({
    this.id,
    required this.subjectCode,
    required this.subjectName,
    required this.room,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

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
