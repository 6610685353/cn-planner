import 'package:cn_planner_app/features/impact_analysis/screens/impact_analysis_screen.dart';
import 'package:flutter/material.dart';
import '../core/widgets/bottom_nav_bar.dart';
import 'home/views/home_page.dart';
import 'roadmap/views/roadmap_page.dart'; // Import หน้าของคุณ
import 'schedule/views/schedule_page.dart'; // Import หน้าของคุณ
import 'profile/views/profile_page.dart';
import 'simulator/screens/simulator_screen.dart'; // Import หน้าของคุณ
import 'impact_analysis/screens/impact_analysis_screen.dart';
import 'simulator/services/simulation_result_model.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  // รายการหน้าหลักทั้ง 4 หน้า
  final List<Widget> _pages = const [
    HomePage(),
    RoadmapPage(mode: RoadmapMode.view), // เปลี่ยนเป็น RoadmapPage()
    SchedulePage(), // เปลี่ยนเป็น SchedulePage()
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack จะทำให้ Nav Bar ไม่หายไป และรักษาข้อมูลในหน้าเดิมไว้ (ไม่โหลดใหม่)
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
