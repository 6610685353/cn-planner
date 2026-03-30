import 'package:cn_planner_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:cn_planner_app/core/models/class_session.dart';
import '../../../core/widgets/timetable_grid.dart';
import 'daily_schedule_page.dart';
import '../../../core/widgets/course_card.dart';
import '../services/mock_schedule_service.dart';
import 'package:cn_planner_app/core/services/notification_service.dart';
import '../../notification/views/notifications_page.dart';
import '../../notification/controllers/notifications_controller.dart';
import '../../notification/models/notifications_models.dart';
import '../services/schedule_service.dart';
import '../services/schedule_service.dart';
import '../../../core/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart'; // อย่าลืม import ถ้าใช้ Firebase Auth

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
      print("🟡 1. เริ่มโหลดข้อมูล...");
      String myUid = "RyMRAjy9Q8ZQMgQM8m1Sdk8GuGU2";

      final service = ScheduleService();
      print("🟡 2. กำลังดึงข้อมูลจาก Supabase...");
      final masterCourses = await service.getRealScheduleForUser(myUid);

      print("🟡 3. ดึงข้อมูลสำเร็จ! ได้มา ${masterCourses.length} วิชา");

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
              section: "01",
              room: slot.room,
              color: cardColors[colorIndex % cardColors.length],
            ),
          );
        }
        colorIndex++;
      }

      // 👉 ลองคอมเมนต์บรรทัด Noti ไว้ก่อน! เพื่อแยกให้ออกว่าพังที่ Noti หรือพังที่ดึงข้อมูล
      // print("🟡 4. กำลังตั้งเวลาแจ้งเตือน...");
      // await NotificationService.autoScheduleAllClasses(convertedClasses);

      // ... (โค้ดดึงข้อมูลด้านบน) ...

      // 4. สั่งให้ระบบตั้งเวลาแจ้งเตือนล่วงหน้า 15 นาที
      await NotificationService.autoScheduleAllClasses(convertedClasses);

      // 👉 เติมบรรทัดนี้ลงไป เพื่อสั่งปริ้นต์เช็คผลลัพธ์ทันที!
      await NotificationService.checkPendingNotifications();

      // ... (โค้ด groupedMap ด้านล่างเหมือนเดิม) ...

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
      print("🟢 5. จัดเตรียมข้อมูลลง UI เสร็จสมบูรณ์!");
    } catch (e) {
      // ถ้ามีอะไรพัง มันจะเด้งมาตรงนี้แทนการค้าง!
      print("🔴 เกิดข้อผิดพลาดอย่างรุนแรงใน _loadData: $e");
    } finally {
      // finally คือ "ทำเสมอไม่ว่าจะพังหรือไม่พัง" -> เอาไว้สั่งหยุดหมุน!
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
      // 👉 ปุ่มสำหรับกดเทสต์ Notification
      // 👉 ปุ่มสำหรับกดเทสต์ In-App Notification (แบบเชื่อมกับของเพื่อน)
      floatingActionButton: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
        onPressed: () {
          // 1. สร้างและโยนข้อมูลใส่ Controller ของเพื่อน (ใช้ Category: CLASS REMINDER)
          NotificationController.addNotification(
            NotificationsModel(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              category: "CLASS REMINDER", // เพื่อนทำไอคอนสำหรับหมวดนี้ไว้แล้ว
              title: '🚨 แจ้งเตือนคลาสเรียน',
              subtitle: 'วิชา CN101 กำลังจะเริ่มในอีก 15 นาทีที่ห้อง SC3-201!',
              time:
                  '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
              isRead: false,
            ),
          );

          print("✅ สร้าง In-App Notification สำเร็จ!");

          // 2. สั่งเปลี่ยนหน้าไปที่หน้ารวม Noti ของเพื่อน
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotificationsPage()),
          );
        },
        child: const Text(
          "🔔 เทสต์หน้ารวม Noti",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
