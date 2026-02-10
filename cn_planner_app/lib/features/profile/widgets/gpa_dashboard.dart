import 'package:flutter/material.dart';
import 'dart:math';
import '../../../core/constants/app_colors.dart';

class GpaDashboard extends StatelessWidget {
  final double gpax;
  final double gpa;

  const GpaDashboard({super.key, required this.gpax, required this.gpa});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 358,
      height: 206,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.errorRed,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.bar_chart,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                "GPA Dashboard",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildGpaCircle("Cumul.", gpax),
              _buildGpaCircle("Semest.", gpa),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildGpaCircle(String label, double value) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 1. วงกลมชิ้นเดียว 8 ส่วนสีสลับ (แดงตรง 12, 3, 6, 9)
        SizedBox(
          width: 100,
          height: 100,
          child: CustomPaint(painter: DesignGpaPainter()),
        ),

        // 2. ตัวเลขเกรดและตัวอักษรสีเทาอ่อนข้างใน
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value.toStringAsFixed(2),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                height: 1.1,
              ),
            ),
            SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textGrey, // สีเทาอ่อน
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class DesignGpaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = 8.0; // ความหนาของวง
    Rect rect = Offset.zero & size;

    Paint yellowPaint = Paint()
      ..color = AppColors.accentYellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    Paint redPaint = Paint()
      ..color = AppColors.errorRed
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // แบ่ง 8 ส่วน ส่วนละ 45 องศา (pi / 4)
    // เพื่อให้สีแดงอยู่ตรง 12 นาฬิกาพอดี เราต้องเริ่มวาดชิ้นแรกที่มุม -90 องศา ลบออกครึ่งหนึ่งของขนาดชิ้น
    double startAngle = (-pi / 2) - (pi / 8);
    double sweepAngle = pi / 4; // 45 องศาต่อชิ้น

    for (int i = 0; i < 8; i++) {
      // สลับสี: ชิ้นที่ 0, 2, 4, 6 เป็นสีแดง (เพื่อให้ตรงตำแหน่ง 12, 3, 6, 9)
      // ชิ้นที่ 1, 3, 5, 7 เป็นสีเหลือง
      Paint currentPaint = (i % 2 == 0) ? redPaint : yellowPaint;

      canvas.drawArc(
        rect,
        startAngle + (i * sweepAngle),
        sweepAngle + 0.01, // +0.01 เพื่อให้สีชนกันสนิทพอดีเป็นชิ้นเดียว
        false,
        currentPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
