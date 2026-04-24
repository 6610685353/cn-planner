import '../models/subject_model.dart';

class ValidationService {
  // แปลง Year/Term เป็นเลขลำดับเพื่อให้เปรียบเทียบง่าย (เช่น ปี 2 เทอม 1 = 21)
  static int getTermIndex(int year, int semester) => (year * 10) + semester;

  static Map<String, dynamic> validateCourse({
    required SubjectModel targetSubject,
    required int targetYear,
    required int targetSemester,
    required List<Map<String, dynamic>> currentPlan, // ข้อมูลใน editedHistory
    required List<SubjectModel> allSubjects,
  }) {
    int targetIdx = getTermIndex(targetYear, targetSemester);
    List<String> missingRequire = [];
    List<String> missingCoreq = [];

    // 1. เช็ค Prerequisite (Require) - ต้องเรียน "ก่อน" เทอมนี้ (<)
    if (targetSubject.require != null) {
      for (String reqCode in targetSubject.require!) {
        bool found = currentPlan.any((item) {
          int itemIdx = getTermIndex(item['year'], item['semester']);
          return item['subject_code'] == reqCode && itemIdx < targetIdx;
        });
        if (!found) missingRequire.add(reqCode);
      }
    }

    // 2. เช็ค Corequisite - ต้องเรียน "ก่อน" หรือ "พร้อมกัน" (<=)
    if (targetSubject.corequisite != null) {
      for (String coCode in targetSubject.corequisite!) {
        bool found = currentPlan.any((item) {
          int itemIdx = getTermIndex(item['year'], item['semester']);
          return item['subject_code'] == coCode && itemIdx <= targetIdx;
        });
        if (!found) missingCoreq.add(coCode);
      }
    }

    // 3. เช็ค Semester ที่เปิดสอน
    bool isWrongSemester = false;
    if (targetSubject.offeredSemester != null &&
        !targetSubject.offeredSemester!.contains(targetSemester)) {
      isWrongSemester = true;
    }

    return {
      'isValid':
          missingRequire.isEmpty && missingCoreq.isEmpty && !isWrongSemester,
      'missingRequire': missingRequire,
      'missingCoreq': missingCoreq,
      'isWrongSemester': isWrongSemester,
    };
  }

  // 4. เช็คหน่วยกิตรวม (ไม่เกิน 22)
  static double calculateTotalCredits(
    List<Map<String, dynamic>> termCourses,
    List<SubjectModel> allSubjects,
  ) {
    double total = 0;
    for (var course in termCourses) {
      final subject = allSubjects.firstWhere(
        (s) => s.subjectCode == course['subject_code'],
        orElse: () => SubjectModel(
          subjectCode: '',
          subjectName: '',
          credits: 0,
          subjectId: 0,
          su_grade: false,
        ),
      );
      total += subject.credits;
    }
    return total;
  }
}
