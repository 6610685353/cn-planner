import 'package:cn_planner_app/core/constants/app_colors.dart';
import 'package:cn_planner_app/core/widgets/top_bar.dart';
import 'package:cn_planner_app/features/manage/widgets/search_box.dart';
import 'package:cn_planner_app/features/manage/widgets/year_course.dart';
import 'package:cn_planner_app/services/data_fetch.dart';
import 'package:flutter/material.dart';
import 'package:cn_planner_app/features/roadmap/models/subject_model.dart';
import 'package:cn_planner_app/services/schedule_service.dart';

class ManageCoursePage extends StatefulWidget {
  final int targetTerm;
  final List<SubjectModel> subjects;
  final List<String> passedSubjects;
  final List<String> alreadyAddedCodes;

  const ManageCoursePage({
    super.key,
    required this.targetTerm,
    required this.subjects,
    required this.passedSubjects,
    required this.alreadyAddedCodes,
  });

  @override
  State<ManageCoursePage> createState() => _ManageCoursePageState();
}

class _ManageCoursePageState extends State<ManageCoursePage> {
  Map<String, dynamic> _pageData = {};
  Map<String, dynamic> _filteredCourses = {};

  bool _isLoading = true;
  String? _errorMessage;

  Map<int, bool> checkedMap = {};
  Map<int, String> gradeMap = {};
  Map<int, String> sectionMap = {}; // ✅ กลับมาใช้
  Map<int, Map<String, List<Map>>> scheduleMap = {};
  Map<int, List<String>> sectionOptionsMap = {};

  late Map<int, SubjectModel> subjectMap;

  @override
  void initState() {
    super.initState();
    subjectMap = {for (var s in widget.subjects) s.subjectId: s};
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final pageDataF = await DataFetch().getManagePageData();
      final scheduleRaw = await DataFetch().getSchedule();
      scheduleMap = ScheduleService.buildScheduleMap(scheduleRaw);
      sectionOptionsMap = ScheduleService.buildSectionOptions(scheduleMap);

      if (!mounted) return;

      setState(() {
        _pageData = pageDataF;
        _filteredCourses = _pageData;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  /// 🔍 search
  void onSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredCourses = _pageData;
      });
      return;
    }

    final Map<String, dynamic> result = {};

    _pageData.forEach((category, items) {
      final List<dynamic> coursesList = items as List<dynamic>;

      final matched = coursesList.where((course) {
        final String code = course['subjectCode']?.toString() ?? "";
        return code.toLowerCase().contains(query.toLowerCase());
      }).toList();

      if (matched.isNotEmpty) {
        result[category] = matched;
      }
    });

