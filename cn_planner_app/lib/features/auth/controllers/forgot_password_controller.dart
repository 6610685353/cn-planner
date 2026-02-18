import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../../core/widgets/status_dialog.dart';

class ForgotPasswordController {
  // เปลี่ยนชื่อจาก emailController เป็น usernameController เพื่อไม่ให้งง
  final usernameController = TextEditingController();
  final _authService = AuthService();

  void dispose() {
    usernameController.dispose();
  }

  Future<void> handleResetPassword(BuildContext context) async {
    // 1. ดึงค่า username จากช่องกรอก
    String username = usernameController.text.trim();

    if (username.isEmpty) {
      _showPopup(context, "Error", "Please enter your username.");
      return;
    }

    try {
      // 2. เรียกฟังก์ชันใหม่ที่เรากำลังจะไปเพิ่มใน AuthService
      await _authService.sendPasswordReset(username);

      if (context.mounted) {
        _showPopup(
          context,
          "Request Sent",
          "If the username exists, a password reset link has been sent to the associated email.",
          isError: false,
        );
      }
    } catch (e) {
      // 3. จัดการ Error กรณีหา username ไม่เจอ
      String errorMessage = "Could not send reset link. Please try again.";
      if (e.toString().contains('user-not-found')) {
        errorMessage = "Username not found. Please check your spelling.";
      }

      if (context.mounted) {
        _showPopup(context, "Error", errorMessage);
      }
    }
  }

  void _showPopup(
    BuildContext context,
    String title,
    String message, {
    bool isError = true,
  }) {
    showDialog(
      context: context,
      builder: (ctx) =>
          StatusDialog(title: title, message: message, isError: isError),
    );
  }
}
