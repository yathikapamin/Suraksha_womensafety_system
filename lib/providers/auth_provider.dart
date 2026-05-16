import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  User? get firebaseUser => _authService.currentUser;

  // ── Initialize ──
  Future<void> initialize() async {
    final firebaseUser = _authService.currentUser;
    if (firebaseUser != null) {
      _user = await _authService.getUserProfile(firebaseUser.uid);
      notifyListeners();
    }
  }

  // ── Sign Up ──
  Future<bool> signUp({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _user = await _authService.signUpWithEmail(
        name: name,
        phone: phone,
        email: email,
        password: password,
      );
      _setLoading(false);
      return _user != null;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // ── Sign In ──
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _user = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      _setLoading(false);
      return _user != null;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // ── Send OTP ──
  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
  }) async {
    await _authService.sendOtp(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onError: onError,
      onAutoVerify: (credential) async {
        // Auto-verification - link phone
        if (_authService.currentUser != null) {
          await _authService.currentUser!.linkWithCredential(credential);
        }
      },
    );
  }

  // ── Verify OTP ──
  Future<bool> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    return await _authService.verifyOtp(
      verificationId: verificationId,
      smsCode: smsCode,
    );
  }

  // ── Update Role ──
  Future<void> updateRole(String role) async {
    if (_user != null) {
      await _authService.updateUserRole(_user!.id, role);
      _user = _user!.copyWith(role: role);
      notifyListeners();
    }
  }

  // ── Update Profile ──
  Future<void> updateProfile(Map<String, dynamic> data) async {
    if (_user != null) {
      await _authService.updateUserProfile(_user!.id, data);
      _user = await _authService.getUserProfile(_user!.id);
      notifyListeners();
    }
  }

  // ── Sign Out ──
  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  // ── Refresh User ──
  Future<void> refreshUser() async {
    if (_authService.currentUser != null) {
      _user = await _authService.getUserProfile(_authService.currentUser!.uid);
      notifyListeners();
    }
  }

  // ── Helpers ──
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
