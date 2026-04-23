import 'package:flutter/material.dart';

class SwipeToReveal extends StatefulWidget {
  final Widget child;
  final Widget action;
  final VoidCallback onAction;
  final double actionWidth = 80.0;

  const SwipeToReveal({
    super.key,
    required this.child,
    required this.action,
    required this.onAction,
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
