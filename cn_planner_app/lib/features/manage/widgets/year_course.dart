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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          ListTile(
            title: Text("Year ${widget.year} Sem ${widget.semester}"),
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
          if (_isExpanded) 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0 ,vertical: 10.0),
              child: Column(
                children: widget.courseSubject.map((course) {
                  return SubjectBox(
                    title: course, 
                    subtitle: widget.subjectData[course]['subjectName'], 
                    credits: widget.subjectData[course]['credits'],
                    grade: "A", 
                    );
                }).toList(),
              ),
            )

          // if (_isExpanded)
          //   Padding(
          //     padding: const EdgeInsets.symmetric(horizontal: 10.0),
          //     child: Text(widget.courseSubject.toString())
          //   )
        ],
      ),
    );
  }
}