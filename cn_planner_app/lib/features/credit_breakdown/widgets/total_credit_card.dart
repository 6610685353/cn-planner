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
    // คำนวณค่า Progress (ป้องกันการหารด้วยศูนย์)
    double progress = totalCredits > 0 ? earnedCredits / totalCredits : 0.0;
    // คำนวณ %
    int percentage = (progress * 100).toInt();

    // กำหนดขนาดของวงกลมตรงนี้
    const double circleSize = 180.0;
    const double strokeWidth = 14.0;

    return Container(
      width: double.infinity,
      // เพิ่ม padding บนล่างให้ดูโปร่งขึ้น
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
          // --- ส่วนที่ 1: วงกลมใหญ่และข้อความข้างใน (เปอร์เซ็นต์) ---
          Stack(
            alignment: Alignment.center,
            children: [
              // ตัววงกลม Progress Indicator
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
              // ข้อความตรงกลางวงกลม (Percent)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "$percentage%",
                    style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w800, // หนาพิเศษ
                      color: Colors.black,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "COMPLETED",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 103, 102, 102),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24), // ระยะห่าง
          // --- ส่วนที่ 2: ข้อความด้านล่าง (จำนวนหน่วยกิต แยกสี) ---
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "$earnedCredits", // ตัวเลขหน่วยกิตที่ได้ (สีดำ)
                  style: const TextStyle(
                    fontSize: 36,
                    // fontWeight: FontWeight.bold,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: " /$totalCredits", // ตัวหารหน่วยกิตทั้งหมด (สีเทา)
                  style: const TextStyle(
                    fontSize: 25,
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
              fontSize: 14,
              color: Color.fromARGB(255, 103, 102, 102),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
