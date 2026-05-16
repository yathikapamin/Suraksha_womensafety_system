import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/otp_screen.dart';
import '../screens/role_selection_screen.dart';
import '../screens/home_dashboard.dart';
import '../screens/verification_screen.dart';
import '../screens/emergency_alert_screen.dart';
import '../screens/emergency_contacts_screen.dart';
import '../screens/voice_terminal_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String otp = '/otp';
  static const String roleSelection = '/role-selection';
  static const String home = '/home';
  static const String verification = '/verification';
  static const String emergency = '/emergency';
  static const String emergencyContacts = '/emergency-contacts';
  static const String voiceTerminal = '/voice-terminal';

  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const SplashScreen(),
        onboarding: (_) => const OnboardingScreen(),
        login: (_) => const LoginScreen(),
        signup: (_) => const SignupScreen(),
        otp: (_) => const OtpScreen(),
        roleSelection: (_) => const RoleSelectionScreen(),
        home: (_) => const HomeDashboard(),
        verification: (_) => const VerificationScreen(),
        emergency: (_) => const EmergencyAlertScreen(),
        emergencyContacts: (_) => const EmergencyContactsScreen(),
        voiceTerminal: (_) => const VoiceTerminalScreen(),
      };
}
