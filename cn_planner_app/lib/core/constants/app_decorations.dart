import 'package:flutter/material.dart';

class AppDecorations {
  static BoxDecoration shadowBox({
    Color color = Colors.white,
    double borderRadius = 20.0,
  }) {
    return BoxDecoration(
      color: color,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }
}
