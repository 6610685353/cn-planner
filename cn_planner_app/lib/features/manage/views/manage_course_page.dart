import 'package:cn_planner_app/core/constants/app_colors.dart';
import 'package:cn_planner_app/features/manage/widgets/search_box.dart';
import 'package:cn_planner_app/features/manage/widgets/year_course.dart';
import 'package:flutter/material.dart';

class ManageCoursePage extends StatelessWidget {
  const ManageCoursePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('Manage Course')
      ),
      body: Column(
        children: [
          SearchBox(),
          Expanded(
            child: ListView(
              children: [
                YearCourseBox(),
                YearCourseBox(),
                YearCourseBox(),
                YearCourseBox(),
                YearCourseBox(),
                YearCourseBox(),
                YearCourseBox(),
                YearCourseBox(),
              ],
            ))
        ],
      )
      ,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50), // ปุ่มกว้างเต็มหน้าจอ
            backgroundColor: Colors.blue,
          ),
          child: const Text('Confirm', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}