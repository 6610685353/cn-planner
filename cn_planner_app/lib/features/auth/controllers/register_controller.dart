import 'package:flutter/material.dart';

class RegisterController {
  final fullnameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController(); // ช่อง Email ที่เพิ่มใหม่
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  int? selectedYear;

  void dispose() {
    fullnameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }

  void handleRegister() {
    // Logic การสมัครสมาชิก
    print("Fullname: ${fullnameController.text}");
    print("Email: ${emailController.text}");
    print("Year: $selectedYear");
  }
}
