import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'package:cn_planner_app/route.dart';

class GPACalculatorPage extends StatefulWidget {
  const GPACalculatorPage({super.key});

  @override
  State<GPACalculatorPage> createState() => _GPACalculatorPageState();
}

class _GPACalculatorPageState extends State<GPACalculatorPage> {
  // --- Data & State ---

  // 1. Mock Data Integration
  final Map<String, dynamic> mockData = {
    "user": {
      "1": {
        "username": "A",
        "year": 2,
        "enrolled": ["CN201"],
        "pass": [
          {"code": "CN101", "grade": "B+"},
          {"code": "MA111", "grade": "A"},
        ],
      },
    },
    "subject": {
      "MA111": {"credits": 3.0},
      "CN101": {"credits": 3.0},
      "CN201": {"credits": 4.0},
    },
  };

  final Map<String, double> gradePoints = {
    "A": 4.0,
    "B+": 3.5,
    "B": 3.0,
    "C+": 2.5,
    "C": 2.0,
    "D+": 1.5,
    "D": 1.0,
    "F": 0.0,
  };

  List<Map<String, dynamic>> currentSemesterCourses = [];

  double currentGPA = 0.00;
  double predictedGPA = 0.00;

  // Accumulated data from past semesters
  double pastTotalPoints = 0.0;
  double pastTotalCredits = 0.0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    // Navigate mock data structure for User "1"
    final user = mockData['user']['1'];
    final subjects = mockData['subject'];

    // 1. Calculate Current GPA from 'pass' list
    List passList = user['pass'] ?? [];
    double tempPoints = 0.0;
    double tempCredits = 0.0;

    for (var item in passList) {
      String code = item['code'];
      String grade = item['grade'];

      // Get credits from subject map or default to 3.0
      double credit = (subjects[code] != null)
          ? subjects[code]['credits']
          : 3.0;
      double point = gradePoints[grade] ?? 0.0;

      tempPoints += (point * credit);
      tempCredits += credit;
    }

    // Set accumulated stats
    pastTotalPoints = tempPoints;
    pastTotalCredits = tempCredits;

    // Calculate initial current GPA
    if (pastTotalCredits > 0) {
      currentGPA = pastTotalPoints / pastTotalCredits;
      predictedGPA = currentGPA; // Initial prediction matches current
    }

