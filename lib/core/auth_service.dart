import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';

class AuthService extends ChangeNotifier {
  final SharedPreferences _prefs;
  final DatabaseHelper _dbHelper;
  bool _isAuthenticated = false;
  String? _currentUserEmail;
  String? _currentUserName;

  AuthService(this._prefs, this._dbHelper) {
    _loadAuthState();
  }

  bool get isAuthenticated => _isAuthenticated;
  String? get currentUserEmail => _currentUserEmail;
  String? get currentUserName => _currentUserName;

  void _loadAuthState() {
    _isAuthenticated = _prefs.getBool('is_authenticated') ?? false;
    _currentUserEmail = _prefs.getString('user_email');
    _currentUserName = _prefs.getString('user_name');
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    // Query the SQLite database for matching credentials
    final user = await _dbHelper.getUser(email, password);

    if (user == null) {
      return false; // Invalid credentials
    }

    _isAuthenticated = true;
    _currentUserEmail = email;
    _currentUserName = user['name'] as String?;
    await _prefs.setBool('is_authenticated', true);
    await _prefs.setString('user_email', email);
    if (_currentUserName != null) {
      await _prefs.setString('user_name', _currentUserName!);
    }
    notifyListeners();
    return true;
  }

  Future<bool> signup(String email, String password, String name) async {
    // Check if user already exists in the database
    final existingUser = await _dbHelper.getUserByEmail(email);
    if (existingUser != null) {
      return false; // User already exists
    }

    // Insert new user into the database
    try {
      await _dbHelper.insertUser(name, email, password);
    } catch (e) {
      return false; // Insert failed (e.g. duplicate email)
    }

    // Auto-login after signup
    _isAuthenticated = true;
    _currentUserEmail = email;
    _currentUserName = name;
    await _prefs.setBool('is_authenticated', true);
    await _prefs.setString('user_email', email);
    await _prefs.setString('user_name', name);

    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _currentUserEmail = null;
    _currentUserName = null;
    await _prefs.setBool('is_authenticated', false);
    await _prefs.remove('user_email');
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    if (_currentUserEmail != null) {
      await _dbHelper.deleteUser(_currentUserEmail!);
    }
    await _prefs.remove('user_name');
    await logout();
  }
}
