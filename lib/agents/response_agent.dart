import 'package:uuid/uuid.dart';
import '../models/alert_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import '../services/sms_service.dart';
import 'nearby_responder_agent.dart';
import '../services/nearby_alert_service.dart';

/// Response Agent - Handles alert dispatch, notifications, SMS, and alarm
class ResponseAgent {
  final FirestoreService _firestoreService = FirestoreService();
  final NotificationService _notificationService = NotificationService();
  final SmsService _smsService = SmsService();
  final NearbyResponderAgent _nearbyAgent = NearbyResponderAgent();
  final Uuid _uuid = const Uuid();

  // ── Trigger Full Alert Pipeline ──
  Future<AlertModel> triggerAlert({
    required UserModel user,
    required double riskScore,
    required Map<String, dynamic> sensorData,
  }) async {
    // 1. Create alert document
    final alert = AlertModel(
      alertId: _uuid.v4(),
      userId: user.id,
      userName: user.name,
      riskScore: riskScore,
      latitude: user.latitude,
      longitude: user.longitude,
      status: 'active',
      sensorData: sensorData,
    );

    // 2. Save to Firestore
    await _firestoreService.createAlert(alert);
    
    // Hard-mark this alert to NEVER pop up on the device that originated it
    NearbyAlertService.locallyGeneratedAlerts.add(alert.alertId);

    // 3. Find nearby responders
    final responders = await _nearbyAgent.findAndNotifyResponders(
      latitude: user.latitude,
      longitude: user.longitude,
      excludeUserId: user.id,
      userName: user.name,
    );

    // 4. Update alert with notified responders
    final List<String> notifiedIds = [];
    final t1 = responders['tier1'];
    final t2 = responders['tier2'];
    if (t1 != null) {
      for (final u in t1) {
        notifiedIds.add(u.id);
      }
    }
    if (t2 != null) {
      for (final u in t2) {
        notifiedIds.add(u.id);
      }
    }

    await _firestoreService.updateAlert(alert.alertId, {
      'notified_responders': notifiedIds,
    });

    // 5. [Disabled] Sending push notification to self
    // (We disable this to prevent the victim from getting an annoying "Emergency Alert Triggered" banner when they themselves generate the SOS).

    // 6. Send emergency SMS to emergency contacts
    final contacts = await _firestoreService.getEmergencyContacts(user.id);
    if (contacts.isNotEmpty) {
      final phoneNumbers = contacts.map((c) => c['phone'] as String).toList();
      await _smsService.sendEmergencyAlert(
        userName: user.name,
        latitude: user.latitude,
        longitude: user.longitude,
        phoneNumbers: phoneNumbers,
      );
    }

    // 7. Save notification record
    await _firestoreService.saveNotification(
      userId: user.id,
      title: '🚨 Emergency Alert Triggered',
      body: 'Risk Score: ${(riskScore * 100).toInt()}% - Help is on the way!',
      type: 'emergency',
      data: {'alert_id': alert.alertId},
    );

    return alert;
  }

  // ── Resolve Alert ──
  Future<void> resolveAlert({
    required String alertId,
    required String resolvedBy,
  }) async {
    await _firestoreService.resolveAlert(alertId, resolvedBy);

    await _notificationService.showNotification(
      title: '✅ Alert Resolved',
      body: 'The emergency alert has been resolved.',
    );
  }

  // ── Cancel Alert ──
  Future<void> cancelAlert(String alertId) async {
    await _firestoreService.updateAlert(alertId, {
      'status': 'cancelled',
    });
  }

  // ── Share Live Location ──
  Future<void> shareLiveLocation({
    required String userId,
    required double latitude,
    required double longitude,
  }) async {
    await _firestoreService.updateUser(userId, {
      'latitude': latitude,
      'longitude': longitude,
      'location_sharing': true,
      'location_updated_at': DateTime.now().toIso8601String(),
    });
  }
}
