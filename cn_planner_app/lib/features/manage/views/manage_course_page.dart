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
  Map<String, dynamic> _dataCourse = {};
  Map<String, dynamic> _dataSubject = {};
  List<dynamic> _dataEnrolled = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final dataCourseF = await DataFetch().getAllCourse();
      final dataSubjectF = await DataFetch().getAllSubject();
      final dataEnrolledF = await DataFetch().fetchEnrolled("");
      print("after calling API");

      if (!mounted) return;

      setState(() {
        _dataCourse = dataCourseF;
        _dataSubject = dataSubjectF;
        _dataEnrolled = dataEnrolledF;
        _isLoading = false;
      });
    } catch (e) {
      if(!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return const Center(child: Text('Error!'));
    }

    if (_dataCourse.isEmpty) {
      return const Center(child: Text("Course not found."));
    }

    if (_dataSubject.isEmpty) {
      return const Center(child: Text("Subject not found."));
    }

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
          Text(_dataEnrolled.toString()),
          SearchBox(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: _dataCourse.entries.map((entry) {
                  return YearCourseBox(
                    year: entry.value['year'], 
                    semester: entry.value['sem'],
                    courseSubject: entry.value['courses'],
                    subjectData: _dataSubject,
                  );
                }).toList(),
              ),
            ),
          )
        ],
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