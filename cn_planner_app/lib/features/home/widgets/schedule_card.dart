import 'package:flutter/material.dart';

class ScheduleCard extends StatelessWidget {
  final String status;
  final String subjectCode;
  final String subjectName;
  final String time;
  final String location;
  final bool isOngoing;

  const ScheduleCard({
    super.key,
    required this.status,
    required this.subjectCode,
    required this.subjectName,
    required this.time,
    required this.location,
    this.isOngoing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: 260,
      margin: const EdgeInsets.only(right: 15, bottom: 10, top: 5),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                status,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: Colors.black,
                ),
              ),
              // const Icon(Icons.more_horiz, color: AppColors.textGrey, size: 20),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            "$subjectCode: $subjectName",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const Spacer(),
          _buildInfoRow(Icons.access_time, time),
          const SizedBox(height: 6),
          _buildInfoRow(Icons.location_on_outlined, location),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.black),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
