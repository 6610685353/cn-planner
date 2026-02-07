import 'features/auth/login_page.dart';
// import 'features/auth/register_page.dart';
// import 'features/profile/profile_page.dart';
// import 'features/profile/setting_page.dart';

class AppRoutes {
  static const login = '/login';
  // static const register = '/register';
  // static const profile = '/profile';
  // static const setting = '/setting';

  static final routes = {
    login: (context) => const LoginPage(),
    // register: (context) => const RegisterPage(),
    // profile: (context) => const ProfilePage(),
    // setting: (context) => const SettingPage(),
  };
}
