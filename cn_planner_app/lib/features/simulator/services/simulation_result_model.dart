class SimulationSummary {
  final int earnedCredits;
  final int totalCredits;
  final double progressPercent;
  final int passCount;
  final int failCount;
  final int withdrawCount;
  final List<CourseRef> failedCourses;
  final List<CourseRef> withdrawnCourses;

  const SimulationSummary({
    required this.earnedCredits,
    required this.totalCredits,
    required this.progressPercent,
    required this.passCount,
    required this.failCount,
    required this.withdrawCount,
    required this.failedCourses,
    required this.withdrawnCourses,
  });

  factory SimulationSummary.fromJson(Map<String, dynamic> j) =>
      SimulationSummary(
        earnedCredits: _asInt(j['earnedCredits']),
        totalCredits: _asInt(j['totalCredits']),
        progressPercent: _asDouble(j['progressPercent']),
        passCount: _asInt(j['passCount']),
        failCount: _asInt(j['failCount']),
        withdrawCount: _asInt(j['withdrawCount']),
        failedCourses: _asList(
          j['failedCourses'],
        ).map((e) => CourseRef.fromJson(_asMap(e))).toList(),
        withdrawnCourses: _asList(
          j['withdrawnCourses'],
        ).map((e) => CourseRef.fromJson(_asMap(e))).toList(),
      );
}

class CourseRef {
  final String code;
  final String name;

  const CourseRef({required this.code, required this.name});

  factory CourseRef.fromJson(Map<String, dynamic> j) =>
      CourseRef(code: _asString(j['code']), name: _asString(j['name']));
}

class SwapSuggestion {
  final String code;
  final String name;
  final int credits;
  final String moveTo;
  final List<String> moveToAll;

  const SwapSuggestion({
    required this.code,
    required this.name,
    required this.credits,
    required this.moveTo,
    required this.moveToAll,
  });

  factory SwapSuggestion.fromJson(Map<String, dynamic> j) => SwapSuggestion(
    code: _asString(j['code']),
    name: _asString(j['name']),
    credits: _asInt(j['credits']),
    moveTo: _asString(j['moveTo']),
    moveToAll: _asList(j['moveToAll']).map((e) => e.toString()).toList(),
  );
}

class RetakeOption {
  final int year;
  final int term;
  final String label;
  final bool canRetake;
  final bool termAvailable;
  final bool wouldExceedLimit;
  final int creditsAfterRetake;
  final int maxCredits;
  final List<CourseRef> conflicts;
  final List<SwapSuggestion> swapSuggestions;

  const RetakeOption({
    required this.year,
    required this.term,
    required this.label,
    required this.canRetake,
    this.termAvailable = true,
    this.wouldExceedLimit = false,
    this.creditsAfterRetake = 0,
    this.maxCredits = 21,
    required this.conflicts,
    this.swapSuggestions = const [],
  });

  factory RetakeOption.fromJson(Map<String, dynamic> j) => RetakeOption(
    year: _asInt(j['year']),
    term: _asInt(j['term']),
    label: _asString(j['label']),
    canRetake: _asBool(j['canRetake']),
    termAvailable: _asBool(j['termAvailable'], defaultValue: true),
    wouldExceedLimit: _asBool(j['wouldExceedLimit']),
    creditsAfterRetake: _asInt(j['creditsAfterRetake']),
    maxCredits: _asInt(j['maxCredits'], defaultValue: 21),
    conflicts: _asList(
      j['conflicts'],
    ).map((e) => CourseRef.fromJson(_asMap(e))).toList(),
    swapSuggestions: _asList(
      j['swapSuggestions'],
    ).map((e) => SwapSuggestion.fromJson(_asMap(e))).toList(),
  );
}

class CourseImpact {
  final String code;
  final String name;
  final String outcome;
  final String normalTerm;
  final List<String> availableTerms;
  final List<CourseRef> blockedCourses;
  final List<RetakeOption> retakeOptions;
  final String summary;

  const CourseImpact({
    required this.code,
    required this.name,
    required this.outcome,
    required this.normalTerm,
    this.availableTerms = const [],
    required this.blockedCourses,
    required this.retakeOptions,
    required this.summary,
  });

