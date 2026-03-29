import 'package:flutter/material.dart';
import 'package:cn_planner_app/features/notification/models/notifications_models.dart';

class NotificationController {
  // 👉 1. เติมคำว่า static ข้างหน้า เพื่อให้หน้า Schedule มองเห็นข้อมูลก้อนเดียวกัน
  static List<NotificationsModel> notifications = [
    NotificationsModel(
      id: '1',
      category: "ACADEMIC ALERT",
      title: "Registration Deadline",
      subtitle:
          "Registration for Semester 2/2024 ends in 3 days. Ensure all fees are paid to avoid penalties.",
      time: "Just now",
      isRead: false,
    ),
    // ... (ข้อมูล mock ของเพื่อนอันอื่นๆ จะเก็บไว้หรือลบออกก็ได้ค่ะ)
  ];

  // 👉 2. สร้างฟังก์ชันสำหรับรับแจ้งเตือนใหม่ (ดันไว้บนสุดของลิสต์)
  static void addNotification(NotificationsModel newNoti) {
    notifications.insert(0, newNoti);
  }

  // ฟังก์ชันช่วยเลือก Icon ตามหมวดหมู่ (เหมือนเดิม)
  IconData getCategoryIcon(String category) {
    switch (category) {
      case "ACADEMIC ALERT":
        return Icons.edit_note;
      case "GRADE UPDATE":
        return Icons.emoji_events_outlined;
      case "CLASS REMINDER":
        return Icons.calendar_month;
      case "SYSTEM UPDATE":
        return Icons.settings;
      default:
        return Icons.notifications_none;
    }
  }

  // ฟังก์ชัน Mark all as read
  void markAllAsRead() {
    for (var noti in notifications) {
      noti.isRead = true;
    }
  }
}
