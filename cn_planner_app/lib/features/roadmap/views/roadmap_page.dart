import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cn_planner_app/core/constants/app_colors.dart';
import '../widgets/progress_header.dart';
import '../widgets/term_column.dart';
import '../models/subject_model.dart';
import '../services/subject_service.dart';
import '../services/profile_service.dart';
import '../services/roadmap_service.dart';
// import '../services/validation_service.dart'; // 🔥 Import validation
import 'academic_history_page.dart';
import 'simulator_page.dart';
import '../../manage/views/manage_course_page.dart';
import 'package:cn_planner_app/services/send_grade.dart';

enum RoadmapMode { view, edit, simulate }

class RoadmapPage extends StatefulWidget {
  final RoadmapMode mode;
  final int initialTabIndex;

  const RoadmapPage({super.key, required this.mode, this.initialTabIndex = 0});

  @override
  State<RoadmapPage> createState() => _RoadmapPageState();
}

class _RoadmapPageState extends State<RoadmapPage> {
  final SubjectService _subjectService = SubjectService();
  final ProfileService _profileService = ProfileService();
  final RoadmapService _roadmapService = RoadmapService();

  int? selectedYear;
  int? selectedTerm;
  int maxYear = 4;

  List<SubjectModel> allSubjects = [];
  Map<String, dynamic>? userProfile;

  Map<String, double> gradeScheme = {
    'A': 4.0,
    'B+': 3.5,
    'B': 3.0,
    'C+': 2.5,
    'C': 2.0,
    'D+': 1.5,
    'D': 1.0,
    'F': 0.0,
  };

  double totalGradePoints = 0;
  double totalCredits = 0;
  double thisSemCredits = 0;
  double thisSemGradePoints = 0;

  List<Map<String, dynamic>> academicHistory = [];
  List<Map<String, dynamic>> editedHistory = [];
  List<Map<String, dynamic>> universityPlan = [];
  List<Map<String, dynamic>> simulatedPlan = [];
  List<String> getPassedSubjects(List<Map<String, dynamic>> plan) {
    return plan
        .where(
          (e) => e['grade'] != null && e['grade'] != 'F' && e['grade'] != 'W',
        )
        .map((e) => e['subject_code'] as String)
        .toList();
  }

  List<String> getAllSubjectCodes(List<Map<String, dynamic>> plan) {
    return plan.map((e) => e['subject_code'] as String).toList();
  }

  bool hasChanges = false;
  bool isLoading = true;

  double _calculateAllTotalCredits(List<Map<String, dynamic>> roadmapSource) {
    double total = 0;
    for (var item in roadmapSource) {
      // หาข้อมูลวิชาจาก allSubjects เพื่อดูหน่วยกิต
      final subject = allSubjects.firstWhere(
        (s) => s.subjectCode == item['subject_code'],
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

  @override
  void initState() {
    super.initState();
    loadAllData();
  }

  Future<void> loadAllData() async {
    setState(() => isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final subjects = await _subjectService.fetchSubjects();
        final profile = await _profileService.getProfile(user.uid);
        final history = await _roadmapService.getUserRoadmap(user.uid);

        setState(() {
          allSubjects = subjects;
          userProfile = profile;
          academicHistory = history;

          editedHistory = List<Map<String, dynamic>>.from(
            history.map(
              (e) => {
                ...Map<String, dynamic>.from(e),
                'section': e['section'] ?? '-', // ✅ กัน null
              },
            ),
          );

          maxYear = profile?['max_year'] ?? 4;

          simulatedPlan = [
            {
              'subject_code': 'CN101',
              'year': 1,
              'semester': 1,
              'status': 'passed',
            },
            {
              'subject_code': 'MA111',
              'year': 1,
              'semester': 1,
              'status': 'passed',
            },
            {
              'subject_code': 'CN201',
              'year': 1,
              'semester': 2,
              'status': 'planned',
            },
          ];

          // 🔥 Mock ข้อมูลแผนจำลอง (หรือดึงจาก DB simulated_plans ถ้ามี)
          // simulatedPlan = List<Map<String, dynamic>>.from(history);

          selectedYear = profile?['current_year'];
          selectedTerm = profile?['current_semester'];
          hasChanges = false;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading data: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void handleDeleteYear(int year) {
    if (year <= 4) return;
    setState(() {
      maxYear--;
      editedHistory.removeWhere((item) => item['year'] == year);
      hasChanges = true;
    });
  }

  Future<void> _confirmDeleteYear(int year) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Year $year?"),
        content: const Text(
          "All courses in this year will be removed from your current edits.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) handleDeleteYear(year);
  }

  Future<bool> _onWillPop() async {
    if (!hasChanges) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Discard Changes?"),
        content: const Text("You have unsaved changes. Leave without saving?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Stay"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Discard", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.redAccent,
          ),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await _onWillPop() && context.mounted) Navigator.pop(context);
      },
      child: widget.mode == RoadmapMode.edit
          ? _buildEditHistoryLayout()
          : _buildViewRoadmapLayout(),
    );
  }

  Widget _buildViewRoadmapLayout() {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text("Roadmap")),
      floatingActionButton: _buildViewFabs(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildTermList(simulatedPlan, isStatic: true),
    );
  }

  Widget _buildEditHistoryLayout() {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Edit Academic History"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            if (await _onWillPop()) Navigator.pop(context);
          },
        ),
      ),
      floatingActionButton: _buildSaveFab(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildTermList(simulatedPlan, isStatic: false),
    );
  }

