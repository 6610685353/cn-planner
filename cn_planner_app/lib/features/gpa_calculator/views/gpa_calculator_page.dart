import 'package:flutter/material.dart';
import '../../manage/views/manage_course_page.dart';
import '../controllers/gpa_calculator_controller.dart';
import 'widgets/gpa_stat_card.dart';
import 'widgets/gpa_course_card.dart';

class GPACalculatorPage extends StatefulWidget {
  const GPACalculatorPage({super.key});

  @override
  State<GPACalculatorPage> createState() => _GPACalculatorPageState();
}

class _GPACalculatorPageState extends State<GPACalculatorPage> {
  final GPACalculatorController _controller = GPACalculatorController();

  @override
  void initState() {
    super.initState();
    _controller.fetchInitialData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _navigateToManageCourses() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManageCoursePage(
          // Target term doesn't matter too much for sandbox, but passing 1 as default unless we expose term
          targetTerm: 1,
          subjects: _controller.allSubjects,
          passedSubjects: _controller.passedSubjects,
          alreadyAddedCodes: _controller.currentSemesterCourses
              .map((c) => c.code)
              .toList(),
        ),
      ),
    );

    if (result != null && result is List<dynamic>) {
      _controller.addCoursesFromManage(result);
    }
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
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // 1. Top Cards Row
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    GPAStatCard(
                      title: "Target GPA",
                      value: "3.95", // Mock or from settings if added later
                      textColor: const Color(0xffB71C1C),
                      iconData: Icons.stars_rounded,
                      iconColor: const Color(0xffB71C1C),
                    ),
                    const SizedBox(width: 16),
                    GPAStatCard(
                      title: "Current",
                      value: _controller.currentGPA.toStringAsFixed(2),
                      textColor: const Color(0xffFFC107),
                      iconData: Icons.bar_chart_rounded,
                      iconColor: const Color(0xffFFC107),
                    ),
                  ],
                ),
              ),

              // 2. Section Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Sandbox Courses",
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
                        "${_controller.currentSemesterCourses.length} courses",
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

              // 3. Course List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _controller.currentSemesterCourses.length,
                  itemBuilder: (context, index) {
                    final course = _controller.currentSemesterCourses[index];
                    return GPACourseCard(
                      code: course.code,
                      name: course.name,
                      credit: course.credits,
                      grade: course.grade,
                      gradeOptions: _controller.gradePoints.keys.toList(),
                      onGradeChanged: (newGrade) {
                        if (newGrade != null) {
                          _controller.updateCourseGrade(index, newGrade);
                        }
                      },
                      onDelete: () {
                        _controller.deleteCourse(index);
                      },
                    );
                  },
                ),
              ),

              // 4. Manage Courses Button (Dashed equivalent)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _navigateToManageCourses,
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: Colors.black87,
                    ),
                    label: const Text(
                      "Add Course",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    style:
                        OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey, width: 1),
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

              // 5. Bottom Result Bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
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
                          "PREDICTED GPAX",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _controller.predictedGPAX.toStringAsFixed(2),
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
                          "PREDICTED GPA",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _controller.predictedGPA.toStringAsFixed(2),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: _controller.calculatePrediction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffB71C1C),
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
          );
        },
      ),
    );
  }
}
