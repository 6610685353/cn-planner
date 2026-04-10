import 'package:flutter/material.dart';
import 'package:cn_planner_app/core/constants/app_colors.dart';
import 'package:cn_planner_app/core/models/class_session.dart';
import 'package:cn_planner_app/features/home/widgets/schedule_card.dart';

class TodayScheduleSection extends StatelessWidget {
  final List<ClassSession> todayClasses;
  final VoidCallback onViewDaySchedule;

  const TodayScheduleSection({
    super.key,
    required this.todayClasses,
    required this.onViewDaySchedule,
  });

  // ตัวช่วยคำนวณเวลา (เอาไว้เช็คสถานะ Ongoing)
  int _timeToMinutes(String time) {
    final parts = time.split(':');
    if (parts.length != 2) return 0;
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const SizedBox(height: 10),
        todayClasses.isEmpty ? _buildNoClassToday() : _buildScheduleList(),
      ],
    );
  }

  // 1. ส่วนหัวข้อและปุ่มกด
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Today's Schedule",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        InkWell(
          onTap:
              onViewDaySchedule, // 👈 เรียกใช้งานฟังก์ชันที่ส่งมาจากหน้า Home
          borderRadius: BorderRadius.circular(8),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              children: [
                Text(
                  'View Day Schedule',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryYellow,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.arrow_right_alt,
                  size: 20,
                  color: AppColors.primaryYellow,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 2. ส่วนแสดงการ์ดตารางเรียนแนวนอน
  Widget _buildScheduleList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: todayClasses.map((session) {
          final timeNow = DateTime.now().hour * 60 + DateTime.now().minute;
          final startMins = _timeToMinutes(session.start);
          final isOngoing = startMins <= timeNow;

          return ScheduleCard(
            status: isOngoing ? "HAPPENING NOW" : "UP NEXT",
            subjectCode: session.code,
            subjectName: session.name,
            time: "${session.start} - ${session.stop}",
            location: session.room,
            isOngoing: isOngoing,
          );
        }).toList(),
      ),
    );
  }

  // 3. ส่วนแสดงเมื่อไม่มีเรียน
  Widget _buildNoClassToday() {
    return Container(
      width: double.infinity,
      height: 150,
      margin: const EdgeInsets.only(bottom: 10, top: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 40,
            color: Colors.green.shade400,
          ),
          const SizedBox(height: 12),
          const Text(
            "No more classes today! 🎉",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Enjoy your free time",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
