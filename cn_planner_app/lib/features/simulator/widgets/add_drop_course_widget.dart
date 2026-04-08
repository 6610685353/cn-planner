import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/course_model.dart';
import '../models/curriculum_data.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AddDropAction model (commented code)
// ─────────────────────────────────────────────────────────────────────────────
class AddDropAction {
  final CourseModel course;
  final bool isAdd; // true = Add, false = Drop
  final int targetYear;
  final int targetTerm;

  const AddDropAction({
    required this.course,
    required this.isAdd,
    required this.targetYear,
    required this.targetTerm,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// AddDropCourseWidget - Main Button to open sheet
// ─────────────────────────────────────────────────────────────────────────────
class AddDropCourseWidget extends StatefulWidget {
  final int currentYear;
  final int currentTerm;
  final List<CourseModel> currentCourses;
  final void Function(List<AddDropAction> actions)? onConfirm;

  /// Catalog of all available courses — passed from simulator_screen
  final Map<String, CourseModel> catalog;

  const AddDropCourseWidget({
    super.key,
    required this.currentYear,
    required this.currentTerm,
    required this.currentCourses,
    required this.catalog,
    this.onConfirm,
  });

  @override
  State<AddDropCourseWidget> createState() => _AddDropCourseWidgetState();
}

class _AddDropCourseWidgetState extends State<AddDropCourseWidget> {
  final List<AddDropAction> _pendingActions = [];

  void _showSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddDropSheet(
        currentYear: widget.currentYear,
        currentTerm: widget.currentTerm,
        initialEnrolledCourses: widget.currentCourses,
        catalog: widget.catalog,
        existingActions: List.from(_pendingActions),
        onConfirm: (actions) {
          setState(() {
            _pendingActions.clear();
            _pendingActions.addAll(actions);
          });
          widget.onConfirm?.call(_pendingActions);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showSheet,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(top: 4, bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add_circle_outline_rounded,
              size: 28,
              color: Color(0xFF9CA3AF),
            ),
            SizedBox(height: 8),
            Text(
              'Tap to Add or Drop courses',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────
class _AddDropSheet extends StatefulWidget {
  final int currentYear;
  final int currentTerm;
  final List<CourseModel> initialEnrolledCourses;
  final List<AddDropAction> existingActions;
  final void Function(List<AddDropAction>) onConfirm;

  /// Catalog of all available courses
  final Map<String, CourseModel> catalog;

  const _AddDropSheet({
    required this.currentYear,
    required this.currentTerm,
    required this.initialEnrolledCourses,
    required this.existingActions,
    required this.catalog,
    required this.onConfirm,
  });

  @override
  State<_AddDropSheet> createState() => _AddDropSheetState();
}

class _AddDropSheetState extends State<_AddDropSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<AddDropAction> _tempActions = [];

  // Tab 1
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Tab 2
  final _codeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _creditsCtrl = TextEditingController();

  // Custom Course Category
  final List<String> _courseCategories = [
    'Major Elective',
    'Free Elective',
    'General Education',
  ];
  late String _selectedCategory;

  String? _codeError;
  final List<_TimeSlotEntry> _timeSlots = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tempActions.addAll(widget.existingActions);
    _selectedCategory = _courseCategories[1]; // Default to Free Elective
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _creditsCtrl.dispose();
    super.dispose();
  }

  bool _isPending(String code, bool isAdd) {
    return _tempActions.any((a) => a.course.code == code && a.isAdd == isAdd);
  }

  void _toggleAction(CourseModel course, bool isAdd) {
    setState(() {
      int idx = _tempActions.indexWhere((a) => a.course.code == course.code);
      if (idx != -1) {
        _tempActions.removeAt(idx);
      } else {
        _tempActions.add(
          AddDropAction(
            course: course,
            isAdd: isAdd,
            targetYear: widget.currentYear,
            targetTerm: widget.currentTerm,
          ),
        );
      }
    });
  }

  void _removeAction(String code) {
    setState(() => _tempActions.removeWhere((a) => a.course.code == code));
  }

  void _submitCustom() {
    final code = _codeCtrl.text.trim().toUpperCase();
    final credits = int.tryParse(_creditsCtrl.text.trim());
    setState(() {
      _codeError = code.isEmpty ? 'Please enter a course code.' : null;
    });
    if (code.isEmpty || credits == null) return;

    final slots = _timeSlots
        .where((s) => s.isValid)
        .map((s) => TimeSlot(day: s.day, start: s.start, end: s.end))
        .toList();

    final finalName = _nameCtrl.text.trim().isEmpty
        ? code
        : _nameCtrl.text.trim();

    final custom = CourseModel(
      code: code,
      name: finalName,
      credits: credits,
      availableTerms: [1, 2],
      isCustom: true,
      schedule: slots,
      category: _selectedCategory,
    );

    setState(() {
      _tempActions.removeWhere((a) => a.course.code == custom.code);
      _tempActions.add(
        AddDropAction(
          course: custom,
          isAdd: true,
          targetYear: widget.currentYear,
          targetTerm: widget.currentTerm,
        ),
      );
    });

    _codeCtrl.clear();
    _nameCtrl.clear();
    _creditsCtrl.clear();
    setState(() => _timeSlots.clear());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$code added to simulation changes.'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final thisTermCourses = widget.initialEnrolledCourses.where((c) {
      final matchSearch =
          c.code.contains(_searchQuery.toUpperCase()) ||
          c.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchSearch;
    }).toList();

    final allAvailable = widget.catalog.values.toList();
    final otherCourses = allAvailable.where((c) {
      final isAlreadyInTerm = widget.initialEnrolledCourses.any(
        (e) => e.code == c.code,
      );
      final matchSearch =
          c.code.contains(_searchQuery.toUpperCase()) ||
          c.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return !isAlreadyInTerm && matchSearch;
    }).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      maxChildSize: 0.96,
      minChildSize: 0.5,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF9FAFB),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ), // Softer sheet edge
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Manage Curriculum',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Year ${widget.currentYear} / Term ${widget.currentTerm}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB).withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(14), // Softer tab bar
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: const Color(0xFF111827),
                unselectedLabelColor: const Color(0xFF6B7280),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(text: 'Curriculum'),
                  Tab(text: 'Custom Course'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // ── Tab 1: Curriculum ──────────────────────────────────────────────
                  ListView(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      TextField(
                        controller: _searchController,
                        onChanged: (v) => setState(() => _searchQuery = v),
                        decoration: InputDecoration(
                          hintText: "Search course code or name...",
                          hintStyle: const TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: Color(0xFF6B7280),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFF6366F1),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),

                      // SECTION 1: THIS TERM
                      _buildSectionHeader(
                        title: "ENROLLED THIS TERM",
                        subtitle: "Courses currently in your schedule",
                        icon: Icons.calendar_month_rounded,
                        color: const Color(0xFF3B82F6),
                        bgColor: const Color(0xFFEFF6FF),
                      ),
                      if (thisTermCourses.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: Text(
                              "No courses found in this term.",
                              style: TextStyle(color: Color(0xFF9CA3AF)),
                            ),
                          ),
                        ),
                      ...thisTermCourses.map(
                        (c) => _buildCourseCard(c, isEnrolled: true),
                      ),

                      const SizedBox(height: 16),

                      // SECTION 2: ADD COURSE
                      _buildSectionHeader(
                        title: "AVAILABLE COURSES",
                        subtitle: "Add new courses to your schedule",
                        icon: Icons.library_add_rounded,
                        color: const Color(0xFF10B981),
                        bgColor: const Color(0xFFECFDF5),
                      ),
                      if (otherCourses.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: Text(
                              "No more courses available to add.",
                              style: TextStyle(color: Color(0xFF9CA3AF)),
                            ),
                          ),
                        ),
                      ...otherCourses.map(
                        (c) => _buildCourseCard(c, isEnrolled: false),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),

                  // ── Tab 2: Custom Course ───────────────────────────────────────────
                  ListView(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      _CustomCourseForm(
                        codeCtrl: _codeCtrl,
                        nameCtrl: _nameCtrl,
                        creditsCtrl: _creditsCtrl,
                        codeError: _codeError,
                        categories: _courseCategories,
                        selectedCategory: _selectedCategory,
                        onCategoryChanged: (val) {
                          setState(() {
                            _selectedCategory = val!;
                          });
                        },
                        timeSlots: _timeSlots,
                        onSubmit: _submitCustom,
                        onTimeSlotsChanged: () => setState(() {}),
                      ),
                      const SizedBox(height: 24),
                      _PendingList(
                        actions: _tempActions,
                        onRemove: _removeAction,
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ],
              ),
            ),

            // ── Bottom Confirm Bar ───────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _tempActions.isEmpty
                      ? null
                      : () {
                          widget.onConfirm(_tempActions);
                          Navigator.pop(context);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    disabledBackgroundColor: const Color(0xFFE5E7EB),
                    foregroundColor: Colors.white,
                    disabledForegroundColor: const Color(0xFF9CA3AF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18), // Softer button
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 0,
                  ),
                  child: Text(
                    _tempActions.isEmpty
                        ? 'Confirm (No changes)'
                        : 'Confirm ${_tempActions.length} change${_tempActions.length > 1 ? "s" : ""}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 24, bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: color.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(CourseModel course, {required bool isEnrolled}) {
    final bool isPendingDrop = _isPending(course.code, false);
    final bool isPendingAdd = _isPending(course.code, true);

    Color cardColor = Colors.white;
    Color borderColor = const Color(0xFFF3F4F6);

    if (isPendingDrop) {
      cardColor = const Color(0xFFFEF2F2);
      borderColor = const Color(0xFFFECACA);
    } else if (isPendingAdd) {
      cardColor = const Color(0xFFECFDF5);
      borderColor = const Color(0xFFA7F3D0);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20), // Softer card edges
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        course.code,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${course.credits} CR',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    course.name,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            isEnrolled
                ? IconButton(
                    // เปลี่ยนไอคอนลบให้เป็นสีแดงชัดเจนตรงนี้
                    icon: Icon(
                      isPendingDrop
                          ? Icons.settings_backup_restore_rounded
                          : Icons.remove_circle_rounded,
                      color: isPendingDrop
                          ? const Color(0xFF6B7280)
                          : const Color(0xFFEF4444),
                      size: 28,
                    ),
                    onPressed: () => _toggleAction(course, false), // Drop
                    tooltip: isPendingDrop ? 'Undo Drop' : 'Drop Course',
                  )
                : IconButton(
                    icon: Icon(
                      isPendingAdd
                          ? Icons.settings_backup_restore_rounded
                          : Icons.add_circle_rounded,
                      color: isPendingAdd
                          ? const Color(0xFF6B7280)
                          : const Color(0xFF6366F1),
                      size: 28,
                    ),
                    onPressed: () => _toggleAction(course, true), // Add
                    tooltip: isPendingAdd ? 'Undo Add' : 'Add Course',
                  ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Time Slot Model
// ─────────────────────────────────────────────────────────────────────────────
class _TimeSlotEntry {
  String day;
  String start;
  String end;

  _TimeSlotEntry({this.day = 'Mon', this.start = '09:00', this.end = '12:00'});

  bool get isValid => start.isNotEmpty && end.isNotEmpty;
}

// ─────────────────────────────────────────────────────────────────────────────
// CustomCourseForm
// ─────────────────────────────────────────────────────────────────────────────
class _CustomCourseForm extends StatelessWidget {
  final TextEditingController codeCtrl;
  final TextEditingController nameCtrl;
  final TextEditingController creditsCtrl;
  final String? codeError;
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String?> onCategoryChanged;
  final List<_TimeSlotEntry> timeSlots;
  final VoidCallback onSubmit;
  final VoidCallback onTimeSlotsChanged;

  const _CustomCourseForm({
    required this.codeCtrl,
    required this.nameCtrl,
    required this.creditsCtrl,
    this.codeError,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.timeSlots,
    required this.onSubmit,
    required this.onTimeSlotsChanged,
  });

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20), // Softer corners
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _field(
                'Course Code *',
                codeCtrl,
                error: codeError,
                hint: 'e.g., CN499',
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                ],
              ),
              const SizedBox(height: 16),
              _field('Course Name', nameCtrl, hint: 'e.g., Special Topics'),
              const SizedBox(height: 16),
              // Category Dropdown
              const Text(
                'Course Category',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF9CA3AF),
                    ),
                    items: categories
                        .map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Text(
                              c,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: onCategoryChanged,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _field(
                'Credits *',
                creditsCtrl,
                hint: '3',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // ── Time slots ─────────────────────
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.access_time_filled_rounded,
                size: 18,
                color: Color(0xFF6366F1),
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Class Schedule',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                Text(
                  'Optional conflict checking',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
              ],
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                timeSlots.add(_TimeSlotEntry());
                onTimeSlotsChanged();
              },
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Time'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF6366F1),
                backgroundColor: const Color(0xFF6366F1).withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        ...timeSlots.asMap().entries.map((entry) {
          final i = entry.key;
          final slot = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.01),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Period ${i + 1}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        timeSlots.removeAt(i);
                        onTimeSlotsChanged();
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    // แก้ไขพื้นที่ของ Day ให้กว้างขึ้น และลด Padding เพื่อไม่ให้ข้อความตกบรรทัด
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Day',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                            ), // ลด padding ซ้ายขวา
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: slot.day,
                                isExpanded: true, // บังคับให้ใช้พื้นที่เต็ม
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Color(0xFF9CA3AF),
                                ),
                                items: _days
                                    .map(
                                      (d) => DropdownMenuItem(
                                        value: d,
                                        child: Text(
                                          d,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null) {
                                    slot.day = v;
                                    onTimeSlotsChanged();
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Start Time',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 6),
                          _TimeSelector(
                            time: slot.start,
                            onChanged: (v) {
                              slot.start = v;
                              onTimeSlotsChanged();
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'End Time',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 6),
                          _TimeSelector(
                            time: slot.end,
                            onChanged: (v) {
                              slot.end = v;
                              onTimeSlotsChanged();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onSubmit,
            icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
            label: const Text('Confirm & Add to Simulation'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl, {
    String? hint,
    String? error,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textCapitalization: TextCapitalization.characters,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontWeight: FontWeight.w400,
            ),
            errorText: error,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF6366F1),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// iOS Style Time Selector Widget
// ─────────────────────────────────────────────────────────────────────────────
class _TimeSelector extends StatelessWidget {
  final String time;
  final ValueChanged<String> onChanged;

  const _TimeSelector({required this.time, required this.onChanged});

  void _showPicker(BuildContext context) {
    int hour = 9;
    int minute = 0;
    if (time.isNotEmpty && time.contains(':')) {
      final parts = time.split(':');
      hour = int.tryParse(parts[0]) ?? 9;
      minute = int.tryParse(parts[1]) ?? 0;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext builderContext) {
        return SizedBox(
          height: 280,
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Color(0xFF9CA3AF)),
                      ),
                      onPressed: () => Navigator.of(builderContext).pop(),
                    ),
                    const Text(
                      'Select Time',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    CupertinoButton(
                      child: const Text(
                        'Done',
                        style: TextStyle(color: Color(0xFF6366F1)),
                      ),
                      onPressed: () => Navigator.of(builderContext).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: true,
                  initialDateTime: DateTime(2022, 1, 1, hour, minute),
                  onDateTimeChanged: (DateTime newDateTime) {
                    final h = newDateTime.hour.toString().padLeft(2, '0');
                    final m = newDateTime.minute.toString().padLeft(2, '0');
                    onChanged('$h:$m');
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              time.isEmpty ? '00:00' : time,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const Icon(
              Icons.access_time_rounded,
              size: 16,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PendingList
// ─────────────────────────────────────────────────────────────────────────────
class _PendingList extends StatelessWidget {
  final List<AddDropAction> actions;
  final ValueChanged<String> onRemove;
  const _PendingList({required this.actions, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.history_rounded,
              size: 20,
              color: Color(0xFF374151),
            ),
            const SizedBox(width: 8),
            const Text(
              'Pending Changes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${actions.length} items',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4B5563),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...actions.map(
          (a) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: a.isAdd
                    ? const Color(0xFF10B981)
                    : const Color(0xFFEF4444),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: a.isAdd
                        ? const Color(0xFFECFDF5)
                        : const Color(0xFFFEF2F2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    a.isAdd ? Icons.add_rounded : Icons.remove_rounded,
                    size: 20,
                    color: a.isAdd
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${a.course.code} – ${a.course.name}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${a.course.credits} Credits • ${a.isAdd ? "Adding" : "Dropping"}'
                        '${a.course.isCustom ? " • Custom" : ""}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => onRemove(a.course.code),
                  icon: const Icon(Icons.delete_outline_rounded),
                  color: const Color(0xFF9CA3AF),
                  tooltip: 'Remove',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
