import 'package:flutter/material.dart';
import 'package:cn_planner_app/route.dart';

class SettingController {
  // สถานะการเปิด/ปิดแจ้งเตือน
  bool isNotificationEnabled = true;

  // ภาษาที่เลือก (en หรือ th)
  String selectedLanguage = 'en';

  void toggleNotification(bool value, Function update) {
    isNotificationEnabled = value;
    update(); // เรียก setState ในหน้า UI
  }

  void changeLanguage(String langCode, Function update) {
    selectedLanguage = langCode;
    update();
  }

  void handleSignOut(BuildContext context) {
    // ล้างข้อมูล Session และกลับไปหน้า Login
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }
}
