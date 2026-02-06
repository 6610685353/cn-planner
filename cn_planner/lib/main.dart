import 'package:flutter/material.dart';
import 'features/home/presentation/home_page.dart';
import 'features/roadmap/presentation/roadmap_page.dart';
import 'features/schedule/presentation/schedule_page.dart';
import 'features/profile/presentation/profile_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: ProfilePage());
  }
}
