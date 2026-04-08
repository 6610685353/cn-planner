import 'package:flutter/material.dart';
import 'package:cn_planner_app/features/roadmap/models/subject_model.dart';

class CourseSelectionPage extends StatefulWidget {
  final List<SubjectModel> subjects;
  final List<String> passedSubjects;
  final List<String> alreadyAddedCodes;
  final int targetTerm; // 🔥 เพิ่ม: เทอมเป้าหมายที่กำลังเลือกแอด (1 หรือ 2)

  const CourseSelectionPage({
    super.key,
    required this.subjects,
    required this.passedSubjects,
    required this.alreadyAddedCodes,
    required this.targetTerm, // 🔥 รับค่าเพิ่ม
  });

  @override
  State<CourseSelectionPage> createState() => _CourseSelectionPageState();
}

class _CourseSelectionPageState extends State<CourseSelectionPage> {
  String searchQuery = "";

  /// 🔍 กรองวิชาตามที่ค้นหา
  List<SubjectModel> get filteredSubjects {
    if (searchQuery.isEmpty) return widget.subjects;

    final query = searchQuery.toLowerCase().trim();

    return widget.subjects.where((subject) {
      final code = (subject.subjectCode ?? "").toLowerCase();
      final name = (subject.subjectName ?? "").toLowerCase();
      return code.contains(query) || name.contains(query);
    }).toList();
  }

  /// ✅ เช็คว่า "ลงได้ไหม" (ต้องผ่านทั้งวิชาตัวต่อ และเปิดสอนในเทอมนี้)
  bool canTake(SubjectModel subject) {
    // 1. เช็ค Prerequisite (ตัวต่อ)
    bool prereqMet = true;
    if (subject.require != null && subject.require!.isNotEmpty) {
      prereqMet = subject.require!.every(
        (req) => widget.passedSubjects.contains(req),
      );
    }

    // 2. เช็ค Offered Semester (เทอมที่เปิดสอน)
    bool isOffered = true;
    if (subject.offeredSemester != null &&
        subject.offeredSemester!.isNotEmpty) {
      isOffered = subject.offeredSemester!.contains(widget.targetTerm);
    }

    return prereqMet && isOffered;
  }

  /// ❌ หาเหตุผลว่าทำไมลงไม่ได้
  List<String> getIneligibleReasons(SubjectModel subject) {
    List<String> reasons = [];

    // เช็คเรื่องเทอม
    if (subject.offeredSemester != null &&
        subject.offeredSemester!.isNotEmpty &&
        !subject.offeredSemester!.contains(widget.targetTerm)) {
      reasons.add("Not offered in Term ${widget.targetTerm}");
    }

    // เช็คเรื่องวิชาตัวต่อ
    if (subject.require != null) {
      List<String> missing = subject.require!
          .where((req) => !widget.passedSubjects.contains(req))
          .toList();
      if (missing.isNotEmpty) {
        reasons.add("Requires: ${missing.join(', ')}");
      }
    }

    return reasons;
  }

  /// 🔥 แสดงเทอมที่เปิดสอน
  String formatSemester(List<int>? semesters) {
    if (semesters == null || semesters.isEmpty) return "Not specified";
    return semesters.map((e) => "Term $e").join(", ");
  }

  /// ✅ กลุ่มวิชาที่ลงได้ (เรียงตามรหัสวิชา)
  List<SubjectModel> get availableSubjects {
    return filteredSubjects.where((s) => canTake(s)).toList()
      ..sort((a, b) => a.subjectCode.compareTo(b.subjectCode));
  }

  /// 🔒 กลุ่มวิชาที่ยังลงไม่ได้ (เรียงตามรหัสวิชา)
  List<SubjectModel> get unavailableSubjects {
    return filteredSubjects.where((s) => !canTake(s)).toList()
      ..sort((a, b) => a.subjectCode.compareTo(b.subjectCode));
  }

  /// 🎨 สร้างการ์ดแสดงรายวิชา
  Widget buildCourseTile(
    BuildContext context,
    SubjectModel subject,
    bool isAvailable,
  ) {
    final reasons = getIneligibleReasons(subject);
    final bool isAlreadyAdded = widget.alreadyAddedCodes.contains(
      subject.subjectCode,
    );

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: isAvailable ? Colors.white : Colors.grey[50],
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          subject.subjectCode,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isAvailable ? Colors.black : Colors.grey.shade600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subject.subjectName,
              style: TextStyle(
                color: isAvailable ? Colors.black87 : Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Offered: ${formatSemester(subject.offeredSemester)}",
              style: TextStyle(
                fontSize: 12,
                color: isAvailable
                    ? Colors.blue.shade300
                    : Colors.grey.shade500,
              ),
            ),
            if (!isAvailable)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: reasons
                      .map(
                        (r) => Text(
                          "❌ $r",
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
          ],
        ),
        trailing: isAvailable
            ? ElevatedButton(
                onPressed: isAlreadyAdded
                    ? null
                    : () => Navigator.pop(context, subject),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isAlreadyAdded
                      ? Colors.grey.shade300
                      : Colors.blue.shade600,
                  foregroundColor: isAlreadyAdded
                      ? Colors.grey.shade600
                      : Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(isAlreadyAdded ? "Added" : "Add"),
              )
            : const Icon(Icons.lock_outline, color: Colors.grey, size: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Select Courses (Term ${widget.targetTerm})", // 🔥 บอกเทอมที่ AppBar เพื่อความชัดเจน
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          /// 🔍 ช่องค้นหา
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() => searchQuery = value);
              },
              decoration: InputDecoration(
                hintText: "Search course code or name...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          /// 📚 รายการวิชาแบ่งตามสถานะ
          Expanded(
            child: ListView(
              children: [
                /// ✅ ส่วนวิชาที่ลงได้
                if (availableSubjects.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text(
                      "Available for Term ${"widget.targetTerm" == "1" ? "1" : "2"}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  ...availableSubjects.map(
                    (s) => buildCourseTile(context, s, true),
                  ),
                ],

                /// 🔒 ส่วนวิชาที่ยังลงไม่ได้
                if (unavailableSubjects.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 24,
                      bottom: 8,
                    ),
                    child: Text(
                      "Unavailable / Other Terms",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  ...unavailableSubjects.map(
                    (s) => buildCourseTile(context, s, false),
                  ),
                ],

                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
