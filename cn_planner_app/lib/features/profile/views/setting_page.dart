import 'package:flutter/material.dart';
import 'package:cn_planner_app/core/constants/app_colors.dart';
import 'package:cn_planner_app/core/widgets/top_bar.dart';
import '../controllers/setting_controller.dart';
import '../widgets/language_selector.dart';
import '../widgets/setting_toggle_tile.dart';
import '../widgets/setting_action_tile.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingPage> {
  final _controller = SettingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const TopBar(
        header: "Settings",
        route: "/profile",
      ), // ใช้ TopBar ที่เคยทำ
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          children: [
            // ส่วนเลือกภาษา
            LanguageSelector(
              selectedLang: _controller.selectedLanguage,
              onLangChange: (code) =>
                  _controller.changeLanguage(code, () => setState(() {})),
            ),

            const SizedBox(height: 15),

            // ส่วนแจ้งเตือน
            SettingToggleTile(
              icon: Icons.notifications_none,
              title: "Notifications",
              value: _controller.isNotificationEnabled,
              onChanged: (val) =>
                  _controller.toggleNotification(val, () => setState(() {})),
            ),

            const SizedBox(height: 5),

            // ส่วน Sign out
            SettingActionTile(
              icon: Icons.logout,
              title: "Sign out",
              onTap: () {
                _controller.handleSignOut(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
