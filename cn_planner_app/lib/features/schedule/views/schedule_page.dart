import 'package:cn_planner_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:cn_planner_app/core/models/class_session.dart';
import '../../../core/widgets/timetable_grid.dart';
import 'daily_schedule_page.dart';
import '../../../core/widgets/course_card.dart';
import '../services/mock_schedule_service.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<SchedulePage> {
  List<ClassSession> myClasses = [];
  List<ClassSession> uniqueClasses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // 1. สมมติว่านี่คือข้อมูลรหัสวิชาที่ดึงมาจากหน้า Roadmap
    List<String> myEnrolledCourses = ["CN101", "TU100"];

    // 2. เรียกใช้ Service จำลองของเรา เพื่อหาเวลาเรียน
    final service = MockScheduleService();
    final masterCourses = service.getScheduleForUser(myEnrolledCourses);

    // 3. แปลงร่างข้อมูลของเรา (MasterCourseModel) ให้กลายเป็นของเพื่อน (ClassSession) เพื่อให้ UI รู้จัก
    List<ClassSession> convertedClasses = [];
    final List<Color> cardColors = [
      const Color(0xFFC8E6B2),
      const Color(0xFFC3EEFA),
    ]; // สีจำลอง

    int colorIndex = 0;
    for (var course in masterCourses) {
      for (var slot in course.timeSlots) {
        convertedClasses.add(
          ClassSession(
            code: course.courseCode,
            name: course.courseName,
            instructor: course.instructor,
            day: slot.day,
            start: slot.startTime,
            stop: slot.endTime,
            section: "01", // สมมติว่าลง Sec 1
            room: slot.room,
            color: cardColors[colorIndex % cardColors.length],
          ),
        );
      }
      colorIndex++;
    }

    // 4. สร้างข้อมูลสำหรับ Card ด้านล่าง (รวมวันแบบที่เพื่อนทำไว้)
    final Map<String, ClassSession> groupedMap = {};
    for (var session in convertedClasses) {
      if (groupedMap.containsKey(session.code)) {
        final existing = groupedMap[session.code]!;
        final newDays = "${existing.day}, ${session.day}";
        groupedMap[session.code] = ClassSession(
          code: existing.code,
          name: existing.name,
          instructor: existing.instructor,
          day: newDays,
          start: existing.start,
          stop: existing.stop,
          section: existing.section,
          room: existing.room,
          color: existing.color,
        );
      } else {
        groupedMap[session.code] = session;
      }
    }

    // 5. อัปเดตหน้าจอ
    if (mounted) {
      setState(() {
        myClasses = convertedClasses; // ส่งเข้าตาราง
        uniqueClasses = groupedMap.values.toList(); // ส่งเข้าการ์ดด้านล่าง
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'CLASS',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DailySchedulePage(allClasses: myClasses),
                ),
              );
            },
            child: const Row(
              children: [
                Text(
                  'View Day Schedule',
                  style: TextStyle(
                    color: Color(0xFFEAB308),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward, size: 16, color: Color(0xFFEAB308)),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ส่วนตารางเรียน
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 10,
                  ),
                  child: TimetableGrid(classes: myClasses),
                ),
                const SizedBox(height: 10),
                // ส่วนรายการด้านล่าง
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(24),
                      itemCount: uniqueClasses.length,
                      itemBuilder: (context, index) {
                        return CourseCard(session: uniqueClasses[index]);
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
