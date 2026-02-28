import 'package:cn_planner_app/features/manage/widgets/subject_box.dart';
import 'package:flutter/material.dart';

class YearCourseBox extends StatefulWidget {
  final String year;
  final String semester;
  final List<dynamic> courseSubject;
  final Map<int, bool> checkedMap;
  final Map<int, String> gradeMap;
  
  //for backend
  final Function(int , bool) onCheckChanged;
  final Function(int , String) onGradeChanged;

  const YearCourseBox({
    super.key,
    required this.year,
    required this.semester,
    required this.courseSubject,
    required this.checkedMap,
    required this.gradeMap,

    required this.onCheckChanged,
    required this.onGradeChanged,
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

  int get selectedCount {
    return widget.courseSubject.where((subject) {
      final id = subject['subjectId'];

      return widget.gradeMap.containsKey(id) && widget.gradeMap[id] != null && widget.gradeMap[id] != "-";
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // ปรับค่าตัวเลขความโค้งที่นี่
      ),
      color: Colors.white,
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.only(top: 6.0, bottom: 6.0),
        child: Column(
          children: [
            ListTile(
              title: Text(
                "Year ${widget.year} Semester ${widget.semester}",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Progress Bar: $selectedCount'),
              trailing: IconButton(
                icon: Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
              ),
            ),
            if (_isExpanded)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 10.0,
                ),
                child: Column(
                  children: widget.courseSubject.map((subject) {
                    return SubjectBox(
                      title: subject['subjectCode'],
                      subtitle: subject['subjectName'],
                      credits: (subject['credits'] as int).toDouble(),
                      grade: widget.gradeMap[subject['subjectId']] ?? "-",
                      subjectId: subject['subjectId'],
                      isChecked: widget.checkedMap[subject['subjectId']] ?? false,
                      onChanged: onChecked,
                      onCheckChanged: widget.onCheckChanged,
                      onGradeChanged: (grade) => widget.onGradeChanged(subject['subjectId'], grade),
                    );
                }).toList(),
              ),
            )
        ],
      ),
    )
    );
  }
}
