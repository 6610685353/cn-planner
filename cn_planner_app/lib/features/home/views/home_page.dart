import 'package:cn_planner_app/core/constants/app_colors.dart';
import 'package:cn_planner_app/features/home/widgets/academic_progress.dart';
import 'package:cn_planner_app/features/home/widgets/home_feature.dart';
import 'package:cn_planner_app/features/home/widgets/welcome_banner.dart';
import 'package:cn_planner_app/features/home/widgets/gpa_banner.dart';
import 'package:cn_planner_app/features/home/widgets/schedule_card.dart';
import 'package:flutter/material.dart';
import 'package:cn_planner_app/route.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          WelcomeBanner(
            fname: "Somchai",
            route: AppRoutes.notification, //แก้ด้วย
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  AcademicProgresss(
                    creditEarned: 100,
                    totalCredit: 146,
                    route: AppRoutes.creditBreakdown,
                  ),

                  const SizedBox(height: 15),

                  Container(
                    width: 358,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        HomeFeature(
                          icon: Icons.edit_square,
                          name: "Edit Academic",
                          route: AppRoutes.main,
                          isLeft: true,
                        ),

                        HomeFeature(
                          icon: Icons.calculate,
                          name: "GPA Calculator",
                          route: AppRoutes.gpa,
                          isLeft: false,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 12),

                  scheduleTitle(context, AppRoutes.main),

                  SizedBox(height: 10),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: const [
                        ScheduleCard(
                          status: "ONGOING",
                          subjectCode: "TU100",
                          subjectName: "Civic Education",
                          time: "9:30 - 11.00",
                          location: "SC3-201",
                          isOngoing: true,
                        ),
                        ScheduleCard(
                          status: "NEXT",
                          subjectCode: "CN101",
                          subjectName: "Introduction to Computer",
                          time: "13:30 - 16:30",
                          location: "SC3-201",
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 15),

                  GpaBanner(gpa: 4.00),

                  SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget scheduleTitle(BuildContext context, String route) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Today's Schedule",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        InkWell(
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.main);
          },
          borderRadius: BorderRadius.circular(8),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'View Day Schedule',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors
                        .primaryYellow, // เปลี่ยนสีให้มองเห็นชัด (เพราะไม่มีพื้นหลังแล้ว)
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.arrow_right_alt,
                  size: 20,
                  color: AppColors.primaryYellow, // สีเดียวกับ Text
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