  factory CourseImpact.fromJson(Map<String, dynamic> j) => CourseImpact(
    code: _asString(j['code']),
    name: _asString(j['name']),
    outcome: _asString(j['outcome']),
    normalTerm: _asString(j['normalTerm']),
    availableTerms: _asList(
      j['availableTerms'],
    ).map((e) => e.toString()).toList(),
    blockedCourses: _asList(
      j['blockedCourses'],
    ).map((e) => CourseRef.fromJson(_asMap(e))).toList(),
    retakeOptions: _asList(
      j['retakeOptions'],
    ).map((e) => RetakeOption.fromJson(_asMap(e))).toList(),
    summary: _asString(j['summary']),
  );
}

class YearPathSummary {
  final bool canCompleteByYear4Term2;
  final String baselineLabel;
  final int delayTerms;
  final int projectedCompletedCreditsByYear4Term2;
  final int totalRequiredCredits;
  final String? selectedTrack;
  final List<int> changedYears;
  final List<String> missingRequirements;
  final int genEdCredits;
  final int freeElectiveCredits;
  final int term1ElectiveCount;
  final int term2ElectiveCount;
  final String statusText;
  final int extraYearsNeeded;

  const YearPathSummary({
    required this.canCompleteByYear4Term2,
    required this.baselineLabel,
    required this.delayTerms,
    required this.projectedCompletedCreditsByYear4Term2,
    required this.totalRequiredCredits,
    required this.selectedTrack,
    required this.changedYears,
    required this.missingRequirements,
    required this.genEdCredits,
    required this.freeElectiveCredits,
    required this.term1ElectiveCount,
    required this.term2ElectiveCount,
    required this.statusText,
    required this.extraYearsNeeded,
  });

  factory YearPathSummary.fromJson(Map<String, dynamic> j) => YearPathSummary(
    canCompleteByYear4Term2: _asBool(j['canCompleteByYear4Term2']),
    baselineLabel: _asString(
      j['baselineLabel'],
      defaultValue: 'Year 4 / Term 2',
    ),
    delayTerms: _asInt(j['delayTerms']),
    projectedCompletedCreditsByYear4Term2: _asInt(
      j['projectedCompletedCreditsByYear4Term2'],
    ),
    totalRequiredCredits: _asInt(j['totalRequiredCredits'], defaultValue: 146),
    selectedTrack: j['selectedTrack']?.toString(),
    changedYears: _asList(j['changedYears']).map((e) => _asInt(e)).toList(),
    missingRequirements: _asList(
      j['missingRequirements'],
    ).map((e) => e.toString()).toList(),
    genEdCredits: _asInt(j['genEdCredits']),
    freeElectiveCredits: _asInt(j['freeElectiveCredits']),
    term1ElectiveCount: _asInt(j['term1ElectiveCount']),
    term2ElectiveCount: _asInt(j['term2ElectiveCount']),
    statusText: _asString(j['statusText']),
    extraYearsNeeded: _asInt(j['extraYearsNeeded']),
  );
}

class SimulationResult {
  final SimulationSummary summary;
  final List<CourseImpact> impacts;
  final List<String> warnings;
  final YearPathSummary yearPathSummary;

  const SimulationResult({
    required this.summary,
    required this.impacts,
    required this.warnings,
    required this.yearPathSummary,
  });

  factory SimulationResult.fromJson(Map<String, dynamic> j) {
    final data = _asMap(j['data'] ?? j);
    return SimulationResult(
      summary: SimulationSummary.fromJson(_asMap(data['summary'])),
      impacts: _asList(
        data['impacts'],
      ).map((e) => CourseImpact.fromJson(_asMap(e))).toList(),
      warnings: _asList(data['warnings']).map((e) => e.toString()).toList(),
      yearPathSummary: YearPathSummary.fromJson(
        _asMap(data['yearPathSummary']),
      ),
    );
  }
}

int _asInt(dynamic value, {int defaultValue = 0}) {
  if (value == null) return defaultValue;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? defaultValue;
}

double _asDouble(dynamic value, {double defaultValue = 0.0}) {
  if (value == null) return defaultValue;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? defaultValue;
}

bool _asBool(dynamic value, {bool defaultValue = false}) {
  if (value == null) return defaultValue;
  if (value is bool) return value;
  final normalized = value.toString().toLowerCase();
  if (normalized == 'true') return true;
  if (normalized == 'false') return false;
  return defaultValue;
}

String _asString(dynamic value, {String defaultValue = ''}) {
  if (value == null) return defaultValue;
  return value.toString();
}

List _asList(dynamic value) {
  if (value is List) return value;
  return const [];
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map)
    return value.map((key, val) => MapEntry(key.toString(), val));
  return <String, dynamic>{};
}
