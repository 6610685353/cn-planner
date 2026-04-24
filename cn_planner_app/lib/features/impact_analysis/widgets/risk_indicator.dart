import 'package:flutter/material.dart';

class RiskIndicator extends StatelessWidget {
  final int failCount;
  final int withdrawCount;

  const RiskIndicator({
    super.key,
    required this.failCount,
    required this.withdrawCount,
  });

  _RiskLevel get _level {
    final total = failCount + withdrawCount;
    if (failCount >= 3 || total >= 5) return _RiskLevel.critical;
    if (failCount >= 2 || total >= 3) return _RiskLevel.high;
    if (failCount >= 1 || total >= 2) return _RiskLevel.medium;
    return _RiskLevel.low;
  }

  @override
  Widget build(BuildContext context) {
    final level = _level;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Risk Level',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              level.label,
              style: TextStyle(
                color: level.color,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            _bar(
              const Color(0xFF22C55E),
              filled: level.index >= _RiskLevel.low.index,
            ),
            const SizedBox(width: 4),
            _bar(
              const Color(0xFFEAB308),
              filled: level.index >= _RiskLevel.medium.index,
            ),
            const SizedBox(width: 4),
            _bar(
              const Color(0xFFF97316),
              filled: level.index >= _RiskLevel.high.index,
            ),
            const SizedBox(width: 4),
            _bar(
              const Color(0xFFEF4444),
              filled: level.index >= _RiskLevel.critical.index,
            ),
          ],
        ),
      ],
    );
  }

  Widget _bar(Color color, {required bool filled}) => Expanded(
    child: Container(
      height: 6,
      decoration: BoxDecoration(
        color: filled ? color : color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );
}

enum _RiskLevel { low, medium, high, critical }

extension _RiskLevelExt on _RiskLevel {
  String get label => switch (this) {
    _RiskLevel.low => 'LOW',
    _RiskLevel.medium => 'MEDIUM',
    _RiskLevel.high => 'HIGH',
    _RiskLevel.critical => 'CRITICAL',
  };

  Color get color => switch (this) {
    _RiskLevel.low => const Color(0xFF22C55E),
    _RiskLevel.medium => const Color(0xFFEAB308),
    _RiskLevel.high => const Color(0xFFF97316),
    _RiskLevel.critical => const Color(0xFFEF4444),
  };
}
