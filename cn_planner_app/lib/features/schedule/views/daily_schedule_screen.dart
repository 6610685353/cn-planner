import 'package:flutter/material.dart';
import 'package:cn_planner_app/core/models/class_session.dart';

class DailyScheduleScreen extends StatefulWidget {
  final List<ClassSession> allClasses;
  const DailyScheduleScreen({super.key, required this.allClasses});

  @override
  State<DailyScheduleScreen> createState() => _DailyScheduleScreenState();
}

class _DailyScheduleScreenState extends State<DailyScheduleScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    // ... (ส่วนจัดการ Date List เหมือนเดิม) ...
    final List<DateTime> nextDays = List.generate(
      5,
      (index) => DateTime.now().add(Duration(days: index)),
    );

    String getDayCode(DateTime date) {
      const days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
      return days[date.weekday - 1];
    }

    final selectedDayCode = getDayCode(_selectedDate);
    final dailyClasses = widget.allClasses
        .where((c) => c.day.toLowerCase().contains(selectedDayCode))
        .toList();

    dailyClasses.sort(
      (a, b) => _timeToMinutes(a.start).compareTo(_timeToMinutes(b.start)),
    );

    // --- LOGIC CHANGE: ตรวจสอบ Ongoing และ Next Class ---
    bool isToday = _isSameDate(_selectedDate, DateTime.now());

    ClassSession? ongoingClass;
    ClassSession? nextClass;

    if (isToday) {
      // หาคลาสที่กำลังเรียนอยู่ (Ongoing)
      ongoingClass = _findOngoingClass(widget.allClasses);

      // ถ้าไม่มีคลาสที่เรียนอยู่ ให้หาคลาสถัดไป (Next)
      if (ongoingClass == null) {
        nextClass = _findNextClass(widget.allClasses);
      }
    }

    // ตัดสินใจว่าจะโชว์ Banner อันไหน (Ongoing สำคัญกว่า)
    final activeBannerClass = ongoingClass ?? nextClass;
    final isOngoing = ongoingClass != null;

    return Scaffold(
      backgroundColor: Colors.white, // พื้นหลังหลัก
      appBar: AppBar(
        title: const Text(
          'Daily Schedule',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: Column(
        children: [
          // --- Date Selector (โค้ดเดิม) ---
          SizedBox(
            height: 90,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: nextDays.map((date) {
                bool isSelected = _isSameDate(date, _selectedDate);
                return GestureDetector(
                  onTap: () => setState(() => _selectedDate = date),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getWeekdayName(date.weekday),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.black : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${date.day} ${_getMonthName(date.month)}",
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.black : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 20,
                        height: 3,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.amber : Colors.transparent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),

          // --- เนื้อหาหลัก ---
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Banner Logic: แสดง Ongoing หรือ Next ---
                  if (activeBannerClass != null) ...[
                    Text(
                      isOngoing
                          ? "Happening Now"
                          : "Next Class", // เปลี่ยนหัวข้อตามสถานะ
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildTopBanner(activeBannerClass, isOngoing: isOngoing),
                    const SizedBox(height: 30),
                  ],

                  const Text(
                    "Today's Schedule",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  if (dailyClasses.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Center(
                        child: Text(
                          "No classes for this day!",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: dailyClasses.length,
                      itemBuilder: (context, index) {
                        return _buildTimelineItem(dailyClasses, index);
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget: แถวของ Break Time (แก้ใหม่: Text Only, No Border) ---
  Widget _buildBreakRow(String start, String end) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. เวลา Break (ซ้าย) - ทำให้จางลงหน่อย
          SizedBox(
            width: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  start,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.grey.shade400, // สีเทาจาง
                  ),
                ),
                Text(
                  end,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.grey.shade400, // สีเทาจาง
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // 2. เส้น Timeline (ยังต้องมีเพื่อให้เส้นเชื่อมต่อกันสวยงาม)
          SizedBox(
            width: 20,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(width: 2, color: Colors.grey.shade200),
                // จุดเล็กๆ แสดงช่วงพัก (Optional)
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),

          // 3. เนื้อหา Break (ขวา) - ลบ Container/Shadow ออก เหลือแค่ Text
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  // จัด Icon และ Text ให้ตรงกลางแนวตั้ง
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                    ), // เพิ่ม Padding บนล่างให้เส้น Timeline ยาวพอดี
                    child: Icon(
                      Icons.coffee_outlined,
                      size: 18,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Break Time",
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  // ระยะเวลา
                  Text(
                    _calculateDuration(start, end),
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget: Banner ด้านบน (รองรับทั้ง Ongoing และ Next) ---
  Widget _buildTopBanner(ClassSession session, {required bool isOngoing}) {
    // เลือกสีตามสถานะ: Ongoing = เขียว, Next = ฟ้า/ส้ม
    final badgeColor = isOngoing ? Colors.green.shade50 : Colors.blue.shade50;
    final badgeTextColor = isOngoing
        ? Colors.green.shade700
        : Colors.blue.shade700;
    final badgeText = isOngoing ? "HAPPENING NOW" : "UP NEXT";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isOngoing) ...[
                  // จุดกะพริบหรือ Icon เล็กๆ
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: badgeTextColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  badgeText,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    color: badgeTextColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "${session.start} - ${session.stop}",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: badgeTextColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text(
            "${session.code}: ${session.name}",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                "Room ${session.room}",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                " • Rangsit Campus",
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- LOGIC FUNCTIONS ---

  // ฟังก์ชันหาคลาสที่ "กำลังเรียนอยู่" (Start <= Now < End)
  ClassSession? _findOngoingClass(List<ClassSession> classes) {
    final now = DateTime.now();
    final timeNow = now.hour * 60 + now.minute;
    const days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    final todayCode = days[now.weekday - 1];

    final todayClasses = classes
        .where((c) => c.day.toLowerCase().contains(todayCode))
        .toList();

    for (var session in todayClasses) {
      final start = _timeToMinutes(session.start);
      final end = _timeToMinutes(session.stop);

      // ถ้าเวลาปัจจุบัน มากกว่าเวลาเริ่ม และ น้อยกว่าเวลาจบ = กำลังเรียน
      if (timeNow >= start && timeNow < end) {
        return session;
      }
    }
    return null;
  }

  // ฟังก์ชันเดิม หาคลาสถัดไป
  ClassSession? _findNextClass(List<ClassSession> classes) {
    final now = DateTime.now();
    final timeNow = now.hour * 60 + now.minute;
    const days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    final todayCode = days[now.weekday - 1];

    final todayClasses = classes
        .where((c) => c.day.toLowerCase().contains(todayCode))
        .toList();
    todayClasses.sort(
      (a, b) => _timeToMinutes(a.start).compareTo(_timeToMinutes(b.start)),
    );

    for (var session in todayClasses) {
      if (_timeToMinutes(session.start) > timeNow) {
        return session;
      }
    }
    return null;
  }

  // ... Helper functions อื่นๆ (_buildTimelineItem, _buildClassRow, _timeToMinutes, etc.) เหมือนเดิม ...
  Widget _buildTimelineItem(List<ClassSession> classes, int index) {
    // ... (เหมือนโค้ดก่อนหน้า) ...
    List<Widget> columnChildren = [];
    bool isLastItemOverall = index == classes.length - 1;

    columnChildren.add(_buildClassRow(classes[index]));

    bool hasBreak = false;
    if (index < classes.length - 1) {
      final currentClassEnd = _timeToMinutes(classes[index].stop);
      final nextClassStart = _timeToMinutes(classes[index + 1].start);
      if (nextClassStart - currentClassEnd > 15) {
        hasBreak = true;
      }
    }

    if (hasBreak) {
      columnChildren.add(_buildTimelineGap(hasLine: true));
      columnChildren.add(
        _buildBreakRow(classes[index].stop, classes[index + 1].start),
      );
      columnChildren.add(_buildTimelineGap(hasLine: true));
    } else {
      if (!isLastItemOverall) {
        columnChildren.add(_buildTimelineGap(hasLine: true));
      } else {
        columnChildren.add(const SizedBox(height: 20));
      }
    }

    return Column(children: columnChildren);
  }

  // (Helper functions อื่นๆ: _buildTimelineGap, _buildClassRow, _timeToMinutes ฯลฯ ใช้ของเดิมได้เลยครับ)
  Widget _buildTimelineGap({bool hasLine = true}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(width: 60),
          const SizedBox(width: 10),
          SizedBox(
            width: 20,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (hasLine) Container(width: 2, color: Colors.grey.shade200),
              ],
            ),
          ),
          const Expanded(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildClassRow(ClassSession session) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: 16),
                Text(
                  session.start,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  session.stop,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 20,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(width: 2, color: Colors.grey.shade200),
                Container(
                  margin: const EdgeInsets.only(top: 18),
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${session.code}: ${session.name}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Instr. ${session.instructor}",
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Room ${session.room}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _timeToMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  String _calculateDuration(String start, String end) {
    int s = _timeToMinutes(start);
    int e = _timeToMinutes(end);
    int diff = e - s;
    int h = diff ~/ 60;
    int m = diff % 60;
    if (h > 0 && m > 0) return "${h}h ${m}m";
    if (h > 0) return "${h}h";
    return "${m}m";
  }

  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _getWeekdayName(int weekday) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[weekday - 1];
  }

  String _getMonthName(int month) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return names[month - 1];
  }
}
