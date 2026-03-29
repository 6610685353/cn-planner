import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
// import '../../../core/widgets/top_bar.dart'; // 👉 ปิดตัวนี้ไว้ก่อนถ้ามันบังคับไปหน้า Home
import '../controllers/notifications_controller.dart';
import '../widgets/notification_tile.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationController _controller = NotificationController();

  // 👉 หัวใจสำคัญ: เมื่อหน้าจอถูกปิด (ผู้ใช้กด Back) ให้สั่ง Mark all as read ทันที
  @override
  void dispose() {
    _controller.markAllAsRead(); // สั่งเปลี่ยนสถานะใน Controller ส่วนกลาง
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // 👉 แก้ไข AppBar ให้ใช้ Navigator.pop เพื่อให้กลับไปหน้า Schedule ได้จริง
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context), // ย้อนกลับหน้าก่อนหน้า
        ),
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: NotificationController.notifications.length,
              itemBuilder: (context, index) {
                final noti = NotificationController.notifications[index];
                return NotificationTile(
                  icon: _controller.getCategoryIcon(noti.category),
                  category: noti.category,
                  title: noti.title,
                  subtitle: noti.subtitle,
                  time: noti.time,
                  isRead: noti.isRead, // จะโชว์ว่ายังไม่อ่านตอนเข้ามาครั้งแรก
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "RECENT",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryYellow,
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _controller.markAllAsRead()),
            child: const Text(
              "Mark all as read",
              style: TextStyle(color: Color(0xFFA52A2A)),
            ),
          ),
        ],
      ),
    );
  }
}
