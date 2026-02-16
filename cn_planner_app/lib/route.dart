import 'package:cn_planner_app/core/models/class_session.dart';
import 'package:cn_planner_app/features/main_wrapper.dart';
import 'package:flutter/material.dart';
import 'features/auth/views/login_page.dart';
import 'features/auth/views/register_page.dart';
import 'features/auth/views/forgot_password_page.dart';
import 'features/home/views/home_page.dart';
import 'features/roadmap/views/roadmap_page.dart';
import 'features/schedule/views/schedule_page.dart';
import 'features/profile/views/profile_page.dart';
import 'features/profile/views/edit_profile_page.dart';
import 'features/profile/views/setting_page.dart';
import 'features/notification/views/notifications_page.dart';
import 'features/credit_breakdown/views/credit_page.dart';

class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const roadmap = '/roadmap';
  static const schedule = '/schedule';
  static const profile = '/profile';
  static const edit_profile = '/edit_profile';
  static const setting = '/setting';
  static const notification = '/notification';
  static const forgotPassword = '/forgot-password';
  static const creditBreakdown = '/credit_breakdown';
  static const main = 'main';

  static final routes = {
    login: (context) => const LoginPage(),
    register: (context) => const RegisterPage(),
    forgotPassword: (context) => const ForgotPasswordPage(),
    main: (context) => const MainWrapper(),
    home: (context) => const HomePage(),
    roadmap: (context) => const RoadMapPage(),
    schedule: (context) => const SchedulePage(),
    profile: (context) => ProfilePage(),
    edit_profile: (context) => EditProfilePage(),
    setting: (context) => const SettingPage(),
    notification: (context) => const NotificationsPage(),
    creditBreakdown: (context) => const CreditBreakdownPage(),
  };
}
