import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // สร้างตัวแปรหลักสำหรับเรียกใช้ Plugin
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // 1. ฟังก์ชันตั้งค่าเริ่มต้น (ต้องเรียกตอนเปิดแอป)
  static Future<void> init() async {
    // กำหนดโซนเวลาให้ระบบรู้จัก
    tz.initializeTimeZones();

    // ตั้งค่าสำหรับ Android (ใช้ไอคอนเริ่มต้นของแอป)
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // ตั้งค่าสำหรับ iOS
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

    // สั่งรันการตั้งค่า
    await _notificationsPlugin.initialize(settings: initializationSettings);
  }

  // 2. ฟังก์ชันขออนุญาตส่งแจ้งเตือน (สำคัญมากสำหรับ Android 13 ขึ้นไป และ iOS)
  static Future<void> requestPermission() async {
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidImplementation?.requestNotificationsPermission();
  }

  // 3. ฟังก์ชันตั้งเวลาแจ้งเตือนล่วงหน้า (เอาไว้ใช้เตือนก่อนเข้าเรียน)
  static Future<void> scheduleClassReminder({
    required int id, // รหัสแจ้งเตือน (ห้ามซ้ำกัน)
    required String title, // หัวข้อ (เช่น "CN101 กำลังจะเริ่ม!")
    required String body, // เนื้อหา (เช่น "เรียนที่ SC3-201 ในอีก 15 นาที")
    required DateTime classStartTime, // เวลาเริ่มเรียนจริง
  }) async {
    // คำนวณเวลาแจ้งเตือน (เตือนก่อน 15 นาที)
    final scheduledTime = classStartTime.subtract(const Duration(minutes: 15));

    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'class_reminder_channel', // ID ของแชแนล
          'Class Reminders', // ชื่อแชแนลที่ผู้ใช้เห็นใน Setting
          channelDescription: 'แจ้งเตือนก่อนถึงเวลาเรียน',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode:
          AndroidScheduleMode.exactAllowWhileIdle, // ให้เตือนแม้เครื่องล็อกอยู่
    );
  }

  // 4. ฟังก์ชันสำหรับยิงแจ้งเตือนทดสอบทันที (ไม่ต้องรอเวลา)
  static Future<void> showTestNotification() async {
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        'test_channel',
        'Test Notifications',
        channelDescription: 'สำหรับการทดสอบระบบแจ้งเตือน',
        importance: Importance.max, // ให้เด้งเตือนแบบมีเสียงและ Pop-up
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    // สั่งโชว์เดี๋ยวนี้เลย!
    await _notificationsPlugin.show(
      id: 999, // 👉 เติม id:
      title: '🔔 สำเร็จแล้ว!', // 👉 เติม title:
      body: 'ระบบ Notification ของคุณมีนทำงานได้ 100% 🎉', // 👉 เติม body:
      notificationDetails:
          platformChannelSpecifics, // 👉 เติม notificationDetails:
    );
  }
}
