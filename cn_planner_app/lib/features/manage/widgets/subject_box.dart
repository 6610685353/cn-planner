import 'package:cn_planner_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class SubjectBox extends StatefulWidget {
  final String title;
  final String subtitle;
  final double credits;
  final String? grade;
  final String? section; // ✅ เพิ่ม section
  final List<String> availableSections; // ✅ รายการ section ที่ให้เลือก
  final int subjectId;
  final bool isChecked;

  final Function(int, bool) onChanged;
  final Function(int, bool) onCheckChanged;
  final Function(String) onGradeChanged;
  final Function(String) onSectionChanged; // ✅ callback สำหรับ section
  final List<String> reasons; // ✅ เพิ่มรายการเหตุผลสำหรับแต่ละวิชา

  const SubjectBox({
    super.key,
    required this.title,
    required this.subtitle,
    required this.credits,
    required this.grade,
    this.section, // ✅ allow null
    this.availableSections = const ["1", "2", "3"], // ✅ default sections
    required this.subjectId,
    required this.isChecked,
    required this.onChanged,
    required this.onCheckChanged,
    required this.onGradeChanged,
    required this.onSectionChanged, // ✅ เพิ่ม
    required this.reasons, // ✅ เพิ่ม
  });

  @override
  State<SubjectBox> createState() => _SubjectBoxState();
}

class _SubjectBoxState extends State<SubjectBox> {
  final String _defaultGrade = "-";
  final String _defaultSection = "-";

  String _selectedGrade = "-";
  String _selectedSection = "-";

  @override
  void initState() {
    super.initState();
    _selectedGrade = widget.grade ?? _defaultGrade;
    _selectedSection = widget.section ?? _defaultSection;
  }

  @override
  void didUpdateWidget(covariant SubjectBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.grade != oldWidget.grade) {
      _selectedGrade = widget.grade ?? _defaultGrade;
    }
    if (widget.section != oldWidget.section) {
      _selectedSection = widget.section ?? _defaultSection;
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
          // --- Checkbox ---
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
                  widget.onGradeChanged(_defaultGrade);
                  widget.onSectionChanged(_defaultSection);
                  setState(() {
                    _selectedGrade = _defaultGrade;
                    _selectedSection = _defaultSection;
                  });
                } else {
                  widget.onGradeChanged("-");
                  // ไม่รีเซ็ต section ถ้าติ๊กถูก (หรือจะรีเซ็ตก็ได้แล้วแต่ logic)
                }
              },
            ),
          ),
          const SizedBox(width: 5),

          // --- Subject Info ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.title,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
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
                if (widget.reasons.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      widget.reasons.join(", "),
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // --- Section Selector ---
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "SECTION",
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              PopupMenuButton<String>(
                enabled: widget.isChecked,
                child: Row(
                  children: [
                    Text(
                      _selectedSection,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: widget.isChecked ? Colors.black : Colors.grey,
                      ),
                    ),
                    if (widget.isChecked)
                      const Icon(Icons.arrow_drop_down, size: 20),
                  ],
                ),
                onSelected: (String value) {
                  widget.onSectionChanged(value);
                  setState(() {
                    _selectedSection = value;
                  });
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem(value: "-", child: Text("-")),
                  ...widget.availableSections.map(
                    (sec) => PopupMenuItem(value: sec, child: Text(sec)),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(width: 12),

          // --- Grade Selector ---
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "GRADE",
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              PopupMenuButton<String>(
                enabled: widget.isChecked,
                child: Row(
                  children: [
                    Text(
                      _selectedGrade,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: widget.isChecked ? Colors.black : Colors.grey,
                      ),
                    ),
                    if (widget.isChecked)
                      const Icon(Icons.arrow_drop_down, size: 20),
                  ],
                ),
                onSelected: (String value) {
                  widget.onGradeChanged(value);
                  setState(() {
                    _selectedGrade = value;
                  });
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem(value: "-", child: Text("-")),
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
