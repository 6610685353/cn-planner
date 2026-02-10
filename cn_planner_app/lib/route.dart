import 'package:flutter/material.dart';
import 'features/auth/views/login_page.dart';
import 'features/auth/views/register_page.dart';
import 'features/profile/views/profile_page.dart';
import 'features/profile/views/edit_profile_page.dart';
import 'features/profile/views/setting_page.dart';
import 'features/gpa_calculator/presentation/gpa_calculator_page.dart';

class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const profile = '/profile';
  static const edit_profile = '/edit_profile';
  static const setting = '/setting';
  static const gpa = '/gpa';

  static final routes = {
    login: (context) => const LoginPage(),
    register: (context) => const RegisterPage(),
    profile: (context) => ProfilePage(),
    edit_profile: (context) => EditProfilePage(),
    setting: (context) => const SettingPage(),
    gpa: (context) => const GPACalculatorPage(),
  };
}
