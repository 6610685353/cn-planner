import 'package:flutter/material.dart';
import '../models/term_model.dart';

/// A modern dropdown pill that shows the selected term label.
class TermTabWidget extends StatelessWidget {
  final List<TermModel> terms;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const TermTabWidget({
    super.key,
    required this.terms,
    required this.selectedIndex,
    required this.onChanged,
  });

  // ปรับโทนสีให้สดใสและเข้ากับภาพรวมของแอป
  Color _statusColor(TermStatus status) {
    switch (status) {
      case TermStatus.passed:
        return const Color(0xFF00C853); // เขียวสดตัวเดียวกับ Card
      case TermStatus.current:
        return const Color(0xFF2196F3); // ฟ้าสดใส
      case TermStatus.upcoming:
        return const Color(0xFF9E9E9E); // เทามาตรฐาน
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = terms[selectedIndex];
    final color = _statusColor(selected.status);

    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white, // ใช้พื้นขาวเพื่อให้ดูเป็น Control มากกว่า Label
          borderRadius: BorderRadius.circular(20), // ความมนรับกับ Card
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status Dot พร้อมเงาฟุ้งๆ ตามสีสถานะ
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              selected.shortLabel,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A), // สีเข้มเพื่อให้อ่านง่ายที่สุด
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons
                  .keyboard_arrow_down_rounded, // ไอคอน Dropdown ที่ดูทันสมัยกว่า
              size: 18,
              color: Color(0xFF757575),
            ),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _TermPickerSheet(
        terms: terms,
        selectedIndex: selectedIndex,
        onChanged: (idx) {
          Navigator.pop(context);
          onChanged(idx);
        },
        statusColor: _statusColor,
      ),
    );
  }
}

// ─── Bottom Sheet ──────────────────────────────────────────────────────────────

class _TermPickerSheet extends StatelessWidget {
  final List<TermModel> terms;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final Color Function(TermStatus) statusColor;

  const _TermPickerSheet({
    required this.terms,
    required this.selectedIndex,
    required this.onChanged,
    required this.statusColor,
  });

  String _statusLabel(TermStatus s) {
    switch (s) {
      case TermStatus.passed:
        return 'Passed';
      case TermStatus.current:
        return 'Current';
      case TermStatus.upcoming:
        return 'Upcoming';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.72,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 20),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEEEE),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              const Padding(
                padding: EdgeInsets.fromLTRB(22, 0, 22, 16),
                child: Row(
                  children: [
                    Text(
                      'Select Term',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A1A),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),

              // List Items
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: Column(
                    children: terms.asMap().entries.map((e) {
                      final idx = e.key;
                      final term = e.value;
                      final isSelected = idx == selectedIndex;
                      final color = statusColor(term.status);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          // ใช้ InkWell เพื่อให้มี ripple effect เวลาเลือก
                          onTap: () => onChanged(idx),
                          borderRadius: BorderRadius.circular(16),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? color.withOpacity(0.08)
                                  : const Color(0xFFF9F9F9),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? color.withOpacity(0.5)
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                // สถานะแบบจุด
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    term.label,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w600,
                                      color: isSelected
                                          ? color
                                          : const Color(0xFF424242),
                                    ),
                                  ),
                                ),
                                // Badge บอกสถานะด้านขวา
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? color
                                        : color.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _statusLabel(term.status),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: isSelected ? Colors.white : color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
