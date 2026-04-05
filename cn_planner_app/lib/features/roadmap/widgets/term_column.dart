import 'package:cn_planner_app/features/manage/views/manage_course_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cn_planner_app/features/roadmap/models/subject_model.dart';
import 'package:cn_planner_app/features/roadmap/widgets/subject_card.dart';
import 'package:cn_planner_app/features/roadmap/services/roadmap_service.dart';
import 'package:cn_planner_app/features/roadmap/services/validation_service.dart'; // 🔥 เพิ่ม
import '../views/roadmap_page.dart';
import 'package:cn_planner_app/features/manage/views/manage_course_page.dart';

class TermColumn extends StatefulWidget {
  final String title;
  final List<SubjectModel> allSubjects;
  final RoadmapMode mode;
  final Map<String, dynamic>? userProfile;
  final List<Map<String, dynamic>> initialCourses; // วิชาในเทอมนี้
  final List<Map<String, dynamic>>
  allPlanCourses; // 🔥 เพิ่ม: วิชาทั้งหมดในแผน (เพื่อเช็คตัวต่อข้ามเทอม)
  final VoidCallback onRefresh;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback? onDeleteYear;

  final Function(List<Map<String, dynamic>> result, int year, int term)?
  onAddPressed;
  final Function(dynamic id)? onDeletePressed;
  final Function(String subjectCode, String grade)? onGradeChangedPressed;

  const TermColumn({
    super.key,
    required this.title,
    required this.allSubjects,
    required this.mode,
    this.userProfile,
    required this.initialCourses,
    required this.allPlanCourses, // 🔥 ต้องส่งมาจากหน้า RoadmapPage
    required this.onRefresh,
    required this.isSelected,
    required this.onSelect,
    this.onAddPressed,
    this.onDeletePressed,
    this.onGradeChangedPressed,
    this.onDeleteYear,
  });

  @override
  State<TermColumn> createState() => _TermColumnState();
}

class _TermColumnState extends State<TermColumn> {
  final RoadmapService _roadmapService = RoadmapService();

  int getYear() => int.parse(widget.title.split(' ')[1]);
  int getTerm() => int.parse(widget.title.split(' ')[4]);

  double _calculateTotalCredits() {
    double total = 0;
    for (var course in widget.initialCourses) {
      final subject = widget.allSubjects.firstWhere(
        (s) => s.subjectCode == course['subject_code'],
        orElse: () => SubjectModel(
          subjectCode: '',
          subjectName: '',
          credits: 0,
          subjectId: 0,
        ),
      );
      total += subject.credits;
    }
    return total;
  }

  bool isPastOrCurrent() {
    if (widget.userProfile == null) return false;
    int curYear = widget.userProfile!['current_year'];
    int curTerm = widget.userProfile!['current_semester'];
    int colYear = getYear();
    int colTerm = getTerm();
    return (colYear < curYear) || (colYear == curYear && colTerm <= curTerm);
  }

  @override
  Widget build(BuildContext context) {
    bool showAddButton = false;
    if (widget.mode == RoadmapMode.simulate) {
      showAddButton = true;
    } else if (widget.mode == RoadmapMode.edit) {
      showAddButton = isPastOrCurrent();
    }

    double currentTotalCredits = _calculateTotalCredits();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 280,
      margin: const EdgeInsets.only(right: 20),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: widget.isSelected
            ? Colors.blue.withOpacity(0.02)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isSelected ? Colors.blue : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header ส่วนหัว
          GestureDetector(
            onTap: widget.onSelect,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: widget.isSelected ? Colors.blue : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Total: ${currentTotalCredits.toStringAsFixed(1)}/22.0 Cr.",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: currentTotalCredits > 22
                              ? Colors.red
                              : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.onDeleteYear != null)
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.delete_sweep,
                      color: Colors.redAccent,
                      size: 22,
                    ),
                    onPressed: widget.onDeleteYear,
                  ),
                if (widget.isSelected)
                  Container(
                    margin: const EdgeInsets.only(left: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text(
                      "Current",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // รายการวิชา (Scrollable)
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ...widget.initialCourses.map((data) {
                  final subject = widget.allSubjects.firstWhere(
                    (s) => s.subjectCode == data['subject_code'],
                    orElse: () => SubjectModel(
                      subjectCode: data['subject_code'],
                      subjectName: "Unknown",
                      credits: 0,
                      subjectId: 0,
                    ),
                  );

                  // 🔥 ตรวจสอบเงื่อนไขตัวต่อข้ามเทอม (ใช้ ValidationService)
                  final validation = ValidationService.validateCourse(
                    targetSubject: subject,
                    targetYear: data['year'],
                    targetSemester: data['semester'],
                    currentPlan: widget.allPlanCourses, // 🔥 เช็คกับทั้งแผน
                    allSubjects: widget.allSubjects,
                  );

                  return SubjectCard(
                    code: subject.subjectCode,
                    name: subject.subjectName,
                    credits: subject.credits.toInt(),
                    // 🔥 ถ้าไม่ผ่านเงื่อนไข ให้โชว์ missing_prereq
                    state: validation['isValid']
                        ? (data['status'] ?? "passed")
                        : "missing_prereq",
                    mode: widget.mode,
                    grade: data['grade'],
                    onGradeChanged: (newGrade) {
                      if (widget.mode == RoadmapMode.simulate ||
                          widget.mode == RoadmapMode.edit) {
                        widget.onGradeChangedPressed?.call(
                          subject.subjectCode,
                          newGrade,
                        );
                      }
                    },
                    onDelete: () {
                      if (widget.mode == RoadmapMode.simulate ||
                          widget.mode == RoadmapMode.edit) {
                        widget.onDeletePressed?.call(data['id']);
                      }
                    },
                  );
                }),

                const SizedBox(height: 8),

                if (showAddButton)
                  AddCourseButton(
                    onTap: () async {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) return;

                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ManageCoursePage(
                            targetTerm: getTerm(),
                            subjects: widget.allSubjects,

                            passedSubjects: widget.allPlanCourses
                                .where(
                                  (e) =>
                                      e['grade'] != null &&
                                      e['grade'] != 'F' &&
                                      e['grade'] != 'W',
                                )
                                .map((e) => e['subject_code'] as String)
                                .toList(),

                            alreadyAddedCodes: widget.allPlanCourses
                                .map((e) => e['subject_code'] as String)
                                .toList(),
                          ),
                        ),
                      );

                      if (result != null && result is List) {
                        for (var item in result) {
                          final subject = item['subject'];
                          final grade = item['grade'];
                          final section = item['section'];

                          if (widget.mode == RoadmapMode.simulate ||
                              widget.mode == RoadmapMode.edit) {
                            widget.onAddPressed?.call(
                              result.cast<Map<String, dynamic>>(),
                              getYear(),
                              getTerm(),
                            );
                          }
                        }
                      }
                    },
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
