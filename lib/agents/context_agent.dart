import 'dart:math';
import '../models/context_model.dart';
import '../services/firestore_service.dart';

/// Context Agent - Maintains shared state across all agents
/// Enriches raw sensor data with location risk, time factors, and history
class ContextAgent {
  final FirestoreService _firestoreService = FirestoreService();
  final Random _random = Random();

  ContextModel? _currentContext;
  ContextModel? get currentContext => _currentContext;

  // ── Initialize Context ──
  Future<ContextModel> initializeContext(String userId) async {
    _currentContext = ContextModel(
      userId: userId,
      currentState: {
        'status': 'monitoring',
        'is_emergency': false,
        'last_check': DateTime.now().toIso8601String(),
      },
      sensorData: {},
      decisionOutput: {},
      locationRiskScore: 0.0,
    );

    await _firestoreService.saveContext(_currentContext!);
    return _currentContext!;
  }

  // ── Update Context with Sensor Data ──
  Future<ContextModel> updateContext({
    required String userId,
    required Map<String, dynamic> sensorData,
    required double latitude,
    required double longitude,
  }) async {
    // Calculate location risk score
    final locationRisk = await calculateLocationRisk(
      latitude: latitude,
      longitude: longitude,
    );

    // Build enriched context
    _currentContext = ContextModel(
      userId: userId,
      currentState: {
        'status': 'processing',
        'is_emergency': false,
        'location': {'lat': latitude, 'lng': longitude},
        'time_of_day': _getTimeCategory(),
        'day_of_week': DateTime.now().weekday,
        'last_check': DateTime.now().toIso8601String(),
      },
      sensorData: sensorData,
      decisionOutput: {},
      locationRiskScore: locationRisk,
    );

    // Persist to Firestore
    await _firestoreService.saveContext(_currentContext!);

    return _currentContext!;
  }

  // ── Calculate Location Risk Score ──
  // In production, this would call the Flask ML API
  // For now, uses heuristics: time of day + simulated area data
  Future<double> calculateLocationRisk({
    required double latitude,
    required double longitude,
  }) async {
    double risk = 0.0;

    // Time-based risk factor
    final hour = DateTime.now().hour;
    if (hour >= 22 || hour <= 5) {
      risk += 0.4; // Late night = higher risk
    } else if (hour >= 18 || hour <= 6) {
      risk += 0.2; // Evening/early morning
    } else {
      risk += 0.05; // Daytime = lower risk
    }

    // Simulated area risk (in production, from ML model)
    // Areas with low lighting, fewer people, etc.
    risk += 0.1 + _random.nextDouble() * 0.3;

    // Cap at 1.0
    return risk.clamp(0.0, 1.0);
  }

  // ── Get Time Category ──
  String _getTimeCategory() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'morning';
    if (hour >= 12 && hour < 17) return 'afternoon';
    if (hour >= 17 && hour < 21) return 'evening';
    return 'night';
  }

  // ── Get Context from Firestore ──
  Future<ContextModel?> getContext(String userId) async {
    _currentContext = await _firestoreService.getContext(userId);
    return _currentContext;
  }

  // ── Update Decision Output ──
  Future<void> updateDecisionOutput(
    String userId,
    Map<String, dynamic> decisionOutput,
  ) async {
    if (_currentContext != null) {
      _currentContext = _currentContext!.copyWith(
        decisionOutput: decisionOutput,
        currentState: {
          ..._currentContext!.currentState,
          'status': decisionOutput['alert_triggered'] == true
              ? 'emergency'
              : 'safe',
          'is_emergency': decisionOutput['alert_triggered'] == true,
        },
      );
      await _firestoreService.saveContext(_currentContext!);
    }
  }

  // ── Stream Context ──
  Stream<ContextModel?> streamContext(String userId) {
    return _firestoreService.streamContext(userId);
  }
}
