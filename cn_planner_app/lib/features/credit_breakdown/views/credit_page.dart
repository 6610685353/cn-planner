import 'package:flutter/material.dart';
import '../widgets/total_credit_card.dart';
import '../widgets/credit_category_item.dart';
import 'package:cn_planner_app/features/profile/controllers/profile_controller.dart';

class CreditBreakdownPage extends StatefulWidget {
  const CreditBreakdownPage({super.key});

  @override
  State<CreditBreakdownPage> createState() => _CreditBreakdownPageState();
}

class _CreditBreakdownPageState extends State<CreditBreakdownPage> {
  final ProfileController _profileController = ProfileController();
  ProfileData? _profileData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await _profileController.fetchUserData();
    if (mounted) {
      setState(() {
        _profileData = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // -----------------------------------------------------------------
    // Mock Data: รายวิชาแยกตาม Part (เก็บไว้โชว์ UI ด้านล่าง)
    // -----------------------------------------------------------------
    final List<Map<String, dynamic>> categories = [
      {
        'part': 'Part I',
        'name': 'General Education Courses',
        'earned': 24,
        'required': 30,
        'color': Colors.grey.shade800,
      },
      {
        'part': 'Part II',
        'name': 'Major Courses',
        'earned': 45,
        'required': 94,
        'color': Colors.grey.shade800,
      },
      {
        'part': 'Part III',
        'name': 'Free Elective Courses',
        'earned': 6,
        'required': 6,
        'color': Colors.grey.shade800,
      },
    ];

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
                  // 1. การ์ดสรุปรวม (โยนค่าจาก Controller ใส่ได้เลย)
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

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      return CreditCategoryItem(
                        part: cat['part'],
                        categoryName: cat['name'],
                        earned: cat['earned'],
                        required: cat['required'],
                        color: cat['color'],
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
