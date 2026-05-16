import 'dart:math';

/// Detection Agent - Monitors for threat indicators
/// In production: accelerometer, microphone, etc.
/// For demo: simulates motion and audio events
class DetectionAgent {
  final Random _random = Random();

  // ── Simulate Motion Event ──
  // In production, this would read from accelerometer/gyroscope
  Map<String, dynamic> simulateMotionEvent({bool isDanger = true}) {
    double motionScore;
    String motionType;

    if (isDanger) {
      // Simulates sudden, erratic movement (running, struggling)
      motionScore = 0.7 + _random.nextDouble() * 0.3; // 0.7 - 1.0
      motionType = 'erratic_movement';
    } else {
      // Normal walking pattern
      motionScore = _random.nextDouble() * 0.3; // 0.0 - 0.3
      motionType = 'normal_walking';
    }

    return {
      'motion_score': double.parse(motionScore.toStringAsFixed(2)),
      'motion_type': motionType,
      'accelerometer_x': _random.nextDouble() * 10,
      'accelerometer_y': _random.nextDouble() * 10,
      'accelerometer_z': _random.nextDouble() * 10,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  // ── Simulate Audio Event ──
  // In production, this would use ML model for scream/distress detection
  Map<String, dynamic> simulateAudioEvent({bool isDanger = true}) {
    double audioScore;
    String audioType;

    if (isDanger) {
      // Simulates scream or distress call detection
      audioScore = 0.75 + _random.nextDouble() * 0.25; // 0.75 - 1.0
      audioType = 'scream_detected';
    } else {
      // Normal ambient sound
      audioScore = _random.nextDouble() * 0.2; // 0.0 - 0.2
      audioType = 'ambient_normal';
    }

    return {
      'audio_score': double.parse(audioScore.toStringAsFixed(2)),
      'audio_type': audioType,
      'decibel_level': isDanger ? 85.0 + _random.nextDouble() * 35 : 40.0 + _random.nextDouble() * 20,
      'frequency_peak': isDanger ? 2000.0 + _random.nextDouble() * 2000 : 200.0 + _random.nextDouble() * 500,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  // ── Process Combined Event ──
  Map<String, dynamic> processEvent({bool simulateDanger = true}) {
    final motionData = simulateMotionEvent(isDanger: simulateDanger);
    final audioData = simulateAudioEvent(isDanger: simulateDanger);

    return {
      'motion': motionData,
      'audio': audioData,
      'combined_threat_indicator': simulateDanger,
      'detection_timestamp': DateTime.now().toIso8601String(),
      'agent': 'DetectionAgent',
      'status': 'event_detected',
    };
  }

  // ── Create Sensor Data for Context ──
  Map<String, dynamic> createSensorPayload({bool simulateDanger = true}) {
    final eventData = processEvent(simulateDanger: simulateDanger);
    return {
      'motion_score': eventData['motion']['motion_score'],
      'audio_score': eventData['audio']['audio_score'],
      'motion_type': eventData['motion']['motion_type'],
      'audio_type': eventData['audio']['audio_type'],
      'decibel_level': eventData['audio']['decibel_level'],
      'raw_event': eventData,
    };
  }
}
