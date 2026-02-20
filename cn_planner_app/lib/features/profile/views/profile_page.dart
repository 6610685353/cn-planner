import 'package:cn_planner_app/features/profile/controllers/setting_controller.dart';
import 'package:cn_planner_app/features/profile/widgets/quick_stats.dart';
import 'package:cn_planner_app/features/profile/widgets/feature_menu.dart';
import 'package:cn_planner_app/features/profile/widgets/setting_action_tile.dart';
import 'package:cn_planner_app/route.dart';
import 'package:flutter/material.dart';
// --- 1. Import Controller ที่มี handleSignOut ---
import '../../../core/constants/app_colors.dart';
import '../widgets/profile_image.dart';
import '../widgets/profile_info.dart';
import '../widgets/gpa_dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cn_planner_app/services/auth_service.dart';

// --- 2. เปลี่ยนจาก StatelessWidget เป็น StatefulWidget ---
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // --- 3. ประกาศ Controller สำหรับเรียกใช้งาน Logic ต่างๆ ---
  final SettingController _settingController = SettingController();
  final AuthService _authService = AuthService();

  String firstName = "";
  String lastName = "";
  String username = "";
  String? uid;
  int year = 0; // เพิ่มตัวแปรสำหรับเก็บชั้นปี

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    uid = user.uid;

    final data = await _authService.getUserProfile();

    if (data != null && mounted) {
      setState(() {
        firstName = data['firstName'] ?? "";
        lastName = data['lastName'] ?? "";
        username = data['username'] ?? ""; // ดึงข้อมูล username จากระบบ
        year = data['year'] ?? 0; // ดึงข้อมูลชั้นปีจากระบบ
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.background,
            automaticallyImplyLeading: false,
            floating: true,
            pinned: false,
            actions: [
              // Padding(
              //   padding: const EdgeInsets.only(right: 10.0),
              //   child: IconButton(
              //     onPressed: () =>
              //         Navigator.pushNamed(context, AppRoutes.setting),
              //     icon: const Icon(
              //       Icons.settings,
              //       size: 30,
              //       color: Colors.black,
              //     ),
              //   ),
              // ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                children: [
                  const ProfileImage(),

                  const SizedBox(height: 20),

                  // --- 4. อัปเดตข้อมูลให้ตรงกับ Profile ของคุณ (Pepper) ---
                  ProfileInfo(
                    // ignore: prefer_interpolation_to_compose_strings
                    name: firstName + " " + lastName, // ข้อมูลจากระบบ
                    subtitle:
                        "@$username | Year $year", // สมมติ Username และชั้นปีปัจจุบัน
                  ),

                  const SizedBox(height: 20),

                  const GpaDashboard(gpax: 3.85, gpa: 4.00),

                  const SizedBox(height: 15),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, bottom: 15),
                      child: Text(
                        "Quick Stats",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),

                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      QuickStats(
                        title: "Earned",
                        mainText: "72",
                        footer: "Credits",
                      ),
                      QuickStats(
                        title: "Remaining",
                        mainText: "56",
                        footer: "Credits",
                      ),
                      QuickStats(
                        title: "Standing",
                        mainText: "Good",
                        footer: "Academic",
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  FeatureMenu(
                    icon: buildIcon(Icons.map_outlined),
                    title: "Roadmap",
                    subtitle: "View overall detail",
                    route: AppRoutes.roadmap,
                  ),
                  FeatureMenu(
                    icon: buildIcon(Icons.calendar_month_outlined),
                    title: "Schedule",
                    subtitle: "Check your timetable",
                    route: AppRoutes.schedule,
                  ),
                  FeatureMenu(
                    icon: buildIcon(Icons.emoji_events_outlined),
                    title: "Credit Breakdown",
                    subtitle: "View overall detail",
                    route: AppRoutes.creditBreakdown,
                  ),
                  const SizedBox(height: 30),

                  // --- 5. ย้ายปุ่ม Logout มาใช้งานในหน้านี้ ---
                  SettingActionTile(
                    icon: Icons.logout,
                    title: "Sign out",
                    onTap: () {
                      _settingController.handleSignOut(context);
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Icon buildIcon(IconData iconData) {
    return Icon(iconData, color: AppColors.textDarkGrey);
  }
}

// import 'package:cn_planner_app/features/profile/widgets/quick_stats.dart';
// import 'package:cn_planner_app/features/profile/widgets/feature_menu.dart';
// import 'package:cn_planner_app/features/profile/widgets/setting_action_tile.dart';
// import 'package:cn_planner_app/route.dart';
// import 'package:flutter/material.dart';
// import '../../../core/constants/app_colors.dart';
// import '../widgets/profile_image.dart';
// import '../widgets/profile_info.dart';
// import '../widgets/gpa_dashboard.dart';

// class ProfilePage extends StatelessWidget {
//   const ProfilePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       body: CustomScrollView(
//         physics: const BouncingScrollPhysics(),
//         slivers: [
//           SliverAppBar(
//             backgroundColor: AppColors.background,
//             automaticallyImplyLeading: false,
//             floating: true,
//             pinned: false,
//             actions: [
//               Padding(
//                 padding: const EdgeInsets.only(right: 10.0),
//                 child: IconButton(
//                   onPressed: () =>
//                       Navigator.pushNamed(context, AppRoutes.setting),
//                   icon: const Icon(
//                     Icons.settings,
//                     size: 30,
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10.0),
//               child: Column(
//                 children: [
//                   ProfileImage(),

//                   const SizedBox(height: 20),

//                   ProfileInfo(
//                     name: "Somchai Thammasat",
//                     subtitle: "@somchaitu | Year 2",
//                   ),

//                   const SizedBox(height: 20),

//                   const GpaDashboard(gpax: 3.85, gpa: 4.00),

//                   const SizedBox(height: 15),

//                   Align(
//                     alignment: Alignment.centerLeft,
//                     child: Padding(
//                       padding: const EdgeInsets.only(left: 10, bottom: 15),
//                       child: Text(
//                         "Quick Stats",
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 18,
//                         ),
//                       ),
//                     ),
//                   ),

//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       QuickStats(
//                         title: "Earned",
//                         mainText: "72",
//                         footer: "Credits",
//                       ),
//                       QuickStats(
//                         title: "Remaining",
//                         mainText: "56",
//                         footer: "Credits",
//                       ),
//                       QuickStats(
//                         title: "Standing",
//                         mainText: "Good",
//                         footer: "Academic",
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 10),

//                   FeatureMenu(
//                     icon: buildIcon(Icons.map_outlined),
//                     title: "Roadmap",
//                     subtitle: "View overall detail",
//                     route: AppRoutes.roadmap,
//                   ),
//                   FeatureMenu(
//                     icon: buildIcon(Icons.calendar_month_outlined),
//                     title: "Schedule",
//                     subtitle: "Check your timetable",
//                     route: AppRoutes.schedule,
//                   ),
//                   FeatureMenu(
//                     icon: buildIcon(Icons.emoji_events_outlined),
//                     title: "Credit Breakdown",
//                     subtitle: "View overall detail",
//                     route: AppRoutes.creditBreakdown,
//                   ),
//                   const SizedBox(height: 40),

//                   SettingActionTile(
//                     icon: Icons.logout,
//                     title: "Sign out",
//                     onTap: () {
//                       // _controller.handleSignOut(context);
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Icon buildIcon(IconData iconData) {
//     return Icon(iconData, color: AppColors.textDarkGrey);
//   }
// }
