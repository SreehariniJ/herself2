import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  final SharedPreferences _prefs;
  bool _isAuthenticated = false;
  String? _currentUserEmail;

  AuthService(this._prefs) {
    _loadAuthState();
  }

  bool get isAuthenticated => _isAuthenticated;
  String? get currentUserEmail => _currentUserEmail;

  void _loadAuthState() {
    _isAuthenticated = _prefs.getBool('is_authenticated') ?? false;
    _currentUserEmail = _prefs.getString('user_email');
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    // For demo purposes, we'll use simple local validation
    // In production, this would connect to a real backend

    final storedEmail = _prefs.getString('registered_email');
    final storedPassword = _prefs.getString('registered_password');

    if (storedEmail == null || storedPassword == null) {
      return false; // No user registered
    }

    if (email == storedEmail && password == storedPassword) {
      _isAuthenticated = true;
      _currentUserEmail = email;
      await _prefs.setBool('is_authenticated', true);
      await _prefs.setString('user_email', email);
      notifyListeners();
      return true;
    }

    return false;
  }

  Future<bool> signup(String email, String password, String name) async {
    // Check if user already exists
    final existingEmail = _prefs.getString('registered_email');
    if (existingEmail != null) {
      return false; // User already exists
    }

    // Store credentials (in production, hash the password!)
    await _prefs.setString('registered_email', email);
    await _prefs.setString('registered_password', password);
    await _prefs.setString('user_name', name);

    // Auto-login after signup
    _isAuthenticated = true;
    _currentUserEmail = email;
    await _prefs.setBool('is_authenticated', true);
    await _prefs.setString('user_email', email);

    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _currentUserEmail = null;
    await _prefs.setBool('is_authenticated', false);
    await _prefs.remove('user_email');
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    await _prefs.remove('registered_email');
    await _prefs.remove('registered_password');
    await _prefs.remove('user_name');
    await logout();
  }
}
