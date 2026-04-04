import 'package:supabase_flutter/supabase_flutter.dart';

class RoadmapService {
  final _supabase = Supabase.instance.client;

  // 1. ดึงวิชาทั้งหมดที่ User คนนี้ลงไว้ใน Roadmap
  Future<List<Map<String, dynamic>>> getUserRoadmap(String uid) async {
    try {
      final data = await _supabase
          .from('UserRoadmap')
          .select()
          .eq('user_id', uid);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      return [];
    }
  }

  // 2. เพิ่มวิชาลงใน Roadmap (ใช้ตอนกด Add จากหน้าเลือกวิชา)
  Future<void> addCourseToRoadmap({
    required String uid,
    required String subjectCode,
    required int subjectId,
    required int year,
    required int semester,
  }) async {
    await _supabase.from('UserRoadmap').insert({
      'user_id': uid,
      'subject_code': subjectCode,
      'subjectId': subjectId,
      'year': year,
      'semester': semester,
      'status': 'planned', // ค่าเริ่มต้นคือวางแผนไว้
    });
  }

  // 🔥 3. อัปเดตเกรดของวิชา (ใช้ในหน้า Edit Academic History)
  Future<void> updateGrade(
    String uid,
    String subjectCode,
    String? grade,
  ) async {
    try {
      await _supabase
          .from('UserRoadmap')
          .update({
            'grade': grade,
            'status': (grade == null || grade == '-')
                ? 'planned'
                : (grade == 'F' || grade == 'W')
                ? 'not_pass'
                : 'passed',
            // ถ้ามีเกรดแล้วให้เปลี่ยน status เป็น passed อัตโนมัติ
          })
          .eq('user_id', uid)
          .eq('subject_code', subjectCode);
    } catch (e) {
      print("Error updating grade: $e");
    }
  }

  // 4. ลบวิชาออกจาก Roadmap
  Future<void> removeCourse(dynamic id) async {
    try {
      // ⚠️ ตรวจสอบชื่อตารางให้เป็น 'UserRoadmap' (U ตัวใหญ่)
      final response = await _supabase
          .from('UserRoadmap')
          .delete()
          .eq('id', id); // 'id' ต้องตรงกับชื่อ column ใน Supabase

      print("✅ Delete response: $response");
    } catch (e) {
      print("❌ RoadmapService Delete Error: $e");
      rethrow;
    }
  }

  Future<void> syncHistoryWithSupabase(
    String uid,
    List<Map<String, dynamic>> history,
  ) async {
    // 1. ลบข้อมูลประวัติการเรียนเดิมทั้งหมดของ User คนนี้ก่อน
    await _supabase.from('UserRoadmap').delete().eq('user_id', uid);

    // 2. เตรียมข้อมูลใหม่เพื่อ Insert (ตัด 'id' ที่เป็น temp_ ออกเพื่อให้ DB สร้างใหม่)
    final dataToInsert = history
        .map(
          (item) => {
            'user_id': uid,
            'subject_code': item['subject_code'],
            'subjectId': item['subjectId'],
            'year': item['year'],
            'semester': item['semester'],
            'grade': item['grade'],
            'status': item['status'] ?? 'planned',
          },
        )
        .toList();

    // 3. Insert ข้อมูลชุดใหม่ลงไป
    if (dataToInsert.isNotEmpty) {
      await _supabase.from('UserRoadmap').insert(dataToInsert);
    }
  }
}
