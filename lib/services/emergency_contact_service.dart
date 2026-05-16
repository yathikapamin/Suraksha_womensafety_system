import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import '../models/emergency_contact.dart';
import '../config/constants.dart';

/// Manages emergency contacts and sends family alerts
class EmergencyContactService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const MethodChannel _smsChannel = MethodChannel('com.safenetai.safenet_ai/sms');

  /// Get all emergency contacts for a user
  Future<List<EmergencyContact>> getContacts(String userId) async {
    try {
      final snapshot = await _db
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection(AppConstants.emergencyContactsCollection)
          .orderBy('is_primary', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => EmergencyContact.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting contacts: $e');
      return [];
    }
  }

  /// Add a new emergency contact
  Future<EmergencyContact> addContact({
    required String userId,
    required String name,
    required String phone,
    required String relationship,
    bool isPrimary = false,
  }) async {
    final id = const Uuid().v4();
    final contact = EmergencyContact(
      id: id,
      name: name,
      phone: phone,
      relationship: relationship,
      isPrimary: isPrimary,
    );

    await _db
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.emergencyContactsCollection)
        .doc(id)
        .set(contact.toMap());

    return contact;
  }

  /// Remove an emergency contact
  Future<void> removeContact(String userId, String contactId) async {
    await _db
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.emergencyContactsCollection)
        .doc(contactId)
        .delete();
  }

  /// Send emergency alert SMS to all contacts
  /// Includes current location and danger type
  Future<void> sendEmergencyAlerts({
    required String userId,
    required String userName,
    required double latitude,
    required double longitude,
    required String dangerType,
    required List<EmergencyContact> contacts,
  }) async {
    final locationUrl =
        'https://www.google.com/maps?q=$latitude,$longitude';

    final message = '🚨 SAFENET AI EMERGENCY ALERT 🚨\n\n'
        '$userName is in danger!\n\n'
        '⚠️ Type: $dangerType\n'
        '📍 Location: $locationUrl\n'
        '🕐 Time: ${DateTime.now().toString().substring(0, 19)}\n\n'
        'Please check on them immediately or call emergency services.\n'
        '- SafeNet AI';

    print('🚨🚨 STARTING SILENT DISPATCH TO \${contacts.length} CONTACTS 🚨🚨');
    
    // Request Runtime Hardware SMS Permission
    var status = await Permission.sms.status;
    if (!status.isGranted) {
      status = await Permission.sms.request();
      if (!status.isGranted) {
        print('❌ NATIVE SMS KERNEL PERMISSION DENIED BY USER');
        return;
      }
    }
    
    if (contacts.isEmpty) {
      print('❌ ERROR: NO EMERGENCY CONTACTS FOUND IN FIREBASE! CANNOT SEND ANY MESSAGES!');
    }

    for (final contact in contacts) {
      print('📞 SENDING NATIVE SMS TO: ${contact.phone}');
      
      try {
        await _smsChannel.invokeMethod('sendSms', {
          'phone': contact.phone,
          'message': message,
        });
        print('✅ NATIVE SMS DISPATCHED: ${contact.phone}');
      } catch (e) {
        print('❌ Native SMS Error: $e');
      }
    }

    print('✅ DISPATCH LOOP COMPLETE');

    // Also save alert to Firestore
    await _db.collection('emergency_alerts').add({
      'user_id': userId,
      'user_name': userName,
      'latitude': latitude,
      'longitude': longitude,
      'danger_type': dangerType,
      'contacts_notified': contacts.map((c) => c.phone).toList(),
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
