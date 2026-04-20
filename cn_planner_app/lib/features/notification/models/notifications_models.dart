class NotificationsModel {
  final String id;
  final String category;
  final String title;
  final String subtitle;
  final String time;
  final DateTime? timestamp; // 👉 เพิ่มฟิลด์นี้มาช่วย Sort
  bool isRead;

  NotificationsModel({
    required this.id,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.time,
    this.timestamp,
    this.isRead = false,
  });
}
