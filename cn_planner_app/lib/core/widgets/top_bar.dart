import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final String? header;
  final String? route;

  const TopBar({super.key, this.header, this.route});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      automaticallyImplyLeading: false, // ป้องกันปุ่มซ้อน
      leading: IconButton(
        onPressed: () {
          if (route != null) {
            Navigator.pushNamed(context, route!);
          } else {
            Navigator.pop(context);
          }
        },
        icon: const Icon(Icons.arrow_back, size: 30, color: Colors.black),
      ),
      title: (header != null && header!.isNotEmpty)
          ? Text(
              header!,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            )
          : null,
    );
  }
}
