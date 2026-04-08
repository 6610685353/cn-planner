import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/subject_model.dart';

class SubjectController {
  final _supabase = Supabase.instance.client;

  // ฟังก์ชันดึงข้อมูลทั้งหมดจากตาราง Subjects
  Future<List<SubjectModel>> getAllSubjects() async {
    try {
      final response = await _supabase
          .from('Subjects')
          .select()
          .order('subjectCode', ascending: true);

      final List<dynamic> data = response;
      // แปลง List ของ Map ให้เป็น List ของ SubjectModel
      return data.map((item) => SubjectModel.fromJson(item)).toList();
    } catch (e) {
      print('Error fetching subjects: $e');
      throw Exception('Failed to load subjects');
    }
  }
}
