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
  int? selectedSem;
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

    if (username.length < 5) {
      _showPopup(
        context,
        "Invalid Username",
        "Username must be at least 5 characters long.",
      );
      return;
    }
    if (username.contains(' ') || username.contains('@')) {
      _showPopup(
        context,
        "Invalid Username",
        "Username cannot contain spaces or the '@' symbol.",
      );
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      _showPopup(
        context,
        "Invalid Email",
        "Please enter a valid email address.",
      );
      return;
    }

    if (password.length < 6) {
      _showPopup(
        context,
        "Weak Password",
        "Password must be at least 6 characters long.",
      );
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

    if (selectedSem == null) {
      _showPopup(context, "Semester", "Please select your semester.");
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
        sem: selectedSem!,
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
      final errorString = e.toString().toLowerCase();

      if (errorString.contains('username-already-in-use')) {
        errorMessage =
            "This username is already taken. Please choose another one.";
      } else if (errorString.contains('email-already-in-use')) {
        errorMessage = "This email is already registered. Try logging in.";
      } else if (errorString.contains('weak-password')) {
        errorMessage = "The password provided is too weak.";
      } else if (errorString.contains('invalid-email')) {
        errorMessage = "The email address is badly formatted.";
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
