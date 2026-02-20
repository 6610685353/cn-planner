import 'package:cn_planner_app/core/constants/app_colors.dart';
import 'package:cn_planner_app/core/widgets/top_bar.dart';
import 'package:cn_planner_app/features/manage/widgets/search_box.dart';
import 'package:cn_planner_app/features/manage/widgets/year_course.dart';
import 'package:cn_planner_app/services/data_fetch.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class ManageCoursePage extends StatefulWidget {
  const ManageCoursePage({super.key});

  @override
  State<ManageCoursePage> createState() => _ManageCoursePage();
}

class _ManageCoursePage extends State<ManageCoursePage> {
  Map<String, dynamic> _dataCourse = {};
  Map<String, dynamic> _dataSubject = {};
  Map<String, dynamic> _filteredCourses = {};
  List<dynamic> _dataEnrolled = [];
  bool _isLoading = true;
  String? _errorMessage;
  String userID = "";

  @override
  void initState() {
    super.initState();
    print("call initState");
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if(user != null) {
        print(user.uid);
        userID = user.uid;
      } else {
        print("Not login");
      }
    });
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final dataCourseF = await DataFetch().getAllCourse();
      final dataSubjectF = await DataFetch().getAllSubject();
      final dataEnrolledF = await DataFetch().fetchEnrolled(userID);
      print("after calling API");

      if (!mounted) return;

      setState(() {
        _dataCourse = dataCourseF;
        _dataSubject = dataSubjectF;
        _dataEnrolled = dataEnrolledF;
        _filteredCourses = _dataCourse;
        
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void onSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredCourses = _dataCourse;
      });
      return;
    }

    final Map<String, dynamic> result = {};

    _dataCourse.forEach((category, items) {
      final courses = (items['courses'] as List<dynamic>);

      final matched = courses.where((c) =>
        c.toString().toLowerCase().contains(query.toLowerCase())
      ).toList();

      if (matched.isNotEmpty) {
        result[category] = {...items, 'courses':matched};
      }
    });

    setState(() {
      _filteredCourses = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return const Center(child: Text('Error'));
    }

    if (_dataCourse.isEmpty) {
      return const Center(child: Text("Course not found."));
    }

    if (_dataSubject.isEmpty) {
      return const Center(child: Text("Subject not found."));
    }

    return Scaffold(
      appBar: TopBar(header: "Manage Courses"),
      body: Column(
        children: [
          SearchBox(onChanged: onSearch),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: _filteredCourses.entries.map((entry) {
                  return YearCourseBox(
                    year: entry.value['year'],
                    semester: entry.value['sem'],
                    courseSubject: entry.value['courses'],
                    subjectData: _dataSubject,
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 15,
          bottom: MediaQuery.of(context).padding.bottom > 0
              ? MediaQuery.of(context).padding.bottom + 10
              : 20,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
          // borderRadius: const BorderRadius.only(
          //   topLeft: Radius.circular(24),
          //   topRight: Radius.circular(24),
          // ),
        ),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentYellow,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Confirm Selection',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
