import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';


class UpdateCourse {
  static Future<void> submitManageCourse(List<Map<String,dynamic>> data) async {
    final url = Uri.parse("http://192.168.1.198:5001/cn-planner-app/asia-southeast3/api/v1/enrolled/submit");
    final uid = FirebaseAuth.instance.currentUser?.uid;

    final response = await http.post(
      url, 
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "uid": uid,
        "enrolledSubjects" : data,
      }),
    );

    print("submit Status: ${response.statusCode}");
    print("Body: ${response.body}");
  }
}