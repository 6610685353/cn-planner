import 'package:flutter/material.dart';

class SubjectBox extends StatefulWidget {
  final String title;
  final String subtitle;
  final String trailingChar; 
  final bool initialValue;
  final ValueChanged<bool?> onChanged;

  const SubjectBox({
    super.key,
    required this.title,
    required this.subtitle,
    required this.trailingChar,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<SubjectBox> createState() => _SubjectBoxState();
}

class _SubjectBoxState extends State<SubjectBox> {
  late bool _isChecked;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: CheckboxListTile(
          controlAffinity: ListTileControlAffinity.leading, // Checkbox อยู่ซ้าย
          secondary: Text( // ใช้ secondary แทน trailing
            widget.trailingChar.toUpperCase(),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          title: Text(widget.title),
          subtitle: Text(widget.subtitle),
          value: _isChecked,
          onChanged: (bool? val) {
            setState(() => _isChecked = val!);
            widget.onChanged(val);
          },
        ),
      ),
    );
  }
}