    setState(() {
      _filteredCourses = result;
    });
  }

  /// ✅ เช็คลงได้ไหม
  bool canTake(SubjectModel subject) {
    final selectedCodes = checkedMap.entries
        .where((e) => e.value)
        .map((e) => subjectMap[e.key]!.subjectCode)
        .toList();

    bool prereqMet = true;
    if (subject.require != null && subject.require!.isNotEmpty) {
      prereqMet = subject.require!.every(
        (req) => widget.passedSubjects.contains(req),
      );
    }

    bool isOffered = true;
    if (subject.offeredSemester != null &&
        subject.offeredSemester!.isNotEmpty) {
      isOffered = subject.offeredSemester!.contains(widget.targetTerm);
    }

    bool notDuplicate =
        !(widget.alreadyAddedCodes.contains(subject.subjectCode) &&
            widget.passedSubjects.contains(subject.subjectCode));

    bool coreqMet = true;
    if (subject.corequisite != null && subject.corequisite!.isNotEmpty) {
      coreqMet = subject.corequisite!.every(
        (c) => widget.passedSubjects.contains(c) || selectedCodes.contains(c),
      );
    }

    return prereqMet && isOffered && notDuplicate && coreqMet;
  }

  List<String> getReasons(SubjectModel subject) {
    final selectedCodes = checkedMap.entries
        .where((e) => e.value)
        .map((e) => subjectMap[e.key]!.subjectCode)
        .toList();

    List<String> reasons = [];

    // ❌ offered
    if (subject.offeredSemester != null &&
        subject.offeredSemester!.isNotEmpty &&
        !subject.offeredSemester!.contains(widget.targetTerm)) {
      reasons.add("Not offered in Term ${widget.targetTerm}");
    }

    // ❌ prerequisite
    if (subject.require != null) {
      final missing = subject.require!
          .where((r) => !widget.passedSubjects.contains(r))
          .toList();

      if (missing.isNotEmpty) {
        reasons.add("Missing prereq: ${missing.join(', ')}");
      }
    }

    // ❌ corequisite
    if (subject.corequisite != null) {
      final missingCoreq = subject.corequisite!
          .where(
            (c) =>
                !widget.passedSubjects.contains(c) &&
                !selectedCodes.contains(c),
          )
          .toList();

      if (missingCoreq.isNotEmpty) {
        reasons.add("Need co-req: ${missingCoreq.join(', ')}");
      }
    }

    // ❌ duplicate
    if (widget.alreadyAddedCodes.contains(subject.subjectCode)) {
      reasons.add("Already added");
    }

    return reasons;
  }

  void updateCheck(int subjectId, bool value) {
    final subject = subjectMap[subjectId];
    bool hasOnlyCoreqIssue(SubjectModel subject) {
      final reasons = getReasons(subject);
      return reasons.every((r) => r.startsWith("Need co-req"));
    }

    if (subject == null) return;

    if (value && !canTake(subject) && !hasOnlyCoreqIssue(subject)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(getReasons(subject).join("\n"))));
      return;
    }

    setState(() {
      checkedMap[subjectId] = value;
      gradeMap[subjectId] = "-";

      if (!value) {
        gradeMap[subjectId] = "-";
        sectionMap[subjectId] = "-";
      } else {
        gradeMap.putIfAbsent(subjectId, () => "-"); // default grade
        sectionMap.putIfAbsent(subjectId, () => "-"); // default section
      }
    });
  }

  void updateGrade(int subjectId, String grade) {
    setState(() {
      gradeMap[subjectId] = grade;
    });
  }

  void updateSection(int subjectId, String section) {
    setState(() => sectionMap[subjectId] = section);
  }

  /// 🔥 ส่งกลับพร้อม grade
  void _onConfirm() {
    final selected = checkedMap.entries
        .where((e) => e.value == true)
        .map((e) => e.key)
        .toList();

    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least 1 course")),
      );
      return;
    }

    final result = selected.map((id) {
      final subject = widget.subjects.firstWhere((s) => s.subjectId == id);

      return {
        "subject": subject,
        "grade": gradeMap[id] ?? "-",
        "section": sectionMap[id] ?? "-", // ✅ default = "-"
      };
    }).toList();

    Navigator.pop(context, result); // 🔥 ส่ง list + grade
  }

  @override
  Widget build(BuildContext context) {
    int selectedCount = checkedMap.values.where((v) => v).length;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null) {
      return Scaffold(body: Center(child: Text('Error : $_errorMessage')));
    }

    return Scaffold(
      appBar: TopBar(header: "Select Course (Term ${widget.targetTerm})"),
      body: Column(
        children: [
          SearchBox(onChanged: onSearch),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: _filteredCourses.entries.map((entry) {
                  final parts = entry.key.split('_');
                  final String year = parts[0];
                  final String sem = parts[1];
                  final List<dynamic> subjects = entry.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      YearCourseBox(
                        year: year,
                        semester: sem,
                        courseSubject: subjects,
                        checkedMap: checkedMap,
                        gradeMap: gradeMap,
                        sectionMap: sectionMap,
                        onCheckChanged: updateCheck,
                        onGradeChanged: updateGrade,
                        onSectionChanged: updateSection,
                        sectionOptionsMap: sectionOptionsMap, // ✅
                        scheduleMap: scheduleMap, // ✅
                      ),

                      ...subjects.map((c) {
                        final subject = subjectMap[c['subjectId']];
                        if (subject == null) return const SizedBox();

                        if (canTake(subject)) return const SizedBox();

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 2,
                          ),
                          child: Text(
                            "${subject.subjectCode}: ${getReasons(subject).join(', ')}",
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          onPressed: _onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentYellow,
            minimumSize: const Size.fromHeight(56),
          ),
          child: Text("Confirm ($selectedCount)"),
        ),
      ),
    );
  }
}
