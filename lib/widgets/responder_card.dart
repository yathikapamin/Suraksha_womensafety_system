import 'package:flutter/material.dart';
import '../config/theme.dart';

class ResponderCard extends StatelessWidget {
  final String name;
  final String role;
  final double distance;
  final int tier;
  final bool isOnline;

  const ResponderCard({
    super.key,
    required this.name,
    required this.role,
    required this.distance,
    required this.tier,
    this.isOnline = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: tier == 1
                    ? AppTheme.primaryBlue.withAlpha(20)
                    : AppTheme.grey100,
                child: Icon(
                  tier == 1 ? Icons.shield_rounded : Icons.person,
                  color: tier == 1 ? AppTheme.primaryBlue : AppTheme.grey500,
                  size: 22,
                ),
              ),
              if (isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.safeGreen,
                      border: Border.all(color: AppTheme.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name, style: AppTheme.labelLarge),
                    const SizedBox(width: 6),
                    if (tier == 1)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withAlpha(15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'VERIFIED',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.primaryBlue,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(role, style: AppTheme.bodySmall),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${distance.toStringAsFixed(1)} km',
                style: AppTheme.labelLarge.copyWith(color: AppTheme.primaryBlue),
              ),
              Text('away', style: AppTheme.bodySmall.copyWith(fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}
