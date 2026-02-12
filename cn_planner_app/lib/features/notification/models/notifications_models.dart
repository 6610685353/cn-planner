class NotificationsModel {
  final String id;
  final String category;
  final String title;
  final String subtitle;
  final String time;
  bool isRead;

  NotificationsModel({
    required this.id,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.time,
    this.isRead = false,
  });
}
