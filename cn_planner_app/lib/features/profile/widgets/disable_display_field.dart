import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class DisabledDisplayField extends StatelessWidget {
  final String value;

  const DisabledDisplayField({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        // ใช้ TextEditingController เพื่อใส่ค่าเริ่มต้น
        controller: TextEditingController(text: value),
        enabled: false, // ล็อกไม่ให้แก้ไข และไม่ให้คีย์บอร์ดเด้ง
        style: const TextStyle(
          color:
              Colors.black54, // สีตัวอักษรให้ออกเทานิดๆ เพื่อให้รู้ว่าแก้ไม่ได้
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.textGrey, // ถมสีเทาอ่อน (Light Grey)
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          // ตั้งค่า Border ตอนที่มัน Disabled ให้เหมือนเดิม
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(
              color: AppColors.borderGrey,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
