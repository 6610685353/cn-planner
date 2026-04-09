import 'package:cn_planner_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:cn_planner_app/core/models/class_session.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cn_planner_app/core/services/notification_service.dart';
import '../services/schedule_service.dart';
import 'daily_schedule_page.dart';
import '../../../core/widgets/timetable_grid.dart';
import '../../../core/widgets/course_card.dart';

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

  // ... โค้ดส่วนบนเหมือนเดิม ...
  Future<void> _loadData() async {
    try {
      // 👉 1. ดึง UID ของคนที่ล็อกอินอยู่จริงๆ
      String myUid = FirebaseAuth.instance.currentUser?.uid ?? "";

      // ถ้าไม่ได้ล็อกอิน (หรือ Session หลุด) ให้หยุดการทำงาน
      if (myUid.isEmpty) {
        print("❌ ผู้ใช้ยังไม่ได้ล็อกอิน");
        return;
      }

      final service = ScheduleService();
      final masterCourses = await service.getRealScheduleForUser(myUid);

      List<ClassSession> convertedClasses = [];
      final List<Color> cardColors = [
        const Color(0xFFC8E6B2),
        const Color(0xFFC3EEFA),
        const Color(0xFFFFD8B1),
        const Color(0xFFE8D1FF),
      ];

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
              section: course.section,
              room: slot.room,
              color: cardColors[colorIndex % cardColors.length],
            ),
          );
        }
        colorIndex++;
      }

      // 👉 2. สั่งตั้งคิวแจ้งเตือนอัตโนมัติ (เอาพวกเช็คปริ้นต์ข้อความออกแล้ว)
      await NotificationService.autoScheduleAllClasses(convertedClasses);

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

      if (mounted) {
        setState(() {
          myClasses = convertedClasses;
          uniqueClasses = groupedMap.values.toList();
        });
      }
    } catch (e) {
      print("🔴 Error ใน _loadData: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // หมายเหตุ: ตรง Scaffold ด้านล่าง ให้ลบ floatingActionButton ทิ้งไปได้เลยค่ะ ไม่ต้องใช้ปุ่มเทสต์แล้ว!

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
