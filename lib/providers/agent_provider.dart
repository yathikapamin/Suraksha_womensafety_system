import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/alert_model.dart';
import '../models/context_model.dart';
import '../agents/detection_agent.dart';
import '../agents/context_agent.dart';
import '../agents/decision_agent.dart';
import '../agents/response_agent.dart';

/// Agent Provider - Orchestrates the multi-agent pipeline
/// Detection → Context → Decision → Response
class AgentProvider extends ChangeNotifier {
  final DetectionAgent _detectionAgent = DetectionAgent();
  final ContextAgent _contextAgent = ContextAgent();
  final DecisionAgent _decisionAgent = DecisionAgent();
  final ResponseAgent _responseAgent = ResponseAgent();

  // State
  bool _isProcessing = false;
  String _currentStage = 'idle';
  double _riskScore = 0.0;
  String _riskLevel = 'SAFE';
  String _statusMessage = 'All systems normal';
  Map<String, dynamic> _lastSensorData = {};
  Map<String, dynamic> _lastDecisionOutput = {};
  ContextModel? _currentContext;
  AlertModel? _lastAlert;
  List<String> _agentLog = [];

  // Getters
  bool get isProcessing => _isProcessing;
  String get currentStage => _currentStage;
  double get riskScore => _riskScore;
  String get riskLevel => _riskLevel;
  String get statusMessage => _statusMessage;
  Map<String, dynamic> get lastSensorData => _lastSensorData;
  Map<String, dynamic> get lastDecisionOutput => _lastDecisionOutput;
  ContextModel? get currentContext => _currentContext;
  AlertModel? get lastAlert => _lastAlert;
  List<String> get agentLog => _agentLog;

  // ═══════════════════════════════════════════════
  // MAIN PIPELINE: Simulate Danger → Full Agent Flow
  // ═══════════════════════════════════════════════
  Future<AlertModel?> runDangerSimulation({
    required UserModel user,
    required double latitude,
    required double longitude,
  }) async {
    _isProcessing = true;
    _agentLog = [];
    notifyListeners();

    try {
      // ── Stage 1: Detection Agent ──
      _updateStage('detection', '🔍 Detection Agent scanning...');
      await Future.delayed(const Duration(milliseconds: 800));

      final sensorData = _detectionAgent.createSensorPayload(
        simulateDanger: true,
      );
      _lastSensorData = sensorData;
      _addLog('Detection Agent: Motion=${sensorData['motion_score']}, Audio=${sensorData['audio_score']}');

      // ── Stage 2: Context Agent ──
      _updateStage('context', '🧠 Context Agent processing...');
      await Future.delayed(const Duration(milliseconds: 800));

      _currentContext = await _contextAgent.updateContext(
        userId: user.id,
        sensorData: sensorData,
        latitude: latitude,
        longitude: longitude,
      );
      _addLog('Context Agent: Location Risk=${_currentContext!.locationRiskScore.toStringAsFixed(2)}');

      // ── Stage 3: Decision Agent ──
      _updateStage('decision', '⚖️ Decision Agent evaluating...');
      await Future.delayed(const Duration(milliseconds: 600));

      _lastDecisionOutput = _decisionAgent.calculateRiskScore(_currentContext!);
      _riskScore = _lastDecisionOutput['final_risk_score'];
      _riskLevel = _lastDecisionOutput['risk_level'];
      _statusMessage = _decisionAgent.getStatusMessage(_riskScore);
      _addLog('Decision Agent: Risk=${_riskScore.toStringAsFixed(3)}, Level=$_riskLevel');

      // Update decision in context
      await _contextAgent.updateDecisionOutput(user.id, _lastDecisionOutput);

      // ── Stage 4: Response Agent (if alert triggered) ──
      if (_lastDecisionOutput['alert_triggered'] == true) {
        _updateStage('response', '🚨 Response Agent dispatching...');
        await Future.delayed(const Duration(milliseconds: 800));

        // Update user with current location before alert
        final updatedUser = user.copyWith(
          latitude: latitude,
          longitude: longitude,
        );

        _lastAlert = await _responseAgent.triggerAlert(
          user: updatedUser,
          riskScore: _riskScore,
          sensorData: sensorData,
        );
        _addLog('Response Agent: Alert ${_lastAlert!.alertId} triggered!');
        _addLog('Response Agent: Notifying nearby responders...');

        _updateStage('complete', '🚨 ALERT ACTIVE - Help dispatched!');
      } else {
        _updateStage('safe', '✅ No threat detected');
        _addLog('Decision: Risk below threshold. No alert triggered.');
      }

      _isProcessing = false;
      notifyListeners();
      return _lastAlert;

    } catch (e) {
      _isProcessing = false;
      _updateStage('error', '❌ Error: ${e.toString()}');
      _addLog('ERROR: ${e.toString()}');
      notifyListeners();
      return null;
    }
  }

  // ── Reset to Safe State ──
  void resetToSafe() {
    _riskScore = 0.0;
    _riskLevel = 'SAFE';
    _statusMessage = 'All systems normal';
    _currentStage = 'idle';
    _lastAlert = null;
    _agentLog = [];
    _lastSensorData = {};
    _lastDecisionOutput = {};
    notifyListeners();
  }

  // ── Resolve Current Alert ──
  Future<void> resolveCurrentAlert(String resolvedBy) async {
    if (_lastAlert != null) {
      await _responseAgent.resolveAlert(
        alertId: _lastAlert!.alertId,
        resolvedBy: resolvedBy,
      );
      _lastAlert = null;
      resetToSafe();
    }
  }

  // ── Helpers ──
  void _updateStage(String stage, String message) {
    _currentStage = stage;
    _statusMessage = message;
    notifyListeners();
  }

  void _addLog(String message) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    _agentLog.add('[$timestamp] $message');
    notifyListeners();
  }
}
