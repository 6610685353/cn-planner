import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ProfileInfo extends StatelessWidget {
  final String name;
  final String subtitle;

  const ProfileInfo({super.key, required this.name, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textDarkGrey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),

        const SizedBox(height: 5),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.lightRed,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.engineering, color: AppColors.errorRed, size: 16),
              SizedBox(width: 6),
              Text(
                "Computer Engineering",
                style: TextStyle(
                  color: AppColors.errorRed,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
