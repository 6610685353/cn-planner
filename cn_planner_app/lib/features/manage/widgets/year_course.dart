import 'package:cn_planner_app/features/manage/widgets/subject_box.dart';
import 'package:flutter/material.dart';

class YearCourseBox extends StatefulWidget {
  final Map<String, dynamic> allCourse; //contain all course in specific year

  const YearCourseBox({
    super.key,
    required this.allCourse,
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
            title: const Text('Course Details'),
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
            for (var item in widget.allCourse['subject']) //Show all Subject in this year
              SubjectBox(
                title: item['title'], 
                subtitle: "Subject full title", 
                trailingChar: "B", 
                initialValue: false, 
                onChanged: (val) {})
        ],
      ),
    );
  }
}