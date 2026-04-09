import 'dart:convert';
import 'package:cn_planner_app/services/api_config.dart';
import 'package:http/http.dart' as http;
import '../models/master_course_model.dart';

class ScheduleService {
  Future<List<MasterCourseModel>> getRealScheduleForUser(String uid) async {
    try {
      final url = Uri.parse("${Config.baseUrl}/v1/schedule/$uid");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) {
          final List<dynamic> slots = json['timeSlots'];
          return MasterCourseModel(
            courseCode: json['courseCode'],
            courseName: json['courseName'],
            instructor: json['instructor'],
            section: json['section'],
            timeSlots: slots.map((s) => TimeSlot(
              day: s['day'],
              startTime: s['startTime'],
              endTime: s['endTime'],
              room: s['room'],
            )).toList(),
          );
        }).toList();
      } else {
        print('❌ Error fetching schedule: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching real schedule: $e');
      return [];
    }
  }
}
