import 'package:cn_planner_app/features/profile/widgets/quick_stats.dart';
import 'package:cn_planner_app/features/profile/widgets/feature_menu.dart';
import 'package:cn_planner_app/route.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/profile_image.dart';
import '../widgets/profile_info.dart';
import '../widgets/gpa_dashboard.dart';
import 'package:cn_planner_app/core/widgets/bottom_nav_bar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: IconButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.setting),
                  icon: const Icon(
                    Icons.settings,
                    size: 30,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                children: [
                  ProfileImage(),

                  const SizedBox(height: 20),

                  ProfileInfo(
                    name: "Somchai Thammasat",
                    subtitle: "@somchaitu | Year 2",
                  ),

                  const SizedBox(height: 20),

                  const GpaDashboard(gpax: 3.85, gpa: 4.00),

                  const SizedBox(height: 15),

                  Align(
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

                  Row(
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
                    route: AppRoutes.schedule,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Icon buildIcon(IconData IconData) {
    return Icon(IconData, color: AppColors.textDarkGrey);
  }
}
