import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class TotalCreditCard extends StatelessWidget {
  final int earnedCredits;
  final int totalCredits;
  final double currentGpa;

  const TotalCreditCard({
    super.key,
    required this.earnedCredits,
    required this.totalCredits,
    required this.currentGpa,
  });

  @override
  Widget build(BuildContext context) {
    double progress = totalCredits > 0 ? earnedCredits / totalCredits : 0.0;
    int percentage = (progress * 100).toInt();

    const double circleSize = 180.0;
    const double strokeWidth = 14.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: circleSize,
                height: circleSize,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: strokeWidth,
                  backgroundColor: AppColors.borderGrey.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.accentYellow,
                  ),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "$percentage%",
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "COMPLETED",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 103, 102, 102),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "$earnedCredits",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: " /$totalCredits",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            "Total Credits Earned",
            style: TextStyle(
              fontSize: 13,
              color: Color.fromARGB(255, 103, 102, 102),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
