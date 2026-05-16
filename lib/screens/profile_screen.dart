import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (_, auth, __) {
        final user = auth.user;
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.chevron_left, color: AppTheme.grey700, size: 28),
                      const SizedBox(width: 4),
                      Text('SafeNet AI', style: AppTheme.brandText),
                      const Spacer(),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.grey100),
                        child: const Icon(Icons.settings_outlined, color: AppTheme.grey600, size: 18),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Avatar
                CircleAvatar(
                  radius: 45,
                  backgroundColor: AppTheme.grey200,
                  child: const Icon(Icons.person, size: 45, color: AppTheme.grey400),
                ),
                const SizedBox(height: 4),
                // Online indicator
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryBlue,
                    border: Border.all(color: AppTheme.white, width: 2),
                  ),
                ),

                const SizedBox(height: 12),

                Text(user?.name ?? 'User', style: AppTheme.headingLarge),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withAlpha(15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        user?.role.toUpperCase() ?? 'USER',
                        style: AppTheme.bodySmall.copyWith(color: AppTheme.primaryBlue, fontWeight: FontWeight.w700, fontSize: 10),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('• Verified Guardian', style: AppTheme.bodySmall.copyWith(color: AppTheme.grey500)),
                  ],
                ),

                const SizedBox(height: 24),

                // Stats
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: AppTheme.cardDecoration,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('TRUST SCORE', style: AppTheme.bodySmall.copyWith(fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 6),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(text: '4.9', style: AppTheme.headingLarge.copyWith(fontSize: 28)),
                                    TextSpan(text: ' / 5.0', style: AppTheme.bodySmall.copyWith(color: AppTheme.grey400)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withAlpha(10),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.primaryBlue.withAlpha(30)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('SAFE WALKS', style: AppTheme.bodySmall.copyWith(fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 6),
                              Text('124', style: AppTheme.headingLarge.copyWith(fontSize: 28, color: AppTheme.primaryBlue)),
                              Text('↑ 12% this month', style: AppTheme.bodySmall.copyWith(color: AppTheme.safeGreen, fontSize: 10)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Emergency Contacts
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Emergency Contacts', style: AppTheme.headingSmall),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, AppRoutes.emergencyContacts),
                            child: Text('Manage All', style: AppTheme.bodySmall.copyWith(color: AppTheme.primaryBlue, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _ContactTile(name: 'Emergency Contact 1', relation: 'Family • Primary Contact', icon: Icons.phone),
                      const SizedBox(height: 10),
                      _ContactTile(name: 'Emergency Contact 2', relation: 'Friend • Secure Link', icon: Icons.phone),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.grey200),
                        ),
                        child: Center(
                          child: Text('+ Add New Contact', style: AppTheme.bodyMedium.copyWith(color: AppTheme.grey500)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Menu items
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _MenuItem(icon: Icons.shield_outlined, title: 'Privacy & Security', color: AppTheme.dangerRed),
                      _MenuItem(icon: Icons.history, title: 'Emergency History', color: AppTheme.grey600),
                      _MenuItem(
                        icon: Icons.verified_user_outlined,
                        title: 'Verify Identity',
                        color: AppTheme.primaryBlue,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.verification),
                      ),
                      _MenuItem(
                        icon: Icons.logout,
                        title: 'Sign Out',
                        color: AppTheme.dangerRed,
                        onTap: () async {
                          await auth.signOut();
                          if (context.mounted) {
                            Navigator.pushReplacementNamed(context, AppRoutes.login);
                          }
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ContactTile extends StatelessWidget {
  final String name;
  final String relation;
  final IconData icon;

  const _ContactTile({required this.name, required this.relation, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.cardDecoration,
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppTheme.grey100,
            child: const Icon(Icons.person, color: AppTheme.grey500, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTheme.labelLarge),
                Text(relation, style: AppTheme.bodySmall),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.primaryBlue.withAlpha(15)),
            child: Icon(icon, color: AppTheme.primaryBlue, size: 18),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback? onTap;

  const _MenuItem({required this.icon, required this.title, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),
            Text(title, style: AppTheme.labelLarge),
            const Spacer(),
            const Icon(Icons.chevron_right, color: AppTheme.grey400, size: 22),
          ],
        ),
      ),
    );
  }
}
