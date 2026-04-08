import 'package:flutter/material.dart';
import '../../simulator/models/term_model.dart';
import '../../simulator/services/simulator_service.dart';
import '../../simulator/services/simulation_result_model.dart';
import '../widgets/risk_indicator.dart';
import '../widgets/year_path_visualizer.dart';

class ImpactAnalysisPage extends StatefulWidget {
  final List<TermModel> terms;
  final SimulationResult result;

  const ImpactAnalysisPage({
    super.key,
    required this.terms,
    required this.result,
  });

  @override
  State<ImpactAnalysisPage> createState() => _ImpactAnalysisPageState();
}

class _ImpactAnalysisPageState extends State<ImpactAnalysisPage> {
  bool _isSaving = false;
  bool _saved = false;

  Future<void> _onSave() async {
    setState(() => _isSaving = true);
    try {
      await SimulatorService.saveSimulation(terms: widget.terms);
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _saved = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '✅ Simulation saved',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Color(0xFF1565C0),
          behavior: SnackBarBehavior.floating,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Save failed: $e',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.result.summary;
    final impacts = widget.result.impacts.where((e) {
      final match = RegExp(
        r'Year\s+(\d+)\s*/\s*Term\s*(\d+)',
      ).firstMatch(e.normalTerm);
      if (match == null) return true;
      final year = int.tryParse(match.group(1) ?? '0') ?? 0;
      final term = int.tryParse(match.group(2) ?? '0') ?? 0;
      return (year < 4) || (year == 4 && term <= 2);
    }).toList();

    final warnings = widget.result.warnings;
    final yearPath = widget.result.yearPathSummary;
    final progress = (s.earnedCredits / s.totalCredits).clamp(0.0, 1.0);
    final isGraduating = progress >= 1.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Impact Analysis',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 16),
              child: Text(
                'IMPACT DASHBOARD',
                style: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            if (warnings.isNotEmpty) ...[
              ...warnings.map((w) => _WarningBanner(message: w)),
              const SizedBox(height: 12),
            ],
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RiskIndicator(
                          failCount: s.failCount,
                          withdrawCount: s.withdrawCount,
                        ),
                        const SizedBox(height: 24),
                        _CreditProgress(
                          earnedCredits: s.earnedCredits,
                          totalCredits: s.totalCredits,
                          progress: progress,
                          isGraduating: isGraduating,
                        ),
                        const SizedBox(height: 32),
                        YearPathVisualizer(
                          changedYears: yearPath.changedYears.toSet(),
                          delayTerms: yearPath.delayTerms,
                          progressPercent: s.progressPercent,
                          canCompleteByBaseline:
                              yearPath.canCompleteByYear4Term2,
                          baselineLabel: yearPath.baselineLabel,
                          statusText: yearPath.statusText,
                        ),
                      ],
                    ),
                  ),
                  if (impacts.isNotEmpty) ...[
                    const Divider(
                      color: Color(0xFFF3F4F6),
                      thickness: 1.5,
                      height: 1,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.list_alt_rounded,
                                size: 20,
                                color: Color(0xFF4B5563),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Impacted Courses',
                                style: TextStyle(
                                  color: Color(0xFF1F2937),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ...impacts.map((e) => _ImpactCard(impact: e)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: (_isSaving || _saved) ? null : _onSave,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Color(0xFF166534),
                          ),
                        )
                      : Icon(
                          _saved
                              ? Icons.check_circle
                              : Icons.check_circle_outline,
                          color: (_isSaving || _saved)
                              ? Colors.grey
                              : const Color(0xFF166534),
                          size: 22,
                        ),
                  label: Text(
                    _saved
                        ? 'Simulation Saved'
                        : _isSaving
                        ? 'Saving...'
                        : 'Save Simulation',
                    style: TextStyle(
                      color: (_isSaving || _saved)
                          ? Colors.grey.shade600
                          : const Color(0xFF166534),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD1FAE5),
                    disabledBackgroundColor: const Color(
                      0xFFD1FAE5,
                    ).withValues(alpha: 0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _CreditProgress extends StatelessWidget {
  final int earnedCredits;
  final int totalCredits;
  final double progress;
  final bool isGraduating;

  const _CreditProgress({
    required this.earnedCredits,
    required this.totalCredits,
    required this.progress,
    required this.isGraduating,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Earned Credits',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            Text(
              '$earnedCredits / $totalCredits',
              style: const TextStyle(
                color: Color(0xFF1F2937),
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: const Color(0xFFF3F4F6),
            valueColor: AlwaysStoppedAnimation<Color>(
              isGraduating ? const Color(0xFF10B981) : const Color(0xFF3B82F6),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isGraduating
              ? '🎓 Graduation completed'
              : '${(progress * 100).toStringAsFixed(1)}% toward graduation',
          style: TextStyle(
            color: isGraduating
                ? const Color(0xFF059669)
                : const Color(0xFF4B5563),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _WarningBanner extends StatelessWidget {
  final String message;
  const _WarningBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFEDD5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFF97316),
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFFC2410C),
                fontWeight: FontWeight.w600,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImpactCard extends StatelessWidget {
  final CourseImpact impact;
  const _ImpactCard({required this.impact});

  @override
  Widget build(BuildContext context) {
    final isFail = impact.outcome == 'fail';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isFail
                        ? const Color(0xFFFEE2E2)
                        : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isFail ? 'F' : 'W',
                    style: TextStyle(
                      color: isFail
                          ? const Color(0xFFDC2626)
                          : const Color(0xFFD97706),
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${impact.code} - ${impact.name}',
                        style: const TextStyle(
                          color: Color(0xFF1F2937),
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Normal term: ${impact.normalTerm}',
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (impact.blockedCourses.isNotEmpty ||
                impact.retakeOptions.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: Color(0xFFE5E7EB)),
              ),
              if (impact.blockedCourses.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.block_flipped,
                        size: 16,
                        color: Color(0xFFEF4444),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Blocked: ${impact.blockedCourses.map((e) => e.code).join(", ")}',
                          style: const TextStyle(
                            color: Color(0xFFDC2626),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (impact.retakeOptions.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    'When to retake',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF374151),
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ...impact.retakeOptions.map((r) => _RetakeTermRow(option: r)),
            ],
          ],
        ),
      ),
    );
  }
}

class _RetakeTermRow extends StatelessWidget {
  final RetakeOption option;
  const _RetakeTermRow({required this.option});

  @override
  Widget build(BuildContext context) {
    final bool available = option.canRetake;
    final bool notOffered = !option.termAvailable;
    final bool creditsFull =
        !available && !notOffered && option.wouldExceedLimit;
    final bool conflict =
        !available && !notOffered && option.conflicts.isNotEmpty;

    final Color statusColor;
    final String statusLabel;

    if (available) {
      statusColor = const Color(0xFF16A34A);
      statusLabel = 'Available';
    } else if (notOffered) {
      statusColor = const Color(0xFF9CA3AF);
      statusLabel = 'Not offered this term';
    } else if (creditsFull && !conflict) {
      statusColor = const Color(0xFFD97706);
      statusLabel =
          'Available — but adding this course would exceed ${option.creditsAfterRetake}/${option.maxCredits} credits';
    } else if (conflict && !creditsFull) {
      final names = option.conflicts.map((c) => c.code).join(', ');
      statusColor = const Color(0xFFDC2626);
      statusLabel = 'Conflict — schedule overlaps with $names';
    } else if (conflict && creditsFull) {
      final names = option.conflicts.map((c) => c.code).join(', ');
      statusColor = const Color(0xFFDC2626);
      statusLabel =
          'Conflict with $names · and would exceed ${option.creditsAfterRetake}/${option.maxCredits} credits';
    } else {
      statusColor = const Color(0xFF9CA3AF);
      statusLabel = 'Unavailable';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, height: 1.4),
                children: [
                  TextSpan(
                    text: option.label,
                    style: const TextStyle(
                      color: Color(0xFF1F2937),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(text: ' — '),
                  TextSpan(
                    text: statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
