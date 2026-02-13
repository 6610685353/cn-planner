import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class FeatureMenu extends StatelessWidget {
  final Icon icon;
  final String title;
  final String subtitle;
  final String route;
  final VoidCallback? onTap;

  const FeatureMenu({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 358,
      height: 74,
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accentYellow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: icon,
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textDarkGrey,
                        ),
                      ),
                    ],
                  ),
                ),

                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, route);
                  },
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
