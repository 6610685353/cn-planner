import 'package:cn_planner_app/features/roadmap/models/subject_model.dart';
import 'package:cn_planner_app/features/roadmap/services/roadmap_service.dart';
import 'package:cn_planner_app/features/roadmap/services/subject_service.dart';
import 'package:cn_planner_app/services/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cn_planner_app/services/send_grade.dart';
import '../widgets/total_credit_card.dart';
import '../widgets/credit_category_item.dart';
import '../widgets/expandable_elective_card.dart';
import '../widgets/add_elective_dialog.dart';
import 'package:cn_planner_app/features/profile/controllers/profile_controller.dart';

class CreditBreakdownPage extends StatefulWidget {
  const CreditBreakdownPage({super.key});

  @override
  State<CreditBreakdownPage> createState() => _CreditBreakdownPageState();
}

class _CreditBreakdownPageState extends State<CreditBreakdownPage> {
  final ProfileController _profileController = ProfileController();
  final _supabase = Supabase.instance.client;

  ProfileData? _profileData;
  bool _isLoading = true;

  List<dynamic> _genEdCourses = [];
  List<dynamic> _freeElectiveCourses = [];

  int _majorEarnedCredits = 0;

  final Map<String, double> gradeScheme = {
    'A': 4.0,
    'B+': 3.5,
    'B': 3.0,
    'C+': 2.5,
    'C': 2.0,
    'D+': 1.5,
    'D': 1.0,
    'F': 0.0,
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    final data = await _profileController.fetchUserData();

    if (user != null) {
      final response = await _supabase
          .from('UserElectives')
          .select()
          .eq('user_id', user.uid);

      _genEdCourses = response.where((c) => c['category'] == 'gen_ed').toList();
      _freeElectiveCourses = response
          .where((c) => c['category'] == 'free_elective')
          .toList();

      try {
        final subjectService = SubjectService();
        final roadmapService = RoadmapService();
        final allSubjects = await subjectService.fetchSubjects();
        final history = await roadmapService.getUserRoadmap(user.uid);

        int majorEarned = 0;

        for (var item in history) {
          String grade = item['grade'] ?? '-';

          if (grade != '-' && grade != 'F' && grade != 'W') {
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
            majorEarned += subject.credits.toInt();
          }
        }
        _majorEarnedCredits = majorEarned;
      } catch (e) {
        print("❌ Error คำนวณหน่วยกิต Major: $e");
      }
    }

    if (mounted) {
      setState(() {
        _profileData = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _recalculateOverallGPA() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final subjectService = SubjectService();
      final roadmapService = RoadmapService();
      final profileService = ProfileService();

      final profile = await profileService.getProfile(user.uid);
      final allSubjects = await subjectService.fetchSubjects();
      final history = await roadmapService.getUserRoadmap(user.uid);
      final electives = await _supabase
          .from('UserElectives')
          .select()
          .eq('user_id', user.uid);

      double totalGradePoints = 0;
      double totalCreditsForGPA = 0;

      for (var item in history) {
        String grade = item['grade'] ?? '-';
        if (!gradeScheme.containsKey(grade)) continue;

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

        totalGradePoints += (gradeScheme[grade]! * subject.credits);
        totalCreditsForGPA += subject.credits;
      }

      for (var elective in electives) {
        String grade = elective['grade'] ?? '-';
        if (!gradeScheme.containsKey(grade)) continue;

        int creds = (elective['credits'] as num?)?.toInt() ?? 0;
        totalGradePoints += (gradeScheme[grade]! * creds);
        totalCreditsForGPA += creds;
      }

      double gpax = totalCreditsForGPA > 0
          ? totalGradePoints / totalCreditsForGPA
          : 0.0;

      double currentGpa = (profile?['gpa'] ?? 0.0).toDouble();
      double currentThisSemCred = (profile?['this_sem_credits'] ?? 0.0)
          .toDouble();

      await SendGrade.submitGPAX(
        gpax,
        totalCreditsForGPA,
        currentGpa,
        currentThisSemCred,
      );
    } catch (e) {
      print("❌ Error คำนวณเกรด: $e");
    }
  }

  Future<void> _handleAddCourse(String category) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddElectiveDialog(
        categoryName: category == 'gen_ed'
            ? 'General Education'
            : 'Free Elective',
      ),
    );

    if (result != null) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      setState(() => _isLoading = true);

      await _supabase.from('UserElectives').insert({
        'user_id': user.uid,
        'category': category,
        'subject_code': result['subject_code'],
        'credits': result['credits'],
        'grade': result['grade'],
      });

      await _recalculateOverallGPA();
      await _loadData();
    }
  }

  Future<void> _handleDeleteCourse(String id) async {
    setState(() => _isLoading = true);
    await _supabase.from('UserElectives').delete().eq('id', id);
    await _recalculateOverallGPA();
    await _loadData();
  }

  int _calculateEarned(List<dynamic> courses) {
    return courses.fold(0, (sum, item) {
      String grade = item['grade'] ?? '-';
      if (grade != 'F' && grade != 'W' && grade != '-') {
        return sum + (item['credits'] as int);
      }
      return sum;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text(
          'Credit Breakdown',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TotalCreditCard(
                    earnedCredits: _profileData?.earned_credits ?? 0,
                    totalCredits: _profileData?.total_credits ?? 146,
                    currentGpa: _profileData?.gpax ?? 0.00,
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Degree Requirements',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  ExpandableElectiveCard(
                    part: 'Part I',
                    categoryName: 'General Education Courses',
                    earned: _calculateEarned(_genEdCourses),
                    required: 12,
                    color: Colors.grey.shade800,
                    addedCourses: _genEdCourses,
                    onAddPressed: () => _handleAddCourse('gen_ed'),
                    onDeletePressed: _handleDeleteCourse,
                  ),

                  CreditCategoryItem(
                    part: 'Part II',
                    categoryName: 'Major Courses',
                    earned: _majorEarnedCredits,
                    required: 128,
                    color: Colors.grey.shade800,
                  ),

                  ExpandableElectiveCard(
                    part: 'Part III',
                    categoryName: 'Free Elective Courses',
                    earned: _calculateEarned(_freeElectiveCourses),
                    required: 6,
                    color: Colors.grey.shade800,
                    addedCourses: _freeElectiveCourses,
                    onAddPressed: () => _handleAddCourse('free_elective'),
                    onDeletePressed: _handleDeleteCourse,
                  ),
                ],
              ),
            ),
    );
  }
}
