import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:cn_planner_app/services/api_config.dart';
import '../models/gpa_course_model.dart';
import '../../roadmap/models/subject_model.dart';

class GPACalculatorController extends ChangeNotifier {
  // Settings
  final Map<String, double> gradePoints = {
    "A": 4.0, "B+": 3.5, "B": 3.0, "C+": 2.5,
    "C": 2.0, "D+": 1.5, "D": 1.0, "F": 0.0,
  };

  // State
  bool isLoading = true;
  double currentGPA = 0.00; // GPAX ล่าสุดจากฐานข้อมูล
  double predictedGPA = 0.00; // เฉพาะวิชาใน Sandbox ของเทอมปัจจุบัน
  double predictedGPAX = 0.00; // เกรดสะสมรวมทั้งหมด (เก่า + Sandbox ใหม่)

  double _pastTotalPoints = 0.0;
  double _pastTotalCredits = 0.0;

  List<GPACourseModel> currentSemesterCourses = [];
  List<SubjectModel> allSubjects = [];
  List<String> passedSubjects = [];

  Future<void> fetchInitialData() async {
    isLoading = true;
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        isLoading = false;
        notifyListeners();
        return;
      }

      // 1. เรียก API Init ทีเดียวจบจาก Backend
      final url = Uri.parse("${Config.baseUrl}/v1/gpa/init/${user.uid}");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        currentGPA = (data['currentGPA'] ?? 0.0).toDouble();
        _pastTotalCredits = (data['pastTotalCredits'] ?? 0.0).toDouble();
        _pastTotalPoints = currentGPA * _pastTotalCredits;

        // รายวิชาที่สอบผ่านแล้ว
        final List<dynamic> passedList = data['passedSubjects'];
        passedSubjects = passedList.map((e) => e.toString()).toList();

        // รายวิชา Master ทั้งหมด
        final List<dynamic> subjectsList = data['allSubjects'];
        allSubjects = subjectsList.map((s) => SubjectModel(
          subjectCode: s['subjectCode'],
          subjectName: s['subjectName'],
          credits: (s['credits'] ?? 0.0).toDouble(),
          subjectId: s['subjectId'],
        )).toList();

        // รายวิชาในเทอมปัจจุบัน (Sandbox เริ่มต้น)
        final List<dynamic> sandboxList = data['currentSemesterCourses'];
        currentSemesterCourses = sandboxList.map((c) => GPACourseModel(
          id: "sandbox_${DateTime.now().millisecondsSinceEpoch}_${c['code']}",
          code: c['code'],
          name: c['name'],
          credits: (c['credits'] ?? 0.0).toDouble(),
          grade: c['grade'],
        )).toList();

        calculatePrediction();
      } else {
        debugPrint("❌ Error fetching GPA init: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error loading GPA Calculator Data: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void updateCourseGrade(int index, String newGrade) {
    if (index >= 0 && index < currentSemesterCourses.length) {
      currentSemesterCourses[index].grade = newGrade;
      notifyListeners();
    }
  }

  void deleteCourse(int index) {
    if (index >= 0 && index < currentSemesterCourses.length) {
      currentSemesterCourses.removeAt(index);
      notifyListeners();
    }
  }

  void calculatePrediction() {
    double semesterPoints = 0.0;
    double semesterCredits = 0.0;

    for (var course in currentSemesterCourses) {
      double point = gradePoints[course.grade] ?? 0.0;
      double credit = course.credits;

      semesterPoints += (point * credit);
      semesterCredits += credit;
    }

    // 1. PREDICTED GPA: เฉพาะใน Sandbox เทอมนี้
    if (semesterCredits > 0) {
      predictedGPA = semesterPoints / semesterCredits;
    } else {
      predictedGPA = 0.0;
    }

    // 2. PREDICTED GPAX: (คะแนนสะสมอดีต + คะแนน Sandbox) / (หน่วยกิตสะสมอดีต + หน่วยกิต Sandbox)
    double totalPoints = _pastTotalPoints + semesterPoints;
    double totalCredits = _pastTotalCredits + semesterCredits;

    if (totalCredits > 0) {
      predictedGPAX = totalPoints / totalCredits;
    } else {
      predictedGPAX = currentGPA;
    }

    notifyListeners();
  }

  void addCoursesFromManage(List<dynamic> results) {
    for (var item in results) {
      final subject = item['subject'] as SubjectModel;
      String grade = item['grade'] ?? '-';

      if (grade == '-' || !gradePoints.containsKey(grade)) {
        grade = 'A';
      }

      if (!currentSemesterCourses.any((c) => c.code == subject.subjectCode)) {
        currentSemesterCourses.add(
          GPACourseModel.createSandbox(
            code: subject.subjectCode,
            name: subject.subjectName,
            credits: subject.credits,
            grade: grade,
          ),
        );
      }
    }
    notifyListeners();
  }
}
