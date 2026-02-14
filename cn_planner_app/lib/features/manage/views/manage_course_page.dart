import 'package:cn_planner_app/core/constants/app_colors.dart';
import 'package:cn_planner_app/features/manage/widgets/search_box.dart';
import 'package:cn_planner_app/features/manage/widgets/year_course.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class ManageCoursePage extends StatefulWidget {
  const ManageCoursePage({super.key});

  @override
  State<ManageCoursePage> createState() => _ManageCoursePage();
}

class _ManageCoursePage extends State<ManageCoursePage> {
  Map<String, dynamic> _data = {}; 
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadJsonData();
  }

  Future<void> _loadJsonData() async {
    final String response = await rootBundle.loadString('assets/mock_data.json');
    final data = await json.decode(response);

    setState(() {
      _data = data;
      _isLoading = false; 
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // List<Map<String, dynamic>> allSem = [];

    // _data['year_course'].forEach((yearKey, sems) {
    //   sems.forEach((semKey, course){
    //     allSem.add({
    //       "year"
    //     })
    //   });
    // });

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
            child: ListView.builder(
              itemCount: _data['year_course'].length,
              itemBuilder: (context, index) {
                String key = _data['year_course'].keys.elementAt(index);
                dynamic value = _data['year_course'][key];

                return YearCourseBox(yearCourse: value, subject: _data['subject'],);
              }
            )
          )
        ],
      )
      // body: Center(
      //   child: Text("Output: ${_data['year_course']['1']}")
      // )
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