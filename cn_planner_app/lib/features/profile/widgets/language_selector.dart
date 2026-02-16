import 'package:flutter/material.dart';

class LanguageSelector extends StatelessWidget {
  final String selectedLang;
  final Function(String) onLangChange;

  const LanguageSelector({
    super.key,
    required this.selectedLang,
    required this.onLangChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          const Divider(height: 1),
          _buildLangItem("English", "assets/images/usFlag.png", "en"),
          const Divider(height: 1),
          _buildLangItem("ไทย", "assets/images/thaiFlag.png", "th"),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.language, color: Colors.black),
          SizedBox(width: 12),
          Text(
            "Language",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildLangItem(String name, String imagePath, String code) {
    bool isCurrent = selectedLang == code;
    return InkWell(
      onTap: () => onLangChange(code),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const SizedBox(width: 40),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200, width: 1),
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(width: 12),
            Text(
              name,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            if (isCurrent)
              const Icon(Icons.check, color: Colors.black, size: 20),
          ],
        ),
      ),
    );
  }
}
