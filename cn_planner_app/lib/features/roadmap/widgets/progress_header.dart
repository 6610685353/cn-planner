import 'package:flutter/material.dart';
import 'package:cn_planner_app/core/constants/app_colors.dart';

class ProgressHeader extends StatelessWidget {
  final double currentCredits; // 🔥 รับค่าหน่วยกิตปัจจุบัน

  const ProgressHeader({super.key, required this.currentCredits});

  @override
  Widget build(BuildContext context) {
    const double maxCredits = 146.0; // 🎯 เป้าหมายหน่วยกิตใหม่

    // คำนวณเปอร์เซ็นต์ (ไม่ให้เกิน 1.0)
    double progress = currentCredits / maxCredits;
    if (progress > 1.0) progress = 1.0;
    if (progress < 0) progress = 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(color: AppColors.background),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Progress",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              // 🔥 แสดงเลขปัจจุบัน / 146
              Text(
                "${currentCredits.toStringAsFixed(1)} / $maxCredits Credits",
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Colors.greenAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
