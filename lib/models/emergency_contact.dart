import 'package:cloud_firestore/cloud_firestore.dart';

class EmergencyContact {
  final String id;
  final String name;
  final String phone;
  final String relationship;
  final bool isPrimary;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    required this.relationship,
    this.isPrimary = false,
  });

  factory EmergencyContact.fromMap(Map<String, dynamic> map) {
    return EmergencyContact(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      relationship: map['relationship'] ?? '',
      isPrimary: map['is_primary'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'relationship': relationship,
      'is_primary': isPrimary,
    };
  }
}
