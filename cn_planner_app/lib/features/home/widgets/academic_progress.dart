import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AcademicProgresss extends StatelessWidget {
  final int totalCredit;
  final int creditEarned;
  final String route;

  const AcademicProgresss({
    super.key,
    required this.creditEarned,
    required this.totalCredit,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    double progress = creditEarned / totalCredit;
    int percentage = (progress * 100).toInt();
    int remaining = totalCredit - creditEarned;

    return Container(
      width: 358,
      height: 210,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "ACADEMIC PROGRESS",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkYellow,
                      letterSpacing: 0.5,
                    ),
                  ),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        "$creditEarned",
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "/$totalCredit",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    "Credits Earned",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
              // --- วงกลมเปอร์เซ็นต์ ---
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 10,
                      backgroundColor: AppColors.borderGrey.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.accentYellow,
                      ),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Text(
                    "$percentage%",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentYellow,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 4),
          const Divider(height: 1, color: AppColors.borderGrey),
          const Spacer(),

          // --- ส่วนล่าง: ข้อความตัวเอียง และ ปุ่ม View Breakdown สีเหลือง ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "$remaining credits remaining to\ngraduate",
                  style: const TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600, // ตัวเอียงตามรูป
                    color: AppColors.textGrey,
                  ),
                ),
              ),
              // --- ปุ่มสีเหลืองตามดีไซน์ ---
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, route);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentYellow,
                    borderRadius: BorderRadius.circular(30), // มนแบบเม็ดยา
                  ),
                  child: Row(
                    children: const [
                      Text(
                        "View\nBreakdown",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 20, color: Colors.black),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
