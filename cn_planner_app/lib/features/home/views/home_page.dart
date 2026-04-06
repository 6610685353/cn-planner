import 'package:cn_planner_app/core/constants/app_colors.dart';
import 'package:cn_planner_app/features/home/widgets/academic_progress.dart';
import 'package:cn_planner_app/features/home/widgets/home_feature.dart';
import 'package:cn_planner_app/features/home/widgets/welcome_banner.dart';
import 'package:cn_planner_app/features/home/widgets/gpa_banner.dart';
import 'package:cn_planner_app/features/home/widgets/schedule_card.dart';
import 'package:cn_planner_app/features/schedule/views/schedule_data.dart';
import 'package:flutter/material.dart';
import 'package:cn_planner_app/route.dart';
import 'package:cn_planner_app/features/schedule/views/daily_schedule_page.dart';
import 'package:cn_planner_app/features/profile/controllers/profile_controller.dart';
import 'package:visibility_detector/visibility_detector.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ProfileController _profileController = ProfileController();
  ProfileData? _profileData;
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await _profileController.fetchUserData();
    if (mounted) {
      setState(() {
        _profileData = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final firstName = _profileData?.name.split(' ').first ?? "";

    return VisibilityDetector(
      key: const Key('home-page-key'),
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction > 0) {
          _loadData();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                color: Colors.white,
                backgroundColor: AppColors.accentYellow,
                onRefresh: _loadData,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    WelcomeBanner(
                      fname: firstName,
                      imageUrl: _profileData?.profileImageUrl,
                      route: AppRoutes.notification,
                    ),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: Column(
                          children: [
                            AcademicProgresss(
                              creditEarned: _profileData?.earned_credits ?? 0,
                              totalCredit: _profileData?.total_credits ?? 0,
                              route: AppRoutes.creditBreakdown,
                            ),
                            const SizedBox(height: 15),

                            SizedBox(
                              width: 358,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      await Navigator.pushNamed(
                                        context,
                                        AppRoutes.main,
                                      );
                                      if (mounted)
                                        _loadData(); // กลับมาแล้วโหลดใหม่
                                    },
                                    child: HomeFeature(
                                      icon: Icons.edit_square,
                                      name: "Edit Academic",
                                      route: AppRoutes.academicHistory,
                                      isLeft: true,
                                    ),
                                  ),

                                  GestureDetector(
                                    onTap: () async {
                                      await Navigator.pushNamed(
                                        context,
                                        AppRoutes.gpa,
                                      );
                                      if (mounted)
                                        _loadData(); // กลับมาแล้วโหลดใหม่
                                    },
                                    child: HomeFeature(
                                      icon: Icons.calculate,
                                      name: "GPA Calculator",
                                      route: AppRoutes.gpa,
                                      isLeft: false,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),
                            scheduleTitle(context),
                            const SizedBox(height: 10),

                            // ส่วนแสดง Schedule (Horizontal Scroll)
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
                            const SizedBox(height: 15),

                            GpaBanner(
                              gpa: _profileData?.gpa ?? 0.00,
                              currentAcademicStanding:
                                  _profileData?.currentAcademicStanding ??
                                  "Error",
                            ),
                            const SizedBox(height: 15),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget scheduleTitle(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Today's Schedule",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        InkWell(
          onTap: () async {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) =>
                  const Center(child: CircularProgressIndicator()),
            );

            try {
              final classes = await ScheduleDataService.getUserClasses("1");
              if (context.mounted) {
                Navigator.pop(context); // ปิด Loading
                // 🌟 จุดที่ 4: เมื่อกลับจากหน้าตารางเรียน
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DailySchedulePage(allClasses: classes),
                  ),
                );
                if (mounted) _loadData();
              }
            } catch (e) {
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              children: [
                Text(
                  'View Day Schedule',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryYellow,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.arrow_right_alt,
                  size: 20,
                  color: AppColors.primaryYellow,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
