import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/subject_model.dart';
import '../services/roadmap_service.dart';

class RoadmapService {
  final _supabase = Supabase.instance.client;

  Future<void> addCourseToRoadmap({
    required String uid,
    required int subjectId,
    required int year,
    required int semester,
  }) async {
    try {
      final response = await _supabase.from('UserRoadmap').insert({
        'user_id': uid, // ต้องเป็น text ใน DB
        'subjectId': subjectId,
        'year': year,
        'semester': semester,
        'status': 'planned',
      }).select(); // ใส่ select เพื่อเช็คว่ามีข้อมูลกลับมาไหม

      print("Insert Success: $response");
    } catch (e) {
      // 🔥 ถ้าไม่ขึ้น ให้ดู Error ตรงนี้ใน Debug Console
      print("Insert Error: $e");
      rethrow;
    }
  }
}
