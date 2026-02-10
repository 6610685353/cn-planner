// import 'package:flutter/material.dart';

// import 'features/home/views/home_page.dart';
// import 'features/roadmap/presentation/roadmap_page.dart';
// import 'features/schedule/presentation/schedule_page.dart';
// import 'features/profile/presentation/profile_page.dart';
// import 'core/widgets/bottom_nav_bar.dart';

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: MainScaffold(),
//     );
//   }
// }

// class MainScaffold extends StatefulWidget {
//   const MainScaffold({super.key});

//   @override
//   State<MainScaffold> createState() => _MainScaffoldState();
// }

// class _MainScaffoldState extends State<MainScaffold> {
//   int _currentIndex = 0;

//   final _pages = const [
//     HomePage(),
//     RoadmapPage(),
//     SchedulePage(),
//     ProfilePage(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _pages[_currentIndex],
//       bottomNavigationBar: BottomNavBar(
//         currentIndex: _currentIndex,
//         onTap: (index) {
//           setState(() {
//             _currentIndex = index;
//           });
//         },
//       ),
//     );
//   }
// }
