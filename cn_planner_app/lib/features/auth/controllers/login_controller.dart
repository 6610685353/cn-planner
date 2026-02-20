import 'package:flutter/material.dart';
import 'package:cn_planner_app/route.dart';
import 'package:cn_planner_app/services/auth_service.dart';
import '../../../core/widgets/status_dialog.dart';

class LoginController {
  // เปลี่ยนชื่อช่องกรอกให้สื่อว่าเป็นได้ทั้งคู่ (ใน UI อาจจะเขียนคำอธิบายว่า Email or Username)
  final identifierController = TextEditingController();
  final passwordController = TextEditingController();
  final _authService = AuthService();

  void dispose() {
    identifierController.dispose();
    passwordController.dispose();
  }

  Future<void> handleLogin(BuildContext context) async {
    final String identifier = identifierController.text.trim();
    final String password = passwordController.text.trim();

    if (identifier.isEmpty || password.isEmpty) {
      _showPopup(
        context,
        "Missing Info",
        "Please enter your email or username.",
      );
      return;
    }

    try {
      // เรียกใช้ฟังก์ชัน login แบบ Hybrid
      await _authService.login(identifier, password);

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.main);
      }
    } catch (e) {
      String errorMessage = "Incorrect email/username or password.";

      if (e.toString().contains('user-not-found')) {
        errorMessage = "Account not found. Please check your spelling.";
      } else if (e.toString().contains('wrong-password') ||
          e.toString().contains('invalid-credential')) {
        errorMessage = "Incorrect password. Please try again.";
      }

      if (context.mounted) {
        _showPopup(context, "Login Failed", errorMessage);
      }
    }
  }

  void _showPopup(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) =>
          StatusDialog(title: title, message: message, isError: true),
    );
  }
}
