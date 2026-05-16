import 'package:flutter/material.dart';
import '../config/theme.dart';

class DangerButton extends StatefulWidget {
  final VoidCallback onPressed;

  const DangerButton({super.key, required this.onPressed});

  @override
  State<DangerButton> createState() => _DangerButtonState();
}

class _DangerButtonState extends State<DangerButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: widget.onPressed,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, child) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              gradient: AppTheme.dangerGradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.dangerRed.withAlpha((30 + 30 * _controller.value).toInt()),
                  blurRadius: 20 + 10 * _controller.value,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'SOS',
                  style: AppTheme.displayLarge.copyWith(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'HOLD TO TRIGGER EMERGENCY',
                  style: AppTheme.bodySmall.copyWith(
                    color: Colors.white.withAlpha(200),
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
