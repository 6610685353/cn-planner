import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/curriculum_data.dart';
import '../models/course_model.dart';
import '../models/term_model.dart';
import '../widgets/add_drop_course_widget.dart';
import '../widgets/course_card_widget.dart';
import '../widgets/progress_header_widget.dart';
import '../widgets/term_status_badge.dart';
import '../widgets/term_tab_widget.dart';
import '../services/simulator_service.dart';
import '../../impact_analysis/screens/impact_analysis_screen.dart';
import '../../roadmap/views/roadmap_page.dart';

class SimulatorPage extends StatefulWidget {
  final String? initialPlanType;
  const SimulatorPage({super.key, this.initialPlanType});

  @override
  State<SimulatorPage> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends State<SimulatorPage> {
  static const Map<String, String> _year4TrackPairs = {
    'CN401': 'CN402',
    'CN403': 'CN404',
    'CN472': 'CN473',
  };

  List<TermModel> _terms = [];
  Map<String, CourseModel> _catalogByCode = {};
  int _selectedTermIndex = 0;
  bool _isLoading = true;
  bool _isSimulating = false;
  bool _isSaving = false;
  bool _hasSavedPlan = false;
  String _currentPlanType = 'Internship';
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ─── Load Data ────────────────────────────────────────────────────────────
  // [#1 FIX] เช็ค saved plan เฉพาะ plan_type ที่ตรงกับที่เลือก
  //          ถ้า plan_type นี้ยังไม่มีใน DB → โหลด static template ของ plan นั้น
  //          ถ้ามีแล้ว → โหลด template ของ plan นั้น แล้ว override outcomes จาก DB

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final planType = widget.initialPlanType ?? 'Internship';
      _currentPlanType = planType;

      // [#1 FIX] เช็ค saved plan เฉพาะ plan_type นี้
      final hasSaved = await SimulatorService.hasSavedPlanForType(planType);

      // โหลด static template ของ plan นี้เสมอ
      final loaded = await CurriculumData.loadFromStaticData(
        planType: planType,
      );

      setState(() {
        _terms = loaded.terms;
        _catalogByCode = loaded.catalogByCode;
        _hasSavedPlan = hasSaved;
        _refreshTermStatuses();
      });

      // ถ้ามี saved plan → restore วิชาที่ add เพิ่ม + override outcomes
      if (hasSaved) {
        final saved = await SimulatorService.loadSimulationPlanWithType(
          planType,
        );
        // [#1 FIX] ดึง full row list เพื่อ restore วิชาที่ add เพิ่มไม่อยู่ใน template
        final simRows = await SimulatorService.loadAsRoadmapPlan(planType);

        setState(() {
          // 1) Override outcomes สำหรับวิชาที่มีอยู่ใน template (current/upcoming เท่านั้น)
          for (final term in _terms) {
            if (term.status == TermStatus.passed) continue;
            for (var i = 0; i < term.courses.length; i++) {
              final course = term.courses[i];
              final savedOutcome = saved.outcomes[course.code];
              if (savedOutcome != null) {
                term.courses[i] = course.copyWith(outcome: savedOutcome);
              }
            }
          }

          // 2) [Fix #1 & #3] Restore วิชาที่ add เพิ่มมา (ทั้ง current และ upcoming)
          // key ด้วย code+year+semester รองรับวิชาซ้ำต่างเทอม
          final existingKeys = _terms
              .expand(
                (t) => t.courses.map((c) => '${c.code}|${t.year}|${t.term}'),
              )
              .toSet();

          for (final row in simRows) {
            final code = row['subject_code'] as String? ?? '';
            final rowYear = row['year'] as int? ?? 1;
            final rowSem = row['semester'] as int? ?? 1;
            final rowKey = '$code|$rowYear|$rowSem';
            if (code.isEmpty || existingKeys.contains(rowKey)) continue;

            final termIdx = _terms.indexWhere(
              (t) => t.year == rowYear && t.term == rowSem,
            );
            if (termIdx == -1) continue;

            final term = _terms[termIdx];
            final simStatus = row['sim_status'] as String?;
            final CourseOutcome outcome;
            if (simStatus == null) {
              outcome = CourseOutcome.notSet;
            } else {
              outcome = saved.outcomes[code] ?? CourseOutcome.notSet;
            }

            term.courses.add(
              CourseModel(
                code: code,
                name: row['subject_name'] as String? ?? code,
                credits: (row['credit'] as int?) ?? 0,
                status: _courseStatusForTerm(term.status),
                outcome: outcome,
                subjectId: null,
              ),
            );
            existingKeys.add(rowKey);
          }
        });
      }

      setState(() {
        _selectedTermIndex = _indexOfCurrentTerm();
        _isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _pageController.jumpToPage(_selectedTermIndex);
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showInfo('Failed to load: $e', backgroundColor: Colors.red);
      }
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  int get _totalEarnedCredits => _terms.fold(
    0,
    (sum, term) =>
        sum +
        term.courses
            .where((c) => c.outcome == CourseOutcome.pass)
            .fold(0, (s, c) => s + c.credits),
  );

  int _indexOfCurrentTerm() {
    final index = _terms.indexWhere((t) => t.status == TermStatus.current);
    return index == -1 ? 0 : index;
  }

  int _termOrder(TermModel term) => (term.year - 1) * 10 + term.term;

  int _findTermIndex(int year, int term) =>
      _terms.indexWhere((t) => t.year == year && t.term == term);

  CourseStatus _courseStatusForTerm(TermStatus status) {
    switch (status) {
      case TermStatus.passed:
        return CourseStatus.passed;
      case TermStatus.current:
        return CourseStatus.current;
      case TermStatus.upcoming:
        return CourseStatus.upcoming;
    }
  }

  CourseModel _catalogCourse(String code) {
    final course = _catalogByCode[code];
    if (course != null) return course;
    return CourseModel(code: code, name: code, credits: 0);
  }

  CourseModel _copyForTerm(CourseModel course, TermModel term) {
    return CourseModel(
      code: course.code,
      name: course.name,
      credits: course.credits,
      prerequisites: course.prerequisites,
      availableTerms: course.availableTerms,
      isCustom: course.isCustom,
      schedule: course.schedule,
      category: course.category,
      subjectId: course.subjectId,
      status: _courseStatusForTerm(term.status),
      outcome: course.outcome,
      grade: course.grade,
    );
  }

  List<String> _missingPrereqs(CourseModel course) {
    return course.prerequisites
        .where(
          (preId) => !_terms.any(
            (term) => term.courses.any(
              (c) => c.code == preId && c.outcome == CourseOutcome.pass,
            ),
          ),
        )
        .toList();
  }

  void _selectTerm(int index) {
    setState(() => _selectedTermIndex = index);
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    }
  }

  void _refreshTermStatuses() {
    _terms.sort((a, b) => _termOrder(a).compareTo(_termOrder(b)));

    int currentIndex = _terms.indexWhere(
      (term) => term.status == TermStatus.current,
    );
    if (currentIndex == -1) {
      currentIndex = _terms.indexWhere((term) => !term.allPassed);
      if (currentIndex == -1 && _terms.isNotEmpty) {
        currentIndex = _terms.length - 1;
      }
    }

    for (var i = 0; i < _terms.length; i++) {
      final term = _terms[i];
      final newStatus = i < currentIndex
          ? TermStatus.passed
          : i == currentIndex
          ? TermStatus.current
          : TermStatus.upcoming;
      term.status = newStatus;
      for (var j = 0; j < term.courses.length; j++) {
        final course = term.courses[j];
        final courseStatus = _courseStatusForTerm(newStatus);
        term.courses[j] = course.copyWith(status: courseStatus);
      }
    }

    if (_selectedTermIndex >= _terms.length) {
      _selectedTermIndex = _terms.isEmpty ? 0 : _terms.length - 1;
    }
  }

  void _showInfo(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ─── Year 4 track rules ───────────────────────────────────────────────────

  void _enforceYear4TrackRules() {
    final y4t1Index = _findTermIndex(4, 1);
    final y4t2Index = _findTermIndex(4, 2);
    if (y4t1Index == -1 || y4t2Index == -1) return;

    final y4t1 = _terms[y4t1Index];
    final y4t2 = _terms[y4t2Index];
    final selectedStarts = y4t1.courses
        .where((c) => _year4TrackPairs.containsKey(c.code))
        .toList();

    if (selectedStarts.isEmpty) {
      y4t2.courses.removeWhere((c) => _year4TrackPairs.values.contains(c.code));
      return;
    }
    final chosenStart = selectedStarts.last;
    for (final other in selectedStarts.take(selectedStarts.length - 1)) {
      y4t1.courses.removeWhere((c) => c.code == other.code);
    }
    y4t2.courses.removeWhere((c) => _year4TrackPairs.values.contains(c.code));
    final pairedCode = _year4TrackPairs[chosenStart.code]!;
    final pairedCourse = _copyForTerm(_catalogCourse(pairedCode), y4t2);
    y4t2.courses.insert(0, pairedCourse);
    if (chosenStart.code == 'CN403') {
      y4t2.courses.removeWhere((c) => c.code != 'CN404');
    }
  }

  bool _canAddCourseToCoopTerm2(int termIndex, CourseModel course) {
    final term = _terms[termIndex];
    final y4t1Index = _findTermIndex(4, 1);
    if (term.year != 4 || term.term != 2 || y4t1Index == -1) return true;
    final coopSelected = _terms[y4t1Index].courses.any(
      (c) => c.code == 'CN403',
    );
    if (!coopSelected) return true;
    return course.code == 'CN404';
  }

  void _applyActionsToTerm(int termIndex, List<AddDropAction> actions) {
    final blockedMessages = <String>[];
    setState(() {
      final term = _terms[termIndex];
      for (final action in actions) {
        if (action.isAdd) {
          if (!_canAddCourseToCoopTerm2(termIndex, action.course)) {
            blockedMessages.add(
              'Co-op track: only CN404 is allowed in Year 4 / Term 2.',
            );
            continue;
          }
          if (!term.courses.any((c) => c.code == action.course.code)) {
            term.courses.add(_copyForTerm(action.course, term));
          }
        } else {
          term.courses.removeWhere((c) => c.code == action.course.code);
        }
      }
      _enforceYear4TrackRules();
      _refreshTermStatuses();
    });
    if (blockedMessages.isNotEmpty && mounted) {
      _showInfo(blockedMessages.first, backgroundColor: Colors.orange.shade700);
    }
  }

  void _addNextYear() {
    final lastYear = _terms.isEmpty ? 4 : _terms.last.year;
    if (lastYear >= CurriculumData.maxSupportedYear) return;
    setState(() {
      _terms.addAll(CurriculumData.getEmptyYearTerms(lastYear + 1));
      _refreshTermStatuses();
      _selectedTermIndex = _terms.length - 2;
    });
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _selectTerm(_selectedTermIndex),
    );
  }

  void _removeLastYear() {
    if (_terms.isEmpty || _terms.last.year < 5) return;
    final yearToRemove = _terms.last.year;
    setState(() {
      _terms.removeWhere((term) => term.year == yearToRemove);
      _refreshTermStatuses();
      _selectedTermIndex = _terms.length - 1;
    });
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _selectTerm(_selectedTermIndex),
    );
  }

