import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../models/alert_model.dart';
import '../models/user_model.dart';
import 'notification_service.dart';

class NearbyAlertService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notifications = NotificationService();
  
  // Hard-block native device generated alerts from ever popping up on self
  static final Set<String> locallyGeneratedAlerts = {};

  // ── Stream of Active Alerts ──
  // Used by all devices to listen for nearby SOS in real-time
  Stream<List<AlertModel>> getActiveAlertsStream() {
    return _firestore.collection('alerts')
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AlertModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // ── Stream of a Single Alert ──
  // Used for real-time tracking of a specific victim
  Stream<AlertModel?> getAlertStream(String alertId) {
    return _firestore.collection('alerts').doc(alertId).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return AlertModel.fromMap(snapshot.data()!, snapshot.id);
    });
  }

  // ── Update Alert Location (for live tracking) ──
  Future<void> updateAlertLocation(String alertId, double lat, double lng) async {
    await _firestore.collection('alerts').doc(alertId).update({
      'latitude': lat,
      'longitude': lng,
    });
  }

  // ── Broadcast Emergency ──
  Future<String> broadcastEmergency({
    required String victimId,
    required String victimName,
    required double lat,
    required double lng,
  }) async {
    // 1. Create Alert Document
    final alertDoc = _firestore.collection('alerts').doc();
    final alert = AlertModel(
      alertId: alertDoc.id,
      userId: victimId,
      userName: victimName,
      latitude: lat,
      longitude: lng,
      status: 'active',
      tier: 'tier1', // Default to tier1
      responderIds: [],
    );

    await alertDoc.set(alert.toMap());
    
    // Hard-mark this alert to NEVER pop up on the device that originated it
    locallyGeneratedAlerts.add(alertDoc.id);

    // 2. Find Nearby Users (500m bounding box)
    // Roughly 0.0045 degrees is 500m
    const double radiusInDegrees = 0.0045;
    
    final query = await _firestore.collection('users')
        .where('latitude', isGreaterThan: lat - radiusInDegrees)
        .where('latitude', isLessThan: lat + radiusInDegrees)
        .get();

    final List<UserModel> nearbyResponders = [];
    final List<UserModel> nearbyPublicUsers = [];

    for (var doc in query.docs) {
      if (doc.id == victimId) continue;
      
      final user = UserModel.fromMap(doc.data());
      
      // Secondary distance check for circular radius
      final distance = Geolocator.distanceBetween(lat, lng, user.latitude, user.longitude);
      
      if (distance <= 500) {
        if (user.role == 'responder' && user.isVerified) {
          nearbyResponders.add(user);
        } else {
          nearbyPublicUsers.add(user);
        }
      }
    }

    // 3. Tiered Dispatch Logic
    if (nearbyResponders.isNotEmpty) {
      // TIER 1: Exact location to verified responders
      for (var responder in nearbyResponders) {
        if (responder.fcmToken != null) {
          // Send Tier 1 Notification
          await _sendNotification(
            token: responder.fcmToken!,
            title: '🚨 Emergency nearby!',
            body: '$victimName needs urgent help. Tap to respond.',
            data: {
              'type': 'tier1_alert',
              'alert_id': alertDoc.id,
              'victim_name': victimName,
              'lat': lat.toString(),
              'lng': lng.toString(),
            },
          );
        }
      }
    } else if (nearbyPublicUsers.isNotEmpty) {
      // TIER 2 FALLBACK: Approximate location to public users
      // Update alert to tier2
      await alertDoc.update({'tier': 'tier2'});

      for (var publicUser in nearbyPublicUsers) {
        if (publicUser.fcmToken != null) {
          // Send Tier 2 Notification
          await _sendNotification(
            token: publicUser.fcmToken!,
            title: '⚠️ Emergency detected near you',
            body: 'Someone needs help (~300m away). Can you assist?',
            data: {
              'type': 'tier2_alert',
              'alert_id': alertDoc.id,
              'lat': (lat + 0.001).toString(), // Slightly obfuscated
              'lng': (lng + 0.001).toString(),
            },
          );
        }
      }
    }

    return alertDoc.id;
  }

  // ── Accept Alert Logic ──
  Future<bool> acceptAlert(String alertId, String responderId, bool isVerified) async {
    final alertRef = _firestore.collection('alerts').doc(alertId);

    return await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(alertRef);
      if (!snapshot.exists) return false;

      final alert = AlertModel.fromMap(snapshot.data()!, snapshot.id);

      // Check if already resolved
      if (alert.status != 'active') return false;

      // Check Tier 2 limits
      if (alert.tier == 'tier2' && !isVerified) {
        if (alert.responderIds.length >= alert.maxPublicResponders) {
          return false; // Limit reached
        }
      }

      // Add responder
      transaction.update(alertRef, {
        'responder_ids': FieldValue.arrayUnion([responderId])
      });

      return true;
    });
  }

  // ── Resolve/Cancel Alert ──
  Future<void> resolveAlert(String alertId, String reason) async {
    await _firestore.collection('alerts').doc(alertId).update({
      'status': 'resolved',
      'resolved_reason': reason,
      'resolved_at': FieldValue.serverTimestamp(),
    });
  }

  // ── Helper: Send Push Notification ──
  Future<void> _sendNotification({
    required String token,
    required String title,
    required String body,
    required Map<String, String> data,
  }) async {
    // In a real app, this would be a call to a Cloud Function or FCM API
    // For this simulation, we'll log it and trigger a local notification
    // if we are the recipient (for testing purposes).
    print('SENDING PUSH TO $token: $title - $body');
    
    // We update NotificationService to handle this dispatch if needed,
    // but typically push is server-side.
  }
}
