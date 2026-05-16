import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class UserModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String role; // 'user' or 'responder'
  final bool isVerified;
  final double trustScore;
  final double latitude;
  final double longitude;
  final String? idProofUrl;
  final String? selfieUrl;
  final String? fcmToken;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.role = 'user',
    this.isVerified = false,
    this.trustScore = 0.0,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.idProofUrl,
    this.selfieUrl,
    this.fcmToken,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'user',
      isVerified: map['is_verified'] ?? false,
      trustScore: (map['trust_score'] ?? 0.0).toDouble(),
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      idProofUrl: map['id_proof_url'],
      selfieUrl: map['selfie_url'],
      fcmToken: map['fcm_token'],
      createdAt: map['created_at'] != null
          ? (map['created_at'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role,
      'is_verified': isVerified,
      'trust_score': trustScore,
      'latitude': latitude,
      'longitude': longitude,
      'id_proof_url': idProofUrl,
      'selfie_url': selfieUrl,
      'fcm_token': fcmToken,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? role,
    bool? isVerified,
    double? trustScore,
    double? latitude,
    double? longitude,
    String? idProofUrl,
    String? selfieUrl,
    String? fcmToken,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      trustScore: trustScore ?? this.trustScore,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      idProofUrl: idProofUrl ?? this.idProofUrl,
      selfieUrl: selfieUrl ?? this.selfieUrl,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  double distanceTo(double otherLat, double otherLng) {
    // Haversine formula for accurate distance in meters
    const double r = 6371000; // Earth radius in meters
    final double dLat = (otherLat - latitude) * (pi / 180);
    final double dLng = (otherLng - longitude) * (pi / 180);
    
    final double a = pow(sin(dLat / 2), 2) +
        cos(latitude * (pi / 180)) *
        cos(otherLat * (pi / 180)) *
        pow(sin(dLng / 2), 2);
    
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }
}
