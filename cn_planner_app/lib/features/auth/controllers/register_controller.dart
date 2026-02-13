import 'package:cn_planner_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import '../../../route.dart';
import '../../../core/widgets/status_dialog.dart'; // Import dialog ที่สร้างใหม่

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
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();
    final String confirmPass = confirmPasswordController.text.trim();
    final String firstName = firstnameController.text.trim();
    final String lastName = lastnameController.text.trim();

    // --- 1. English Validation Logic ---
    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      _showPopup(context, "Missing Info", "Please fill in all fields.");
      return;
    }

    if (password != confirmPass) {
      _showPopup(context, "Password Mismatch", "Passwords do not match.");
      return;
    }

    if (password.length < 6) {
      _showPopup(
        context,
        "Weak Password",
        "Password must be at least 6 characters.",
      );
      return;
    }

    if (selectedYear == null) {
      _showPopup(context, "Academic Year", "Please select your academic year.");
      return;
    }

    try {
      // --- 2. Firebase Auth & Firestore ---
      // เรียกใช้ register ที่เราอัปเกรดให้เก็บข้อมูลลง Firestore ด้วย
      final user = await _authService.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        year: selectedYear!,
      );

      if (user != null) {
        // Success Popup
        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false, // ป้องกันการกดปิดข้างนอก
            builder: (ctx) => const StatusDialog(
              title: "Success!",
              message: "Your account has been created successfully.",
              isError: false,
            ),
          );

          // รอแป๊บหนึ่งแล้วย้ายไปหน้า Login
          await Future.delayed(const Duration(seconds: 2));
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, AppRoutes.login);
          }
        }
      }
    } catch (e) {
      // --- 3. Error Handling (English) ---
      String errorTitle = "Registration Failed";
      String errorMessage = "Something went wrong. Please try again.";

      if (e.toString().contains('email-already-in-use')) {
        errorMessage = "This email is already in use by another account.";
      } else if (e.toString().contains('invalid-email')) {
        errorMessage = "The email address is not valid.";
      }

      if (context.mounted) {
        _showPopup(context, errorTitle, errorMessage);
      }
    }
  }

  // Helper function สำหรับโชว์ Popup แบบสั้นๆ
  void _showPopup(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => StatusDialog(title: title, message: message),
    );
  }
}
