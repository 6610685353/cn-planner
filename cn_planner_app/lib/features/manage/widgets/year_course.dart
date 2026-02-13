import 'package:flutter/material.dart';

class YearCourseBox extends StatefulWidget {
  @override
  _YearCourseBox createState() => _YearCourseBox();
}

class _YearCourseBox extends State<YearCourseBox> {
  bool _isExpanded = false; // ตัวแปรเก็บสถานะ เปิด/ปิด

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          ListTile(
            title: const Text('Course Details'),
            trailing: IconButton(
              icon: Icon(_isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded; // สลับค่า true/false
                });
              },
            ),
          ),
          // ถ้า _isExpanded เป็น true จะแสดงข้อมูลข้างล่างนี้
          if (_isExpanded)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('นี่คือเนื้อหาที่ซ่อนอยู่ภายในกล่องครับ...'),
            ),
        ],
      ),
    );
  }
}