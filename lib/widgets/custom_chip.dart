import 'package:flutter/material.dart';

class CustomTabItem extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const CustomTabItem({
    Key? key,
    required this.label,
    required this.isSelected,
    this.onTap,
  }) : super(key: key);

  @override
  _CustomTabItemState createState() => _CustomTabItemState();
}

class _CustomTabItemState extends State<CustomTabItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _indicatorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _indicatorAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Start animation based on initial selection
    if (widget.isSelected) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(CustomTabItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      splashColor: Colors.green.withOpacity(0.1),
      highlightColor: Colors.green.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.label,
              style: TextStyle(
                color: widget.isSelected ? Colors.green : Colors.black87,
                fontWeight:
                    widget.isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedBuilder(
              animation: _indicatorAnimation,
              builder: (context, child) {
                return Container(
                  height: 3,
                  width: 24 * _indicatorAnimation.value,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
