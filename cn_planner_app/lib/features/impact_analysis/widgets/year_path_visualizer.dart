import 'package:flutter/material.dart';

class YearPathVisualizer extends StatelessWidget {
  final Set<int> changedYears;
  final int delayTerms;
  final double progressPercent;
  final bool canCompleteByBaseline;
  final String baselineLabel;
  final String statusText;

  const YearPathVisualizer({
    super.key,
    required this.changedYears,
    required this.delayTerms,
    required this.progressPercent,
    required this.canCompleteByBaseline,
    required this.baselineLabel,
    required this.statusText,
  });

  bool get hasExtraYear => delayTerms > 0;

  @override
  Widget build(BuildContext context) {
    final headline = canCompleteByBaseline
        ? 'ON TRACK FOR $baselineLabel'
        : '+${(delayTerms / 2).ceil()} YEAR NEEDED';

    final headlineColor = canCompleteByBaseline
        ? const Color(0xFF22C55E)
        : const Color(0xFFEF4444);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Year Path Projection',
          style: TextStyle(
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: headlineColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                canCompleteByBaseline ? Icons.check_circle : Icons.access_time,
                color: headlineColor,
                size: 14,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  headline,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: headlineColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          statusText,
          style: TextStyle(
            color: headlineColor,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ...List.generate(4, (i) {
              final year = i + 1;
              final isImpacted = changedYears.contains(year);

              return _YearBox(
                label: 'Y$year',
                color: isImpacted
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF20C987),
              );
            }),
            _YearBox(
              label: 'Y5+',
              color: hasExtraYear
                  ? const Color(0xFFEF4444)
                  : const Color(0xFFD1D5DB),
            ),
          ],
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: (progressPercent / 100).clamp(0.0, 1.0),
          minHeight: 8,
          backgroundColor: const Color(0xFFF3F4F6),
          valueColor: AlwaysStoppedAnimation<Color>(
            canCompleteByBaseline
                ? const Color(0xFF10B981)
                : const Color(0xFF3B82F6),
          ),
        ),
      ],
    );
  }
}

class _YearBox extends StatelessWidget {
  final String label;
  final Color color;

  const _YearBox({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 55,
      child: Column(
        children: [
          Container(
            width: 55,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
          ),
        ],
      ),
    );
  }
}
