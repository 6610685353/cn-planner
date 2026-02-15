import 'package:cn_planner_app/features/manage/widgets/subject_box.dart';
import 'package:flutter/material.dart';

class YearCourseBox extends StatefulWidget {
  final Map<String, dynamic> yearCourse; //contain all course in specific year
  final Map<String, dynamic> subject;

  const YearCourseBox({
    super.key,
    required this.yearCourse,
    required this.subject,
  });

  @override
  _YearCourseBox createState() => _YearCourseBox();
}

class _YearCourseBox extends State<YearCourseBox> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          ListTile(
            title: Text("Year ${widget.yearCourse['year'].toString()} Sem ${widget.yearCourse['sem'].toString()}"),
            subtitle: Text('Progress Bar: %'),
            trailing: IconButton(
              icon: Icon(_isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
            ),
          ),
          // ถ้า _isExpanded เป็น true จะแสดงข้อมูลข้างล่างนี้
          if (_isExpanded) 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                children: (widget.yearCourse['courses'] as List).map((course) {
                  return SubjectBox(
                    title: course, 
                    subtitle: widget.subject[course]["subject name"], 
                    credits: widget.subject[course]["credits"],
                    grade: "A", 
                    );
                }).toList(),
              ),
            )
        ],
      ),
    );
  }
}