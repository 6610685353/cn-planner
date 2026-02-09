import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'package:cn_planner_app/route.dart';

class EditProfileImage extends StatelessWidget {
  final String? imageUrl;

  const EditProfileImage({super.key, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: AppColors.accentYellow,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 55,
                backgroundColor: AppColors.background,
                // ตรวจสอบว่ามี URL รูปภาพหรือไม่
                backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
                    ? NetworkImage(imageUrl!)
                    : null,
                // ถ้าไม่มีรูปภาพ ให้แสดงไอคอนคนแทน
                child: imageUrl != null && imageUrl!.isNotEmpty
                    ? null
                    : const Icon(
                        Icons.person,
                        size: 70,
                        color: AppColors.borderGrey,
                      ),
              ),
            ),
          ),

          Positioned(
            bottom: 5,
            right: 5,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColors.accentYellow,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
