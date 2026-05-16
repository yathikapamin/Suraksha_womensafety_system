import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/alert_model.dart';
import '../models/context_model.dart';
import '../config/constants.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ═══════════════════════════════════════
  // USERS
  // ═══════════════════════════════════════

  Future<void> createUser(UserModel user) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.id)
        .set(user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();
    if (doc.exists) return UserModel.fromMap(doc.data()!);
    return null;
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .update(data);
  }

  Stream<UserModel?> streamUser(String uid) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromMap(doc.data()!) : null);
  }

  Future<List<UserModel>> getAllUsers() async {
    final snapshot =
        await _firestore.collection(AppConstants.usersCollection).get();
    return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
  }

  // ── Nearby Users (Geo Query) ──
  Future<List<UserModel>> getNearbyUsers({
    required double lat,
    required double lng,
    double radiusKm = AppConstants.nearbyRadiusKm,
  }) async {
    // Simple bounding box query since Firestore doesn't natively support radius
    final latRange = radiusKm / 111.0; // ~111km per degree latitude
    final lngRange = radiusKm / (111.0 * 0.85); // approximate

    final snapshot = await _firestore
        .collection(AppConstants.usersCollection)
        .where('latitude', isGreaterThan: lat - latRange)
        .where('latitude', isLessThan: lat + latRange)
        .get();

    // Filter by longitude in memory (Firestore limitation)
    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data()))
        .where((user) =>
            user.longitude >= lng - lngRange &&
            user.longitude <= lng + lngRange)
        .toList();
  }

  // ── Find Responders by Tier ──
  Future<Map<String, List<UserModel>>> findRespondersByTier({
    required double lat,
    required double lng,
    required String excludeUserId,
  }) async {
    final nearbyUsers = await getNearbyUsers(lat: lat, lng: lng);

    // Exclude the user who triggered the alert
    final filtered = nearbyUsers.where((u) => u.id != excludeUserId).toList();

    // Tier 1: Verified Responders
    final tier1 = filtered
        .where((u) => u.role == 'responder' && u.isVerified)
        .toList();

    // Tier 2: All other users (fallback)
    final tier2 = filtered
        .where((u) => !(u.role == 'responder' && u.isVerified))
        .toList();

    return {
      'tier1': tier1,
      'tier2': tier2,
    };
  }

  // ═══════════════════════════════════════
  // ALERTS
  // ═══════════════════════════════════════

  Future<void> createAlert(AlertModel alert) async {
    await _firestore
        .collection(AppConstants.alertsCollection)
        .doc(alert.alertId)
        .set(alert.toMap());
  }

  Future<void> updateAlert(String alertId, Map<String, dynamic> data) async {
    await _firestore
        .collection(AppConstants.alertsCollection)
        .doc(alertId)
        .update(data);
  }

  Future<void> resolveAlert(String alertId, String resolvedBy) async {
    await _firestore
        .collection(AppConstants.alertsCollection)
        .doc(alertId)
        .update({
      'status': 'resolved',
      'resolved_by': resolvedBy,
      'resolved_at': Timestamp.now(),
    });
  }

  Stream<List<AlertModel>> streamAlerts({String? userId}) {
    Query query = _firestore
        .collection(AppConstants.alertsCollection)
        .orderBy('timestamp', descending: true);

    if (userId != null) {
      query = query.where('user_id', isEqualTo: userId);
    }

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => AlertModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList()
        .cast<AlertModel>());
  }

  Stream<List<AlertModel>> streamActiveAlerts() {
    return _firestore
        .collection(AppConstants.alertsCollection)
        .where('status', isEqualTo: 'active')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AlertModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList()
            .cast<AlertModel>());
  }

  Future<List<AlertModel>> getRecentAlerts({int limit = 5}) async {
    final snapshot = await _firestore
        .collection(AppConstants.alertsCollection)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs
        .map((doc) => AlertModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList()
        .cast<AlertModel>();
  }

  // ═══════════════════════════════════════
  // CONTEXT
  // ═══════════════════════════════════════

  Future<void> saveContext(ContextModel context) async {
    await _firestore
        .collection(AppConstants.contextCollection)
        .doc(context.userId)
        .set(context.toMap(), SetOptions(merge: true));
  }

  Future<ContextModel?> getContext(String userId) async {
    final doc = await _firestore
        .collection(AppConstants.contextCollection)
        .doc(userId)
        .get();
    if (doc.exists) return ContextModel.fromMap(doc.data()!);
    return null;
  }

  Stream<ContextModel?> streamContext(String userId) {
    return _firestore
        .collection(AppConstants.contextCollection)
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? ContextModel.fromMap(doc.data()!) : null);
  }

  // ═══════════════════════════════════════
  // VERIFICATION REQUESTS
  // ═══════════════════════════════════════

  Future<void> submitVerification({
    required String userId,
    required String idProofUrl,
    required String selfieUrl,
  }) async {
    await _firestore.collection(AppConstants.verificationCollection).doc(userId).set({
      'user_id': userId,
      'id_proof_url': idProofUrl,
      'selfie_url': selfieUrl,
      'status': 'pending',
      'submitted_at': Timestamp.now(),
      'reviewed_at': null,
    });
  }

  Future<Map<String, dynamic>?> getVerificationStatus(String userId) async {
    final doc = await _firestore
        .collection(AppConstants.verificationCollection)
        .doc(userId)
        .get();
    return doc.data();
  }

  // ═══════════════════════════════════════
  // EMERGENCY CONTACTS
  // ═══════════════════════════════════════

  Future<void> addEmergencyContact({
    required String userId,
    required String name,
    required String phone,
    required String relationship,
  }) async {
    await _firestore.collection(AppConstants.emergencyContactsCollection).add({
      'user_id': userId,
      'name': name,
      'phone': phone,
      'relationship': relationship,
    });
  }

  Future<List<Map<String, dynamic>>> getEmergencyContacts(String userId) async {
    final snapshot = await _firestore
        .collection(AppConstants.emergencyContactsCollection)
        .where('user_id', isEqualTo: userId)
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // ═══════════════════════════════════════
  // NOTIFICATIONS
  // ═══════════════════════════════════════

  Future<void> saveNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    await _firestore.collection(AppConstants.notificationsCollection).add({
      'user_id': userId,
      'title': title,
      'body': body,
      'type': type,
      'data': data ?? {},
      'read': false,
      'created_at': Timestamp.now(),
    });
  }

  Stream<List<Map<String, dynamic>>> streamNotifications(String userId) {
    return _firestore
        .collection(AppConstants.notificationsCollection)
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }
}
