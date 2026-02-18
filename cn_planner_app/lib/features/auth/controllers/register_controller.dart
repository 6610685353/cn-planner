import 'package:flutter/material.dart';
import 'package:cn_planner_app/route.dart';
import 'package:cn_planner_app/services/auth_service.dart';
import '../../../core/widgets/status_dialog.dart';

class RegisterController {
  final firstnameController = TextEditingController();
  final lastnameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  int? selectedYear;
  final _authService = AuthService();

  void dispose() {
    firstnameController.dispose();
    lastnameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }

  Future<void> handleRegister(BuildContext context) async {
    final String firstName = firstnameController.text.trim();
    final String lastName = lastnameController.text.trim();
    final String username = usernameController.text.trim();
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();
    final String confirmPass = confirmPasswordController.text.trim();

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        username.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      _showPopup(context, "Missing Info", "Please fill in all fields.");
      return;
    }

    if (password != confirmPass) {
      _showPopup(context, "Password Mismatch", "Passwords do not match.");
      return;
    }

    if (selectedYear == null) {
      _showPopup(context, "Academic Year", "Please select your academic year.");
      return;
    }

    try {
      await _authService.register(
        email: email,
        password: password,
        username: username,
        firstName: firstName,
        lastName: lastName,
        year: selectedYear!,
      );

      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => const StatusDialog(
            title: "Success!",
            message: "Your account has been created successfully.",
            isError: false,
          ),
        );

        await Future.delayed(const Duration(seconds: 2));
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
      }
    } catch (e) {
      String errorMessage = "Something went wrong. Please try again.";

      if (e.toString().contains('username-already-in-use')) {
        errorMessage = "This username is already taken.";
      } else if (e.toString().contains('email-already-in-use')) {
        errorMessage = "This email is already in use.";
      }

      if (context.mounted) {
        _showPopup(context, "Registration Failed", errorMessage);
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
