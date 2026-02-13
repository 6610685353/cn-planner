import 'package:cn_planner_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class ManageCoursePage extends StatelessWidget{
  const ManageCoursePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Text(
        'Test Manage'
      )
    );
  }
}