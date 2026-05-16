import 'package:cloud_firestore/cloud_firestore.dart';

class AlertModel {
  final String alertId;
  final String userId; // Matches existing agent code
  final String userName; // Matches existing agent code
  final double latitude;
  final double longitude;
  final String status; // 'active', 'resolved', 'cancelled'
  final double riskScore; // Matches existing agent code
  final Map<String, dynamic>? sensorData; // Matches existing agent code
  final String tier; // For Tiered Alert System
  final List<String> responderIds; // For Tiered Alert System
  final int maxPublicResponders;
  final DateTime createdAt;

  // Victim aliases for the Tiered Alert prompt requirements
  String get victimId => userId;
  String get victimName => userName;

  AlertModel({
    required this.alertId,
    required this.userId,
    required this.userName,
    required this.latitude,
    required this.longitude,
    required this.status,
    this.riskScore = 0.0,
    this.sensorData,
    this.tier = 'tier1',
    this.responderIds = const [],
    this.maxPublicResponders = 3,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AlertModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    return AlertModel(
      alertId: docId ?? map['alert_id'] ?? '',
      userId: map['user_id'] ?? map['victim_id'] ?? '',
      userName: map['user_name'] ?? map['victim_name'] ?? 'Someone',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'active',
      riskScore: (map['risk_score'] ?? 0.0).toDouble(),
      sensorData: map['sensor_data'],
      tier: map['tier'] ?? 'tier1',
      responderIds: List<String>.from(map['responder_ids'] ?? map['notified_responders'] ?? []),
      maxPublicResponders: map['max_public_responders'] ?? 3,
      createdAt: map['created_at'] != null
          ? (map['created_at'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'alert_id': alertId,
      'user_id': userId,
      'victim_id': victimId, // Include both for compatibility
      'user_name': userName,
      'victim_name': victimName,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'risk_score': riskScore,
      'sensor_data': sensorData,
      'tier': tier,
      'responder_ids': responderIds,
      'max_public_responders': maxPublicResponders,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  AlertModel copyWith({
    String? alertId,
    String? userId,
    String? userName,
    double? latitude,
    double? longitude,
    String? status,
    double? riskScore,
    Map<String, dynamic>? sensorData,
    String? tier,
    List<String>? responderIds,
    int? maxPublicResponders,
    DateTime? createdAt,
  }) {
    return AlertModel(
      alertId: alertId ?? this.alertId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      riskScore: riskScore ?? this.riskScore,
      sensorData: sensorData ?? this.sensorData,
      tier: tier ?? this.tier,
      responderIds: responderIds ?? this.responderIds,
      maxPublicResponders: maxPublicResponders ?? this.maxPublicResponders,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
