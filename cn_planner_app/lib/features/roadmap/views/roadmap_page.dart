import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cn_planner_app/core/constants/app_colors.dart';
import '../widgets/progress_header.dart';
import '../widgets/term_column.dart';
import '../models/subject_model.dart';
import '../services/subject_service.dart';
import '../services/profile_service.dart';
import '../services/roadmap_service.dart';
import 'academic_history_page.dart';
import '../../simulator/screens/simulator_screen.dart';
import 'package:cn_planner_app/services/send_grade.dart';
import '../data/static_roamap_data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../simulator/services/simulator_service.dart';

enum RoadmapMode { view, edit, simulate, history }

class RoadmapPage extends StatefulWidget {
  final RoadmapMode mode;
  final int initialTabIndex;

  const RoadmapPage({super.key, required this.mode, this.initialTabIndex = 0});

  @override
  State<RoadmapPage> createState() => _RoadmapPageState();
}

class _RoadmapPageState extends State<RoadmapPage>
    with SingleTickerProviderStateMixin {
  final SubjectService _subjectService = SubjectService();
  final ProfileService _profileService = ProfileService();
  final RoadmapService _roadmapService = RoadmapService();

  bool _isAlreadyNoti = false;

  late TabController _tabController;
  final ScrollController _horizontalScrollController = ScrollController();
  String selectedPlanType = RoadmapTemplate.PLAN_INTERNSHIP;

  int? selectedYear;
  int? selectedTerm;
  int maxYear = 4;

  List<SubjectModel> allSubjects = [];
  Map<String, dynamic>? userProfile;

  Map<String, double> gradeScheme = {
    'S': 4.0,
    'A': 4.0,
    'B+': 3.5,
    'B': 3.0,
    'C+': 2.5,
    'C': 2.0,
    'D+': 1.5,
    'D': 1.0,
    'F': 0.0,
    'U': 0.0,
  };

  double totalGradePoints = 0;
  double totalCredits = 0;
  double thisSemCredits = 0;
  double thisSemGradePoints = 0;

  List<Map<String, dynamic>> academicHistory = [];
  List<Map<String, dynamic>> editedHistory = [];
  List<Map<String, dynamic>> roadmapPlan = [];
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
      final subject = allSubjects.firstWhere(
        (s) => s.subjectCode == item['subject_code'],
        orElse: () => SubjectModel(
          subjectCode: '',
          subjectName: '',
          credits: 0,
          subjectId: 0,
          su_grade: false,
        ),
      );
      total += subject.credits;
    }
    return total;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
    loadAllData();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (!_tabController.indexIsChanging) return;

    String newPlan;
    switch (_tabController.index) {
      case 1:
        newPlan = RoadmapTemplate.PLAN_COOP;
        break;
      case 2:
        newPlan = RoadmapTemplate.PLAN_RESEARCH;
        break;
      default:
        newPlan = RoadmapTemplate.PLAN_INTERNSHIP;
    }
    if (newPlan == selectedPlanType) return;

    setState(() {
      selectedPlanType = newPlan;
      simulatedPlan = [];
      _buildRoadmapData();
    });

    _loadSimulatorPlan();
  }

  void _buildRoadmapData() {
    final template = RoadmapTemplate.getTemplate();

    final filteredTemplate = template.where((item) {
      return item['plan'] == 'all' || item['plan'] == selectedPlanType;
    }).toList();

    roadmapPlan = filteredTemplate.map((item) {
      String code = item['subject_code'];
      String displayName = "";

      if (code.contains('X')) {
        displayName = item['subject_name'] ?? "Elective Course";
      } else {
        try {
          final match = allSubjects.firstWhere((s) => s.subjectCode == code);
          displayName = match.subjectName;
        } catch (e) {
          displayName = item['subject_name'] ?? code;
        }
      }

      final historyItem = academicHistory.firstWhere(
        (h) => h['subject_code'] == code,
        orElse: () => {},
      );

      return {
        ...item,
        'subject_name': displayName,
        'status': historyItem.isNotEmpty ? 'passed' : 'planned',
        'grade': historyItem['grade'] ?? '-',
      };
    }).toList();
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
                'section': e['section'] ?? '-',
              },
            ),
          );

          maxYear = profile?['max_year'] ?? 4;

          String userPlan =
              profile?['plan_type'] ?? RoadmapTemplate.PLAN_INTERNSHIP;
          selectedPlanType = userPlan;
          if (userPlan == RoadmapTemplate.PLAN_COOP) _tabController.index = 1;
          if (userPlan == RoadmapTemplate.PLAN_RESEARCH) {
            _tabController.index = 2;
          }

          _buildRoadmapData();

          simulatedPlan = List<Map<String, dynamic>>.from(history);

          selectedYear = profile?['current_year'];
          selectedTerm = profile?['current_semester'];
          hasChanges = false;
          isLoading = false;
        });

        await _loadSimulatorPlan();
        _scrollToCurrentTerm();
      }
    } catch (e) {
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _scrollToCurrentTerm() {
    if (selectedYear == null || selectedTerm == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_horizontalScrollController.hasClients) return;

      const double termWidth = 300.0;
      const double padding = 16.0;

      final List<Map<String, int>> terms = [];
      for (int y = 1; y <= maxYear; y++) {
        terms.add({"year": y, "term": 1});
        terms.add({"year": y, "term": 2});
        final roadmapSource = simulatedPlan.isNotEmpty
            ? simulatedPlan
            : roadmapPlan;
        if (roadmapSource.any((e) => e['year'] == y && e['semester'] == 3)) {
          terms.add({"year": y, "term": 3});
        }
      }

      final idx = terms.indexWhere(
        (t) => t['year'] == selectedYear && t['term'] == selectedTerm,
      );
      if (idx < 0) return;

      final targetOffset = (idx * termWidth) + padding;
      final maxOffset = _horizontalScrollController.position.maxScrollExtent;

      _horizontalScrollController.animateTo(
        targetOffset.clamp(0.0, maxOffset),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _loadSimulatorPlan() async {
    try {
      final hasSaved = await SimulatorService.hasSavedPlanForType(
        selectedPlanType,
      );
      if (!hasSaved) {
        setState(() {
          simulatedPlan = [];
        });
        return;
      }

      final simRows = await SimulatorService.loadAsRoadmapPlan(
        selectedPlanType,
      );
      if (simRows.isEmpty) {
        setState(() {
          simulatedPlan = [];
        });
        return;
      }

      final simByKey = <String, Map<String, dynamic>>{};
      for (final row in simRows) {
        final key = '${row['subject_code']}|${row['year']}|${row['semester']}';
        simByKey[key] = row;
      }

      final failedCodes = simRows
          .where((r) => r['sim_status'] == 'fail')
          .map((r) => r['subject_code'] as String)
          .toSet();

      final merged = roadmapPlan.map((item) {
        final code = item['subject_code'] as String;
        final year = item['year'];
        final sem = item['semester'];
        final simRow = simByKey['$code|$year|$sem'];
        if (simRow != null) {
          return {
            ...item,
            'status': simRow['sim_status'] == 'fail' ? 'failed' : 'passed',
            'grade': simRow['grade'],
            'sim_status': simRow['sim_status'],
          };
        }

        return item;
      }).toList();

      for (final simRow in simRows) {
        final code = simRow['subject_code'] as String;
        final year = simRow['year'];
        final sem = simRow['semester'];
        final alreadyIn = merged.any(
          (m) =>
              m['subject_code'] == code &&
              m['year'] == year &&
              m['semester'] == sem,
        );
        if (!alreadyIn) {
          final rowSimStatus = simRow['sim_status'] as String?;
          merged.add({
            ...simRow,
            'status': rowSimStatus == null
                ? 'planned'
                : rowSimStatus == 'fail'
                ? 'failed'
                : 'passed',
          });
        }
      }

      final expandedFailed = Set<String>.from(failedCodes);
      bool changed = true;
      while (changed) {
        changed = false;
        for (final subject in allSubjects) {
          if (expandedFailed.contains(subject.subjectCode)) continue;
          final hasFailedPrereq =
              subject.require?.any((req) => expandedFailed.contains(req)) ??
              false;
          if (hasFailedPrereq) {
            expandedFailed.add(subject.subjectCode);
            changed = true;
          }
        }
      }

      final finalPlan = merged.map((item) {
        final code = item['subject_code'] as String;
        if (item['sim_status'] == 'fail') return item;

        if (expandedFailed.contains(code)) {
          return {
            ...item,
            'status': 'failed',
            'sim_status': 'fail',
            'is_blocked_by_fail': true,
          };
        }
        return item;
      }).toList();

      setState(() {
        simulatedPlan = finalPlan;
      });
    } catch (e) {
      setState(() {
        simulatedPlan = [];
      });
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
      child:
          widget.mode == RoadmapMode.edit || widget.mode == RoadmapMode.history
          ? _buildEditHistoryLayout()
          : _buildViewRoadmapLayout(),
    );
  }

  Widget _buildSelectionHint() {
    if (widget.mode != RoadmapMode.edit) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              "Tip: Tap on a Year/Semester title to set it as your current term.",
              style: TextStyle(
                fontSize: 12,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewRoadmapLayout() {
    bool canPop = ModalRoute.of(context)?.canPop ?? false;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: canPop,
        leading: canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.maybePop(context),
              )
            : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'ROADMAP',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            Text(
              'Computer Engineering',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primaryBlue,
          tabs: const [
            Tab(text: "Project"),
            Tab(text: "Coop"),
            Tab(text: "Research"),
          ],
        ),
      ),
      floatingActionButton: _buildViewFabs(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildTermList(
              simulatedPlan.isNotEmpty ? simulatedPlan : roadmapPlan,
              isStatic: false,
            ),
    );
  }

  Widget _buildEditHistoryLayout() {
    bool canPop = ModalRoute.of(context)?.canPop ?? false;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: canPop,
        leading: canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.maybePop(context),
              )
            : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'EDIT ACADEMIC HISTORY',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            Text(
              'Computer Engineering',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
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
    required bool isStatic,
  }) {
    final List<Map<String, int>> terms = [];
    int loopMaxYear = isStatic ? 4 : maxYear;

    for (int y = 1; y <= loopMaxYear; y++) {
      terms.add({"year": y, "term": 1});
      terms.add({"year": y, "term": 2});
      if (roadmapSource.any((e) => e['year'] == y && e['semester'] == 3)) {
        terms.add({"year": y, "term": 3});
      }
    }

    double allCredits;

    if (widget.mode == RoadmapMode.edit) {
      allCredits = _calculateAllTotalCredits(editedHistory);
    } else {
      allCredits = _calculateAllTotalCredits(academicHistory);
    }

    return Column(
      children: [
        ProgressHeader(currentCredits: allCredits),

        _buildSelectionHint(),

        Expanded(
          child: SingleChildScrollView(
            controller: _horizontalScrollController,
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
                    title:
                        "Year ${term['year']} / ${term['term'] == 3 ? 'Summer' : 'Term ${term['term']}'}",
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
                          selectedYear = term['year'];
                          selectedTerm = term['term'];
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

                    onAddPressed: (result, year, termIdx) {
                      _isAlreadyNoti = false;
                      final isCurrentTerm =
                          year == userProfile?['current_year'] &&
                          termIdx == userProfile?['current_semester'];

                      final existingInTerm = editedHistory
                          .where(
                            (e) =>
                                e['year'] == year && e['semester'] == termIdx,
                          )
                          .toList();

                      final toAdd = result.where((item) {
                        final subject = item['subject'] as SubjectModel;
                        return !existingInTerm.any(
                          (e) =>
                              e['subject_code'] == subject.subjectCode &&
                              e['subjectId'] == subject.subjectId,
                        );
                      }).toList();

                      if (toAdd.isEmpty) return;

                      final existingCredits = existingInTerm.fold<double>(0, (
                        sum,
                        item,
                      ) {
                        final subject = allSubjects.firstWhere(
                          (s) => s.subjectCode == item['subject_code'],
                          orElse: () => SubjectModel(
                            subjectCode: '',
                            subjectName: '',
                            credits: 0,
                            subjectId: 0,
                            su_grade: false,
                          ),
                        );
                        return sum + subject.credits;
                      });

                      final addingCredits = toAdd.fold<double>(
                        0,
                        (sum, item) =>
                            sum + (item['subject'] as SubjectModel).credits,
                      );

                      if (existingCredits + addingCredits > 22) {
                        if (!_isAlreadyNoti) {
                          _isAlreadyNoti = true;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Cannot add: total would be ${(existingCredits + addingCredits).toStringAsFixed(1)} credits (max 22).",
                              ),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                        return;
                      }

                      if (isCurrentTerm) {
                        final missSection = toAdd.any((item) {
                          final section = item['section'];
                          return section == null ||
                              section == "-" ||
                              section == "";
                        });
                        if (missSection) {
                          _showErrorDialog(
                            "Section Required",
                            "You must select a section for current semester courses.",
                          );
                          return;
                        }
                      }

                      setState(() {
                        for (var item in toAdd) {
                          final subject = item['subject'] as SubjectModel;
                          final grade = item['grade'];
                          final section = item['section'];

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
                }),
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
    return GestureDetector(
      onTap: () => setState(() {
        maxYear++;
        hasChanges = true;
      }),
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(left: 10, top: 40),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              color: Colors.grey.shade500,
              size: 26,
            ),
            const SizedBox(height: 6),
            Text(
              "Add Year",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
          onTap: () {
            String currentPlan;
            switch (_tabController.index) {
              case 1:
                currentPlan = RoadmapTemplate.PLAN_COOP;
                break;
              case 2:
                currentPlan = RoadmapTemplate.PLAN_RESEARCH;
                break;
              default:
                currentPlan = RoadmapTemplate.PLAN_INTERNSHIP;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SimulatorPage(
                  initialPlanType: currentPlan,
                  initialRoadmapData: simulatedPlan.isNotEmpty
                      ? simulatedPlan
                      : roadmapPlan,
                ),
              ),
            ).then((_) => loadAllData());
          },
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
            color: Colors.black.withValues(alpha: 0.1),
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
          totalGradePoints = 0;
          totalCredits = 0;
          thisSemCredits = 0;
          thisSemGradePoints = 0;

          for (var item in editedHistory) {
            String grade = item['grade'] ?? '-';

            if (!gradeScheme.containsKey(grade)) continue;

            final subject = allSubjects.firstWhere(
              (s) => s.subjectCode == item['subject_code'],
              orElse: () => SubjectModel(
                subjectCode: '',
                subjectName: '',
                credits: 0,
                subjectId: 0,
                su_grade: false,
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

          final supabase = Supabase.instance.client;
          final electives = await supabase
              .from('UserElectives')
              .select('credits, grade')
              .eq('user_id', user.uid);

          for (var elective in electives) {
            String grade = elective['grade'] ?? '-';
            if (!gradeScheme.containsKey(grade)) continue;

            int creds = (elective['credits'] as num?)?.toInt() ?? 0;
            totalGradePoints += (gradeScheme[grade]! * creds);
            totalCredits += creds;
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
