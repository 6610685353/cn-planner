import 'package:cn_planner_app/core/constants/app_colors.dart';
import 'package:cn_planner_app/features/home/widgets/academic_progress.dart';
import 'package:cn_planner_app/features/home/widgets/home_feature.dart';
import 'package:cn_planner_app/features/home/widgets/welcome_banner.dart';
import 'package:cn_planner_app/features/home/widgets/gpa_banner.dart';
import 'package:flutter/material.dart';
import 'package:cn_planner_app/route.dart';
import 'package:cn_planner_app/features/schedule/views/daily_schedule_page.dart';
import 'package:cn_planner_app/features/profile/controllers/profile_controller.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cn_planner_app/features/schedule/services/schedule_service.dart';
import 'package:cn_planner_app/core/models/class_session.dart';
import 'package:cn_planner_app/features/home/widgets/today_schedule_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ProfileController _profileController = ProfileController();
  ProfileData? _profileData;
  List<ClassSession> _todayClasses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final data = await _profileController.fetchUserData();
    final classes = await _fetchTodayUpcomingClasses();

    if (mounted) {
      setState(() {
        _profileData = data;
        _todayClasses = classes;
        _isLoading = false;
      });
    }
  }

  Future<List<ClassSession>> _fetchTodayUpcomingClasses() async {
    try {
      String myUid = FirebaseAuth.instance.currentUser?.uid ?? "";
      if (myUid.isEmpty) return [];

      final service = ScheduleService();
      final masterCourses = await service.getRealScheduleForUser(myUid);

      List<ClassSession> allRealClasses = [];
      for (var course in masterCourses) {
        for (var slot in course.timeSlots) {
          allRealClasses.add(
            ClassSession(
              code: course.courseCode,
              name: course.courseName,
              instructor: course.instructor,
              day: slot.day,
              start: slot.startTime,
              stop: slot.endTime,
              section: course.section,
              room: slot.room,
              color: Colors.blue,
            ),
          );
        }
      }

      final now = DateTime.now();
      const days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
      final todayCode = days[now.weekday - 1];

      final todayClasses = allRealClasses
          .where((c) => c.day.toLowerCase().contains(todayCode))
          .toList();

      todayClasses.sort(
        (a, b) => _timeToMinutes(a.start).compareTo(_timeToMinutes(b.start)),
      );

      final timeNow = now.hour * 60 + now.minute;
      final upcomingClasses = todayClasses.where((c) {
        return _timeToMinutes(c.stop) > timeNow;
      }).toList();

      return upcomingClasses.take(2).toList();
    } catch (e) {
      print("❌ Error fetching today schedule: $e");
      return [];
    }
  }

  int _timeToMinutes(String time) {
    final parts = time.split(':');
    if (parts.length != 2) return 0;
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  Future<void> _handleViewDaySchedule() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      String myUid = FirebaseAuth.instance.currentUser?.uid ?? "";
      final masterCourses = await ScheduleService().getRealScheduleForUser(
        myUid,
      );

      List<ClassSession> convertedClasses = [];
      for (var course in masterCourses) {
        for (var slot in course.timeSlots) {
          convertedClasses.add(
            ClassSession(
              code: course.courseCode,
              name: course.courseName,
              instructor: course.instructor,
              day: slot.day,
              start: slot.startTime,
              stop: slot.endTime,
              section: course.section,
              room: slot.room,
              color: Colors.blue,
            ),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context);
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DailySchedulePage(allClasses: convertedClasses),
          ),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
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
                                  Expanded(child:
                                    GestureDetector(
                                      onTap: () async {
                                        await Navigator.pushNamed(
                                          context,
                                          AppRoutes.main,
                                        );
                                        if (mounted) _loadData();
                                      },
                                      child: HomeFeature(
                                        icon: Icons.edit_square,
                                        name: "Edit Academic",
                                        route: AppRoutes.academicHistory,
                                        isLeft: true,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(child:
                                    GestureDetector(
                                      onTap: () async {
                                        await Navigator.pushNamed(
                                          context,
                                          AppRoutes.gpa,
                                        );
                                        if (mounted) _loadData();
                                      },
                                      child: HomeFeature(
                                        icon: Icons.calculate,
                                        name: "GPA Calculator",
                                        route: AppRoutes.gpa,
                                        isLeft: false,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            TodayScheduleSection(
                              todayClasses: _todayClasses,
                              onViewDaySchedule: _handleViewDaySchedule,
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
}
