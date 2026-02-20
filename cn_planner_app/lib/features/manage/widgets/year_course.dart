import 'package:cn_planner_app/features/manage/widgets/subject_box.dart';
import 'package:flutter/material.dart';

class YearCourseBox extends StatefulWidget {
  final int year;
  final String semester;
  final List<dynamic> courseSubject;
  final Map<String, dynamic> subjectData;

  const YearCourseBox({
    super.key,
    required this.year,
    required this.semester,
    required this.courseSubject,
    required this.subjectData,
  });

  @override
  _YearCourseBox createState() => _YearCourseBox();
}

class _YearCourseBox extends State<YearCourseBox> {
  bool _isExpanded = false;
  Map<String, bool> checkedItems = {};

  void onChecked(String key, bool value) {
    setState(() {
      checkedItems[key] = value;
    });
  }

  int get selectedCount => checkedItems.values.where((v) => v).length;

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
                  children: widget.courseSubject.map((course) {
                    return SubjectBox(
                      title: course,
                      subtitle: widget.subjectData[course]['subjectName'],
                      credits: (widget.subjectData[course]['credits'] as int).toDouble(),
                      grade: "A",
                      value: checkedItems[course] ?? false,
                      onChanged: onChecked,
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
