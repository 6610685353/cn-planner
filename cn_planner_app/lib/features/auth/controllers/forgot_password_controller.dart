import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../../core/widgets/status_dialog.dart';

class ForgotPasswordController {
  final emailController = TextEditingController();
  final _authService = AuthService();

  void dispose() {
    emailController.dispose();
  }

  Future<void> handleResetPassword(BuildContext context) async {
    String email = emailController.text.trim();

    if (email.isEmpty) {
      _showPopup(context, "Error", "Please enter your email address.");
      return;
    }

    try {
      await _authService.sendPasswordReset(email);

      if (context.mounted) {
        _showPopup(
          context,
          "Email Sent",
          "A password reset link has been sent to $email. Please check your inbox.",
          isError: false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showPopup(
          context,
          "Error",
          "Could not send reset email. Please check if the email is correct.",
        );
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
