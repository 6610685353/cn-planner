import 'package:cn_planner_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:cn_planner_app/core/models/class_session.dart';
import 'schedule_data.dart';
import '../../../core/widgets/timetable_grid.dart';
import 'daily_schedule_page.dart';
import '../../../core/widgets/course_card.dart';
import 'package:cn_planner_app/features/schedule/views/daily_schedule_page.dart';
import 'package:cn_planner_app/core/widgets/bottom_nav_bar.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<SchedulePage> {
  List<ClassSession> myClasses = []; // สำหรับ Grid (แยกวัน)
  List<ClassSession> uniqueClasses = []; // สำหรับ List Card (รวมวัน)
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // 1. โหลดข้อมูลดิบ (ซึ่งแยกวันมา เช่น CNXXX มี object วันจันทร์ และ พฤหัส)
    final classes = await ScheduleDataService.getUserClasses("1");

    // 2. สร้างข้อมูลสำหรับ Card โดยการรวมวิชาเดียวกันเข้าด้วยกัน
    final Map<String, ClassSession> groupedMap = {};

    for (var session in classes) {
      if (groupedMap.containsKey(session.code)) {
        // ถ้ารหัสวิชานี้มีอยู่แล้ว ให้เอาวันมาต่อท้าย
        final existing = groupedMap[session.code]!;

        // ตัวอย่าง: ของเดิม "MON" ของใหม่ "THU" -> รวมเป็น "MON, THU"
        final newDays = "${existing.day}, ${session.day}";

        // อัปเดตข้อมูลใน Map (สร้าง Object ใหม่ที่รวมวันแล้ว)
        groupedMap[session.code] = ClassSession(
          code: existing.code,
          name: existing.name,
          instructor: existing.instructor,
          day: newDays, // ใช้วันที่รวมกันแล้ว
          start: existing.start,
          stop: existing.stop,
          section: existing.section,
          room: existing.room,
          color: existing.color,
        );
      } else {
        // ถ้ายังไม่มีวิชานี้ ใส่เข้าไปเลย
        groupedMap[session.code] = session;
      }
    }

    if (mounted) {
      setState(() {
        myClasses = classes; // ส่งให้ Grid แบบเดิม (แยกวัน)
        uniqueClasses = groupedMap.values.toList(); // ส่งให้ List (รวมวันแล้ว)
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
                // 1. ส่วนตารางเรียน (Timetable Grid)
                // ใช้ myClasses (แบบแยกวัน) เพื่อให้ Grid วาดถูกต้องตามเวลาจริง
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 10,
                  ),
                  child: TimetableGrid(classes: myClasses),
                ),

                const SizedBox(height: 10),

                // 2. ส่วนรายการด้านล่าง (List รายวิชา)
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
                    // ใช้ uniqueClasses (แบบรวมวัน) เพื่อให้ Card แสดงใบเดียวต่อ 1 วิชา
                    child: ListView.builder(
                      padding: const EdgeInsets.all(24),
                      itemCount: uniqueClasses.length, // จำนวนตามวิชาที่ไม่ซ้ำ
                      itemBuilder: (context, index) {
                        return CourseCard(session: uniqueClasses[index]);
                      },
                    ),
                  ),
                ),
              ],
            ),
      // bottomNavigationBar: BottomNavBar(currentIndex: 3, onTap: onTap),
    );
  }
}
