import 'package:flutter/material.dart';

class SwipeToReveal extends StatefulWidget {
  final Widget child;
  final Widget action;
  final VoidCallback onAction;
  final double actionWidth;

  const SwipeToReveal({
    super.key,
    required this.child,
    required this.action,
    required this.onAction,
    this.actionWidth = 80.0,
  });

  @override
  State<SwipeToReveal> createState() => _SwipeToRevealState();
}

class _SwipeToRevealState extends State<SwipeToReveal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _dragExtent = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragExtent += details.primaryDelta!;
      if (_dragExtent > 0) _dragExtent = 0;
      if (_dragExtent < -widget.actionWidth * 1.5) {
        _dragExtent = -widget.actionWidth * 1.5;
      }
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_dragExtent < -widget.actionWidth / 2) {
      _animateTo(-widget.actionWidth);
    } else {
      _animateTo(0.0);
    }
  }

  void _animateTo(double target) {
    final start = _dragExtent;
    Animation<double> animation = Tween<double>(
      begin: start,
      end: target,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.reset();
    animation.addListener(() {
      setState(() {
        _dragExtent = animation.value;
      });
    });
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  _animateTo(0.0);
                  widget.onAction();
                },
                child: Container(
                  width: widget.actionWidth,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xffB71C1C),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: widget.action,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onHorizontalDragUpdate: _handleDragUpdate,
          onHorizontalDragEnd: _handleDragEnd,
          child: Transform.translate(
            offset: Offset(_dragExtent, 0),
            child: widget.child,
          ),
        ),
      ],
    );
  }
}

class GPACourseCard extends StatelessWidget {
  final String code;
  final String name;
  final double credit;
  final String grade;
  final List<String> gradeOptions;
  final ValueChanged<String?> onGradeChanged;
  final VoidCallback onDelete;

  const GPACourseCard({
    super.key,
    required this.code,
    required this.name,
    required this.credit,
    required this.grade,
    required this.gradeOptions,
    required this.onGradeChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$code | $name",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${credit.toStringAsFixed(1)} Credits",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF1976D2),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "GRADE",
                  style: TextStyle(
                    color: Color(0xFF1976D2),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                DropdownButton<String>(
                  value: grade,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.black54,
                  ),
                  underline: const SizedBox(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black87,
                  ),
                  items: gradeOptions.map((g) {
                    return DropdownMenuItem(value: g, child: Text(g));
                  }).toList(),
                  onChanged: onGradeChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return SwipeToReveal(
      action: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete_outline, color: Colors.white, size: 28),
          SizedBox(height: 4),
          Text(
            "Delete",
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      onAction: onDelete,
      child: cardContent,
    );
  }
}
