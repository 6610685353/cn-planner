import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class EditProfileImage extends StatelessWidget {
  final File? imageFile;
  final String? imageUrl;

  const EditProfileImage({super.key, this.imageFile, this.imageUrl});

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
                backgroundImage: imageFile != null
                    ? FileImage(imageFile!)
                    : (imageUrl != null && imageUrl!.isNotEmpty
                              ? NetworkImage(imageUrl!)
                              : null)
                          as ImageProvider?,
                child:
                    (imageFile == null &&
                        (imageUrl == null || imageUrl!.isEmpty))
                    ? const Icon(
                        Icons.person,
                        size: 70,
                        color: AppColors.borderGrey,
                      )
                    : null,
              ),
            ),
          ),
          Positioned(
            bottom: 5,
            right: 5,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: AppColors.accentYellow,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
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
        ],
      ),
    );
  }
}
