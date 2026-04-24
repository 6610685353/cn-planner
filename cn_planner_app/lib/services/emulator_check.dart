import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<String> getHost() async {
  if (kIsWeb) {
    return 'localhost';
  }

  final deviceInfo = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    final android = await deviceInfo.androidInfo;

    final isEmulator = !android.isPhysicalDevice;

    if (isEmulator) {
      return '10.0.2.2';
    } else {
      return dotenv.env['EMU_HOST']!;
    }
  }

  if (Platform.isIOS) {
    final ios = await deviceInfo.iosInfo;

    final isEmulator = !ios.isPhysicalDevice;

    if (isEmulator) {
      return 'localhost';
    } else {
      return dotenv.env['EMU_HOST']!;
    }
  }

  return 'localhost';
}
