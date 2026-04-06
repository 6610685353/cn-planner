import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/subject_model.dart';

class SubjectService {
  final supabase = Supabase.instance.client;

  Future<List<SubjectModel>> fetchSubjects() async {
    final response = await supabase
        .from('Subjects') // 🔥 ชื่อตารางใน Supabase
        .select();

    return (response as List).map((e) => SubjectModel.fromJson(e)).toList();
  }
}
