import 'package:flutter/material.dart';
import 'package:cn_planner_app/features/gpa_calculator/widgets/swipe_to_reveal.dart';

class CourseCard extends StatelessWidget {
  final String name;
  final double credit;
  final String grade;
  final List<String> gradeOptions;
  final ValueChanged<String?> onGradeChanged;
  final VoidCallback onDelete;

  const CourseCard({
    super.key, 
    required this.name,
    required this.credit,
    required this.grade,
    required this.gradeOptions,
    required this.onGradeChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // The inner card content
    Widget cardContent = Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween, // Remove this since we have Expanded
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD), // Light Blue
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${credit.toStringAsFixed(0)} Credits", // e.g. "3 Credits"
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF1976D2), // Blue
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Grade Column (Centered)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Centered alignment
              children: [
                const Text(
                  "GRADE",
                  style: TextStyle(
                    color: Color(0xFF1976D2),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                DropdownButton<String>(
                  value: grade,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.black54,
                  ),
                  underline: const SizedBox(), // Remove underline
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black87,
                  ),
                  items: gradeOptions.map((g) {
                    return DropdownMenuItem(value: g, child: Text(g));
                  }).toList(),
                  onChanged: onGradeChanged,
                ),
              ],
            ),
          ),

          // Removed standard Delete Button
        ],
      ),
    );

    return SwipeToReveal(
      action: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete_outline, color: Colors.white, size: 28),
          SizedBox(height: 4),
          Text(
            "Delete",
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      onAction: onDelete,
      child: cardContent,
    );
  }
}