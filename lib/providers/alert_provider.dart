import 'package:flutter/material.dart';
import '../models/alert_model.dart';
import '../services/firestore_service.dart';

class AlertProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<AlertModel> _alerts = [];
  List<AlertModel> _activeAlerts = [];
  AlertModel? _currentAlert;
  bool _isLoading = false;

  List<AlertModel> get alerts => _alerts;
  List<AlertModel> get activeAlerts => _activeAlerts;
  AlertModel? get currentAlert => _currentAlert;
  bool get isLoading => _isLoading;
  bool get hasActiveAlert => _activeAlerts.isNotEmpty;

  // ── Load Recent Alerts ──
  Future<void> loadRecentAlerts({int limit = 10}) async {
    _isLoading = true;
    notifyListeners();

    _alerts = await _firestoreService.getRecentAlerts(limit: limit);

    _isLoading = false;
    notifyListeners();
  }

  // ── Stream Alerts ──
  void streamAlerts({String? userId}) {
    _firestoreService.streamAlerts(userId: userId).listen((alerts) {
      _alerts = alerts;
      _activeAlerts = alerts.where((a) => a.status == 'active').toList();
      notifyListeners();
    });
  }

  // ── Stream Active Alerts ──
  void streamActiveAlerts() {
    _firestoreService.streamActiveAlerts().listen((alerts) {
      _activeAlerts = alerts;
      notifyListeners();
    });
  }

  // ── Set Current Alert ──
  void setCurrentAlert(AlertModel alert) {
    _currentAlert = alert;
    notifyListeners();
  }

  // ── Resolve Alert ──
  Future<void> resolveAlert(String alertId, String resolvedBy) async {
    await _firestoreService.resolveAlert(alertId, resolvedBy);
    _currentAlert = null;
    notifyListeners();
  }

  // ── Clear ──
  void clear() {
    _alerts = [];
    _activeAlerts = [];
    _currentAlert = null;
    notifyListeners();
  }
}
