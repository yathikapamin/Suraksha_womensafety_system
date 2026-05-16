import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Classifies detected motion events
enum MotionEvent {
  normal,
  phoneDrop,
  violentMotion,
  panicRunning,
}

/// Motion Detection Service
/// Monitors accelerometer for abnormal patterns:
/// - Phone drop (free-fall → impact)
/// - Violent motion / struggle
/// - Panic running
class MotionDetectionService extends ChangeNotifier {
  // ── State ──
  bool _isMonitoring = false;
  bool _dangerDetected = false;
  MotionEvent _lastEvent = MotionEvent.normal;
  String _statusText = 'Idle';
  double _currentMagnitude = 0.0;

  // ── Subscriptions ──
  StreamSubscription<AccelerometerEvent>? _accelSub;

  // ── Thresholds ──
  static const double _freeFallThreshold = 2.0;     // m/s² (near zero = free fall)
  static const double _impactThreshold = 25.0;       // m/s² (high spike = impact)
  static const double _violentThreshold = 18.0;      // m/s² per axis change
  static const double _panicRunThreshold = 15.0;     // sustained high acceleration
  static const int _violentWindowMs = 2000;          // 2 second window
  static const int _violentMinSpikes = 4;            // min spikes in window
  static const int _cooldownMs = 30000;              // 30 second cooldown

  // ── Tracking ──
  bool _inFreeFall = false;
  DateTime? _freeFallStart;
  final List<_AccelSample> _recentSamples = [];
  DateTime? _lastTriggerTime;

  // ── Callbacks ──
  Function(MotionEvent event)? onDangerDetected;

  // ── Getters ──
  bool get isMonitoring => _isMonitoring;
  bool get dangerDetected => _dangerDetected;
  MotionEvent get lastEvent => _lastEvent;
  String get statusText => _statusText;
  double get currentMagnitude => _currentMagnitude;

  /// Start monitoring device sensors
  void startMonitoring() {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _dangerDetected = false;
    _statusText = 'Monitoring...';
    notifyListeners();

    _accelSub = accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 50), // 20 Hz
    ).listen(_processAccelData);
  }

  /// Stop monitoring
  void stopMonitoring() {
    _isMonitoring = false;
    _dangerDetected = false;
    _statusText = 'Idle';
    _accelSub?.cancel();
    _accelSub = null;
    _recentSamples.clear();
    notifyListeners();
  }

  /// Process each accelerometer reading
  void _processAccelData(AccelerometerEvent event) {
    final now = DateTime.now();
    final magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
    _currentMagnitude = magnitude;

    // Add to recent samples (keep last 3 seconds)
    _recentSamples.add(_AccelSample(
      x: event.x,
      y: event.y,
      z: event.z,
      magnitude: magnitude,
      time: now,
    ));
    _recentSamples.removeWhere(
      (s) => now.difference(s.time).inMilliseconds > 3000,
    );

    // ── Check 1: Phone Drop (free-fall → impact) ──
    if (magnitude < _freeFallThreshold && !_inFreeFall) {
      _inFreeFall = true;
      _freeFallStart = now;
    } else if (_inFreeFall && magnitude > _impactThreshold) {
      // Impact after free fall
      final fallDuration = now.difference(_freeFallStart!).inMilliseconds;
      if (fallDuration < 1000) {
        // Free fall < 1 second followed by impact = phone drop
        _triggerEvent(MotionEvent.phoneDrop, now);
      }
      _inFreeFall = false;
    } else if (_inFreeFall && magnitude > _freeFallThreshold + 3) {
      // No longer in free fall
      _inFreeFall = false;
    }

    // ── Check 2: Violent Motion / Struggle ──
    final windowSamples = _recentSamples.where(
      (s) => now.difference(s.time).inMilliseconds <= _violentWindowMs,
    ).toList();

    if (windowSamples.length > 5) {
      int spikeCount = 0;
      for (int i = 1; i < windowSamples.length; i++) {
        final dx = (windowSamples[i].x - windowSamples[i - 1].x).abs();
        final dy = (windowSamples[i].y - windowSamples[i - 1].y).abs();
        final dz = (windowSamples[i].z - windowSamples[i - 1].z).abs();
        if (dx > _violentThreshold || dy > _violentThreshold || dz > _violentThreshold) {
          spikeCount++;
        }
      }

      if (spikeCount >= _violentMinSpikes) {
        _triggerEvent(MotionEvent.violentMotion, now);
      }
    }

    // ── Check 3: Panic Running ──
    if (windowSamples.length > 10) {
      final highAccelCount = windowSamples
          .where((s) => s.magnitude > _panicRunThreshold)
          .length;
      final ratio = highAccelCount / windowSamples.length;
      if (ratio > 0.6) {
        // 60%+ readings are high = sustained running/panic
        _triggerEvent(MotionEvent.panicRunning, now);
      }
    }

    // periodic UI update (reduce rebuilds)
    if (now.millisecond % 200 < 60) {
      notifyListeners();
    }
  }

  /// Trigger a danger event
  void _triggerEvent(MotionEvent event, DateTime now) {
    // Cooldown check
    if (_lastTriggerTime != null &&
        now.difference(_lastTriggerTime!).inMilliseconds < _cooldownMs) {
      return;
    }

    _lastTriggerTime = now;
    _dangerDetected = true;
    _lastEvent = event;
    _statusText = _eventLabel(event);
    notifyListeners();

    // Notify callback
    onDangerDetected?.call(event);
  }

  /// Reset after user dismisses alert
  void resetDanger() {
    _dangerDetected = false;
    _lastEvent = MotionEvent.normal;
    _statusText = _isMonitoring ? 'Monitoring...' : 'Idle';
    _recentSamples.clear();
    notifyListeners();
  }

  String _eventLabel(MotionEvent event) {
    switch (event) {
      case MotionEvent.phoneDrop:
        return '📱 Phone Drop Detected';
      case MotionEvent.violentMotion:
        return '⚠️ Violent Motion Detected';
      case MotionEvent.panicRunning:
        return '🏃 Panic Running Detected';
      case MotionEvent.normal:
        return 'Monitoring...';
    }
  }

  String eventDescription(MotionEvent event) {
    switch (event) {
      case MotionEvent.phoneDrop:
        return 'Your phone experienced a free-fall followed by a sudden impact. This may indicate the phone was knocked or dropped during an incident.';
      case MotionEvent.violentMotion:
        return 'Rapid, violent motion changes detected on multiple axes. This pattern is consistent with a physical struggle.';
      case MotionEvent.panicRunning:
        return 'Sustained high-acceleration movement detected. This pattern indicates running or panic movement.';
      case MotionEvent.normal:
        return 'No abnormal motion detected.';
    }
  }

  @override
  void dispose() {
    stopMonitoring();
    super.dispose();
  }
}

class _AccelSample {
  final double x, y, z, magnitude;
  final DateTime time;

  _AccelSample({
    required this.x,
    required this.y,
    required this.z,
    required this.magnitude,
    required this.time,
  });
}
