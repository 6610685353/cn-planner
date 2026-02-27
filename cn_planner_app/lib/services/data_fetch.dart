import 'package:http/http.dart' as http;
import 'dart:convert';

class DataFetch {
  static final DataFetch _instance = DataFetch._internal();
  factory DataFetch() => _instance;
  DataFetch._internal();

  Future<Map<String, dynamic>> getAllCourse() async {
    final url = Uri.parse("http://192.168.1.198:5001/cn-planner-app/asia-southeast3/api/v1/enrolled/courses");

    try {
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"}
      );
      print("Status: ${response.statusCode}");

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Error fetching data, Error message: $e');
    }
  }

  Future<Map<String, dynamic>> getAllSubject() async {
    final url = Uri.parse("http://192.168.1.198:5001/cn-planner-app/asia-southeast3/api/v1/enrolled/subjects");

    try {
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"}
      );
      print("getAllSubject Status: ${response.statusCode}");

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Error fetching data, Error message: $e');
    }
  }

  Future<List<dynamic>> fetchEnrolled(String uid) async {
    final url = Uri.parse("http://192.168.1.198:5001/cn-planner-app/asia-southeast3/api/v1/enrolled/uid/$uid");

    try {
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"}
      ).timeout(Duration(seconds: 10));
      print("fetchEnrolled Status: ${response.statusCode}");

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Error fetching data, Error message: $e');
    }
  }
}