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
        // ✅ เทอม passed → พื้นหลัง Modern Soft Cool Gray
        color: course.status == CourseStatus.passed
            ? const Color(0xFFF8F9FA)
            : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: course.status == CourseStatus.passed
              ? const Color(0xFFEDEEF1)
              : const Color(0xFFE0E0E0),
          width: 1.2,
        ),
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
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: course.status == CourseStatus.passed
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF1A1A1A),
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
                        : course.outcome == CourseOutcome.withdraw
                        ? const Color(0xFFFF9800)
                        : const Color(0xFF9E9E9E),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 4),
                _buildOutcomeIcon(),
              ],
            ),
            const SizedBox(height: 0),
            Text(
              course.name,
              style: TextStyle(
                fontSize: 14,
                color: course.status == CourseStatus.passed
                    ? const Color(0xFF9CA3AF)
                    : const Color(0xFF616161),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            _OutcomeControl(
              course: course,
              isEditable: isEditable,
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

class _OutcomeControl extends StatelessWidget {
  final CourseModel course;
  final bool isEditable;
  final ValueChanged<CourseOutcome>? onChanged;

  const _OutcomeControl({
    required this.course,
    required this.isEditable,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (course.status == CourseStatus.upcoming) {
      return _LockedBadge();
    }
    if (course.status == CourseStatus.passed) {
      return _PassedOutcomeBadge(outcome: course.outcome);
    }
    return _OutcomeSegmentedControl(
      outcome: course.outcome,
      onChanged: onChanged,
    );
  }
}

// ✅ Upcoming - Modern Locked Badge
class _LockedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 43,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
      ),
      child: const Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 16,
              color: Color(0xFF9CA3AF),
            ),
            SizedBox(width: 8),
            Text(
              'Pending Enrollment',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
                fontSize: 13,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ Passed - Modern Badge (Removed "From transcript")
class _PassedOutcomeBadge extends StatelessWidget {
  final CourseOutcome outcome;
  const _PassedOutcomeBadge({required this.outcome});

  @override
  Widget build(BuildContext context) {
    final bool isPassed = outcome == CourseOutcome.pass;
    final bool isFail = outcome == CourseOutcome.fail;
    final bool isWithdraw = outcome == CourseOutcome.withdraw;

    Color bgColor;
    Color textColor;
    Color borderColor;
    IconData icon;
    String label;

    if (isPassed) {
      bgColor = const Color(0xFFDCFCE7);
      textColor = const Color(0xFF166534);
      borderColor = const Color(0xFFBBF7D0);
      icon = Icons.check_circle_rounded;
      label = 'PASS';
    } else if (isFail) {
      bgColor = const Color(0xFFFEE2E2);
      textColor = const Color(0xFF991B1B);
      borderColor = const Color(0xFFFECACA);
      icon = Icons.cancel_rounded;
      label = 'Grade F';
    } else if (isWithdraw) {
      bgColor = const Color(0xFFFFEDD5);
      textColor = const Color(0xFF9A3412);
      borderColor = const Color(0xFFFED7AA);
      icon = Icons.remove_circle_rounded;
      label = 'Withdrawn';
    } else {
      bgColor = const Color(0xFFF3F4F6);
      textColor = const Color(0xFF6B7280);
      borderColor = const Color(0xFFE5E7EB);
      icon = Icons.help_outline_rounded;
      label = 'Unknown';
    }

    return Container(
      height: 43,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ⛔ Current Term - No changes made
class _OutcomeSegmentedControl extends StatelessWidget {
  final CourseOutcome outcome;
  final ValueChanged<CourseOutcome>? onChanged;

  const _OutcomeSegmentedControl({
    required this.outcome,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPassed = outcome == CourseOutcome.pass;

    return GestureDetector(
      onTap: () =>
          onChanged?.call(isPassed ? CourseOutcome.fail : CourseOutcome.pass),
      child: Container(
        height: 43,
        decoration: BoxDecoration(
          color: const Color(0xFFBDBDBD),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
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
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Row(
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
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
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
