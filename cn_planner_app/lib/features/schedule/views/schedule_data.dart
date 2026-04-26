import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:cn_planner_app/core/models/class_session.dart';

class ScheduleDataService {
  static final List<Color> _colors = [
    const Color(0xFFF26665),
    const Color(0xFFFFB5B5),
    const Color(0xFFFFE2AC),
    const Color(0xFFFFFFB5),
    const Color(0xFFC8E6B2),
    const Color(0xFFC3EEFA),
    const Color(0xFF93B9DD),
    const Color(0xFFC8B5FF),
    const Color(0xFFFF8FAB),
    const Color(0xFFDDB4A5),
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
          List<dynamic> daysList = time['day'];

          for (var day in daysList) {
            sessions.add(
              ClassSession(
                code: code,
                name: subject['subject name'] ?? "",
                instructor: subject['instructor'] ?? "",
                day: day,
                start: time['start'],
                stop: time['end'],
                section: time['section'] ?? "",
                room: time['room'] ?? "",
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
