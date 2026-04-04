import 'package:cn_planner_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class SubjectBox extends StatefulWidget {
  final String title;
  final String subtitle;
  final double credits;
  final String? grade; // ✅ allow null
  final int subjectId;
  final bool isChecked;

  final Function(int, bool) onChanged;
  final Function(int, bool) onCheckChanged;
  final Function(String) onGradeChanged;

  const SubjectBox({
    super.key,
    required this.title,
    required this.subtitle,
    required this.credits,
    required this.grade,
    required this.subjectId,
    required this.isChecked,
    required this.onChanged,
    required this.onCheckChanged,
    required this.onGradeChanged,
  });

  @override
  State<SubjectBox> createState() => _SubjectBoxState();
}

class _SubjectBoxState extends State<SubjectBox> {
  final String _defaultValue = "-";
  String _selectedValue = "-";

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.grade ?? _defaultValue; // ✅ กัน null
  }

  @override
  void didUpdateWidget(covariant SubjectBox oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 🔥 sync เวลาค่าเปลี่ยนจากข้างนอก
    if (widget.grade != oldWidget.grade) {
      _selectedValue = widget.grade ?? _defaultValue;
    }
  }

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
              value: widget.isChecked,
              checkColor: Colors.transparent,
              fillColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.accentYellow;
                }
                return Colors.white;
              }),
              onChanged: (bool? value) {
                final bool newValue = value ?? false;

                widget.onChanged(widget.subjectId, newValue);
                widget.onCheckChanged(widget.subjectId, newValue);

                if (!newValue) {
                  // 🔥 reset grade
                  widget.onGradeChanged(_defaultValue);
                  setState(() {
                    _selectedValue = _defaultValue;
                  });
                } else {
                  // 🔥 set default grade ตอนติ๊ก
                  widget.onGradeChanged("-");
                  setState(() {
                    _selectedValue = "-";
                  });
                }
              },
            ),
          ),
          const SizedBox(width: 5),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
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
                enabled: widget.isChecked,
                child: Row(
                  children: [
                    Text(
                      _selectedValue,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: widget.isChecked ? Colors.black : Colors.grey,
                      ),
                    ),
                    if (widget.isChecked) const Icon(Icons.arrow_drop_down),
                  ],
                ),
                onSelected: (String value) {
                  widget.onGradeChanged(value);
                  setState(() {
                    _selectedValue = value;
                  });
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem(value: "-", child: Text("-")), // ✅ เพิ่ม
                  const PopupMenuItem(value: "A", child: Text("A")),
                  const PopupMenuItem(value: "B+", child: Text("B+")),
                  const PopupMenuItem(value: "B", child: Text("B")),
                  const PopupMenuItem(value: "C+", child: Text("C+")),
                  const PopupMenuItem(value: "C", child: Text("C")),
                  const PopupMenuItem(value: "D+", child: Text("D+")),
                  const PopupMenuItem(value: "D", child: Text("D")),
                  const PopupMenuItem(value: "F", child: Text("F")),
                  const PopupMenuItem(value: "W", child: Text("W")),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
