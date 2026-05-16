import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'providers/auth_provider.dart';
import 'providers/location_provider.dart';
import 'providers/alert_provider.dart';
import 'providers/agent_provider.dart';
import 'services/motion_detection_service.dart';
import 'services/audio_detection_service.dart';
import 'services/voice_detection_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const SafeNetApp());
}

class SafeNetApp extends StatelessWidget {
  const SafeNetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => AlertProvider()),
        ChangeNotifierProvider(create: (_) => AgentProvider()),
        ChangeNotifierProvider(create: (_) => MotionDetectionService()),
        ChangeNotifierProvider(create: (_) => AudioDetectionService()),
        ChangeNotifierProvider(create: (_) => VoiceDetectionService()),
      ],
      child: MaterialApp(
        title: 'SafeNet AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
      ),
    );
  }
}
