import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  //for local emu test
  static final String _localUrl = "http://${dotenv.env['EMU_HOST']}:5001/cn-planner-app/asia-southeast1/api";
  
  //for cloud deployment
  static const String _prodUrl = "https://asia-southeast1-cn-planner-app.cloudfunctions.net/api";

  static String get baseUrl => kDebugMode ? _localUrl : _prodUrl;
}