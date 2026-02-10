import 'package:flutter/material.dart';

class RegisterController {
  final firstnameController = TextEditingController();
  final lastnameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  int? selectedYear;

  void dispose() {
    firstnameController.dispose();
    lastnameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }

  void handleRegister() {
    // Logic การสมัครสมาชิก
    print("First name: ${firstnameController.text}");
    print("Last name: ${lastnameController.text}");
    print("Email: ${emailController.text}");
    print("Year: $selectedYear");
  }
}
