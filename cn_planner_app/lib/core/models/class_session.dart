import 'package:flutter/material.dart';

class ClassSession {
  final String code;
  final String name;
  final String instructor;
  final String day;
  final String start;
  final String stop;
  final String section;
  final String room;
  final Color color;

  ClassSession({
    required this.code,
    required this.name,
    required this.instructor,
    required this.day,
    required this.start,
    required this.stop,
    required this.section,
    required this.room,
    required this.color,
  });
}
