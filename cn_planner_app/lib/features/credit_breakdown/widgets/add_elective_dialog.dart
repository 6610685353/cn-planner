import 'package:flutter/material.dart';
import 'package:cn_planner_app/core/constants/app_colors.dart';

class AddElectiveDialog extends StatefulWidget {
  final String categoryName;
  const AddElectiveDialog({super.key, required this.categoryName});

  @override
  State<AddElectiveDialog> createState() => _AddElectiveDialogState();
}

class _AddElectiveDialogState extends State<AddElectiveDialog> {
  final _codeController = TextEditingController();
  final _creditController = TextEditingController();
  String _selectedGrade = 'A';

  // รายการเกรดที่สามารถเลือกได้
  final List<String> _grades = ['A', 'B+', 'B', 'C+', 'C', 'D+', 'D', 'F'];

  @override
  void dispose() {
    _codeController.dispose();
    _creditController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        "Add to ${widget.categoryName}",
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ช่องกรอกรหัสวิชา
          TextField(
            controller: _codeController,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: 'Course Code (e.g. TU101)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 15),

          // ช่องกรอกหน่วยกิต
          TextField(
            controller: _creditController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Credits (e.g. 3)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 15),

          // Dropdown เลือกเกรด
          DropdownButtonFormField<String>(
            value: _selectedGrade,
            decoration: InputDecoration(
              labelText: 'Grade',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            items: _grades.map((grade) {
              return DropdownMenuItem(value: grade, child: Text(grade));
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() => _selectedGrade = val);
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            // เช็คว่ากรอกข้อมูลครบไหม
            if (_codeController.text.trim().isEmpty ||
                _creditController.text.trim().isEmpty) {
              return; // ถ้าไม่ครบไม่ให้ไปต่อ
            }

            // ส่งข้อมูลกลับไปให้หน้า CreditBreakdownPage
            Navigator.pop(context, {
              'subject_code': _codeController.text.trim().toUpperCase(),
              'credits': int.tryParse(_creditController.text.trim()) ?? 3,
              'grade': _selectedGrade,
            });
          },
          child: const Text(
            "Save Course",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
