import '../models/context_model.dart';
import '../config/constants.dart';

/// Decision Agent - Combines all scores and determines if alert should trigger
/// Implements weighted risk calculation with configurable thresholds
class DecisionAgent {
  // ── Calculate Final Risk Score ──
  // Formula: finalRisk = (motionScore * 0.3) + (audioScore * 0.4) + (locationRisk * 0.3)
  Map<String, dynamic> calculateRiskScore(ContextModel context) {
    final motionScore =
        (context.sensorData['motion_score'] ?? 0.0) as double;
    final audioScore =
        (context.sensorData['audio_score'] ?? 0.0) as double;
    final locationRisk = context.locationRiskScore;

    // Weighted calculation
    final finalRisk = (motionScore * AppConstants.motionWeight) +
        (audioScore * AppConstants.audioWeight) +
        (locationRisk * AppConstants.locationWeight);

    // Determine risk level
    String riskLevel;
    if (finalRisk >= AppConstants.riskThresholdDanger) {
      riskLevel = 'HIGH';
    } else if (finalRisk >= AppConstants.riskThresholdSafe) {
      riskLevel = 'MEDIUM';
    } else {
      riskLevel = 'LOW';
    }

    // Should we trigger an alert?
    final alertTriggered = finalRisk >= AppConstants.riskThresholdDanger;

    return {
      'final_risk_score': double.parse(finalRisk.toStringAsFixed(3)),
      'risk_level': riskLevel,
      'alert_triggered': alertTriggered,
      'component_scores': {
        'motion_score': motionScore,
        'motion_weight': AppConstants.motionWeight,
        'motion_contribution': double.parse(
            (motionScore * AppConstants.motionWeight).toStringAsFixed(3)),
        'audio_score': audioScore,
        'audio_weight': AppConstants.audioWeight,
        'audio_contribution': double.parse(
            (audioScore * AppConstants.audioWeight).toStringAsFixed(3)),
        'location_risk': locationRisk,
        'location_weight': AppConstants.locationWeight,
        'location_contribution': double.parse(
            (locationRisk * AppConstants.locationWeight).toStringAsFixed(3)),
      },
      'threshold': AppConstants.riskThresholdDanger,
      'decision_timestamp': DateTime.now().toIso8601String(),
      'agent': 'DecisionAgent',
    };
  }

  // ── Should Trigger Alert ──
  bool shouldTriggerAlert(ContextModel context) {
    final result = calculateRiskScore(context);
    return result['alert_triggered'] as bool;
  }

  // ── Get Risk Level Color Name ──
  String getRiskLevelColor(double riskScore) {
    if (riskScore >= AppConstants.riskThresholdDanger) return 'red';
    if (riskScore >= AppConstants.riskThresholdSafe) return 'yellow';
    return 'green';
  }

  // ── Get Human-Readable Status ──
  String getStatusMessage(double riskScore) {
    if (riskScore >= 0.8) return 'CRITICAL DANGER - Immediate help needed!';
    if (riskScore >= 0.6) return 'HIGH RISK - Alert triggered';
    if (riskScore >= 0.4) return 'ELEVATED - Stay cautious';
    if (riskScore >= 0.3) return 'MODERATE - Be aware of surroundings';
    return 'SAFE - No threats detected';
  }
}
