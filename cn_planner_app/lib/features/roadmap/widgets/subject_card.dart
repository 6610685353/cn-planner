import 'package:cn_planner_app/features/roadmap/views/course_selection_page.dart';
import 'package:cn_planner_app/features/roadmap/models/subject_model.dart';
import 'package:flutter/material.dart';
import '../views/roadmap_page.dart'; // 🔥 สำหรับการเรียกใช้ RoadmapMode

class SubjectCard extends StatelessWidget {
  final String code;
  final String name;
  final int credits;
  final String state; // "passed", "planned", "simulated", "missing_prereq"
  final RoadmapMode mode;
  final String? grade;
  final Function(String)? onGradeChanged;
  final VoidCallback? onDelete;

  const SubjectCard({
    super.key,
    required this.code,
    required this.name,
    required this.credits,
    required this.state,
    required this.mode,
    this.grade,
    this.onGradeChanged,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // เช็คว่าวิชานี้ติดตัวต่อหรือไม่
    bool isMissingPrereq = state == "missing_prereq";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
        // ถ้าติดตัวต่อให้ขึ้นขอบแดงจางๆ
        border: Border.all(
          color: isMissingPrereq ? Colors.red.shade200 : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      code,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // โชว์ Badge เฉพาะในหน้า Simulator
                    if (mode == RoadmapMode.simulate)
                      _buildStatusBadge(isMissingPrereq),
                  ],
                ),
              ),
              Row(
                children: [
                  Text(
                    "$credits Cr.",
                    style: TextStyle(
                      color: isMissingPrereq ? Colors.red : Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  // แสดงไอคอนสถานะ (ผ่านแล้ว / ติดล็อค)
                  if (state == "passed" || state == "Passed")
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 14,
                    ),
                  if (isMissingPrereq)
                    const Icon(Icons.lock, color: Colors.red, size: 14),

                  // 🔥 ปุ่มลบ: จะโชว์เฉพาะโหมด Edit และ Simulate เท่านั้น
                  if (mode != RoadmapMode.view)
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.red.shade300,
                        size: 22,
                      ),
                      onPressed: onDelete,
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),

          // แสดงส่วนจัดการเกรด (เฉพาะโหมด View และ Edit)
          if (mode != RoadmapMode.simulate) _buildGradeSection(),

          // แสดงปุ่มจำลอง PASS/FAIL (เฉพาะโหมด Simulate)
          if (mode == RoadmapMode.simulate) _buildSimulateActions(),
        ],
      ),
    );
  }

  // Badge บอกว่าผ่านเงื่อนไขวิชาตัวต่อหรือยัง
  Widget _buildStatusBadge(bool isMissing) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isMissing ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isMissing ? "⚠️ Missing Prereq" : "∞ Prereq Met",
        style: TextStyle(
          color: isMissing ? Colors.red : Colors.green,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ส่วนแสดงเกรดหรือดรอปดาวน์เลือกเกรด
  Widget _buildGradeSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text(
            "GRADE",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          if (mode == RoadmapMode.view)
            Text(
              grade ?? "-",
              style: const TextStyle(fontWeight: FontWeight.bold),
            )
          else
            DropdownButton<String>(
              value: (grade == null || grade == "-") ? null : grade,
              hint: const Text(
                "-",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              underline: const SizedBox(),
              items: [
                "-",
                "A",
                "B+",
                "B",
                "C+",
                "C",
                "D",
                "F",
                "W",
              ].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
              onChanged: (val) =>
                  val != null ? onGradeChanged?.call(val) : null,
            ),
        ],
      ),
    );
  }

  // ปุ่มกดสำหรับโหมด Simulator
  Widget _buildSimulateActions() {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Row(
        children: [
          Expanded(
            child: _actionButton("PASS", const Color(0xFF22C55E), Colors.white),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _actionButton(
              "Grade: F/W",
              Colors.grey.shade200,
              Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String label, Color bg, Color fg) {
    return SizedBox(
      height: 32,
      child: ElevatedButton(
        onPressed: () {
          // Logic การจำลองจะถูกจัดการที่ Parent (SimulatorPage)
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class AddCourseButton extends StatelessWidget {
  final VoidCallback onTap;

  const AddCourseButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade100.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          // แสดงขอบเป็นเส้นประจางๆ (ใช้เส้นทึบสีอ่อนแทนเพื่อประสิทธิภาพ)
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline,
                color: Colors.grey.shade500,
                size: 28,
              ),
              const SizedBox(height: 6),
              Text(
                "Add or Drop courses here",
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
