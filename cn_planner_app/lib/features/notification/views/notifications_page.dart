import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/top_bar.dart';
import '../controllers/notifications_controller.dart';
import '../widgets/notification_tile.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // 1. ประกาศ Controller ไว้ที่ระดับ State เพื่อให้เก็บข้อมูลไว้ได้ตลอดอายุของหน้านี้
  final NotificationController _controller = NotificationController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const TopBar(header: "Notifications", route: "main"),
      body: Column(
        children: [
          // ส่วนหัว RECENT และปุ่ม Mark all as read
          _buildHeader(),

          // รายการแจ้งเตือน
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: _controller.notifications.length,
              itemBuilder: (context, index) {
                final noti = _controller.notifications[index];
                return NotificationTile(
                  // ดึง Icon ตามหมวดหมู่จาก Controller
                  icon: _controller.getCategoryIcon(noti.category),
                  category: noti.category,
                  title: noti.title,
                  subtitle: noti.subtitle,
                  time: noti.time,
                  isRead: noti.isRead,
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
              letterSpacing: 1.1,
            ),
          ),
          TextButton(
            onPressed: () {
              // 2. เมื่อกดปุ่ม สั่งให้ Controller เปลี่ยนสถานะ และสั่ง setState เพื่อ Refresh หน้าจอ
              setState(() {
                _controller.markAllAsRead();
              });
            },
            child: const Text(
              "Mark all as read",
              style: TextStyle(
                color: Color(0xFFA52A2A), // สีน้ำตาลแดงตามดีไซน์
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