  Widget _buildTermList(
    List<Map<String, dynamic>> roadmapSource, {
    bool isStatic = false,
  }) {
    final int termCount = isStatic ? 8 : maxYear * 2;
    final terms = List.generate(termCount, (index) {
      int year = (index ~/ 2) + 1;
      int term = (index % 2) + 1;
      return {"title": "Year $year / Term $term", "year": year, "term": term};
    });

    double allCredits = _calculateAllTotalCredits(roadmapSource);

    return Column(
      children: [
        ProgressHeader(currentCredits: allCredits),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...terms.map((term) {
                  final termCourses = roadmapSource
                      .where(
                        (item) =>
                            item['year'] == term['year'] &&
                            item['semester'] == term['term'],
                      )
                      .toList();

                  return TermColumn(
                    title: term["title"] as String,
                    allSubjects: allSubjects,
                    mode: widget.mode,
                    userProfile: userProfile,
                    initialCourses: termCourses,
                    allPlanCourses: editedHistory,

                    onRefresh: loadAllData,

                    isSelected:
                        selectedYear == term['year'] &&
                        selectedTerm == term['term'],

                    onSelect: () {
                      if (widget.mode == RoadmapMode.edit) {
                        setState(() {
                          selectedYear = term['year'] as int;
                          selectedTerm = term['term'] as int;
                          hasChanges = true;
                        });
                      }
                    },

                    onDeleteYear:
                        !isStatic &&
                            (term['year'] as int) > 4 &&
                            term['term'] == 2
                        ? () => _confirmDeleteYear(term['year'] as int)
                        : null,

                    /// 🔥 ADD COURSE (ใช้ Manage ใหม่)
                    onAddPressed: (result, year, termIdx) {
                      setState(() {
                        final isCurrentTerm =
                            year == userProfile?['current_year'] &&
                            termIdx == userProfile?['current_semester'];
                        // คำนวณจำนวนเครดิตปัจจุบันของเทอมนี้
                        double currentCredits = 0;
                        final termCourses = editedHistory.where(
                          (e) => e['year'] == year && e['semester'] == termIdx,
                        );
                        for (var item in termCourses) {
                          final subject = allSubjects.firstWhere(
                            (s) => s.subjectCode == item['subject_code'],
                            orElse: () => SubjectModel(
                              subjectCode: '',
                              subjectName: '',
                              credits: 0,
                              subjectId: 0,
                            ),
                          );
                          currentCredits += subject.credits;
                        }

                        // คำนวณเครดิตของวิชาที่กำลังจะเพิ่ม
                        double newCredits = 0;
                        for (var item in result) {
                          final subject = item['subject'] as SubjectModel;
                          newCredits += subject.credits;
                        }

                        // ตรวจสอบว่าเกิน 22 หน่วยกิตหรือไม่
                        if (currentCredits + newCredits > 22) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Cannot add courses: exceeding 22 credits per term.",
                              ),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                          return; // ❌ ไม่เพิ่มวิชา
                        }

                        // เพิ่มวิชาได้
                        for (var item in result) {
                          final subject = item['subject'] as SubjectModel;
                          final grade = item['grade'];
                          final section = item['section'];
                          if (isCurrentTerm &&
                              (section == null ||
                                  section == "-" ||
                                  section == "")) {
                            _showErrorDialog(
                              "Section Required",
                              "You must select a section for current semester courses.",
                            );
                            return; // ❌ หยุดทันที
                          }

                          final exists = editedHistory.any(
                            (e) =>
                                e['subject_code'] == subject.subjectCode &&
                                e['subjectId'] == subject.subjectId &&
                                e['year'] == year &&
                                e['semester'] == termIdx,
                          );
                          if (exists) continue;

                          editedHistory.add({
                            'id':
                                'temp_${DateTime.now().millisecondsSinceEpoch}_${subject.subjectCode}',
                            'subject_code': subject.subjectCode,
                            'subjectId': subject.subjectId,
                            'year': year,
                            'semester': termIdx,
                            'section': section ?? "-",
                            'status': (grade == null || grade == '-')
                                ? 'planned'
                                : (grade == 'F' || grade == 'W')
                                ? 'not_pass'
                                : 'passed',
                            'grade': grade ?? "-",
                          });
                        }
                        hasChanges = true;
                      });
                    },
                    onDeletePressed: (id) {
                      setState(() {
                        editedHistory.removeWhere((item) => item['id'] == id);
                        hasChanges = true;
                      });
                    },

                    onGradeChangedPressed: (code, grade) {
                      setState(() {
                        final idx = editedHistory.indexWhere(
                          (e) => e['subject_code'] == code,
                        );
                        if (idx != -1) {
                          editedHistory[idx]['grade'] = grade;
                          hasChanges = true;
                        }

                        if (grade == "-" || grade == "W" || grade == "F") {
                          editedHistory[idx]['status'] = (grade == "-")
                              ? 'planned'
                              : 'not_pass';
                        } else {
                          editedHistory[idx]['status'] = 'passed';
                        }
                      });
                    },
                  );
                }).toList(),
                if (!isStatic && widget.mode != RoadmapMode.view)
                  _buildAddYearButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddYearButton() {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(left: 10, top: 40),
      child: OutlinedButton.icon(
        onPressed: () => setState(() {
          maxYear++;
          hasChanges = true;
        }),
        icon: const Icon(Icons.add),
        label: const Text("Add Year"),
      ),
    );
  }

