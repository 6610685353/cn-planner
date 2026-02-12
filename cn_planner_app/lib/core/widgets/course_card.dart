import 'package:flutter/material.dart';
import '../models/class_session.dart';

class CourseCard extends StatelessWidget {
  final ClassSession session;

  const CourseCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final List<String> days = session.day.split(', ');

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 40,
            offset: const Offset(5, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // --- แถบสีด้านซ้าย ---
          Container(
            width: 4,
            height: 90,
            decoration: BoxDecoration(
              color: session.color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),

          // --- ข้อมูลรายวิชา ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. รหัสวิชา + Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      session.code,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "Section ${session.section}",
                      style: const TextStyle(
                        color: Color.fromARGB(255, 78, 77, 77),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // 2. ชื่อวิชา
                Text(
                  session.name,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                // 3. ชื่ออาจารย์
                Text(
                  session.instructor,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color.fromARGB(255, 78, 77, 77),
                  ),
                ),

                const SizedBox(height: 12),

                // 4. บรรทัดล่างสุด: วันเวลา (ซ้าย) vs สถานที่ (ขวา)
                Row(
                  children: [
                    // --- ส่วนซ้าย: วันและเวลา (Scroll ได้ถ้าเยอะ) ---
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: days.map((day) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                right: 12.0,
                              ), // เว้นระยะห่างแต่ละวัน
                              child: Row(
                                children: [
                                  Text(
                                    day.toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "${session.start}-${session.stop}", // เวลา (8:00-9:30)
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    // --- ส่วนขวา: สถานที่ (ชิดขวาสุด) ---
                    // ไม่ต้อง Scroll ตามวัน
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        session.room,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
