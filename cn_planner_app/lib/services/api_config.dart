import 'package:flutter/foundation.dart';

class Config {
  //for local emu test
  static const String _localUrl = "http://192.168.1.112:5001/cn-planner-app/asia-southeast3/api";
  
  //for cloud deployment
  static const String _cloudUrl = "";

  static String get baseUrl => kDebugMode ? _localUrl : _cloudUrl;
}