import 'package:cn_planner_app/core/constants/app_colors.dart';
import 'package:cn_planner_app/core/widgets/bottom_nav_bar.dart';
import 'package:cn_planner_app/features/home/widgets/academic_progress.dart';
import 'package:cn_planner_app/features/home/widgets/welcome_banner.dart';
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
            route: AppRoutes.main, //แก้ด้วย
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  AcademicProgresss(
                    creditEarned: 100,
                    totalCredit: 146,
                    route: AppRoutes.main,
                  ),

                  // สามารถเพิ่ม Widget อื่นๆ ต่อท้ายได้ที่นี่
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
