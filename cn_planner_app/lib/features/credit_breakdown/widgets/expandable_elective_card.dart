import 'package:flutter/material.dart';
import 'package:cn_planner_app/core/constants/app_colors.dart';

class ExpandableElectiveCard extends StatelessWidget {
  final String part;
  final String categoryName;
  final int earned;
  final int required;
  final Color color;
  final List<dynamic> addedCourses;
  final VoidCallback onAddPressed;
  final Function(String) onDeletePressed;

  const ExpandableElectiveCard({
    super.key,
    required this.part,
    required this.categoryName,
    required this.earned,
    required this.required,
    required this.color,
    required this.addedCourses,
    required this.onAddPressed,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    // เช็คว่าหน่วยกิตถึงเกณฑ์หรือยัง
    bool isCompleted = earned >= required;

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isCompleted ? Colors.green.shade300 : Colors.grey.shade200,
          width: isCompleted ? 2 : 1,
        ),
      ),
      child: Theme(
        // ปิดเส้นขอบเวลาคลิกกาง ExpansionTile
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: color,
          collapsedIconColor: color,
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          title: Text(
            "$part: $categoryName",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                Icon(
                  isCompleted ? Icons.check_circle : Icons.pending,
                  size: 16,
                  color: isCompleted ? Colors.green : AppColors.textGrey,
                ),
                const SizedBox(width: 6),
                Text(
                  "Earned: $earned / $required",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? Colors.green : AppColors.textDarkGrey,
                  ),
                ),
              ],
            ),
          ),
          children: [
            const Divider(height: 1),
            // พื้นที่แสดงรายวิชาที่เพิ่มมา
            if (addedCourses.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  "No courses added yet.\nTap the button below to add.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),

            // ลูปสร้างรายการวิชา
            ...addedCourses.map(
              (course) => ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                title: Text(
                  course['subject_code'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "Grade: ${course['grade']}  •  Credits: ${course['credits']}",
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  onPressed: () {
                    // โชว์ Dialog คอนเฟิร์มก่อนลบ
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Delete Course?"),
                        content: Text(
                          "Are you sure you want to remove ${course['subject_code']}?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              onDeletePressed(course['id']); // สั่งลบ
                            },
                            child: const Text(
                              "Delete",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            // ปุ่ม Add Course สีเหลืองเด่นๆ
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accentYellow,
                    side: BorderSide(color: AppColors.accentYellow),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: onAddPressed,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text(
                    "Add Course Manually",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
