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
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: TextEditingController(text: value),
        enabled: false,
        style: const TextStyle(
          color: Colors.black54,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.textGrey,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),

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
