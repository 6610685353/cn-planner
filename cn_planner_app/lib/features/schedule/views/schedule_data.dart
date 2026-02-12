import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:cn_planner_app/core/models/class_session.dart';

class ScheduleDataService {
  // ชุดสี
  static final List<Color> _colors = [
    const Color(0xFFF26665), // แดง
    const Color(0xFFFFB5B5), // ชมพู
    const Color(0xFFFFE2AC), // ส้มอ่อน
    const Color(0xFFFFFFB5), // เหลืองอ่อน
    const Color(0xFFC8E6B2), // เขียว
    const Color(0xFFC3EEFA), // ฟ้า
    const Color(0xFF93B9DD), // คราม
    const Color(0xFFC8B5FF), // ม่วง
    const Color(0xFFFF8FAB), // ชมพูเข้ม
    const Color(0xFFDDB4A5), // น้ำตาล
  ];

  static Future<List<ClassSession>> getUserClasses(String userId) async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/mock_data.json',
      );
      final Map<String, dynamic> data = json.decode(jsonString);

      final user = data['user'][userId];
      if (user == null) return [];

      final List<dynamic> enrolledCodes = user['enrolled'];
      final List<ClassSession> sessions = [];
      int colorIndex = 0;

      for (var code in enrolledCodes) {
        final subject = data['subject'][code];
        final time = data['time_table'][code];

        if (subject != null && time != null) {
          // ดึงข้อมูลวันออกมาเป็น List (เช่น ["tue", "thu"])
          List<dynamic> daysList = time['day'];

          // วนลูปสร้าง Session ตามจำนวนวันที่มีเรียน
          for (var day in daysList) {
            sessions.add(
              ClassSession(
                code: code,
                name:
                    subject['subject name'] ?? "", // แก้ key เป็น subject name
                instructor: subject['instructor'] ?? "",
                day: day, // แยกเป็นวันๆ ไป
                start: time['start'],
                stop: time['end'], // แก้ key เป็น end
                section: time['section'] ?? "", // รับค่า section
                room: time['room'] ?? "", // รับค่า room
                color: _colors[colorIndex % _colors.length],
              ),
            );
          }
          colorIndex++;
        }
      }
      return sessions;
    } catch (e) {
      debugPrint("Error loading data: $e");
      return [];
    }
  }
}
