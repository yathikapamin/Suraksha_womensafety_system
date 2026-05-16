import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';
import 'speech_ml_classifier.dart';

enum VoiceEvent {
  normal,
  distressKeyword,
}

class _PhraseHistory {
  final String phrase;
  final int time;
  _PhraseHistory(this.phrase, this.time);
}

class VoiceDetectionService extends ChangeNotifier {
  final SpeechToText _speechToText = SpeechToText();
  
  bool _isMonitoring = false;
  bool _dangerDetected = false;
  bool _speechEnabled = false;
  
  VoiceEvent _lastEvent = VoiceEvent.normal;
  String _statusText = 'Idle';
  String _lastRecognizedWords = '';

  // Distress dictionary & Logic Structures
  final List<String> _distressKeywords = [
    "help me", "please help me", "save me", "someone help me",
    "i am in danger", "stop please", "leave me alone", "leave me", "stop it",
    "rescue me", "i need a rescue", "emergency sos", "being attacked",
    "sahaya madi", "nanna kapadi", "nanna bidu", "dayavittu sahaya madi",
    "bachao"
  ];
  
  final List<String> _safeContextWords = ["with", "to", "for", "in", "on"];
  final List<String> _negativeKeywords = ["work", "homework", "project", "assignment", "task", "job", "code", "study"];
  final List<String> _safeRequestPhrases = ["can you help me", "could you help me", "will you help me", "help me fix this"];
  
  List<_PhraseHistory> _phraseHistory = [];
  final int _historyWindowMs = 15000;
  late final MLClassifier _mlEngine;

  VoiceDetectionService() {
    _mlEngine = MLClassifier();
    _mlEngine.train([
      {'text': "I am in danger", 'intent': "DISTRESS"},
      {'text': "please save me", 'intent': "DISTRESS"},
      {'text': "he is following me", 'intent': "DISTRESS"},
      {'text': "someone is following me", 'intent': "DISTRESS"},
      {'text': "he is hurting me", 'intent': "DISTRESS"},
      {'text': "help me I'm kidnapped", 'intent': "DISTRESS"},
      {'text': "somebody is trying to kill me", 'intent': "DISTRESS"},
      {'text': "stop hurting me", 'intent': "DISTRESS"},
      {'text': "leave me alone immediately", 'intent': "DISTRESS"},
      {'text': "they are attacking", 'intent': "DISTRESS"},
      
      {'text': "can you help me with this", 'intent': "REQUEST"},
      {'text': "could you help me", 'intent': "REQUEST"},
      {'text': "will you help me", 'intent': "REQUEST"},
      {'text': "help me with my homework", 'intent': "REQUEST"},
      {'text': "help me with my work", 'intent': "REQUEST"},
      {'text': "help me complete this", 'intent': "REQUEST"},
      {'text': "I need help with this code", 'intent': "REQUEST"},
      {'text': "I need help with my project", 'intent': "REQUEST"},
      {'text': "can someone help me understand this", 'intent': "REQUEST"},
      {'text': "help me fix this", 'intent': "REQUEST"},
      {'text': "save this file for me please", 'intent': "REQUEST"},

      {'text': "the weather is nice today", 'intent': "NEUTRAL"},
      {'text': "i am walking to the store", 'intent': "NEUTRAL"},
      {'text': "hello how are you doing", 'intent': "NEUTRAL"},
      {'text': "what is the time now", 'intent': "NEUTRAL"},
      {'text': "let's get lunch later", 'intent': "NEUTRAL"},
    ]);
  }

  static const int _cooldownMs = 30000;
  DateTime? _lastTriggerTime;

  Function(VoiceEvent event, String keyword)? onDangerDetected;

  bool get isMonitoring => _isMonitoring;
  bool get dangerDetected => _dangerDetected;
  VoiceEvent get lastEvent => _lastEvent;
  String get statusText => _statusText;
  String get lastRecognizedWords => _lastRecognizedWords;

