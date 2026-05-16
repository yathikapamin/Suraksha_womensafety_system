import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/theme.dart';
import '../config/routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      icon: Icons.security_rounded,
      title: 'AI-Powered Protection',
      description: 'Our smart algorithms monitor your surroundings to detect potential threats automatically.',
      color: AppTheme.primaryBlue,
    ),
    _OnboardingData(
      icon: Icons.location_on_rounded,
      title: 'Live Location Sharing',
      description: 'Share your real-time location with trusted contacts and nearby verified responders.',
      color: AppTheme.safeGreen,
    ),
    _OnboardingData(
      icon: Icons.groups_rounded,
      title: 'Community Response',
      description: 'A network of verified guardians ready to respond within minutes when you need help.',
      color: AppTheme.accentPurple,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('SafeNet AI', style: AppTheme.brandText),
                  TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                    child: Text(
                      'SKIP',
                      style: AppTheme.labelLarge.copyWith(color: AppTheme.grey400),
                    ),
                  ),
                ],
              ),
            ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Phone mockup with icon
                        Container(
                          width: 220,
                          height: 320,
                          decoration: BoxDecoration(
                            color: AppTheme.grey50,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: AppTheme.grey200),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: page.color.withAlpha(25),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(page.icon, size: 40, color: page.color),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: page.color.withAlpha(25),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle, size: 14, color: page.color),
                                    const SizedBox(width: 6),
                                    Text(
                                      index == 0
                                          ? 'Threat Detected'
                                          : index == 1
                                              ? 'Location Shared'
                                              : 'Responder Nearby',
                                      style: AppTheme.bodySmall.copyWith(
                                        color: page.color,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 500.ms).scale(
                              begin: const Offset(0.9, 0.9),
                              end: const Offset(1.0, 1.0),
                              duration: 500.ms,
                            ),

                        const SizedBox(height: 48),

                        Text(
                          page.title,
                          style: AppTheme.headingLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page.description,
                          style: AppTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Dots indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 28 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i ? AppTheme.primaryBlue : AppTheme.grey300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Next / Get Started button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                      );
                    } else {
                      Navigator.pushReplacementNamed(context, AppRoutes.login);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentPage < _pages.length - 1 ? 'Next' : 'Get Started',
                        style: AppTheme.buttonText,
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _OnboardingData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  _OnboardingData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
