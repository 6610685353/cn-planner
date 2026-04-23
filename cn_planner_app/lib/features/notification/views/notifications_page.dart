import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/notifications_controller.dart';
import '../widgets/notification_tile.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationController _controller = NotificationController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    setState(() => _isLoading = true);

    await NotificationController.loadNotifications();

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _markAllAsReadAndRefresh() {
    setState(() {
      NotificationController.markAllAsRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            _markAllAsReadAndRefresh();
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _initData,
        color: AppColors.primaryYellow,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : NotificationController.notifications.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: NotificationController.notifications.length,
                      itemBuilder: (context, index) {
                        final noti =
                            NotificationController.notifications[index];

                        return NotificationTile(
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
            onPressed: _markAllAsReadAndRefresh,
            child: const Text(
              "Mark all as read",
              style: TextStyle(color: Color(0xFFA52A2A)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        const Center(
          child: Column(
            children: [
              Icon(Icons.notifications_none, size: 80, color: Colors.grey),
              SizedBox(height: 10),
              Text(
                "No reminders for today or tomorrow.",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
