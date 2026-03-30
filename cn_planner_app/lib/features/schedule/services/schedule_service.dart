import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/master_course_model.dart';

class ScheduleService {
  final _supabase = Supabase.instance.client;

  Future<List<MasterCourseModel>> getRealScheduleForUser(String uid) async {
    try {
      // 1. ดึง Profile
      final profileResponse = await _supabase
          .from('profiles')
          .select('current_year, current_semester')
          .eq('user_id', uid)
          .maybeSingle();

      if (profileResponse == null) return [];

      final currentYear = profileResponse['current_year'];
      final currentSemester = profileResponse['current_semester'];

      // 2. ดึง Roadmap
      final roadmapResponse = await _supabase
          .from('UserRoadmap')
          .select('subject_code')
          .eq('user_id', uid)
          .eq('year', currentYear)
          .eq('semester', currentSemester);

      List<String> myEnrolledCourses = (roadmapResponse as List)
          .map((item) => item['subject_code'].toString())
          .toList();

      if (myEnrolledCourses.isEmpty) return [];

      // 3. ดึง ClassSchedules
      final scheduleResponse = await _supabase
          .from('ClassSchedules')
          .select()
          .inFilter('subject_code', myEnrolledCourses);

      // 4. 👉 ใหม่! ดึงชื่อวิชาและชื่ออาจารย์จากตาราง Subjects ของเพื่อน
      final subjectsResponse = await _supabase
          .from('Subjects') // ชื่อ Table ต้องตรงกับในภาพที่เพื่อนทำไว้นะคะ
          .select(
            'subjectCode, subjectName, instructor',
          ) // ดึงคอลัมน์ชื่อวิชาและอาจารย์
          .inFilter('subjectCode', myEnrolledCourses);

      // สร้าง Map เพื่อให้ค้นหาชื่อวิชาง่ายๆ
      Map<String, Map<String, dynamic>> subjectDetails = {};
      for (var sub in subjectsResponse) {
        subjectDetails[sub['subjectCode']] = sub;
      }

      // 5. ประกอบร่างข้อมูล
      Map<String, MasterCourseModel> courseMap = {};
      for (var row in scheduleResponse) {
        final code = row['subject_code'];
        final slot = TimeSlot(
          day: row['day'],
          startTime: row['start_time'],
          endTime: row['end_time'],
          room: row['room'],
        );

        if (courseMap.containsKey(code)) {
          courseMap[code]!.timeSlots.add(slot);
        } else {
          // 👉 อัปเดตการดึงชื่อและอาจารย์จาก Map ที่เราเตรียมไว้
          final subjectInfo = subjectDetails[code];
          final realName = subjectInfo?['subjectName'] ?? 'Unknown Course';
          final realInstructor = subjectInfo?['instructor'] ?? 'TBA';

          courseMap[code] = MasterCourseModel(
            courseCode: code,
            courseName: realName,
            instructor: realInstructor,
            timeSlots: [slot],
          );
        }
      }

      return courseMap.values.toList();
    } catch (e) {
      print('❌ Error fetching real schedule: $e');
      return [];
    }
  }
}
