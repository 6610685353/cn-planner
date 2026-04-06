class ScheduleService {
  /// แปลง schedule → usable format
  static Map<int, Map<String, List<Map<String, dynamic>>>> buildScheduleMap(
    List<dynamic> raw,
  ) {
    final Map<int, Map<String, List<Map<String, dynamic>>>> result = {};

    for (var item in raw) {
      final subjectId = item['subject_id'];
      final section = item['section'];

      result.putIfAbsent(subjectId, () => {});
      result[subjectId]!.putIfAbsent(section, () => []);

      result[subjectId]![section]!.add({
        'day': item['day'],
        'start': _timeToInt(item['start_time']),
        'end': _timeToInt(item['end_time']),
      });
    }

    return result;
  }

  /// ดึง list section ของแต่ละวิชา
  static Map<int, List<String>> buildSectionOptions(
    Map<int, Map<String, List<Map>>> scheduleMap,
  ) {
    final Map<int, List<String>> result = {};

    scheduleMap.forEach((subjectId, sections) {
      result[subjectId] = sections.keys.toList();
    });

    return result;
  }

  /// แปลงเวลา 09:30 → 570
  static int _timeToInt(String time) {
    final parts = time.split(":");
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}
