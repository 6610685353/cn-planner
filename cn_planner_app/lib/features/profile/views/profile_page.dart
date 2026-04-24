import 'package:cn_planner_app/core/widgets/confirm_dialog.dart';
import 'package:cn_planner_app/features/credit_breakdown/views/credit_page.dart';
import 'package:cn_planner_app/features/profile/widgets/quick_stats.dart';
import 'package:cn_planner_app/features/profile/widgets/feature_menu.dart';
import 'package:cn_planner_app/features/profile/widgets/setting_action_tile.dart';
import 'package:cn_planner_app/route.dart';
import 'package:cn_planner_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/profile_image.dart';
import '../widgets/profile_info.dart';
import '../widgets/gpa_dashboard.dart';
import '../controllers/profile_controller.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
    return VisibilityDetector(
      key: const Key('profile-page-key'),
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction > 0.5 && !_isLoading) {
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
                    const SliverAppBar(
                      backgroundColor: AppColors.background,
                      automaticallyImplyLeading: false,
                      floating: true,
                      pinned: false,
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                await Navigator.pushNamed(
                                  context,
                                  AppRoutes.editProfile,
                                );

                                if (mounted) {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  await Future.delayed(
                                    const Duration(milliseconds: 500),
                                  );
                                  await _loadData();
                                }
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  ProfileImage(
                                    imageUrl: _profileData?.profileImageUrl,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            ProfileInfo(
                              name: _profileData?.name ?? "",
                              subtitle:
                                  "@${_profileData?.username ?? ''} | Year ${_profileData?.year ?? 0}",
                            ),
                            const SizedBox(height: 20),

                            GpaDashboard(
                              gpax: _profileData?.gpax ?? 0.0,
                              gpa: _profileData?.gpa ?? 0.0,
                            ),
                            const SizedBox(height: 15),

                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.only(left: 10, bottom: 15),
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
                                  mainText:
                                      _profileData?.earned_credits.toString() ??
                                      "0",
                                  footer: "Credits",
                                ),
                                QuickStats(
                                  title: "Remaining",
                                  mainText:
                                      _profileData?.remaining_credits
                                          .toString() ??
                                      "0",
                                  footer: "Credits",
                                ),
                                QuickStats(
                                  title: "Standing",
                                  mainText:
                                      _profileData?.academicStanding ?? "-",
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
                              subtitle: "View your progress",
                              route: AppRoutes.creditBreakdown,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const CreditBreakdownPage(),
                                  ),
                                ).then((_) {
                                  _loadData();
                                });
                              },
                            ),
                            const SizedBox(height: 30),

                            SettingActionTile(
                              icon: Icons.logout,
                              title: "Sign out",
                              onTap: () {
                                ConfirmDialog.show(
                                  context: context,
                                  title: 'Sign Out',
                                  content:
                                      'Are you sure you want to sign out of your account?',
                                  confirmText: 'Sign out',
                                  onConfirm: () async {
                                    await AuthService().logout();
                                    if (context.mounted) {
                                      Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        AppRoutes.login,
                                        (route) => false,
                                      );
                                    }
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 50),
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

  Icon buildIcon(IconData iconData) {
    return Icon(iconData, color: AppColors.textDarkGrey);
  }
}
