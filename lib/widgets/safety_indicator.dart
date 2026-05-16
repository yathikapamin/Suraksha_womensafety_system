import 'package:flutter/material.dart';
import '../config/theme.dart';

class SafetyIndicator extends StatelessWidget {
  final double safetyScore;
  final bool isActive;

  const SafetyIndicator({
    super.key,
    required this.safetyScore,
    this.isActive = true,
  });

  Color get _color {
    if (safetyScore >= 0.7) return AppTheme.safeGreen;
    if (safetyScore >= 0.4) return AppTheme.cautionYellow;
    return AppTheme.dangerRed;
  }

  String get _label {
    if (safetyScore >= 0.7) return 'SECURED';
    if (safetyScore >= 0.4) return 'CAUTION';
    return 'DANGER';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _color.withAlpha(20),
          ),
          child: Icon(
            safetyScore >= 0.7
                ? Icons.shield_rounded
                : safetyScore >= 0.4
                    ? Icons.warning_rounded
                    : Icons.dangerous_rounded,
            color: _color,
            size: 32,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: _color.withAlpha(20),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _label,
            style: AppTheme.bodySmall.copyWith(
              color: _color,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
