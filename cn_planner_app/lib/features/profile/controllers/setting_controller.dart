import 'package:flutter/material.dart';
import 'package:cn_planner_app/route.dart';
import '../../../services/auth_service.dart'; // ตรวจสอบ path ให้ถูกต้อง

class SettingController {
  // --- เพิ่มบรรทัดนี้ เพื่อเรียกใช้งาน AuthService ---
  final AuthService _authService = AuthService();

  bool isNotificationEnabled = true;
  String selectedLanguage = 'en';

  void toggleNotification(bool value, Function update) {
    isNotificationEnabled = value;
    update();
  }

  void changeLanguage(String langCode, Function update) {
    selectedLanguage = langCode;
    update();
  }

  // แก้ไขให้เป็น Future เพื่อรองรับ await
  Future<void> handleSignOut(BuildContext context) async {
    try {
      await _authService.logout();

      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint("Logout error: $e");
    }
  }
}
