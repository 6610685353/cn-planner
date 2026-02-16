import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class QuickStats extends StatelessWidget {
  final String title;
  final String mainText;
  final String footer;

  const QuickStats({
    super.key,
    required this.title,
    required this.mainText,
    required this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textDarkGrey,
            ),
          ),
          const SizedBox(height: 2),

          Text(
            mainText,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 2),

          Text(
            footer,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textGrey,
            ),
          ),
        ],
      ),
    );
  }
}
