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
  double predictedGPAX = 0;
  double currentGPAX = 0;

  double predictedGPA = 0;
  double currentGPA = 0;

  double creditsGPA = 0;
  double creditsGPAX = 0;

  List<dynamic> currentSemCourses = [];
  List<dynamic> thisSemSubject = [];
  Map<String, dynamic> gradeCred = {};
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

  final Map<String, double> gradePointsSU = {"S": 4.0, "U": 0.0, "-": 0.0};

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

  Future<void> _loadData({bool useCache = true}) async {
    try {
      final gradeCredF = await DataFetch().fetchGPAcred(
        userID,
        isUseCache: useCache,
      );
      final thisSemSubjectF = await DataFetch().fetchThisSem(
        userID,
        isUseCache: useCache,
      );

      setState(() {
        thisSemSubject = thisSemSubjectF;

        currentSemCourses = thisSemSubject.map((item) {
          return {...item, 'grade': "-"};
        }).toList();

        gradeCred = gradeCredF[0] as Map<String, dynamic>;
        currentGPAX = gradeCred['gpax'].toDouble();
        predictedGPAX = currentGPAX;
        currentGPA = gradeCred['gpa'].toDouble();
        predictedGPA = currentGPA;

        creditsGPA = gradeCred['this_sem_credits'].toDouble();
        creditsGPAX = gradeCred['earned_credits'].toDouble();
      });
    } catch (e) {
      print("fail get current sem: $e");
      throw Exception(e);
    }
  }

  void goToEditAcademic() async {
    await Navigator.pushNamed(context, '/academic_history');

    if (mounted) {
      setState(() {
        _loadData(useCache: false);
      });
    }
  }

  void _updateCourseGrade(int index, String newGrade) {
    setState(() {
      currentSemCourses[index]['grade'] = newGrade;
      double totalGradePoints = 0;
      double totalCredits = 0;

      currentSemCourses.forEach((item) {
        totalCredits += item['grade'] != "-" ? item['credits'] : 0;
        var credits = item['grade'] != "-" ? item['credits'] : 0;
        var gradePoint = gradePoints[item['grade']] ?? 0.0;
        totalGradePoints += credits * gradePoint;
      });

      predictedGPA = totalCredits > 0
          ? ((totalGradePoints + (currentGPA * creditsGPA)) /
                (totalCredits + creditsGPA))
          : currentGPA;
      predictedGPAX = totalCredits > 0
          ? ((totalGradePoints + (currentGPAX * creditsGPAX)) /
                (totalCredits + creditsGPAX))
          : currentGPAX;
    });
  }

  void _deleteCourse(int index) {
    setState(() {
      currentSemCourses.removeAt(index);
    });
  }

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
                  title: "Pred GPA",
                  value: predictedGPA.toStringAsFixed(2),
                  textColor: const Color(0xffB71C1C),
                  iconData: Icons.stars_rounded,
                  iconColor: const Color(0xffB71C1C),
                ),
                const SizedBox(width: 16),
                StatCard(
                  title: "Pred GPAX",
                  value: predictedGPAX.toStringAsFixed(2),
                  textColor: const Color(0xffFFC107),
                  iconData: Icons.bar_chart_rounded,
                  iconColor: const Color(0xffFFC107),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Planned Subjects",
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

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: currentSemCourses.length,
              itemBuilder: (context, index) {
                final course = currentSemCourses[index];
                return CourseCard(
                  name: course['subjectName'],
                  credit: course['credits'],
                  grade: course['grade'],
                  gradeOptions: course['su_grade'] == true
                      ? gradePointsSU.keys.toList()
                      : gradePoints.keys.toList(),
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

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              height: 56,
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  goToEditAcademic();
                },
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: Colors.black87,
                ),
                label: const Text(
                  "Add Planned Course(s)",
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
                      backgroundColor: const Color(0xFFF5F5F5),
                    ).copyWith(
                      side: WidgetStateProperty.all(
                        const BorderSide(color: Colors.grey, width: 1),
                      ),
                    ),
              ),
            ),
          ),

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
                      "CURRENT GPA",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      currentGPA.toStringAsFixed(2),
                      style: const TextStyle(
                        color: Color(0xffB71C1C),
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
                      "CURRENT GPAX",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      currentGPAX.toStringAsFixed(2),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
