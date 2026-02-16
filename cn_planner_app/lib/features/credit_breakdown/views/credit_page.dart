import 'package:flutter/material.dart';
import '../widgets/total_credit_card.dart';
import '../widgets/credit_category_item.dart';

class CreditBreakdownPage extends StatelessWidget {
  const CreditBreakdownPage({super.key});

  @override
  Widget build(BuildContext context) {
    // -----------------------------------------------------------------
    // Mock Data: เพิ่ม field 'part' เข้ามา
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

    // คำนวณหน่วยกิตรวม
    final int totalEarned = categories.fold(
      0,
      (sum, item) => sum + (item['earned'] as int),
    );
    final int totalRequired = categories.fold(
      0,
      (sum, item) => sum + (item['required'] as int),
    );

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
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. การ์ดสรุปรวม
            TotalCreditCard(
              earnedCredits: totalEarned,
              totalCredits: totalRequired,
              currentGpa: 3.42,
            ),

            const SizedBox(height: 30),

            // 2. หัวข้อ Degree Requirements
            const Text(
              'Degree Requirements',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // 3. รายการหมวดวิชา (ส่งค่า part ไปด้วย)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                return CreditCategoryItem(
                  part: cat['part'], // <-- ส่ง Part
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
