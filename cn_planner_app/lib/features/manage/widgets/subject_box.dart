import 'package:flutter/material.dart';

class SubjectBox extends StatefulWidget {
  final String title;
  final String subtitle;
  final double credits;
  final String grade; 

  const SubjectBox({
    super.key,
    required this.title,
    required this.subtitle,
    required this.credits,
    required this.grade,
  });

  @override
  State<SubjectBox> createState() => _SubjectBoxState();
}

class _SubjectBoxState extends State<SubjectBox> {
  bool _isChecked = false;
  String _selectedValue = "A";

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Transform.scale(
            scale:  2,
            child: Checkbox(
              value: _isChecked,
              checkColor: Color.fromARGB(0, 0, 0, 0),
              fillColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.green;
                }
                return Colors.white;
              }),
              onChanged: (bool? value) {
                setState(() {
                  _isChecked = value ?? false;
                });
              },
            ),
          ),
          const SizedBox(width: 20),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(widget.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4)),
                      child: Text("${widget.credits} Credits", style: TextStyle(fontSize: 10)),
                    ),
                  ],
                ),
                Text(widget.subtitle, style: TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Grade", style: TextStyle(fontSize: 11, color: Colors.blueGrey)),
              PopupMenuButton<String>(
                child: Text(
                  _selectedValue,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                onSelected: (String value) {
                  setState(() {
                    _selectedValue = value;
                  });
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem(value: "A", child: Text("Option A")),
                  const PopupMenuItem(value: "B", child: Text("Option B")),
                  const PopupMenuItem(value: "C", child: Text("Option C")),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}