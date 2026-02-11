import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class WelcomeBanner extends StatelessWidget {
  final String? imageUrl;
  final String fname;
  final String route;

  const WelcomeBanner({
    super.key,
    this.imageUrl,
    required this.fname,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.background,
      automaticallyImplyLeading: false,
      floating: true,
      pinned: false,
      toolbarHeight: 80,
      elevation: 0,
      // ใช้ title แทน flexibleSpace ถ้าต้องการให้จัดการตำแหน่งง่ายขึ้นในแนวนอน
      title: Row(
        children: [
          // --- รูปโปรไฟล์วงกลม ---
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.textDarkGrey,
            backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
                ? NetworkImage(imageUrl!)
                : null,
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? null
                : const Icon(Icons.person, size: 40, color: Colors.white),
          ),
          const SizedBox(width: 12),
          _buildTextSection(),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 15.0),
          child: IconButton(
            onPressed: () {
              Navigator.pushNamed(context, route);
            },
            style: IconButton.styleFrom(
              shape: CircleBorder(),
              padding: EdgeInsets.all(5),
              side: BorderSide(color: Colors.black, width: 1),
            ),
            icon: const Icon(
              Icons.notifications_none_outlined,
              size: 25,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'THAMMASAT UNIVERSITY',
          style: TextStyle(
            fontSize: 12,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          'Welcome, $fname!',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
