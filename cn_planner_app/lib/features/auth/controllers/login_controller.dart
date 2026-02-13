import 'package:cn_planner_app/route.dart';
import 'package:cn_planner_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import '../../../core/widgets/status_dialog.dart'; // Import Dialog ที่เราสร้างไว้

class LoginController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final _authService = AuthService();

  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
  }

  Future<void> handleLogin(BuildContext context) async {
    final String email = usernameController.text.trim();
    final String password = passwordController.text.trim();

    // --- 1. Validation (ตรวจสอบว่ากรอกข้อมูลครบไหม) ---
    if (email.isEmpty || password.isEmpty) {
      _showPopup(
        context,
        "Missing Info",
        "Please enter both your email and password.",
      );
      return;
    }

    try {
      // --- 2. Firebase Login ---
      await _authService.login(email, password);

      // ถ้าสำเร็จ ไปหน้า Main
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.main);
      }
    } catch (e) {
      // --- 3. Error Handling (แสดงผลเป็น Pop-up แทน SnackBar) ---
      String errorMessage = "Incorrect email or password. Please try again.";

      // กรณีอีเมลผิดรูปแบบ หรือหาไม่เจอในระบบ
      if (e.toString().contains('user-not-found') ||
          e.toString().contains('invalid-email')) {
        errorMessage = "User not found. Please check your email.";
      } else if (e.toString().contains('wrong-password')) {
        errorMessage = "Incorrect password. Please try again.";
      }

      if (context.mounted) {
        _showPopup(context, "Login Failed", errorMessage);
      }
    }
  }

  // Helper Function สำหรับเรียก Pop-up
  void _showPopup(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => StatusDialog(
        title: title,
        message: message,
        isError: true, // ตั้งเป็น true เพื่อให้เป็นไอคอนสีแดง
      ),
    );
  }
}
