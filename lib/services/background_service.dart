import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'nearby_alert_service.dart';
import 'notification_service.dart';
import '../models/alert_model.dart';
import 'audio_detection_service.dart';
import 'motion_detection_service.dart';
import 'voice_detection_service.dart';

class BackgroundService {
  static Future<void> initialize() async {
    final service = FlutterBackgroundService();

    // 1. Configure Notification Channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'safenet_guard',
      'SafeNet Guard',
      description: 'Keeps SafeNet AI monitoring in the background.',
      importance: Importance.low,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 2. Setup Service
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: 'safenet_guard',
        initialNotificationTitle: 'SafeNet Guard Active',
        initialNotificationContent: 'Monitoring sensors and nearby SOS...',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    return true;
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();
    await Firebase.initializeApp();

    final NearbyAlertService nearbyService = NearbyAlertService();
    final NotificationService notificationService = NotificationService();
    await notificationService.initialize();

    // Track processed alerts to avoid duplicate notifications in background
    String? currentUserId;
    final Set<String> processedAlerts = {};

    service.on('setUserId').listen((event) {
      if (event != null && event['id'] != null) {
        currentUserId = event['id'];
        print('[Background] Logged in user: $currentUserId');
      }
    });

    Timer.periodic(const Duration(seconds: 15), (timer) async {
      if (service is AndroidServiceInstance) {
        if (await service.isForegroundService()) {
          service.setAsForegroundService();
          service.setForegroundNotificationInfo(
            title: "SafeNet Guard Active",
            content: "Monitoring for your safety...",
          );
        }
      }

      // Check for nearby alerts every 15 seconds in the background
      // This is a simplified version of the listener for background use
      Position? currentPos;
      try {
        currentPos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
        );
      } catch (e) {
        print('[Background] Location access denied or failed.');
        return;
      }

      final alerts = await nearbyService.getActiveAlertsStream().first;
      
      for (var alert in alerts) {
        // Simple distance check
        double distance = Geolocator.distanceBetween(
          currentPos.latitude,
          currentPos.longitude,
          alert.latitude,
          alert.longitude,
        );

        if (distance <= 500 && !processedAlerts.contains(alert.alertId)) {
          // Skip if self
          if (alert.userId == currentUserId) {
            continue;
          }
          
          processedAlerts.add(alert.alertId);
          notificationService.showNotification(
            title: '🚨 NEARBY EMERGENCY',
            body: '${alert.userName} needs help nearby!',
            payload: {'alert_id': alert.alertId, 'type': 'emergency_dispatch'},
          );
        }
      }
    });

    service.on('stopService').listen((event) {
      service.stopSelf();
    });
  }
}
