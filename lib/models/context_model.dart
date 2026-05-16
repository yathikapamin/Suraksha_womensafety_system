import 'package:cloud_firestore/cloud_firestore.dart';

class ContextModel {
  final String userId;
  final Map<String, dynamic> currentState;
  final Map<String, dynamic> sensorData;
  final Map<String, dynamic> decisionOutput;
  final double locationRiskScore;
  final DateTime lastUpdated;

  ContextModel({
    required this.userId,
    this.currentState = const {},
    this.sensorData = const {},
    this.decisionOutput = const {},
    this.locationRiskScore = 0.0,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  factory ContextModel.fromMap(Map<String, dynamic> map) {
    return ContextModel(
      userId: map['user_id'] ?? '',
      currentState: Map<String, dynamic>.from(map['current_state'] ?? {}),
      sensorData: Map<String, dynamic>.from(map['sensor_data'] ?? {}),
      decisionOutput: Map<String, dynamic>.from(map['decision_output'] ?? {}),
      locationRiskScore: (map['location_risk_score'] ?? 0.0).toDouble(),
      lastUpdated: map['last_updated'] != null
          ? (map['last_updated'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'current_state': currentState,
      'sensor_data': sensorData,
      'decision_output': decisionOutput,
      'location_risk_score': locationRiskScore,
      'last_updated': Timestamp.fromDate(lastUpdated),
    };
  }

  ContextModel copyWith({
    String? userId,
    Map<String, dynamic>? currentState,
    Map<String, dynamic>? sensorData,
    Map<String, dynamic>? decisionOutput,
    double? locationRiskScore,
    DateTime? lastUpdated,
  }) {
    return ContextModel(
      userId: userId ?? this.userId,
      currentState: currentState ?? this.currentState,
      sensorData: sensorData ?? this.sensorData,
      decisionOutput: decisionOutput ?? this.decisionOutput,
      locationRiskScore: locationRiskScore ?? this.locationRiskScore,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
