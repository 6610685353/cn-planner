import 'dart:convert';
import 'package:cn_planner_app/services/api_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;


class SendGrade {
  static Future<void> submitGPAX(double gpax, double totalCredits, double gpa, double thisSemCredits) async {
    print("Calling submitGPAX");
    final url = Uri.parse("${Config.baseUrl}/v1/roadmap/submit");
    final uid = FirebaseAuth.instance.currentUser?.uid;

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "uid": uid,
        "gpax": gpax,
        "credits": totalCredits,
        "gpa": gpa,
        "thisSemCred": thisSemCredits,
      }),
    );

    print("submit gpax Status: ${response.statusCode}");
  }
}