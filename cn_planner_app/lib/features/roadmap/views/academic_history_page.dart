import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cn_planner_app/core/constants/app_colors.dart';
import '../widgets/progress_header.dart';
import '../widgets/term_column.dart';
import '../models/subject_model.dart';
import '../services/subject_service.dart';
import '../services/profile_service.dart';
import '../services/roadmap_service.dart';
import 'roadmap_page.dart'; // เพื่อใช้ RoadmapMode

class AcademicHistoryPage extends StatefulWidget {
  const AcademicHistoryPage({super.key});

  @override
  State<AcademicHistoryPage> createState() => _AcademicHistoryPageState();
}

class _AcademicHistoryPageState extends State<AcademicHistoryPage> {
  final SubjectService _subjectService = SubjectService();
  final ProfileService _profileService = ProfileService();
  final RoadmapService _roadmapService = RoadmapService();
  int maxYear = 4;

  List<SubjectModel> allSubjects = [];
  Map<String, dynamic>? userProfile;
  List<Map<String, dynamic>> academicHistory = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final subjects = await _subjectService.fetchSubjects();
      final profile = await _profileService.getProfile(user.uid);
      final history = await _roadmapService.getUserRoadmap(user.uid);

      setState(() {
        allSubjects = subjects;
        userProfile = profile;
        academicHistory = history;
        maxYear = profile?['max_year'] ?? 4;
        isLoading = false;
      });
    }
  }

  // 🔥 ฟังก์ชันคำนวณหน่วยกิตรวมทั้งหมด
  double _calculateAllCredits() {
    double total = 0;
    for (var item in academicHistory) {
      // ค้นหาข้อมูลวิชาจาก allSubjects เพื่อเอาจำนวน credits
      final subject = allSubjects.firstWhere(
        (s) => s.subjectCode == item['subject_code'],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'ACADEMIC HISTORY',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            Text(
              'Computer Engineering',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          heroTag: "goToEditBtn",
          elevation: 0,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const RoadmapPage(mode: RoadmapMode.edit),
              ),
            ).then((_) => loadData());
          },
          backgroundColor: Color(0xFFFFFBEE),
          foregroundColor: AppColors.accentYellow,

          icon: const Icon(Icons.edit_note, size: 24),
          label: const Text(
            "Edit History",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 🔥 ส่งค่าหน่วยกิตรวมที่คำนวณได้เข้าไป
                ProgressHeader(currentCredits: _calculateAllCredits()),

                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment
                          .stretch, // 🔥 ทำให้คอลัมน์สูงเท่ากันเพื่อ scroll แนวตั้งได้ดี
                      children: List.generate(maxYear * 2, (index) {
                        int year = (index ~/ 2) + 1;
                        int term = (index % 2) + 1;

                        final termCourses = academicHistory
                            .where(
                              (item) =>
                                  item['year'] == year &&
                                  item['semester'] == term,
                            )
                            .toList();

                        return TermColumn(
                          title: "Year $year / Term $term",
                          allSubjects: allSubjects,
                          mode: RoadmapMode.history, // View Mode แก้ไขไม่ได้
                          userProfile: userProfile,
                          initialCourses: termCourses,
                          allPlanCourses:
                              academicHistory, // 🔥 ส่งทั้งแผนไปเช็คตัวต่อ
                          onRefresh: loadData,
                          isSelected:
                              userProfile?['current_year'] == year &&
                              userProfile?['current_semester'] == term,
                          onSelect: () {},
                          onDeleteYear: null,
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
