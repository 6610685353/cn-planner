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

class SimulatorPage extends StatefulWidget {
  const SimulatorPage({super.key});

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
  bool _isLoading = true; // loading initial data from Supabase
  bool _isSimulating = false; // running simulate call
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

  // ─── Load from Supabase ───────────────────────────────────────────────────

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final loaded = await CurriculumData.loadFromSupabase();
      final savedPlan = await SimulatorService.loadSimulationPlan();

      setState(() {
        _terms = loaded.terms;
        _catalogByCode = loaded.catalogByCode;
        _refreshTermStatuses(); // ทำก่อน เพื่อ set status ให้ถูกต้อง

        // Apply saved outcomes หลัง _refreshTermStatuses()
        // เพื่อไม่ให้ถูก override กลับเป็น fail
        if (savedPlan.isNotEmpty) {
          for (final term in _terms) {
            for (var i = 0; i < term.courses.length; i++) {
              final course = term.courses[i];
              final savedOutcome = savedPlan[course.code];
              if (savedOutcome != null) {
                term.courses[i] = course.copyWith(outcome: savedOutcome);
              }
            }
          }
        }

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
        _showInfo('Failed to load data: $e', backgroundColor: Colors.red);
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

  int _termOrder(TermModel term) => (term.year - 1) * 2 + term.term;

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
    final missing = <String>[];
    for (final preId in course.prerequisites) {
      final passed = _terms.any(
        (term) => term.courses.any(
          (c) => c.code == preId && c.outcome == CourseOutcome.pass,
        ),
      );
      if (!passed) missing.add(preId);
    }
    return missing;
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
        final nextOutcome =
            term.status == TermStatus.current &&
                course.outcome == CourseOutcome.notSet
            ? CourseOutcome.fail
            : course.outcome;
        term.courses[j] = course.copyWith(
          status: courseStatus,
          outcome: nextOutcome,
        );
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

  void _enforceYear4TrackRules() {
    final y4t1Index = _findTermIndex(4, 1);
    final y4t2Index = _findTermIndex(4, 2);
    if (y4t1Index == -1 || y4t2Index == -1) return;

    final y4t1 = _terms[y4t1Index];
    final y4t2 = _terms[y4t2Index];
    final selectedStarts = y4t1.courses
        .where((course) => _year4TrackPairs.containsKey(course.code))
        .toList();

    if (selectedStarts.isEmpty) {
      y4t2.courses.removeWhere(
        (course) => _year4TrackPairs.values.contains(course.code),
      );
      return;
    }

    final chosenStart = selectedStarts.last;
    for (final other in selectedStarts.take(selectedStarts.length - 1)) {
      y4t1.courses.removeWhere((course) => course.code == other.code);
    }

    y4t2.courses.removeWhere(
      (course) => _year4TrackPairs.values.contains(course.code),
    );

    final pairedCode = _year4TrackPairs[chosenStart.code]!;
    final pairedCourse = _copyForTerm(_catalogCourse(pairedCode), y4t2);
    y4t2.courses.insert(0, pairedCourse);

    if (chosenStart.code == 'CN403') {
      y4t2.courses.removeWhere((course) => course.code != 'CN404');
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
              'Co-op track allows only CN404 in Year 4 / Term 2.',
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
          builder: (_) => ImpactAnalysisPage(terms: _terms, result: result),
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
        floatingActionButton: _isLoading ? null : _buildSimulateButton(),
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
              Text(
                CurriculumData.programName,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const Spacer(),
          // Reload button
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.grey),
            tooltip: 'Reload from Supabase',
            onPressed: _isSimulating ? null : _loadData,
          ),
        ],
      ),
    );
  }

  Widget _buildTermContent(TermModel term, int termIndex) {
    return ListView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
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
            isEditable: true,
            onOutcomeChanged: (outcome) =>
                _onOutcomeChanged(termIndex, entry.key, outcome),
          );
        }),
        const SizedBox(height: 8),
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

  Widget _buildSimulateButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: _isSimulating ? null : _onSimulate,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isSimulating)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF1565C0),
                    ),
                  )
                else
                  const Icon(
                    Icons.settings_rounded,
                    size: 18,
                    color: Color(0xFF1565C0),
                  ),
                const SizedBox(width: 7),
                Text(
                  _isSimulating ? 'Analyzing...' : 'Simulate',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1565C0),
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
