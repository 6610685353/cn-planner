import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  Future<Map<String, dynamic>> getAllSubject() async {
    try {
      final List<dynamic> response = await Supabase.instance.client.from('Subjects').select();

      return {
        for (var item in response)
          item['subjectCode']: item
      };
    } catch (e) {
      throw Exception('Error fetching data, Error message: $e');
    }
  }

  Future<List<dynamic>> fetchEnrolled(String uid) async {
    print("UID: $uid");
    final url = Uri.parse("http://192.168.1.198:3000/api/v1/enrolled/$uid");

    try {
      print("3 in fetch");
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"}
      ).timeout(Duration(seconds: 5));


      print("Status: ${response.statusCode}");
      print("BODY: ${response.body}");
      return jsonDecode(response.body);
    } catch (e) {
      print("Error: $e");
      return [];
    }

    // if (response.statusCode == 200) {
    //   
    // } else {
    //   throw Exception("Failed to load data");
    // }
  }
}