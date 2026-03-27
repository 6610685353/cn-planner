import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cn_planner_app/core/constants/app_colors.dart';
import '../widgets/progress_header.dart';
import '../widgets/term_column.dart';
import '../models/subject_model.dart';
import '../services/subject_service.dart';
import '../services/profile_service.dart';
import '../services/roadmap_service.dart';
import '../services/validation_service.dart'; // 🔥 Import validation
import 'academic_history_page.dart';
import 'simulator_page.dart';

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

  List<Map<String, dynamic>> academicHistory = [];
  List<Map<String, dynamic>> editedHistory = [];
  List<Map<String, dynamic>> universityPlan = [];
  List<Map<String, dynamic>> simulatedPlan = [];

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
            history.map((e) => Map<String, dynamic>.from(e)),
          );

          maxYear = profile?['max_year'] ?? 4;

          universityPlan = [
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
          simulatedPlan = List<Map<String, dynamic>>.from(history);

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
    return DefaultTabController(
      length: 2,
      initialIndex: widget.initialTabIndex,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text("Roadmap"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "University Plan"),
              Tab(text: "My Saved Plan"),
            ],
          ),
        ),
        floatingActionButton: _buildViewFabs(),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildTermList(universityPlan, isStatic: true),
                  _buildTermList(simulatedPlan, isStatic: false),
                ],
              ),
      ),
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
          : _buildTermList(editedHistory, isStatic: false),
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
                    onAddPressed: (subject, year, termIdx) {
                      // 🔥 เช็คหน่วยกิตก่อนแอด
                      double currentCredits =
                          ValidationService.calculateTotalCredits(
                            termCourses,
                            allSubjects,
                          );
                      if (currentCredits + subject.credits > 22) {
                        _showErrorDialog(
                          "Credits Exceeded",
                          "This term's total credits will exceed 22.0 limit.",
                        );
                        return;
                      }

                      // 🔥 เช็คตัวต่อ (Validation)
                      final validation = ValidationService.validateCourse(
                        targetSubject: subject,
                        targetYear: year,
                        targetSemester: termIdx,
                        currentPlan: editedHistory,
                        allSubjects: allSubjects,
                      );

                      if (validation['isValid']) {
                        setState(() {
                          editedHistory.add({
                            'id':
                                'temp_${DateTime.now().millisecondsSinceEpoch}',
                            'subject_code': subject.subjectCode,
                            'year': year,
                            'semester': termIdx,
                            'status': 'passed',
                            'grade': null,
                          });
                          hasChanges = true;
                        });
                      } else {
                        String msg = "";
                        if (validation['isWrongSemester'])
                          msg +=
                              "• This course is not offered in Term $termIdx\n";
                        if (validation['missingRequire'].isNotEmpty)
                          msg +=
                              "• Missing Prerequisite: ${validation['missingRequire'].join(', ')}\n";
                        if (validation['missingCoreq'].isNotEmpty)
                          msg +=
                              "• Missing Corequisite: ${validation['missingCoreq'].join(', ')}";
                        _showErrorDialog("Ineligible Course", msg);
                      }
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
