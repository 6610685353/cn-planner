import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/gpa_course_model.dart';
import '../../roadmap/services/profile_service.dart';
import '../../roadmap/services/roadmap_service.dart';
import '../../roadmap/services/subject_service.dart';
import '../../roadmap/models/subject_model.dart';

class GPACalculatorController extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();
  final RoadmapService _roadmapService = RoadmapService();
  final SubjectService _subjectService = SubjectService();

  // Settings
  final Map<String, double> gradePoints = {
    "A": 4.0,
    "B+": 3.5,
    "B": 3.0,
    "C+": 2.5,
    "C": 2.0,
    "D+": 1.5,
    "D": 1.0,
    "F": 0.0,
  };

  // State
  bool isLoading = true;
  double currentGPA = 0.00; // GPAX ล่าสุดจากฐานข้อมูล
  double predictedGPA = 0.00; // เฉพาะวิชาใน Sandbox ของเทอมปัจจุบัน
  double predictedGPAX = 0.00; // เกรดสะสมรวมทั้งหมด (เก่า + Sandbox ใหม่)

  double _pastTotalPoints = 0.0;
  double _pastTotalCredits = 0.0;

  int _currentYear = 1;
  int _currentSemester = 1;

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

      // 1. Fetch Profile & Master Data
      final profile = await _profileService.getProfile(user.uid);
      allSubjects = await _subjectService.fetchSubjects();
      final history = await _roadmapService.getUserRoadmap(user.uid);

      if (profile != null) {
        _currentYear = profile['current_year'] ?? 1;
        _currentSemester = profile['current_semester'] ?? 1;
        currentGPA = (profile['gpax'] ?? 0.0).toDouble();

        // 2. ดึงค่าสะสมในอดีต (Past Baseline) จาก profiles โดยตรง
        _pastTotalCredits = (profile['earned_credits'] ?? 0.0).toDouble();
        _pastTotalPoints = currentGPA * _pastTotalCredits;
      }

      // 3. เตรียมวิชาในเทอมปัจจุบัน (Sandbox)
      passedSubjects = history
          .where(
            (e) =>
                e['grade'] != null &&
                e['grade'] != '-' &&
                e['grade'] != 'F' &&
                e['grade'] != 'W',
          )
          .map((e) => e['subject_code'] as String)
          .toList();

      final currentTermHistory = history
          .where(
            (e) =>
                e['year'] == _currentYear && e['semester'] == _currentSemester,
          )
          .toList();

      currentSemesterCourses = currentTermHistory.map((item) {
        final code = item['subject_code'];
        final subject = allSubjects.firstWhere(
          (s) => s.subjectCode == code,
          orElse: () => SubjectModel(
            subjectCode: code,
            subjectName: code,
            credits: 3.0,
            subjectId: 0,
          ),
        );

        String grade = item['grade'] ?? '-';
        if (grade == '-' || !gradePoints.containsKey(grade)) {
          grade = 'A';
        }

        return GPACourseModel(
          id:
              item['id']?.toString() ??
              "sandbox_${DateTime.now().millisecondsSinceEpoch}_$code",
          code: code,
          name: subject.subjectName,
          credits: subject.credits,
          grade: grade,
        );
      }).toList();

      calculatePrediction();
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
      // calculatePrediction(); // คำนวณใหม่ทันทีที่เปลี่ยนเกรด
    }
  }

  void deleteCourse(int index) {
    if (index >= 0 && index < currentSemesterCourses.length) {
      currentSemesterCourses.removeAt(index);
      notifyListeners();
      // calculatePrediction(); // คำนวณใหม่ทันทีที่ลบ
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
    // calculatePrediction(); // คำนวณใหม่ทันทีที่เพิ่มวิชา
  }
}
