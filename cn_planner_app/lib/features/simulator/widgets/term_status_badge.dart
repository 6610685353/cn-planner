import 'package:flutter/material.dart';
import '../models/term_model.dart';

class TermStatusBadge extends StatelessWidget {
  final TermStatus status;

  const TermStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    Color borderColor;
    String label;

    switch (status) {
      case TermStatus.passed:
        bgColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF00C853);
        borderColor = const Color(0xFF00C853).withOpacity(0.5);
        label = 'Passed';
        break;
      case TermStatus.current:
        bgColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF1565C0);
        borderColor = const Color(0xFF1565C0).withOpacity(0.5);
        label = 'Current';
        break;
      case TermStatus.upcoming:
        bgColor = const Color(0xFFF5F5F5);
        textColor = const Color(0xFF616161);
        borderColor = const Color(0xFFBDBDBD);
        label = 'Upcoming';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}
