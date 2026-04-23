import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cn_planner_app/route.dart';
import 'package:cn_planner_app/services/auth_service.dart';
import '../../../core/widgets/status_dialog.dart';

class LoginController {
  final identifierController = TextEditingController();
  final passwordController = TextEditingController();
  final _authService = AuthService();

  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<bool> rememberMe = ValueNotifier(false);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    final isRemembered = prefs.getBool('remember_me') ?? false;
    rememberMe.value = isRemembered;

    if (isRemembered) {
      identifierController.text = prefs.getString('saved_identifier') ?? '';
      passwordController.text = prefs.getString('saved_password') ?? '';
    } else {
      identifierController.clear();
      passwordController.clear();
    }
  }

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }

  void dispose() {
    identifierController.dispose();
    passwordController.dispose();
    isLoading.dispose();
    rememberMe.dispose();
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

    isLoading.value = true;

    try {
      await _authService.login(identifier, password);

      final prefs = await SharedPreferences.getInstance();
      if (rememberMe.value) {
        await prefs.setBool('remember_me', true);
        await prefs.setString('saved_identifier', identifier);
        await prefs.setString('saved_password', password);
      } else {
        await prefs.remove('remember_me');
        await prefs.remove('saved_identifier');
        await prefs.remove('saved_password');
      }

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
    } finally {
      isLoading.value = false;
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