  Future<void> initSpeech() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      _statusText = 'Mic Permission Denied';
      notifyListeners();
      return;
    }

    _speechEnabled = await _speechToText.initialize(
      onStatus: _onSpeechStatus,
      onError: (val) => _startListeningLoop(), // Auto-restart on error (e.g. silent timeout)
    );
  }

  Future<void> startMonitoring() async {
    if (_isMonitoring) return;
    
    if (!_speechEnabled) {
      await initSpeech();
    }
    
    if (!_speechEnabled) {
      _statusText = 'Speech not supported';
      notifyListeners();
      return;
    }

    _isMonitoring = true;
    _dangerDetected = false;
    _statusText = 'Listening for keywords...';
    notifyListeners();

    _startListeningLoop();
  }

  void _startListeningLoop() async {
    if (!_isMonitoring || _dangerDetected) return;

    if (!_speechToText.isListening) {
      try {
        await _speechToText.listen(
          onResult: _onSpeechResult,
          partialResults: true,
          cancelOnError: false, // Don't cancel immediately
          listenMode: ListenMode.dictation,
        );
      } catch (e) {
        // If it fails to restart immediately, try again in a second
        Future.delayed(const Duration(seconds: 1), _startListeningLoop);
      }
    }
  }

  void _onSpeechStatus(String status) {
    if (!_isMonitoring) return;
    
    // Auto-restart STT when Android/iOS force closes it due to silence
    if (status == 'done' || status == 'notListening') {
      Future.delayed(const Duration(milliseconds: 500), _startListeningLoop);
    }
  }

  void stopMonitoring() {
    _isMonitoring = false;
    _dangerDetected = false;
    _statusText = 'Idle';
    _lastRecognizedWords = '';
    _speechToText.stop();
    notifyListeners();
  }

  void _analyzeSpeech(String text) {
    if (!_isMonitoring) return;
    
    String cleanText = text.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), ' ').trim();
    if (cleanText.isEmpty) return;
    List<String> words = cleanText.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();

    bool isSafeContext = false;

    for (var p in _safeRequestPhrases) {
      if (cleanText.contains(p)) isSafeContext = true;
    }

    for (var kw in _negativeKeywords) {
      if (words.contains(kw)) isSafeContext = true;
    }

    for (int i = 0; i < words.length - 2; i++) {
      if (words[i] == "help" && words[i + 1] == "me") {
        if (_safeContextWords.contains(words[i + 2])) {
          isSafeContext = true;
        }
      }
    }

    bool ruleTrigger = false;
    bool foundStrongPhrase = false;

    if (!isSafeContext) {
      for (var phrase in _distressKeywords) {
        if (cleanText.contains(phrase)) {
          foundStrongPhrase = true;
          int now = DateTime.now().millisecondsSinceEpoch;
          bool recent = _phraseHistory.any((h) => h.phrase == phrase && (now - h.time) < 2000);
          if (!recent) _phraseHistory.add(_PhraseHistory(phrase, now));
        }
      }

      final singleDistressWords = ["help", "save", "stop", "danger", "kapadi", "sahaya", "rescue", "bachao"];
      if (words.length <= 4) {
        for (var word in singleDistressWords) {
          if (words.contains(word)) {
            foundStrongPhrase = true;
            int now = DateTime.now().millisecondsSinceEpoch;
            bool recent = _phraseHistory.any((h) => h.phrase == word && (now - h.time) < 2000);
            if (!recent) _phraseHistory.add(_PhraseHistory(word, now));
          }
        }
      }
    }

    int currentTime = DateTime.now().millisecondsSinceEpoch;
    _phraseHistory.removeWhere((h) => (currentTime - h.time) > _historyWindowMs);

    if (_phraseHistory.length >= 2) {
      ruleTrigger = true;
    }

    var mlResult = _mlEngine.predict(cleanText);
    String intent = mlResult['intent'];
    double confidence = mlResult['confidence'];

    if (isSafeContext && intent == "DISTRESS") {
      intent = "REQUEST";
      confidence *= 0.2;
    }

    if (foundStrongPhrase && !isSafeContext) {
      intent = "DISTRESS";
      confidence = [confidence, 0.85].reduce(max);
    }

    bool triggerAlert = false;
    if (ruleTrigger || (intent == "DISTRESS" && confidence >= 0.85)) {
      triggerAlert = true;
    }

    if (triggerAlert) {
      _triggerEvent(text);
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (!_isMonitoring) return;

    _lastRecognizedWords = result.recognizedWords.toLowerCase();
    
    // Broadcast partial results to UI immediately
    notifyListeners();
    
    _analyzeSpeech(_lastRecognizedWords);
  }

  void _triggerEvent(String triggeredKeyword) {
    final now = DateTime.now();
    if (_lastTriggerTime != null && now.difference(_lastTriggerTime!).inMilliseconds < _cooldownMs) {
      return; // Prevent spamming
    }

    _lastTriggerTime = now;
    _dangerDetected = true;
    _lastEvent = VoiceEvent.distressKeyword;
    _statusText = '⚠️ "$triggeredKeyword" heard!';
    
    // Don't stop STT - let the SOS screen show the continuing transcript
    notifyListeners();

    onDangerDetected?.call(_lastEvent, triggeredKeyword);
  }

  void resetDanger() {
    _dangerDetected = false;
    _lastEvent = VoiceEvent.normal;
    _statusText = _isMonitoring ? 'Listening for keywords...' : 'Idle';
    _lastRecognizedWords = '';
    notifyListeners();
    
    if (_isMonitoring) {
      _startListeningLoop();
    }
  }

  @override
  void dispose() {
    if (_isMonitoring) {
      stopMonitoring();
    }
    super.dispose();
  }
}
