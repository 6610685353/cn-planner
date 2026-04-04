import 'package:cn_planner_app/services/data_fetch.dart';
import 'package:flutter/material.dart';
import 'package:cn_planner_app/features/gpa_calculator/widgets/course_card.dart';
import 'package:cn_planner_app/features/gpa_calculator/widgets/stat_card.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GPACalculatorPage extends StatefulWidget {
  const GPACalculatorPage({super.key});

  @override
  State<GPACalculatorPage> createState() => _GPACalculatorPageState();
}

class _GPACalculatorPageState extends State<GPACalculatorPage> {
  double targetGPA = 0;
  double currentGPAX = 0;
  double predictedGPAX = 0;
  double predictOnlyThisSem = 0;
  List<dynamic> currentSemCourses = [];
  String userID = "";

  final Map<String, double> gradePoints = {
    "A": 4.0,
    "B+": 3.5,
    "B": 3.0,
    "C+": 2.5,
    "C": 2.0,
    "D+": 1.5,
    "D": 1.0,
    "F": 0.0,
    "-": 0.0,
  };

  // List<Map<String, dynamic>> currentSemesterCourses = [];

  double currentGPA = 0.00;
  double predictedGPA = 0.00;

  // Accumulated data from past semesters
  double pastTotalPoints = 0.0;
  double pastTotalCredits = 0.0;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userID = user.uid;
    }
    _loadData();
  }

  Future<void> _loadData() async {
    try {  
      final currentSemCourseF = await DataFetch().fetchCurrentSem(userID);
      print("pulling current sem course");

      setState(() {
        currentSemCourses = currentSemCourseF;
      });
    } catch (e) {
      print("fail get current sem: $e");
      throw Exception(e);
    }
  }

  void _updateCourseGrade(int index, String newGrade) {
    setState(() {
      currentSemCourses[index]['grade'] = newGrade;
    });
  }

  void _calculatePrediction() {
    double semesterPoints = 0.0;
    double semesterCredits = 0.0;

    for (var course in currentSemCourses) {
      double point = gradePoints[course['grade']] ?? 0.0;
      int credit = 0;

      if (course['grade'] != "-") {
        credit = course['credit'];
      }

      semesterPoints += (point * credit);
      semesterCredits += credit;
    }

    double totalPoints = pastTotalPoints + semesterPoints;
    double totalCredits = pastTotalCredits + semesterCredits;

    setState(() {
      if (totalCredits > 0) {
        predictedGPA = totalPoints / totalCredits;
      } else {
        predictedGPA = 0.0;
      }
    });
  }

  // void _showAddCourseDialog() {
  //   String name = "";
  //   String creditStr = "3.0";

  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(16),
  //         ),
  //         title: const Text("Add New Course"),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             TextField(
  //               decoration: const InputDecoration(
  //                 labelText: "Subject Name/Code",
  //                 border: OutlineInputBorder(),
  //               ),
  //               onChanged: (v) => name = v,
  //             ),
  //             const SizedBox(height: 12),
  //             TextField(
  //               decoration: const InputDecoration(
  //                 labelText: "Credits",
  //                 border: OutlineInputBorder(),
  //               ),
  //               keyboardType: const TextInputType.numberWithOptions(
  //                 decimal: true,
  //               ),
  //               onChanged: (v) => creditStr = v,
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: const Text(
  //               "Cancel",
  //               style: TextStyle(color: Colors.black54),
  //             ),
  //           ),
  //           ElevatedButton(
  //             onPressed: () {
  //               if (name.isNotEmpty) {
  //                 final credit = double.tryParse(creditStr) ?? 3.0;
  //                 _addNewCourse(name, credit);
  //                 Navigator.pop(context);
  //               }
  //             },
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: AppColors.errorRed,
  //               foregroundColor: Colors.white,
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //             ),
  //             child: const Text("Add"),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void _deleteCourse(int index) {
    setState(() {
      // currentSemesterCourses.removeAt(index);
    });
  }

  //main page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      appBar: AppBar(
        title: const Text(
          "GPA Calculator",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                StatCard(
                  title: "Pred GPAX",
                  value: targetGPA.toString(),
                  textColor: const Color(0xffB71C1C), 
                  iconData: Icons.stars_rounded,
                  iconColor: const Color(0xffB71C1C),
                ),
                const SizedBox(width: 16),
                StatCard(
                  title:
                      "Cur GPAX",
                  value: currentGPAX.toString(), 
                  textColor: const Color(0xffFFC107), 
                  iconData: Icons.bar_chart_rounded,
                  iconColor: const Color(0xffFFC107),
                ),
              ],
            ),
          ),

          // 2. Section Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Current Semester",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD), 
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${currentSemCourses.length} courses",
                    style: const TextStyle(
                      color: Color(0xFF1976D2), 
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Course List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: currentSemCourses.length,
              itemBuilder: (context, index) {
                final course = currentSemCourses[index];
                return CourseCard(
                  name: course['subjectName'],
                  credit: course['credit'],
                  grade: course['grade'],
                  gradeOptions: gradePoints.keys.toList(),
                  onGradeChanged: (newGrade) {
                    if (newGrade != null) {
                      _updateCourseGrade(index, newGrade);
                    }
                  },
                  onDelete: () {
                    _deleteCourse(index);
                  },
                );
              },
            ),
          ),

          // 4. Manage Courses Button (Dashed)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              height: 56,
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/manage');
                },
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: Colors.black87,
                ),
                label: const Text(
                  "Manage Courses",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                style:
                    OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Colors.grey,
                        width: 1,
                        style: BorderStyle.none,
                        ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: const Color(
                        0xFFF5F5F5,
                      ), // Light background
                    ).copyWith(
                      side: WidgetStateProperty.all(
                        const BorderSide(color: Colors.grey, width: 1),
                      ),
                    ),
              ),
            ),
          ),

          // Bottom Result Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "PREDICTED GPA",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      predictedGPA.toStringAsFixed(2),
                      style: const TextStyle(
                        color: Color(0xffB71C1C), // Deep Red
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Pred this sem",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      currentGPA.toStringAsFixed(2),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: _calculatePrediction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffB71C1C), // Deep Red
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Calculate",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

