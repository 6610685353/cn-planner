import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class GpaBanner extends StatelessWidget {
  final double gpa;

  const GpaBanner({super.key, required this.gpa});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 358,
      height: 130,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: AppColors.accentYellow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "CURRENT SEMESTER GPA",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                gpa.toStringAsFixed(2),
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),
              const Text(
                "Good Job!",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFFED14F),
              // สีเหลืองเข้มกว่านิดหน่อย
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.emoji_events_outlined, size: 45),
          ),
        ],
      ),
    );
  }
}