  // --- FABs ---
  Widget _buildViewFabs() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildFab(
          context,
          heroTag: "simBtn",
          text: "Simulator",
          icon: Icons.auto_awesome,
          bgColor: const Color(0xFFF5F9FF),
          fgColor: AppColors.primaryBlue,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SimulatorPage()),
          ).then((_) => loadAllData()),
        ),
        const SizedBox(height: 12),
        _buildFab(
          context,
          heroTag: "editBtn",
          text: "Academic History",
          icon: Icons.edit,
          bgColor: const Color(0xFFFFFBEE),
          fgColor: AppColors.accentYellow,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AcademicHistoryPage()),
          ).then((_) => loadAllData()),
        ),
      ],
    );
  }

  Widget _buildSaveFab() {
    return _buildFab(
      context,
      heroTag: "saveBtn",
      text: "Save",
      icon: Icons.check,
      bgColor: const Color(0XFFD1FAE5),
      fgColor: const Color(0XFF297505),
      onTap: handleSaveCurrentStatus,
    );
  }

  Widget _buildFab(
    BuildContext context, {
    required String heroTag,
    required String text,
    required IconData icon,
    required Color bgColor,
    required Color fgColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        heroTag: heroTag,
        elevation: 0,
        onPressed: onTap,
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        icon: Icon(icon, size: 20),
        label: Text(
          text,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        extendedPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 10,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  Future<void> handleSaveCurrentStatus() async {
    if (selectedYear == null || selectedTerm == null) return;
    bool? confirm = await _showConfirmDialog();
    if (confirm == true) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() => isLoading = true);
        try {
          print("calculating grade");
          for (var item in editedHistory) {
            String grade = item['grade'];

            if (!gradeScheme.containsKey(grade)) continue;

            final subject = allSubjects.firstWhere(
              (s) => s.subjectCode == item['subject_code'],
              orElse: () => SubjectModel(
                subjectCode: '',
                subjectName: '',
                credits: 0,
                subjectId: 0,
              ),
            );

            totalGradePoints += (gradeScheme[grade]! * subject.credits);
            totalCredits += subject.credits;

            if (item['year'] == selectedYear &&
                item['semester'] == selectedTerm) {
              thisSemGradePoints += (gradeScheme[grade]! * subject.credits);
              thisSemCredits += subject.credits;
            }
          }

          var gpax = totalCredits > 0 ? totalGradePoints / totalCredits : 0.0;
          var gpa = thisSemCredits > 0
              ? thisSemGradePoints / thisSemCredits
              : 0.0;

          await SendGrade.submitGPAX(gpax, totalCredits, gpa, thisSemCredits);

          await _profileService.updateStatus(
            user.uid,
            selectedYear!,
            selectedTerm!,
          );
          await _profileService.updateMaxYear(user.uid, maxYear);
          await _roadmapService.syncHistoryWithSupabase(
            user.uid,
            editedHistory,
          );
          await loadAllData();
          hasChanges = false;
          if (mounted) Navigator.pop(context);
        } catch (e) {
          debugPrint("Save error: $e");
          setState(() => isLoading = false);
        }
      }
    }
  }

  Future<bool?> _showConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Update"),
        content: const Text("Save all changes to your academic history?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }
}
