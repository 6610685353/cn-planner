import 'package:http/http.dart' as http;
import 'package:cn_planner_app/services/api_config.dart';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

class DataFetch {
  static final DataFetch _instance = DataFetch._internal();
  factory DataFetch() => _instance;
  DataFetch._internal();

  Future<Map<String, dynamic>> getManagePageData() async {
    final url = Uri.parse("${Config.baseUrl}/v1/enrolled/manage");

    try {
      final response = await http
          .get(url, headers: {"Content-Type": "application/json"})
          .timeout(Duration(seconds: 10));
      print("get Manage Page Data Status: ${response.statusCode}");

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Error fetching page data, Error message: $e');
    }
  }

  Future<List<dynamic>> fetchEnrolled(String uid) async {
    final url = Uri.parse("${Config.baseUrl}/v1/enrolled/manage/$uid");

    try {
      final response = await http
          .get(url, headers: {"Content-Type": "application/json"})
          .timeout(Duration(seconds: 10));
      print("fetchEnrolled Status: ${response.statusCode}");

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Error fetching enrolled data, Error message: $e');
    }
  }

  Future<List<dynamic>> fetchGPAcred(String uid, {bool isUseCache = true}) async {
    final url = Uri.parse("${Config.baseUrl}/v1/gpa/fetch").replace(
      queryParameters: {'uid': uid, 'useCache' : isUseCache.toString()}
    );
    
    try {
      final response = await http
        .get(url, headers: {"Content-Type": "application/json"})
        .timeout(Duration(seconds: 10));
      print("fetch GPA Status: ${response.statusCode}");

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Error fetching gpa data, Error message: $e');
    }
  }

  Future<List<dynamic>> fetchThisSem(String uid, {bool isUseCache = true}) async {
    print("calling fetch this sem");
    final url = Uri.parse("${Config.baseUrl}/v1/gpa/this_sem").replace(
      queryParameters: {'uid': uid, 'useCache' : isUseCache.toString()}
    );

    try {
      final response = await http
        .get(url, headers: {"Content-Type": "application/json"})
        .timeout(Duration(seconds: 10));

      print("fetch this sem Status: ${response.statusCode}");
      return jsonDecode(response.body);
    } catch (err) {
      throw Exception('Error fetching this sem data, Error message: $err');
    }
  }

  Future<List<dynamic>> getSchedule() async {
    final res = await Supabase.instance.client.from('ClassSchedules').select();
    return res;
  }
}
