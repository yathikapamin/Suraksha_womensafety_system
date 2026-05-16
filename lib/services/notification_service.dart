import 'dart:ui' show Color;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // ── Initialize ──
  Future<void> initialize() async {
    // Request permission
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: true,
    );

    // Initialize local notifications
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    const androidChannel = AndroidNotificationChannel(
      'safenet_alerts',
      'SafeNet Alerts',
      description: 'Emergency alert notifications',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background message tap
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  // ── Get FCM Token ──
  Future<String?> getToken() async {
    return await _fcm.getToken();
  }

  // ── Subscribe to Topic ──
  Future<void> subscribeToTopic(String topic) async {
    await _fcm.subscribeToTopic(topic);
  }

  // ── Unsubscribe from Topic ──
  Future<void> unsubscribeFromTopic(String topic) async {
    await _fcm.unsubscribeFromTopic(topic);
  }

  // ── Show Local Notification ──
  Future<void> showNotification({
    required String title,
    required String body,
    Map<String, dynamic>? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'safenet_alerts',
      'SafeNet Alerts',
      channelDescription: 'Emergency alert notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFEF4444),
      styleInformation: BigTextStyleInformation(''),
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      notificationDetails,
      payload: payload?.toString(),
    );
  }

  // ── Show Emergency Notification ──
  Future<void> showEmergencyNotification({
    required String userName,
    required String location,
  }) async {
    await showNotification(
      title: '🚨 EMERGENCY ALERT',
      body: '$userName needs help! Tap to view location and respond.',
      payload: {'type': 'emergency', 'location': location},
    );
  }

  // ── Handle Foreground Message ──
  void _handleForegroundMessage(RemoteMessage message) {
    if (message.notification != null) {
      showNotification(
        title: message.notification!.title ?? 'SafeNet AI',
        body: message.notification!.body ?? '',
        payload: message.data,
      );
    }
  }

  // ── Handle Message Opened App ──
  void _handleMessageOpenedApp(RemoteMessage message) {
    if (message.data['type'] == 'tier1_alert' || message.data['type'] == 'tier2_alert') {
      // In a real app, we would use a navigation service global key
      // For now, we log and expect the UI listeners to handle it
      print('Emergency Alert Received: ${message.data['alert_id']}');
    }
  }

  // ── Handle Notification Tap ──
  void _onNotificationTapped(NotificationResponse response) {
    // ignore: avoid_print
    print('Notification tapped: ${response.payload}');
  }
}
