class TimeSlot {
  final String day;
  final String startTime;
  final String endTime;
  final String room;

  TimeSlot({
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.room,
  });
}

class MasterCourseModel {
  final String courseCode;
  final String courseName;
  final String instructor;
  final List<TimeSlot> timeSlots;

  MasterCourseModel({
    required this.courseCode,
    required this.courseName,
    required this.instructor,
    required this.timeSlots,
  });
}
