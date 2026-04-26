import 'package:cn_planner_app/features/manage/widgets/subject_box.dart';
import 'package:flutter/material.dart';

class YearCourseBox extends StatefulWidget {
  final String year;
  final String semester;
  final List<dynamic> courseSubject;
  final Map<int, bool> checkedMap;
  final Map<int, String> gradeMap;
  final Map<int, String> sectionMap;

  final Function(int, bool) onCheckChanged;
  final Function(int, String) onGradeChanged;
  final Function(int, String) onSectionChanged;
  final Map<int, List<String>> sectionOptionsMap;
  final Map<int, Map<String, List<Map>>> scheduleMap;
  final Map<int, List<String>> reasonsMap;
  final bool isSUGrade;

  const YearCourseBox({
    super.key,
    required this.year,
    required this.semester,
    required this.courseSubject,
    required this.checkedMap,
    required this.gradeMap,
    required this.sectionMap,
    required this.onCheckChanged,
    required this.onGradeChanged,
    required this.onSectionChanged,
    required this.sectionOptionsMap,
    required this.scheduleMap,
    required this.reasonsMap,
    required this.isSUGrade,
  });

  @override
  _YearCourseBox createState() => _YearCourseBox();
}

class _YearCourseBox extends State<YearCourseBox> {
  bool _isExpanded = false;

  void onChecked(int key, bool value) {
    setState(() {
      widget.checkedMap[key] = value;
    });
  }

  // ── Select All helpers ────────────────────────────────────────────────────

  List<int> get _subjectIds =>
      widget.courseSubject.map<int>((s) => s['subjectId'] as int).toList();

  bool get _allChecked =>
      _subjectIds.isNotEmpty &&
      _subjectIds.every((id) => widget.checkedMap[id] == true);

  bool get _someChecked =>
      _subjectIds.any((id) => widget.checkedMap[id] == true);

  /// Tap → if all checked, uncheck all; otherwise check all.
  void _toggleSelectAll() {
    final newValue = !_allChecked;
    for (final id in _subjectIds) {
      widget.onCheckChanged(id, newValue);
    }
    // Force local rebuild so the checkbox header updates immediately.
    setState(() {});
  }

  Widget _buildSelectAllCheckbox() {
    return Transform.scale(
      scale: 1.3,
      child: Checkbox(
        tristate: true, // allows indeterminate (null) state
        value: _allChecked
            ? true
            : _someChecked
            ? null // indeterminate
            : false,
        checkColor: Colors.white,
        onChanged: (_) => _toggleSelectAll(),
      ),
    );
  }

  // ── Schedule conflict helpers ─────────────────────────────────────────────

  bool isConflict(int newSubjectId, String newSection) {
    for (var entry in widget.sectionMap.entries) {
      final oldSubjectId = entry.key;
      final oldSection = entry.value;

      if (oldSection == "-" || oldSubjectId == newSubjectId) continue;

      if (_checkTimeOverlap(
        newSubjectId,
        newSection,
        oldSubjectId,
        oldSection,
      )) {
        return true;
      }
    }
    return false;
  }

  bool _checkTimeOverlap(int s1, String sec1, int s2, String sec2) {
    final schedule1 = widget.scheduleMap[s1]?[sec1] ?? [];
    final schedule2 = widget.scheduleMap[s2]?[sec2] ?? [];

    for (var a in schedule1) {
      for (var b in schedule2) {
        if (a['day'] == b['day']) {
          if (a['start'] < b['end'] && b['start'] < a['end']) {
            return true;
          }
        }
      }
    }
    return false;
  }

  List<String> getAvailableSections(int subjectId) {
    final all = widget.sectionOptionsMap[subjectId] ?? [];
    return all.where((sec) => !isConflict(subjectId, sec)).toList();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.only(top: 6.0, bottom: 6.0),
        child: Column(
          children: [
            ListTile(
              // Select All checkbox on the left
              leading: _buildSelectAllCheckbox(),
              title: Text(
                "Year ${widget.year} Semester ${widget.semester}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: IconButton(
                icon: Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
                onPressed: () => setState(() => _isExpanded = !_isExpanded),
              ),
            ),
            if (_isExpanded)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 10.0,
                ),
                child: Column(
                  spacing: 10.0,
                  children: widget.courseSubject.map((subject) {
                    return SubjectBox(
                      title: subject['subjectCode'],
                      subtitle: subject['subjectName'],
                      credits: (subject['credits'] as int).toDouble(),
                      grade: widget.gradeMap[subject['subjectId']] ?? "-",
                      subjectId: subject['subjectId'],
                      isChecked:
                          widget.checkedMap[subject['subjectId']] ?? false,
                      onChanged: onChecked,
                      onCheckChanged: widget.onCheckChanged,
                      onGradeChanged: (grade) =>
                          widget.onGradeChanged(subject['subjectId'], grade),
                      section: widget.sectionMap[subject['subjectId']] ?? "-",
                      onSectionChanged: (sec) =>
                          widget.onSectionChanged(subject['subjectId'], sec),
                      availableSections: getAvailableSections(
                        subject['subjectId'],
                      ),
                      reasons: widget.reasonsMap[subject['subjectId']] ?? [],
                      isSUGrade: subject['su_grade'] ?? false,
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
