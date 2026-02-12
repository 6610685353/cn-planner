import 'package:flutter/material.dart';
import '../models/class_session.dart';

class TimetableGrid extends StatelessWidget {
  final List<ClassSession> classes;

  const TimetableGrid({super.key, required this.classes});

  // --- Configuration ---
  final double startHour = 8.0;
  final double endHour = 20.0;
  final double timeStep = 1.5;
  final double timeColWidth = 50.0;
  final double headerHeight = 30.0;

  @override
  Widget build(BuildContext context) {
    final int totalSlots = ((endHour - startHour) / timeStep).ceil();

    return LayoutBuilder(
      builder: (context, constraints) {
        final double gridWidth = constraints.maxWidth - timeColWidth;
        final double slotWidth = gridWidth / totalSlots;
        final double totalHours = endHour - startHour;

        return Column(
          children: [
            // --- Header เวลา ---
            SizedBox(
              height: headerHeight,
              child: Row(
                children: [
                  SizedBox(width: timeColWidth),

                  Expanded(
                    child: Stack(
                      children: List.generate(totalSlots + 1, (index) {
                        double timeVal = startHour + (index * timeStep);
                        double leftPx = index * slotWidth;

                        // --- Logic การจัดตำแหน่ง (Fine-tune) ---
                        // Default: กึ่งกลาง (-0.5)
                        Offset translation = const Offset(-0.5, 0);

                        if (index == 0) {
                          // 08:00 -> ชิดซ้าย
                          translation = const Offset(0, 0);
                        } else if (index == totalSlots) {
                          // 20:00 -> ชิดขวา
                          translation = const Offset(-1.0, 0);
                        } else if (index == 1) {
                          // 09:30 -> ขยับขวา (หนี 08:00)
                          // ยิ่งค่าลบน้อย ยิ่งไปขวา (จาก -0.5 เป็น -0.2)
                          translation = const Offset(-0.2, 0);
                        } else if (index == totalSlots - 1) {
                          // 18:30 -> ขยับซ้าย (หนี 20:00)
                          // ยิ่งค่าลบมาก ยิ่งไปซ้าย (จาก -0.5 เป็น -0.8)
                          translation = const Offset(-0.8, 0);
                        }

                        return Positioned(
                          left: leftPx,
                          top: 5,
                          child: FractionalTranslation(
                            translation: translation,
                            child: Text(
                              _formatTime(timeVal),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                              softWrap: false,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),

            // --- Body ตาราง (เหมือนเดิม) ---
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                  left: BorderSide(color: Colors.grey.shade300),
                  right: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Column(
                children: [
                  ...['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'].map((
                    day,
                  ) {
                    return Container(
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: timeColWidth,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            child: Text(
                              day,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Stack(
                              children: [
                                Row(
                                  children: List.generate(totalSlots, (index) {
                                    return Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            right: BorderSide(
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                                ...classes
                                    .where(
                                      (c) =>
                                          c.day.toLowerCase() ==
                                          day.toLowerCase(),
                                    )
                                    .map(
                                      (c) => _buildClassBlock(
                                        c,
                                        gridWidth,
                                        totalHours,
                                      ),
                                    ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildClassBlock(ClassSession c, double gridWidth, double totalHours) {
    double start = _timeToDouble(c.start);
    double end = _timeToDouble(c.stop);
    double left = ((start - startHour) / totalHours) * gridWidth;
    double width = ((end - start) / totalHours) * gridWidth;

    return Positioned(
      left: left,
      top: 5,
      bottom: 5,
      width: width,
      child: Container(
        decoration: BoxDecoration(
          color: c.color,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  String _formatTime(double timeVal) {
    int h = timeVal.floor();
    int m = ((timeVal - h) * 60).round();
    return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}";
  }

  double _timeToDouble(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) + (int.parse(parts[1]) / 60.0);
  }
}
