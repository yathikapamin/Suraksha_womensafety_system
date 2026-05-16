import 'package:flutter/material.dart';
import '../config/theme.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      _NotifData('Safety Alert', 'Movement pattern analyzed - All clear', Icons.shield_rounded, AppTheme.safeGreen, '2m ago', false),
      _NotifData('Emergency', 'SOS triggered by nearby user', Icons.warning_rounded, AppTheme.dangerRed, '15m ago', true),
      _NotifData('System', 'App updated to v4.2 with enhanced AI', Icons.system_update, AppTheme.primaryBlue, '1h ago', false),
      _NotifData('Responder', 'New verified responder in your area', Icons.person_add_rounded, AppTheme.accentPurple, '3h ago', false),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.chevron_left, color: AppTheme.grey700, size: 28),
                  ),
                  Text('SafeNet AI', style: AppTheme.brandText),
                  const Spacer(),
                  Text('Mark all read', style: AppTheme.bodySmall.copyWith(color: AppTheme.primaryBlue, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Notifications', style: AppTheme.headingLarge),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: notifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final n = notifications[i];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: n.isEmergency
                          ? AppTheme.dangerRed.withAlpha(8)
                          : AppTheme.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: n.isEmergency
                            ? AppTheme.dangerRed.withAlpha(30)
                            : AppTheme.grey100,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: n.color.withAlpha(20),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(n.icon, color: n.color, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(n.title, style: AppTheme.labelLarge),
                              const SizedBox(height: 2),
                              Text(n.subtitle, style: AppTheme.bodySmall),
                            ],
                          ),
                        ),
                        Text(n.time, style: AppTheme.bodySmall.copyWith(fontSize: 11)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifData {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final String time;
  final bool isEmergency;
  _NotifData(this.title, this.subtitle, this.icon, this.color, this.time, this.isEmergency);
}
