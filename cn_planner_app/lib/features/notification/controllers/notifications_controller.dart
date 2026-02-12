import 'package:flutter/material.dart';
import 'package:cn_planner_app/features/notification/models/notifications_models.dart';

class NotificationController {
  // ข้อมูลสมมติ
  List<NotificationsModel> notifications = [
    NotificationsModel(
      id: '1',
      category: "ACADEMIC ALERT",
      title: "Registration Deadline",
      subtitle:
          "Registration for Semester 2/2024 ends in 3 days. Ensure all fees are paid to avoid penalties.",
      time: "Just now",
      isRead: false,
    ),
    NotificationsModel(
      id: '2',
      category: "GRADE UPDATE",
      title: "New Grade Published",
      subtitle: "A new grade has been posted for TU100: Civic Education.",
      time: "2h ago",
      isRead: false,
    ),
    NotificationsModel(
      id: '3',
      category: "CLASS REMINDER",
      title: "Upcoming: EC211 Microeconomics",
      subtitle: "Lecture starts at 13:00 tomorrow in Building L7-101.",
      time: "Yesterday",
      isRead: true,
    ),
    NotificationsModel(
      id: '4',
      category: "SYSTEM UPDATE",
      title: "Scholarship Status Updated",
      subtitle:
          "Your application for the Excellence Scholarship is now in the Review phase.",
      time: "Oct 24",
      isRead: true,
    ),
  ];

  // ฟังก์ชันช่วยเลือก Icon ตามหมวดหมู่ (Scalable Logic)
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

  void markAllAsRead() {
    for (var noti in notifications) {
      noti.isRead = true;
    }
  }
}
