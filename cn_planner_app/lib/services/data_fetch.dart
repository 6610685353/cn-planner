import 'package:http/http.dart' as http;
import 'package:cn_planner_app/services/api_config.dart';
import 'dart:convert';

class DataFetch {
  static final DataFetch _instance = DataFetch._internal();
  factory DataFetch() => _instance;
  DataFetch._internal();

  Future<Map<String, dynamic>> getManagePageData() async {
    final url = Uri.parse("${Config.baseUrl}/v1/enrolled/manage");

    try {
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"}
      ).timeout(Duration(seconds: 15));
      print("Status: ${response.statusCode}");

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Error fetching page data, Error message: $e');
    }
  }

  Future<List<dynamic>> fetchEnrolled(String uid) async {
    final url = Uri.parse("${Config.baseUrl}/v1/enrolled/manage/$uid");

    try {
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"}
      ).timeout(Duration(seconds: 15));
      print("fetchEnrolled Status: ${response.statusCode}");

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Error fetching data, Error message: $e');
    }
  }
}