  void _onOutcomeChanged(int termIdx, int courseIdx, CourseOutcome outcome) {
    HapticFeedback.lightImpact();
    final term = _terms[termIdx];
    final course = term.courses[courseIdx];

    // เทอม passed → ไม่ให้เปลี่ยน
    if (term.status == TermStatus.passed) return;

    if (outcome == CourseOutcome.pass) {
      final missing = _missingPrereqs(course);
      if (missing.isNotEmpty) {
        _showInfo(
          'Cannot mark ${course.code} as pass. Missing prerequisites: ${missing.join(", ")}.',
          backgroundColor: const Color(0xFFEF4444),
        );
        return;
      }
    }

    setState(() {
      term.courses[courseIdx] = course.copyWith(outcome: outcome);
      _refreshTermStatuses();
    });
  }

  // ─── Save Plan ────────────────────────────────────────────────────────────

  Future<void> _onSavePlan() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Save'),
        content: const Text('Save this simulation plan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _isSaving = true);
    try {
      await SimulatorService.saveSimulation(
        terms: _terms,
        planType: _currentPlanType,
      );
      setState(() {
        _hasSavedPlan = true;
        _isSaving = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Plan saved successfully!'),
          backgroundColor: Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      // Navigator.pushAndRemoveUntil(
      //   context,
      //   MaterialPageRoute(
      //     builder: (_) => const RoadmapPage(mode: RoadmapMode.view),
      //   ),
      //   (route) => false,
      // );
      Navigator.pop(context);
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        _showInfo('Error saving: $e', backgroundColor: Colors.red);
      }
    }
  }

  // ─── Simulate ─────────────────────────────────────────────────────────────

  Future<void> _onSimulate() async {
    HapticFeedback.mediumImpact();
    setState(() => _isSimulating = true);
    try {
      final result = await SimulatorService.simulate(_terms);
      if (!mounted) return;
      setState(() => _isSimulating = false);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ImpactAnalysisPage(
            terms: _terms,
            result: result,
            planType: _currentPlanType,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSimulating = false);
      _showInfo('Error: $e', backgroundColor: Colors.red);
    }
  }

  bool _canShowAddYearButton(int termIndex) {
    final term = _terms[termIndex];
    return term.term == 2 &&
        termIndex == _terms.length - 1 &&
        term.year < CurriculumData.maxSupportedYear;
  }

  bool _canShowRemoveYearButton(int termIndex) {
    final term = _terms[termIndex];
    return term.term == 2 && termIndex == _terms.length - 1 && term.year >= 5;
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAppBar(),
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: Color(0xFFF0F0F0),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
                          child: ProgressHeaderWidget(
                            earnedCredits: _totalEarnedCredits,
                            totalCredits: CurriculumData.totalProgramCredits,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: TermTabWidget(
                            terms: _terms,
                            selectedIndex: _selectedTermIndex,
                            onChanged: _selectTerm,
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _terms.length,
                        onPageChanged: (index) =>
                            setState(() => _selectedTermIndex = index),
                        itemBuilder: (context, index) =>
                            _buildTermContent(_terms[index], index),
                      ),
                    ),
                  ],
                ),
        ),
        floatingActionButton: _isLoading ? null : _buildFabGroup(),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
            onPressed: () => Navigator.maybePop(context),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Simulator',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              Row(
                children: [
                  Text(
                    CurriculumData.programName,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      border: Border.all(color: const Color(0xFF90CAF9)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _currentPlanType,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF1565C0),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (_hasSavedPlan) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        border: Border.all(color: Colors.green.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Saved',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.grey),
            tooltip: 'Reload',
            onPressed: (_isSimulating || _isSaving) ? null : _loadData,
          ),
        ],
      ),
    );
  }

  Widget _buildTermContent(TermModel term, int termIndex) {
    final isCurrentOrPassed = term.status != TermStatus.upcoming;
    return ListView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      children: [
        Row(
          children: [
            Text(
              term.label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            TermStatusBadge(status: term.status),
          ],
        ),
        const SizedBox(height: 14),
        ...term.courses.asMap().entries.map((entry) {
          return CourseCardWidget(
            course: entry.value,
            isEditable: isCurrentOrPassed,
            onOutcomeChanged: isCurrentOrPassed
                ? (outcome) => _onOutcomeChanged(termIndex, entry.key, outcome)
                : null,
          );
        }),
        const SizedBox(height: 8),
        // Add/Drop: เปิดทั้ง current และ upcoming (upcoming แสดง Pending Enrollment)
        if (term.status == TermStatus.current ||
            term.status == TermStatus.upcoming)
          AddDropCourseWidget(
            currentYear: term.year,
            currentTerm: term.term,
            currentCourses: term.courses,
            catalog: _catalogByCode,
            onConfirm: (actions) => _applyActionsToTerm(termIndex, actions),
          ),
        if (_canShowAddYearButton(termIndex) ||
            _canShowRemoveYearButton(termIndex))
          const SizedBox(height: 12),
        if (_canShowAddYearButton(termIndex))
          OutlinedButton.icon(
            onPressed: _addNextYear,
            icon: const Icon(Icons.add_circle_outline_rounded),
            label: Text('Add Year ${term.year + 1}'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        if (_canShowRemoveYearButton(termIndex)) ...[
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _removeLastYear,
            icon: const Icon(Icons.delete_outline_rounded),
            label: Text('Remove Year ${term.year}'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              foregroundColor: Colors.red.shade700,
              side: BorderSide(color: Colors.red.shade200),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFabGroup() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildFabButton(
          label: _isSaving ? 'Saving...' : 'Save Plan',
          icon: _isSaving
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.green.shade700,
                  ),
                )
              : Icon(
                  Icons.save_rounded,
                  size: 18,
                  color: Colors.green.shade700,
                ),
          color: Colors.green.shade50,
          textColor: Colors.green.shade700,
          borderColor: Colors.green.shade300,
          onTap: (_isSimulating || _isSaving) ? null : _onSavePlan,
        ),
        const SizedBox(height: 10),
        _buildFabButton(
          label: _isSimulating ? 'Analyzing...' : 'Simulate',
          icon: _isSimulating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF1565C0),
                  ),
                )
              : const Icon(
                  Icons.settings_rounded,
                  size: 18,
                  color: Color(0xFF1565C0),
                ),
          color: Colors.white,
          textColor: const Color(0xFF1565C0),
          borderColor: const Color(0xFFBBDEFB),
          onTap: (_isSimulating || _isSaving) ? null : _onSimulate,
        ),
      ],
    );
  }

  Widget _buildFabButton({
    required String label,
    required Widget icon,
    required Color color,
    required Color textColor,
    Color? borderColor,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
        border: borderColor != null
            ? Border.all(color: borderColor, width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                const SizedBox(width: 7),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
