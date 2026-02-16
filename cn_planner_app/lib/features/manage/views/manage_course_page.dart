import 'package:cn_planner_app/core/constants/app_colors.dart';
import 'package:cn_planner_app/features/manage/widgets/search_box.dart';
import 'package:cn_planner_app/features/manage/widgets/year_course.dart';
import 'package:cn_planner_app/services/data_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class ManageCoursePage extends StatefulWidget {
  const ManageCoursePage({super.key});

  @override
  State<ManageCoursePage> createState() => _ManageCoursePage();
}

class _ManageCoursePage extends State<ManageCoursePage> {
  // Map<String, dynamic> _data = {}; 
  late Future<Map<String, dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = DataFetch().getAllCourse();
  }


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
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dataFuture, 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.hasData) {
            final dataMap = snapshot.data!;

            return Text(dataMap.toString());
          }
          return const Center(child: Text("No data found"));
        }
      ),
      
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