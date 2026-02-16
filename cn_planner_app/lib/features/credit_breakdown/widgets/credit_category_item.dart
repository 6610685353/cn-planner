import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CreditCategoryItem extends StatelessWidget {
  final String part;
  final String categoryName;
  final int earned;
  final int required;
  final Color color;

  const CreditCategoryItem({
    super.key,
    required this.part,
    required this.categoryName,
    required this.earned,
    required this.required,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = required > 0 ? earned / required : 0.0;
    final bool isCompleted = earned >= required;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.borderGrey.withOpacity(0.6)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- ส่วนซ้าย: ข้อมูลหมวดวิชา (ปรับขนาดพอดีคำ) ---
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      part.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.errorRed,
                        fontWeight: FontWeight.bold,
                        fontSize: 10, // เล็กลงหน่อย
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      categoryName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16, // ขนาดมาตรฐาน 16
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isCompleted
                          ? 'Completed'
                          : '${required - earned} credits left',
                      style: TextStyle(
                        fontSize: 12, // ขนาดมาตรฐาน 12
                        color: isCompleted ? Colors.green : AppColors.textGrey,
                        fontWeight: isCompleted
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // --- ส่วนขวา: วงรีแสดงหน่วยกิต (ขนาดพอดี) ---
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$earned',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14, // ตัวเลขไม่ใหญ่เกินไป
                          color: Colors.black,
                        ),
                      ),
                      const TextSpan(
                        text: ' / ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      TextSpan(
                        text: '$required',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          // --- เส้นแถบ Progress Bar (ความหนามาตรฐาน) ---
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress > 1.0 ? 1.0 : progress,
              minHeight: 7,
              backgroundColor: AppColors.borderGrey.withOpacity(0.5),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.errorRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
