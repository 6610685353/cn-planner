import 'package:supabase_flutter/supabase_flutter.dart';

class DataFetch {
  static final DataFetch _instance = DataFetch._internal();
  factory DataFetch() => _instance;
  DataFetch._internal();

  Future<Map<String, dynamic>> getAllCourse() async {
    try {
      final List<dynamic> response = await Supabase.instance.client.from('YearCourses').select();

      return {
        for (var item in response)
          "${item['year']}_${item['sem']}}": item
      };
    } catch (e) {
      throw Exception('Error fetching data, Error message: $e');
    }
  }
}