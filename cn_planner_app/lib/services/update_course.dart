import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cn_planner_app/services/api_config.dart';


class UpdateCourse {
  static Future<void> submitManageCourse(List<Map<String,dynamic>> data) async {
    final url = Uri.parse("${Config.baseUrl}/v1/enrolled/submit");
    final uid = FirebaseAuth.instance.currentUser?.uid;

    final response = await http.post(
      url, 
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "uid": uid,
        "gradeList" : data,
      }),
    );

    print("submit Status: ${response.statusCode}");
    print("Body: ${response.body}");
  }
}