import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
// 👉 1. Import ตัวนี้เพิ่ม เพื่อให้ใช้ kIsWeb ได้
import 'package:flutter/foundation.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // 👉 2. ถ้าเป็นเว็บ ให้หยุดการทำงานฟังก์ชันนี้ไปเลย
    if (kIsWeb) {
      print("🌐 ระบบรันบน Web: ข้ามการตั้งค่า Notification");
      return;
    }

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Bangkok'));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );
    await _notificationsPlugin.initialize(settings: initializationSettings);
  }

  static Future<void> requestPermission() async {
    if (kIsWeb) return; // กันพังบนเว็บ
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    // 🌟 ขอสิทธิ์แจ้งเตือนแบบชัดเจนสำหรับ Android 13+
    await androidImplementation?.requestNotificationsPermission();

    // 🌟 ขอสิทธิ์เพื่อตั้งเวลาล่วงหน้าแบบเป๊ะๆ (Exact Alarm)
    await androidImplementation?.requestExactAlarmsPermission();
  }

  static Future<void> scheduleClassReminder({
    required int id,
    required String title,
    required String body,
    required DateTime classStartTime,
  }) async {
    if (kIsWeb) return; // กันพังบนเว็บ

    final scheduledTime = classStartTime.subtract(const Duration(minutes: 15));
    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'class_reminder_channel',
          'Class Reminders',
          channelDescription: 'Reminder before class starts',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> showTestNotification() async {
    if (kIsWeb) return;
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        'test_channel',
        'Test Notifications',
        channelDescription: 'For testing',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
    await _notificationsPlugin.show(
      id: 999,
      title: '🔔 Success!',
      body: 'Notification system is working 100% 🎉',
      notificationDetails: platformChannelSpecifics,
    );
  }

  static DateTime _getNextClassDateTime(String dayName, String timeStr) {
    final now = DateTime.now();
    final dayMap = {
      'MON': 1,
      'TUE': 2,
      'WED': 3,
      'THU': 4,
      'FRI': 5,
      'SAT': 6,
      'SUN': 7,
    };
    final targetWeekday = dayMap[dayName.toUpperCase()] ?? 1;
    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
    while (scheduledDate.weekday != targetWeekday ||
        scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  static Future<void> autoScheduleAllClasses(
    List<dynamic> classSessions,
  ) async {
    // 🌐 ถ้าเผลอรันบน Web ให้หยุดทำงานไปเลยแบบเงียบๆ (ไม่ปริ้นต์อะไรแล้ว)
    if (kIsWeb) return;

    // 📱 รันบน Mobile: ตั้งเวลาแจ้งเตือนของจริง
    await _notificationsPlugin.cancelAll();
    int notiId = 0;
    for (var session in classSessions) {
      final days = session.day.split(', ');
      for (var day in days) {
        final classTime = _getNextClassDateTime(day, session.start);

        String roomText =
            (session.room == '-' || session.room.toUpperCase() == 'TBA')
            ? '!'
            : ' in Room ${session.room}!';
        String titleMsg = '🚨 Class Reminder';
        String bodyMsg =
            'Course ${session.code} is starting in 15 minutes$roomText';

        await scheduleClassReminder(
          id: notiId++,
          title: titleMsg,
          body: bodyMsg,
          classStartTime: classTime,
        );
      }
    }
  }

  static Future<void> checkPendingNotifications() async {
    if (kIsWeb) {
      // print("🌐 รันบน Web: ไม่สามารถเช็คคิวแจ้งเตือนของมือถือได้");
      return;
    }

    final pendingRequests = await _notificationsPlugin
        .pendingNotificationRequests();

    print("==================================================");
    print("🔔 มีคิวแจ้งเตือนล่วงหน้าทั้งหมด: ${pendingRequests.length} รายการ");

    for (var noti in pendingRequests) {
      print("-> ID: ${noti.id}");
      print("   หัวข้อ: ${noti.title}");
      print("   ข้อความ: ${noti.body}");
      print("--------------------------------------------------");
    }
    print("==================================================");
  }
}
