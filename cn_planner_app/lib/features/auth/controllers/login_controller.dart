import 'package:flutter/material.dart';

class LoginController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
  }

  void handleLogin() {
    print("Username: ${usernameController.text}");
    print("Password: ${passwordController.text}");
    // TODO: ส่งข้อมูลไปตรวจสอบที่ Server
  }
}
