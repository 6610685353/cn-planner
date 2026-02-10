import 'package:flutter/material.dart';
import 'features/auth/views/login_page.dart';
import 'features/auth/views/register_page.dart';
import 'features/home/views/home_page.dart';
import 'features/profile/views/profile_page.dart';
import 'features/profile/views/edit_profile_page.dart';
import 'features/profile/views/setting_page.dart';

class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const profile = '/profile';
  static const edit_profile = '/edit_profile';
  static const setting = '/setting';

  static final routes = {
    login: (context) => const LoginPage(),
    register: (context) => const RegisterPage(),
    home: (context) => const HomePage(),
    profile: (context) => ProfilePage(),
    edit_profile: (context) => EditProfilePage(),
    setting: (context) => const SettingPage(),
  };
}
