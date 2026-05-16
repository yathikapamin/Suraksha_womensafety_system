import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';

/// Classifies detected audio events
enum AudioEvent {
  normal,
  scream,
  continuousPanic,
}

/// Audio Detection Service
/// Monitors the microphone for loud panic noises (screaming / shouting):
/// - Scream (multiple short bursting spikes > 85dB)
/// - Continuous Panic (sustained noise > 90dB)
class AudioDetectionService extends ChangeNotifier {
  // ── State ──
  bool _isMonitoring = false;
  bool _dangerDetected = false;
  AudioEvent _lastEvent = AudioEvent.normal;
  String _statusText = 'Idle';
  double _currentDecibel = 0.0;

  // ── Subscriptions ──
  StreamSubscription<NoiseReading>? _noiseSub;
  NoiseMeter? _noiseMeter;

  // ── Thresholds ──
  static const double _spikeThreshold = 85.0;        // dB
  static const double _sustainedThreshold = 95.0;    // dB
  static const int _analysisWindowMs = 4000;         // 4 second window
  static const int _requiredSpikes = 3;              // min spikes in window
  static const int _cooldownMs = 30000;              // 30 second cooldown

  // ── Tracking ──
  final List<_DbSample> _recentSamples = [];
  DateTime? _lastTriggerTime;
  Timer? _uiUpdateTimer;

  // ── Callbacks ──
  Function(AudioEvent event, double decibel)? onDangerDetected;

  // ── Getters ──
  bool get isMonitoring => _isMonitoring;
  bool get dangerDetected => _dangerDetected;
  AudioEvent get lastEvent => _lastEvent;
  String get statusText => _statusText;
  double get currentDecibel => _currentDecibel;

  /// Start monitoring microphone
  Future<void> startMonitoring() async {
    if (_isMonitoring) return;

    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      _statusText = 'Mic Permission Denied';
      notifyListeners();
      return;
    }

    _isMonitoring = true;
    _dangerDetected = false;
    _statusText = 'Listening...';
    _noiseMeter ??= NoiseMeter();
    notifyListeners();

    try {
      _noiseSub = _noiseMeter?.noise.listen(
        _onData,
        onError: _onError,
      );
      
      // Separate timer for UI to prevent extreme rebuild rate
      _uiUpdateTimer = Timer.periodic(const Duration(milliseconds: 250), (_) {
        notifyListeners();
      });
    } catch (err) {
      _onError(err);
    }
  }

  /// Stop monitoring
  void stopMonitoring() {
    _isMonitoring = false;
    _dangerDetected = false;
    _statusText = 'Idle';
    _currentDecibel = 0.0;
    
    _noiseSub?.cancel();
    _noiseSub = null;
    _uiUpdateTimer?.cancel();
    _recentSamples.clear();
    
    notifyListeners();
  }

  /// Process incoming decibel payload
  void _onData(NoiseReading noiseReading) {
    if (!_isMonitoring) return;

    final now = DateTime.now();
    _currentDecibel = noiseReading.meanDecibel;

    // Save sample and cleanup old ones
    _recentSamples.add(_DbSample(db: _currentDecibel, time: now));
    _recentSamples.removeWhere(
      (s) => now.difference(s.time).inMilliseconds > _analysisWindowMs,
    );

    _analyzeSamples(now);
  }

  void _analyzeSamples(DateTime now) {
    if (_recentSamples.isEmpty) return;

    // ── Check 1: Continuous Panic (Sustained extreme volume) ──
    final lastSecSamples = _recentSamples.where(
      (s) => now.difference(s.time).inMilliseconds < 1500, // 1.5 seconds
    ).toList();
    
    if (lastSecSamples.length > 5) {
      final sustainedCount = lastSecSamples.where((s) => s.db > _sustainedThreshold).length;
      if (sustainedCount / lastSecSamples.length > 0.8) {
        _triggerEvent(AudioEvent.continuousPanic, now);
        return;
      }
    }

    // ── Check 2: Scream (Multiple loud spikes) ──
    // Count distinct spikes (allow 500ms between spikes to avoid double-counting the same scream)
    int spikeCount = 0;
    DateTime? lastSpikeTime;

    for (var sample in _recentSamples) {
      if (sample.db > _spikeThreshold) {
        if (lastSpikeTime == null || sample.time.difference(lastSpikeTime).inMilliseconds > 500) {
          spikeCount++;
          lastSpikeTime = sample.time;
        }
      }
    }

    if (spikeCount >= _requiredSpikes) {
      _triggerEvent(AudioEvent.scream, now);
    }
  }

  void _onError(Object error) {
    stopMonitoring();
    _statusText = 'Audio Error';
    notifyListeners();
  }

  /// Trigger danger logic
  void _triggerEvent(AudioEvent event, DateTime now) {
    if (_lastTriggerTime != null && now.difference(_lastTriggerTime!).inMilliseconds < _cooldownMs) {
      return;
    }

    _lastTriggerTime = now;
    _dangerDetected = true;
    _lastEvent = event;
    _statusText = _eventLabel(event);
    notifyListeners();

    onDangerDetected?.call(event, _currentDecibel);
  }

  /// Reset state after user cancels alert
  void resetDanger() {
    _dangerDetected = false;
    _lastEvent = AudioEvent.normal;
    _statusText = _isMonitoring ? 'Listening...' : 'Idle';
    _recentSamples.clear();
    notifyListeners();
  }

  String _eventLabel(AudioEvent event) {
    switch (event) {
      case AudioEvent.scream:
        return '😱 Scream Detected';
      case AudioEvent.continuousPanic:
        return '⚠️ Loud Panic Detected';
      case AudioEvent.normal:
        return 'Listening...';
    }
  }

  String eventDescription(AudioEvent event) {
    switch (event) {
      case AudioEvent.scream:
        return 'Microphone detected multiple sudden high-volume spikes. This pattern is consistent with a person screaming for help.';
      case AudioEvent.continuousPanic:
        return 'Microphone detected sustained maximum volume noise. This is triggered during continuous panic or struggle sounds.';
      case AudioEvent.normal:
        return 'No abnormal audio detected.';
    }
  }

  @override
  void dispose() {
    stopMonitoring();
    super.dispose();
  }
}

class _DbSample {
  final double db;
  final DateTime time;

  _DbSample({required this.db, required this.time});
}
