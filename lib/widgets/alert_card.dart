import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/alert_model.dart';

class AlertCard extends StatelessWidget {
  final AlertModel alert;
  final VoidCallback? onTap;

  const AlertCard({
    super.key,
    required this.alert,
    this.onTap,
  });

  Color get _statusColor {
    switch (alert.status) {
      case 'active':
        return AppTheme.dangerRed;
      case 'resolved':
        return AppTheme.safeGreen;
      default:
        return AppTheme.grey400;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _statusColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  alert.status.toUpperCase(),
                  style: AppTheme.bodySmall.copyWith(
                    color: _statusColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatTime(alert.timestamp),
                  style: AppTheme.bodySmall.copyWith(fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Risk Score: ${(alert.riskScore * 100).toInt()}%',
              style: AppTheme.labelLarge.copyWith(fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              'Alert from ${alert.userName}',
              style: AppTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            // Risk bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: alert.riskScore,
                backgroundColor: AppTheme.grey100,
                color: _statusColor,
                minHeight: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return 'Just now';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
