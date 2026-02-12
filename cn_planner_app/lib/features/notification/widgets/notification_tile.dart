import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class NotificationTile extends StatelessWidget {
  final IconData icon;
  final String category;
  final String title;
  final String subtitle;
  final String time;
  final bool isRead;

  const NotificationTile({
    super.key,
    required this.icon,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.time,
    this.isRead = false,
  });

  @override
  Widget build(BuildContext context) {
    // กำหนดสีตามสถานะการอ่าน
    final Color bgColor = isRead
        ? const Color(0xFFF5F5F5)
        : const Color(0xFFFFFBEB);
    final Color sideColor = isRead ? Colors.transparent : AppColors.errorRed;
    final Color iconBorderColor = isRead
        ? AppColors.borderGrey
        : AppColors.accentYellow;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          left: BorderSide(color: sideColor, width: 5), // เส้นสีแดงด้านข้าง
          bottom: const BorderSide(color: AppColors.borderGrey, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Icon ในวงกลม ---
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: iconBorderColor, width: 1.5),
              color: Colors.white,
            ),
            child: Icon(
              icon,
              color: isRead ? Colors.grey : AppColors.errorRed,
              size: 24,
            ),
          ),
          const SizedBox(width: 15),

          // --- เนื้อหาข้อความ ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      category,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isRead ? Colors.grey : AppColors.errorRed,
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isRead ? Colors.grey.shade700 : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: isRead ? Colors.grey : Colors.black54,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          // --- จุดสีแดง (กรณีที่ยังไม่อ่าน) ---
          if (!isRead)
            Container(
              margin: const EdgeInsets.only(left: 10, top: 25),
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.errorRed,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
