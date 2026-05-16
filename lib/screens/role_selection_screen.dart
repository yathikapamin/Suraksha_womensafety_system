import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/theme.dart';
import '../config/routes.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('SafeNet AI', style: AppTheme.brandText),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.safeGreen,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              Text('Select Your Role', style: AppTheme.displayLarge),
              const SizedBox(height: 12),
              Text(
                'Choose how you will interact with the SafeNet ecosystem. Your choice determines your available tools and responsibilities.',
                style: AppTheme.bodyLarge,
              ),

              const SizedBox(height: 32),

              // Normal User Card
              _RoleCard(
                icon: Icons.person_rounded,
                title: 'Normal User',
                description: 'Access safety maps, real-time alerts, and immediate SOS support. Perfect for individuals seeking personal protection.',
                actionText: 'GET PROTECTED →',
                isSelected: _selectedRole == 'user',
                onTap: () => setState(() => _selectedRole = 'user'),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),

              const SizedBox(height: 16),

              // Responder Card
              _RoleCard(
                icon: Icons.shield_rounded,
                title: 'Become Responder',
                description: 'Join our network of verified guardians. Receive alerts, respond to SOS calls, and help build a safer community.',
                actionText: 'START GUARDING 🛡',
                isSelected: _selectedRole == 'responder',
                onTap: () => setState(() => _selectedRole = 'responder'),
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1),

              const SizedBox(height: 32),

              // Features
              _FeatureItem(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy First',
                description: 'Your data stays securely within our encrypted networks.',
              ),
              const SizedBox(height: 12),
              _FeatureItem(
                icon: Icons.groups_outlined,
                title: 'Community Driven',
                description: 'Join over 10,000 active guardians.',
              ),
              const SizedBox(height: 12),
              _FeatureItem(
                icon: Icons.flash_on_outlined,
                title: 'Instant Response',
                description: 'Sub-second alert distribution.',
              ),

              const SizedBox(height: 32),

              // Continue button
              if (_selectedRole != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, AppRoutes.home);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text('Continue as ${_selectedRole == 'user' ? 'User' : 'Responder'}',
                        style: AppTheme.buttonText),
                  ),
                ).animate().fadeIn(duration: 300.ms),

              const SizedBox(height: 24),

              // Footer
              Center(
                child: Text(
                  'POWERED BY SAFENET AI DSR • 2024',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.grey400,
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String actionText;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.actionText,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : AppTheme.grey200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withAlpha(20),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withAlpha(15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.primaryBlue, size: 24),
            ),
            const SizedBox(height: 16),
            Text(title, style: AppTheme.headingSmall),
            const SizedBox(height: 8),
            Text(description, style: AppTheme.bodyMedium.copyWith(height: 1.5)),
            const SizedBox(height: 14),
            Text(
              actionText,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.dangerRed,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.grey500, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppTheme.grey700)),
            Text(description, style: AppTheme.bodySmall.copyWith(fontSize: 11)),
          ],
        ),
      ],
    );
  }
}
