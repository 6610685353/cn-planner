import 'package:cn_planner_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class SubjectBox extends StatefulWidget {
  final String title;
  final String subtitle;
  final double credits;
  final String grade;
  final Function(bool) onChanged;

  const SubjectBox({
    super.key,
    required this.title,
    required this.subtitle,
    required this.credits,
    required this.grade,
    required this.onChanged,
  });

  @override
  State<SubjectBox> createState() => _SubjectBoxState();
}

class _SubjectBoxState extends State<SubjectBox> {
  bool _isChecked = false;
  String _selectedValue = "A";

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Transform.scale(
            scale: 1.5,
            child: Checkbox(
              value: _isChecked,
              checkColor: Color.fromARGB(0, 0, 0, 0),
              fillColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.accentYellow;
                }
                return Colors.white;
              }),
              onChanged: (bool? value) {
                setState(() {
                  _isChecked = value!;
                });
                widget.onChanged(_isChecked);
              },
            ),
          ),
          const SizedBox(width: 5),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lightBlue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${widget.credits.toInt()} Credits",
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  widget.subtitle,
                  style: TextStyle(color: AppColors.textGrey, fontSize: 13),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "GRADE",
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              PopupMenuButton<String>(
                child: Row(
                  children: [
                    Text(
                      _selectedValue,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, color: Colors.black),
                  ],
                ),
                onSelected: (String value) {
                  setState(() {
                    _selectedValue = value;
                  });
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem(value: "A", child: Text("A")),
                  const PopupMenuItem(value: "B+", child: Text("B+")),
                  const PopupMenuItem(value: "B", child: Text("B")),
                  const PopupMenuItem(value: "C+", child: Text("C+")),
                  const PopupMenuItem(value: "C", child: Text("C")),
                  const PopupMenuItem(value: "D+", child: Text("D+")),
                  const PopupMenuItem(value: "D", child: Text("D")),
                  const PopupMenuItem(value: "F", child: Text("F")),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
