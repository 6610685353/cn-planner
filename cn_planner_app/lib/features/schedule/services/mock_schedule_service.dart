import '../models/master_course_model.dart';

class MockScheduleService {
  // จำลองฐานข้อมูลส่วนกลาง (เสมือนว่าดึงมาจาก Firebase)
  final List<MasterCourseModel> _mockDatabase = [
    MasterCourseModel(
      courseCode: "CN101",
      courseName: "Introduction to Computer",
      instructor: "Dr. Somchai",
      timeSlots: [
        TimeSlot(
          day: "mon",
          startTime: "09:30",
          endTime: "11:00",
          room: "SC3-201",
        ),
        TimeSlot(
          day: "wed",
          startTime: "09:30",
          endTime: "11:00",
          room: "SC3-201",
        ),
      ],
    ),
    MasterCourseModel(
      courseCode: "TU100",
      courseName: "Civic Education",
      instructor: "Aj. Somsri",
      timeSlots: [
        TimeSlot(
          day: "tue",
          startTime: "13:30",
          endTime: "16:30",
          room: "SC1-101",
        ),
      ],
    ),
  ];

  // ต้องบอกมันด้วยว่า รอรับ "ลิสต์รายวิชา (enrolledCourses)" เข้ามานะ
  List<MasterCourseModel> getScheduleForUser(List<String> enrolledCourses) {
    return _mockDatabase
        .where((course) => enrolledCourses.contains(course.courseCode))
        .toList();
  }
}
