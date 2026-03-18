import 'package:cn_planner_app/services/emulator_check.dart';
import 'package:flutter/foundation.dart';

class Config {
  //for local emu test
  static late String _localUrl;

  //for cloud deployment
  static const String _prodUrl = "https://asia-southeast1-cn-planner-app.cloudfunctions.net/api";

  static Future<void> init() async {
    final host = await getHost();
    _localUrl = "http://$host:5001/cn-planner-app/asia-southeast1/api";
  }
  
  
  
  static String get baseUrl => kDebugMode ? _localUrl : _prodUrl;
}