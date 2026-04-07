import 'package:flutter/material.dart';
import '../models/course_model.dart';

class CourseCardWidget extends StatelessWidget {
  final CourseModel course;
  final bool isEditable;
  final ValueChanged<CourseOutcome>? onOutcomeChanged;

  const CourseCardWidget({
    super.key,
    required this.course,
    this.isEditable = false,
    this.onOutcomeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  course.code,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                    height: 1.8,
                  ),
                ),
                const SizedBox(width: 8),
                if (course.prerequisites.isNotEmpty &&
                    course.status != CourseStatus.passed)
                  _PrereqBadge(),
                const Spacer(),
                Text(
                  '${course.credits} Cr.',
                  style: TextStyle(
                    fontSize: 15,
                    color: course.outcome == CourseOutcome.pass
                        ? const Color(0xFF00C853)
                        : course.outcome == CourseOutcome.fail
                        ? const Color(0xFFE53935)
                        : const Color(0xFF9E9E9E),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 4),
                _buildOutcomeIcon(),
              ],
            ),
            // 3. ลดระยะห่างระหว่าง Code และ Name (จาก 3 เหลือ 0 หรือ 1 ตามต้องการ)
            const SizedBox(height: 0),
            Text(
              course.name,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF616161),
                fontWeight: FontWeight.w500,
              ),
            ),
            // 4. ลดระยะห่างก่อนถึงตัวสไลด์ด้านล่าง (จาก 11 เหลือ 8)
            const SizedBox(height: 8),
            _OutcomeSegmentedControl(
              outcome: course.outcome,
              isClickable: isEditable,
              onChanged: onOutcomeChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutcomeIcon() {
    switch (course.outcome) {
      case CourseOutcome.pass:
        return const Icon(
          Icons.check_circle,
          color: Color(0xFF00C853),
          size: 22,
        );
      case CourseOutcome.fail:
        return const Icon(Icons.cancel, color: Color(0xFFE53935), size: 22);
      case CourseOutcome.withdraw:
        return const Icon(
          Icons.remove_circle,
          color: Color(0xFFFF9800),
          size: 18,
        );
      case CourseOutcome.notSet:
        return const Icon(
          Icons.check_circle,
          color: Color(0xFFCCCCCC),
          size: 18,
        );
    }
  }
}

// ─────────────────────────────────────────────
// Sliding Segmented Control
// ─────────────────────────────────────────────
class _OutcomeSegmentedControl extends StatelessWidget {
  final CourseOutcome outcome;
  final bool isClickable;
  final ValueChanged<CourseOutcome>? onChanged;

  const _OutcomeSegmentedControl({
    required this.outcome,
    required this.isClickable,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPassed = outcome == CourseOutcome.pass;

    return GestureDetector(
      onTap: isClickable
          ? () => onChanged?.call(
              isPassed ? CourseOutcome.fail : CourseOutcome.pass,
            )
          : null,
      child: Container(
        height: 43,
        decoration: BoxDecoration(
          color: const Color(0xFFBDBDBD),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            // ── Sliding thumb ──
            AnimatedAlign(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              alignment: isPassed
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isPassed
                        ? const Color(0xFF00C853)
                        : const Color(0xFFE53935),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Labels ──
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      'PASS',
                      style: TextStyle(
                        color: Colors.white,

                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Grade: F/W',
                      style: TextStyle(
                        color: Colors.white,

                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Prereq Badge
// ─────────────────────────────────────────────
class _PrereqBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        border: Border.all(color: const Color(0xFF66BB6A), width: 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 11,
            color: Color(0xFF43A047),
          ),
          SizedBox(width: 3),
          Text(
            'Prereq Met',
            style: TextStyle(
              fontSize: 10.5,
              color: Color(0xFF43A047),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