    // 2. Load 'enrolled' courses for the current semester
    List enrolledList = user['enrolled'] ?? [];
    for (var code in enrolledList) {
      double credit = (subjects[code] != null)
          ? subjects[code]['credits']
          : 3.0;
      // Add to list with default grade 'A'
      currentSemesterCourses.add({
        "code": code,
        "name": "Subject $code", // Using code as placeholder name
        "credit": credit,
        "grade": "A",
      });
    }
  }

  // --- Logic ---

  void _addNewCourse(String name, double credit) {
    setState(() {
      currentSemesterCourses.add({
        "code": name, // Using name as code for manually added subjects
        "name": name,
        "credit": credit,
        "grade": "A",
      });
    });
  }

  void _updateCourseGrade(int index, String newGrade) {
    setState(() {
      currentSemesterCourses[index]['grade'] = newGrade;
      // Note: We DO NOT calculate GPA here, only update the state.
    });
  }

  void _calculatePrediction() {
    double semesterPoints = 0.0;
    double semesterCredits = 0.0;

    for (var course in currentSemesterCourses) {
      double point = gradePoints[course['grade']] ?? 0.0;
      double credit = course['credit'];

      semesterPoints += (point * credit);
      semesterCredits += credit;
    }

    double totalPoints = pastTotalPoints + semesterPoints;
    double totalCredits = pastTotalCredits + semesterCredits;

    setState(() {
      if (totalCredits > 0) {
        predictedGPA = totalPoints / totalCredits;
      } else {
        predictedGPA = 0.0; // Should handle 0 credits appropriately
      }
    });
  }

  void _showAddCourseDialog() {
    String name = "";
    String creditStr = "3.0";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Add New Course"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: "Subject Name/Code",
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => name = v,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: "Credits",
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (v) => creditStr = v,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.black54),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (name.isNotEmpty) {
                  final credit = double.tryParse(creditStr) ?? 3.0;
                  _addNewCourse(name, credit);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _deleteCourse(int index) {
    setState(() {
      currentSemesterCourses.removeAt(index);
      // Not recalculating GPA automatically, matching the requirement.
    });
  }

  // --- UI Construction ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors
          .white, // Match design background or AppColors.background if suitable
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
          // 1. Top Cards Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _StatCard(
                  title: "Target GPA",
                  value: "3.95",
                  textColor: const Color(0xffB71C1C), // Deep Red
                  iconData: Icons.stars_rounded,
                  iconColor: const Color(0xffB71C1C),
                ),
                const SizedBox(width: 16),
                _StatCard(
                  title:
                      "Estimated", // Assuming "Estimated" refers to current standing or prediction
                  value: "3.45", // Mock value or use currentGPA
                  textColor: const Color(0xffFFC107), // Amber/Yellow
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
                    color: const Color(0xFFE3F2FD), // Light Blue
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${currentSemesterCourses.length} courses",
                    style: const TextStyle(
                      color: Color(0xFF1976D2), // Blue
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
              itemCount: currentSemesterCourses.length,
              itemBuilder: (context, index) {
                final course = currentSemesterCourses[index];
                return _CourseCard(
                  name: course['name'],
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
                        style: BorderStyle
                            .none, // Can't do native dashed border easily in flutter without custom paint, using solid grey for now to be safe, or stick to provided request instructions strictly if possible.
                        // To do a dashed border properly requires `DottedBorder` package or `CustomPainter`.
                        // I will replicate the "style" with a specific visual if possible, otherwise solid grey border.
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

          // Custom Dashed Border workaround (Optional polish):
          // Since OutlinedButton doesn't support dashed border out of the box, users usually use DottedBorder or CustomPainter.
          // I'll stick to a standard OutlinedButton with grey border as the next best native thing for now.

          // 5. Bottom Result Bar
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

// --- Private Widgets (Refactored) ---

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color textColor;
  final IconData iconData;
  final Color iconColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.textColor,
    required this.iconData,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 120, // Check height usage
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(
            0xFFFFFBE6,
          ), // Light Yellowish bg for both? Or distinct?
          // The image shows white cards actually. Let's use White with specific styles.
          // Wait, the design description said "White cards with shadow".
          gradient: const LinearGradient(
            colors: [Colors.white, Colors.white], // Just white
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(iconData, size: 20, color: iconColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: iconColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Swipe to Reveal Helper ---
class _SwipeToReveal extends StatefulWidget {
  final Widget child;
  final Widget action;
  final VoidCallback onAction;
  final double actionWidth = 80.0;

  const _SwipeToReveal({
    required this.child,
    required this.action,
    required this.onAction,
  });

  @override
  State<_SwipeToReveal> createState() => _SwipeToRevealState();
}

class _SwipeToRevealState extends State<_SwipeToReveal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _dragExtent = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragExtent += details.primaryDelta!;
      if (_dragExtent > 0) _dragExtent = 0; // Prevent swipe right
      if (_dragExtent < -widget.actionWidth * 1.5) {
        _dragExtent = -widget.actionWidth * 1.5; // Limit overscroll
      }
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_dragExtent < -widget.actionWidth / 2) {
      // Snap open
      _animateTo(-widget.actionWidth);
    } else {
      // Snap close
      _animateTo(0.0);
    }
  }

  void _animateTo(double target) {
    final start = _dragExtent;
    // Simple animation loop using controller value as a progress ticker
    // Actually, let's just use a Tweener or simple setState for simplicity in this context
    // or use the controller to drive value.
    // For simplicity in a single-file widget without external deps:

    Animation<double> animation = Tween<double>(
      begin: start,
      end: target,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.reset();
    animation.addListener(() {
      setState(() {
        _dragExtent = animation.value;
      });
    });
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background (Action)
        Positioned.fill(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  // Close then act
                  _animateTo(0.0);
                  widget.onAction();
                },
                child: Container(
                  width: widget.actionWidth,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xffB71C1C),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(
                    bottom: 12,
                  ), // Same margin as card
                  child: widget.action,
                ),
              ),
            ],
          ),
        ),
        // Foreground (Child)
        GestureDetector(
          onHorizontalDragUpdate: _handleDragUpdate,
          onHorizontalDragEnd: _handleDragEnd,
          child: Transform.translate(
            offset: Offset(_dragExtent, 0),
            child: widget.child,
          ),
        ),
      ],
    );
  }
}

class _CourseCard extends StatelessWidget {
  final String name;
  final double credit;
  final String grade;
  final List<String> gradeOptions;
  final ValueChanged<String?> onGradeChanged;
  final VoidCallback onDelete;

  const _CourseCard({
    required this.name,
    required this.credit,
    required this.grade,
    required this.gradeOptions,
    required this.onGradeChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // The inner card content
    Widget cardContent = Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween, // Remove this since we have Expanded
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD), // Light Blue
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${credit.toStringAsFixed(0)} Credits", // e.g. "3 Credits"
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF1976D2), // Blue
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Grade Column (Centered)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Centered alignment
              children: [
                const Text(
                  "GRADE",
                  style: TextStyle(
                    color: Color(0xFF1976D2),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                DropdownButton<String>(
                  value: grade,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.black54,
                  ),
                  underline: const SizedBox(), // Remove underline
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black87,
                  ),
                  items: gradeOptions.map((g) {
                    return DropdownMenuItem(value: g, child: Text(g));
                  }).toList(),
                  onChanged: onGradeChanged,
                ),
              ],
            ),
          ),

          // Removed standard Delete Button
        ],
      ),
    );

    return _SwipeToReveal(
      action: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete_outline, color: Colors.white, size: 28),
          SizedBox(height: 4),
          Text(
            "Delete",
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      onAction: onDelete,
      child: cardContent,
    );
  }
}
