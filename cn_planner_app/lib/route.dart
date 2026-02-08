import 'package:flutter/material.dart';
import 'features/auth/views/login_page.dart';
import 'features/auth/views/register_page.dart';
// import 'features/profile/views.profile_page.dart';
// import 'features/profile/views/setting_page.dart';

class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  // static const profile = '/profile';
  // static const setting = '/setting';

  static final routes = {
    login: (context) => const LoginPage(),
    register: (context) => const RegisterPage(),
    // profile: (context) => const ProfilePage(),
    // setting: (context) => const SettingPage(),
  };
}
