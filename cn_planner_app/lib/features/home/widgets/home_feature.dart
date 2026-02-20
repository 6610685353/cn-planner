import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class HomeFeature extends StatelessWidget {
  final IconData icon;
  final String name;
  final String route;
  final bool isLeft; // เปลี่ยนจาก String? left เป็น bool isLeft

  const HomeFeature({
    super.key,
    required this.icon,
    required this.name,
    required this.route,
    this.isLeft = true, // กำหนดค่าเริ่มต้นเป็นฝั่งซ้าย (สีเหลือง)
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 169,
      height: 130,
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.pushNamed(context, route);
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 61,
                height: 53,
                decoration: BoxDecoration(
                  color: isLeft
                      ? AppColors.accentYellow.withValues(alpha: 0.2)
                      : AppColors.errorRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isLeft ? AppColors.primaryYellow : AppColors.errorRed,
                  size: 30,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
