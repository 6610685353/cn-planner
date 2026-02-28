import 'package:cn_planner_app/core/constants/app_colors.dart';
import 'package:cn_planner_app/core/widgets/top_bar.dart';
import 'package:cn_planner_app/features/manage/widgets/search_box.dart';
import 'package:cn_planner_app/features/manage/widgets/year_course.dart';
import 'package:cn_planner_app/services/data_fetch.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cn_planner_app/services/update_course.dart';


class ManageCoursePage extends StatefulWidget {
  const ManageCoursePage({super.key});

  @override
  State<ManageCoursePage> createState() => _ManageCoursePage();
}

class _ManageCoursePage extends State<ManageCoursePage> {
  //get from backend
  Map<String, dynamic> _pageData = {};

  //normal use
  bool _isLoading = true;
  String? _errorMessage;
  String userID = "";
  Map<String, dynamic> _filteredCourses = {};

  //for backend
  Map<int, bool> checkedMap = {};
  Map<int, String> gradeMap = {};

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
      final pageDataF = await DataFetch().getManagePageData();
      final dataEnrolledF = await DataFetch().fetchEnrolled(userID);
      print("after calling API");

      for (var item in dataEnrolledF) {
        gradeMap[item['subjectId']] = item['grade'];
        checkedMap[item['subjectId']] = true;
      }

      if (!mounted) return;

      setState(() {
        _pageData = pageDataF;
        _filteredCourses = _pageData;
        
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
        _filteredCourses = _pageData;
      });
      return;
    }

    final Map<String, dynamic> result = {};

    _pageData.forEach((category, items) {
      final List<dynamic> coursesList = items as List<dynamic>;

      final matched = coursesList.where((course) {
        final String code = course['subjectCode']?.toString() ?? "";
        return code.toLowerCase().contains(query.toLowerCase());
      }).toList();

      if (matched.isNotEmpty) {
        result[category] = matched;
      }
    });

    setState(() {
      _filteredCourses = result;
    });
  }

  void updateCheck(int subjectId, bool value) {
    setState(() {
      checkedMap[subjectId] = value;

      if(!value) {
        gradeMap[subjectId] = "-";
      }
    });
  }

  void updateGrade(int subjectId, String grade) {
    setState(() {
      gradeMap[subjectId] = grade;
    });
  }

  List<Map<String , dynamic>> buildSubmitList() {
    return checkedMap.entries
      .where((entry) => 
        entry.value == true &&
        gradeMap[entry.key] != null &&
        gradeMap[entry.key] != "-")
      .map<Map<String, dynamic>>((entry) => {
        "subjectId": entry.key,
        "grade": gradeMap[entry.key]!
      }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text('Error : ${_errorMessage ?? "idk"}'));
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
                  final parts = entry.key.split('_');
                  final String year = parts[0];
                  final String sem = parts[1];
                  final List<dynamic> subjects = entry.value;
                  return YearCourseBox(
                    year: year,
                    semester: sem,
                    courseSubject: subjects,
                    checkedMap: checkedMap,
                    gradeMap: gradeMap,
                    onCheckChanged: updateCheck,
                    onGradeChanged: updateGrade,
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
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: ElevatedButton(
          onPressed: () {
            final result = buildSubmitList();
            UpdateCourse.submitManageCourse(result);
            Navigator.pop(context);
          },
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
