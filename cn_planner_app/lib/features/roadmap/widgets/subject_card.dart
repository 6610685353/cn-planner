import 'package:cn_planner_app/features/roadmap/models/subject_model.dart';
import 'package:flutter/material.dart';
import '../views/roadmap_page.dart';

class SubjectCard extends StatelessWidget {
  final String code;
  final String name;
  final int credits;
  final String state;
  final RoadmapMode mode;
  final String? grade;
  final Function(String)? onGradeChanged;
  final VoidCallback? onDelete;
  final String? section;
  final bool isSuGrade;
  final bool isBlockedByFail;

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
    this.section,
    this.isBlockedByFail = false,
    required this.isSuGrade,
  });

  @override
  Widget build(BuildContext context) {
    bool isMissingPrereq = state == "missing_prereq";

    bool isFailed = state == "failed";
    bool isViewMode = mode == RoadmapMode.view;

    Color cardColor;
    Border cardBorder;

    if (isFailed) {
      cardColor = Colors.red.shade50;
      cardBorder = Border.all(color: Colors.red.shade400, width: 2.0);
    } else if (!isViewMode && isMissingPrereq) {
      cardColor = Colors.white;
      cardBorder = Border.all(color: Colors.red.shade200, width: 1.5);
    } else {
      cardColor = Colors.white;
      cardBorder = Border.all(color: Colors.transparent, width: 1.5);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isFailed ? 0.08 : 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
        border: cardBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔹 LEFT SIDE
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          code,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isFailed
                                ? Colors.red.shade700
                                : Colors.black,
                          ),
                        ),

                        if (section != null &&
                            section!.isNotEmpty &&
                            section != "-") ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "SEC $section",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(width: 8),

                        if (mode == RoadmapMode.simulate)
                          _buildStatusBadge(isMissingPrereq),

                        if (isViewMode && isFailed) _buildFailedBadge(),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      name,
                      style: TextStyle(
                        color: isFailed
                            ? Colors.red.shade400
                            : Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),

                    if (!isViewMode && isMissingPrereq && !isFailed)
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          "Missing Prerequisite",
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),

                    if (isFailed && isViewMode)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          isBlockedByFail
                              ? "Prerequisite received F/W — blocked"
                              : "Received F/W in simulation — needs retake",
                          style: TextStyle(
                            color: Colors.red.shade400,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "$credits Cr.",
                        style: TextStyle(
                          color: isFailed
                              ? Colors.red.shade600
                              : (!isViewMode && isMissingPrereq)
                              ? Colors.red
                              : Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),

                      if (state.toLowerCase() == "passed")
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 14,
                        ),

                      if (isFailed)
                        Icon(
                          Icons.cancel,
                          color: Colors.red.shade400,
                          size: 14,
                        ),

                      if (!isViewMode && isMissingPrereq && !isFailed)
                        const Icon(Icons.lock, color: Colors.red, size: 14),

                      if (mode != RoadmapMode.view)
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            Icons.delete_outline,
                            color: Colors.red.shade300,
                            size: 20,
                          ),
                          onPressed: onDelete,
                        ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  if (mode == RoadmapMode.history)
                    const Text(
                      "GRADE",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (mode == RoadmapMode.history)
                    Text(
                      grade ?? "-",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ],
          ),

          if (mode != RoadmapMode.view &&
              mode != RoadmapMode.simulate &&
              mode != RoadmapMode.history)
            _buildGradeSection(),

          if (mode == RoadmapMode.simulate) _buildSimulateActions(),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isMissing) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isMissing ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isMissing ? "⚠️ Missing Prereq" : "✓ Prereq Met",
        style: TextStyle(
          color: isMissing ? Colors.red : Colors.green,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFailedBadge() {
    final label = isBlockedByFail ? "BLOCKED" : "F/W";
    final bg = isBlockedByFail ? Colors.orange.shade100 : Colors.red.shade100;
    final fg = isBlockedByFail ? Colors.orange.shade800 : Colors.red.shade700;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

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
              items:
                  (isSuGrade
                          ? ['-', 'S', 'U']
                          : [
                              "-",
                              "A",
                              "B+",
                              "B",
                              "C+",
                              "C",
                              "D+",
                              "D",
                              "F",
                              "W",
                            ])
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
              onChanged: (val) =>
                  val != null ? onGradeChanged?.call(val) : null,
            ),
        ],
      ),
    );
  }

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
        onPressed: () {},
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
          color: Colors.grey.shade100.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
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
