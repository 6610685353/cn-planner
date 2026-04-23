import 'package:flutter/material.dart';
import 'package:cn_planner_app/features/notification/models/notifications_models.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cn_planner_app/features/schedule/services/schedule_service.dart';

class NotificationController {
  static List<NotificationsModel> notifications = [];

  static Future<void> loadNotifications() async {
    try {
      String myUid = FirebaseAuth.instance.currentUser?.uid ?? "";
      if (myUid.isEmpty) {
        notifications = [];
        return;
      }

      final service = ScheduleService();
      final masterCourses = await service.getRealScheduleForUser(myUid);

      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));

      const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
      final todayCode = days[now.weekday - 1];
      final tomorrowCode = days[tomorrow.weekday - 1];

      List<NotificationsModel> fetchedNoti = [];

      for (var course in masterCourses) {
        for (var slot in course.timeSlots) {
          String? label;
          DateTime? sortTime;

          if (slot.day.toUpperCase().contains(todayCode)) {
            label = "TODAY";
            sortTime = _parseToDateTime(now, slot.startTime);
          } else if (slot.day.toUpperCase().contains(tomorrowCode)) {
            label = "TOMORROW";
            sortTime = _parseToDateTime(tomorrow, slot.startTime);
          }

          if (label != null && sortTime != null) {
            fetchedNoti.add(
              NotificationsModel(
                id: "${course.courseCode}-${slot.day}-${slot.startTime}",
                category: "CLASS REMINDER",
                title: "Class Reminder",
                subtitle:
                    "Course ${course.courseCode} starts at ${slot.startTime} in room ${slot.room}",
                time: label,
                timestamp: sortTime,
                isRead: false,
              ),
            );
          }
        }
      }

      fetchedNoti.sort((a, b) => b.timestamp!.compareTo(a.timestamp!));

      notifications = fetchedNoti;
    } catch (e) {
      print("❌ NotificationController: Failed to load notifications -> $e");
    }
  }

  static DateTime _parseToDateTime(DateTime base, String timeStr) {
    final parts = timeStr.split(':');
    return DateTime(
      base.year,
      base.month,
      base.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  static void addNotification(NotificationsModel newNoti) {
    notifications.insert(0, newNoti);
  }

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

  static void markAllAsRead() {
    for (var noti in notifications) {
      noti.isRead = true;
    }
  }
}
