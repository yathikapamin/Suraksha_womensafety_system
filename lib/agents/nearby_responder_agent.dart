import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../services/sms_service.dart';
import '../services/notification_service.dart';
import '../config/constants.dart';

/// Nearby Responder Agent - Finds users within radius and applies tier logic
/// Tier 1: Verified responders → exact location
/// Tier 2: Public users (fallback) → approximate location, first 2-3 get exact
class NearbyResponderAgent {
  final FirestoreService _firestoreService = FirestoreService();
  final SmsService _smsService = SmsService();
  final NotificationService _notificationService = NotificationService();

  // ── Find Nearby Users by Tier ──
  Future<Map<String, List<UserModel>>> findRespondersByTier({
    required double latitude,
    required double longitude,
    required String excludeUserId,
  }) async {
    return await _firestoreService.findRespondersByTier(
      lat: latitude,
      lng: longitude,
      excludeUserId: excludeUserId,
    );
  }

  // ── Find and Notify Responders ──
  Future<Map<String, List<UserModel>>> findAndNotifyResponders({
    required double latitude,
    required double longitude,
    required String excludeUserId,
    required String userName,
  }) async {
    final tiers = await findRespondersByTier(
      latitude: latitude,
      longitude: longitude,
      excludeUserId: excludeUserId,
    );

    final tier1 = tiers['tier1'] ?? [];
    final tier2 = tiers['tier2'] ?? [];

    // ── Notify Tier 1: Verified Responders ──
    // They get EXACT location immediately
    for (final responder in tier1) {
      await _notifyResponder(
        responder: responder,
        userName: userName,
        latitude: latitude,
        longitude: longitude,
        exactLocation: true,
        tier: 1,
      );
    }

    // ── Notify Tier 2: Public Users (Fallback) ──
    // First 2-3 get exact location, rest get approximate
    for (int i = 0; i < tier2.length; i++) {
      final exactForTier2 = i < AppConstants.maxTier2ExactLocation;
      await _notifyResponder(
        responder: tier2[i],
        userName: userName,
        latitude: latitude,
        longitude: longitude,
        exactLocation: exactForTier2,
        tier: 2,
      );
    }

    return {
      'tier1': tier1,
      'tier2': tier2,
    };
  }

  // ── Notify Individual Responder ──
  Future<void> _notifyResponder({
    required UserModel responder,
    required String userName,
    required double latitude,
    required double longitude,
    required bool exactLocation,
    required int tier,
  }) async {
    // Push notification
    String title;
    String body;

    if (tier == 1) {
      title = '🛡️ Emergency Response Needed';
      body = '$userName needs immediate help near your location! Tap to view exact location.';
    } else {
      title = '⚠️ Someone Nearby Needs Help';
      body = '$userName has triggered an emergency alert in your area. Tap to help.';
    }

    await _notificationService.showNotification(
      title: title,
      body: body,
      payload: {
        'type': 'responder_alert',
        'tier': tier,
        'latitude': exactLocation ? latitude : _approximate(latitude),
        'longitude': exactLocation ? longitude : _approximate(longitude),
      },
    );

    // Save notification to Firestore for the responder
    await _firestoreService.saveNotification(
      userId: responder.id,
      title: title,
      body: body,
      type: 'responder_alert',
      data: {
        'tier': tier,
        'exact_location': exactLocation,
        'latitude': exactLocation ? latitude : _approximate(latitude),
        'longitude': exactLocation ? longitude : _approximate(longitude),
      },
    );

    // SMS notification for Tier 1 responders
    if (tier == 1 && responder.phone.isNotEmpty) {
      await _smsService.sendResponderAlert(
        responderPhone: responder.phone,
        userName: userName,
        latitude: latitude,
        longitude: longitude,
        exactLocation: true,
      );
    }
  }

  // ── Approximate Location (for Tier 2) ──
  double _approximate(double value) {
    // Round to 2 decimal places (~1.1km precision)
    return (value * 100).round() / 100;
  }

  // ── Get Responder Count Summary ──
  Future<Map<String, int>> getResponderSummary({
    required double latitude,
    required double longitude,
    required String excludeUserId,
  }) async {
    final tiers = await findRespondersByTier(
      latitude: latitude,
      longitude: longitude,
      excludeUserId: excludeUserId,
    );

    return {
      'tier1_count': tiers['tier1']?.length ?? 0,
      'tier2_count': tiers['tier2']?.length ?? 0,
      'total': (tiers['tier1']?.length ?? 0) + (tiers['tier2']?.length ?? 0),
    };
  }
}
