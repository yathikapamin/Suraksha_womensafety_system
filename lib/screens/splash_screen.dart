import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    await Future.delayed(const Duration(milliseconds: 3000));
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isLoggedIn) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.splashGradient),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),

              // Shield Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(40),
                ),
                child: Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withAlpha(60),
                    ),
                    child: const Icon(
                      Icons.shield_rounded,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 800.ms)
                  .scale(begin: const Offset(0.5, 0.5), end: const Offset(1.0, 1.0), duration: 800.ms),

              const SizedBox(height: 32),

              // App Name
              Text(
                'SafeNet AI',
                style: AppTheme.displayLarge.copyWith(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 600.ms),

              const SizedBox(height: 12),

              // Tagline
              Text(
                '"Your Safety, Our Priority"',
                style: AppTheme.bodyLarge.copyWith(
                  color: Colors.white.withAlpha(200),
                  fontStyle: FontStyle.italic,
                  fontSize: 15,
                ),
              ).animate().fadeIn(delay: 700.ms, duration: 600.ms),

              const Spacer(flex: 3),

              // Get Protected Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60),
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.white, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Get Protected',
                        style: AppTheme.buttonText.copyWith(fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.3),

              const SizedBox(height: 24),

              // Footer
              Text(
                '🔒 SECURE ENCRYPTED SESSION',
                style: AppTheme.bodySmall.copyWith(
                  color: Colors.white.withAlpha(120),
                  fontSize: 10,
                  letterSpacing: 1.5,
                ),
              ).animate().fadeIn(delay: 1200.ms),

              const SizedBox(height: 16),

              Text(
                'GUARDIAN PROTOCOL V4.2',
                style: AppTheme.bodySmall.copyWith(
                  color: Colors.white.withAlpha(80),
                  fontSize: 9,
                  letterSpacing: 2,
                ),
              ).animate().fadeIn(delay: 1400.ms),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
