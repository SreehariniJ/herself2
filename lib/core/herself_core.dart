import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';

class TaskItem {
  final String id;
  final String title;
  TaskItem({required this.id, required this.title});
  Map<String, dynamic> toMap() => {'id': id, 'title': title};
  factory TaskItem.fromMap(Map<String, dynamic> map) =>
      TaskItem(id: map['id'], title: map['title']);
}

class InteractionLog {
  final String mood;
  final int energy;
  final String module;
  InteractionLog({
    required this.mood,
    required this.energy,
    required this.module,
  });
  Map<String, dynamic> toMap() => {
    'mood': mood,
    'energy': energy,
    'module': module,
  };
  factory InteractionLog.fromMap(Map<String, dynamic> map) => InteractionLog(
    mood: map['mood'],
    energy: map['energy'],
    module: map['module'],
  );
}

class EmergencyContact {
  final String id;
  final String name;
  final String phone;
  EmergencyContact({required this.id, required this.name, required this.phone});
  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'phone': phone};
  factory EmergencyContact.fromMap(Map<String, dynamic> map) =>
      EmergencyContact(id: map['id'], name: map['name'], phone: map['phone']);
}

class UserState extends ChangeNotifier {
  String _name;
  String _mood;
  int _energyLevel;
  List<TaskItem> _tasks;
  int _waterCups;
  List<EmergencyContact> _emergencyContacts;
  int _sleepHours;
  int _daysUntilCycle;
  int _meditationMinutes;
  bool _isSharingLocation;
  String _currentCoordinates = "Unknown";
  DateTime _lastOpened;
  List<InteractionLog> _history = [];

  final SharedPreferences _prefs;

  String get name => _name;
  String get mood => _mood;
  int get energyLevel => _energyLevel;
  List<TaskItem> get tasks => _tasks;
  int get waterCups => _waterCups;
  List<EmergencyContact> get emergencyContacts => _emergencyContacts;
  int get sleepHours => _sleepHours;
  int get daysUntilCycle => _daysUntilCycle;
  int get meditationMinutes => _meditationMinutes;
  bool get isSharingLocation => _isSharingLocation;
  String get currentCoordinates => _currentCoordinates;
  String? get geminiApiKey => _prefs.getString('gemini_api_key');

  UserState(this._prefs)
    : _name = _prefs.getString('user_name') ?? 'Sreeharini',
      _mood = _prefs.getString('user_mood') ?? 'happy',
      _energyLevel = _prefs.getInt('user_energy') ?? 7,
      _tasks = (_prefs.getStringList('user_tasks_v2') ?? [])
          .map((t) {
            try {
              return TaskItem.fromMap(jsonDecode(t));
            } catch (_) {
              return null;
            }
          })
          .whereType<TaskItem>()
          .toList(),
      _waterCups = _prefs.getInt('user_water') ?? 0,
      _emergencyContacts = (_prefs.getStringList('user_contacts_v1') ?? [])
          .map((c) => EmergencyContact.fromMap(jsonDecode(c)))
          .toList(),
      _sleepHours = _prefs.getInt('user_sleep') ?? 7,
      _daysUntilCycle = _prefs.getInt('user_cycle') ?? 12,
      _meditationMinutes = _prefs.getInt('user_meditation') ?? 0,
      _isSharingLocation = _prefs.getBool('user_location') ?? true,
      _lastOpened = _parseSafeDate(_prefs.getString('last_opened')) {
    // Add default contacts if list is empty
    if (_emergencyContacts.isEmpty) {
      _emergencyContacts = [
        EmergencyContact(id: '1', name: 'Mom', phone: '1234567890'),
        EmergencyContact(id: '2', name: 'Police', phone: '100'),
      ];
    }

    _history = (_prefs.getStringList('user_learning_v1') ?? [])
        .map((item) => InteractionLog.fromMap(jsonDecode(item)))
        .toList();

    _autoUpdateCycleAndWater();
    if (_isSharingLocation) updateLocation();
  }

  static DateTime _parseSafeDate(String? dateStr) {
    if (dateStr == null) return DateTime.now();
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      return DateTime.now();
    }
  }

  void _autoUpdateCycleAndWater() {
    final now = DateTime.now();
    final lastDate = DateTime(
      _lastOpened.year,
      _lastOpened.month,
      _lastOpened.day,
    );
    final nowDate = DateTime(now.year, now.month, now.day);
    final dayDifference = nowDate.difference(lastDate).inDays;

    if (dayDifference > 0) {
      _waterCups = 0;
      _prefs.setInt('user_water', 0);
      _daysUntilCycle = (_daysUntilCycle - dayDifference).clamp(0, 40);
      _prefs.setInt('user_cycle', _daysUntilCycle);
      _meditationMinutes = 0;
      _prefs.setInt('user_meditation', 0);
    }
    _lastOpened = now;
    _prefs.setString('last_opened', now.toIso8601String());
  }

  // --- LOCATION LOGIC ---
  Future<void> updateLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _currentCoordinates = "Location disabled";
      notifyListeners();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _currentCoordinates = "Permission denied";
        notifyListeners();
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      _currentCoordinates =
          "${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}";
    } catch (e) {
      _currentCoordinates = "Error fetching";
    }
    notifyListeners();
  }

  // --- CONTACTS LOGIC ---
  Future<void> addContact(String name, String phone) async {
    final newContact = EmergencyContact(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      phone: phone.trim(),
    );
    _emergencyContacts.add(newContact);
    notifyListeners();
    _saveContacts();
  }

  Future<void> removeContact(String id) async {
    _emergencyContacts.removeWhere((c) => c.id == id);
    notifyListeners();
    _saveContacts();
  }

  void _saveContacts() async {
    final list = _emergencyContacts.map((c) => jsonEncode(c.toMap())).toList();
    await _prefs.setStringList('user_contacts_v1', list);
  }

  // --- LEARNING LOGIC ---
  void logInteraction(String moduleName) {
    _history.add(
      InteractionLog(mood: _mood, energy: _energyLevel, module: moduleName),
    );
    if (_history.length > 50) _history.removeAt(0);
    final encoded = _history.map((e) => jsonEncode(e.toMap())).toList();
    _prefs.setStringList('user_learning_v1', encoded);
  }

  String getSuggestedModule() {
    Map<String, int> patterns = {};
    for (var log in _history) {
      if (log.mood == _mood) {
        patterns[log.module] = (patterns[log.module] ?? 0) + 1;
      }
    }
    if (patterns.isNotEmpty) {
      var sortedPatterns = patterns.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      return sortedPatterns.first.key;
    }
    if (_mood == 'stressed' || _mood == 'tired') return 'Safe Space';
    if (_energyLevel < 4) return 'Boost';
    if (_tasks.isNotEmpty) return 'Daily Planner';
    return 'Health Care';
  }

  // --- UPDATERS ---
  Future<void> updateName(String newName) async {
    final sanitized = newName.trim();
    if (sanitized.isEmpty) return;
    _name = sanitized;
    notifyListeners();
    await _prefs.setString('user_name', _name);
  }

  Future<void> updateMood(String newMood) async {
    _mood = newMood;
    notifyListeners();
    await _prefs.setString('user_mood', newMood);
    HapticFeedback.selectionClick();
  }

  Future<void> updateEnergy(int level) async {
    _energyLevel = level;
    notifyListeners();
    await _prefs.setInt('user_energy', level);
  }

  Future<void> addTask(String title) async {
    final sanitized = title.trim();
    if (sanitized.isEmpty) return;
    final newTask = TaskItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: sanitized,
    );
    _tasks.add(newTask);
    notifyListeners();
    _saveTasks();
    HapticFeedback.lightImpact();
  }

  Future<void> removeTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
    _saveTasks();
    HapticFeedback.mediumImpact();
  }

  void _saveTasks() async {
    final list = _tasks.map((t) => jsonEncode(t.toMap())).toList();
    await _prefs.setStringList('user_tasks_v2', list);
  }

  Future<void> incrementWater() async {
    if (_waterCups < 15) {
      _waterCups++;
      notifyListeners();
      await _prefs.setInt('user_water', _waterCups);
      HapticFeedback.lightImpact();
    }
  }

  Future<void> resetWater() async {
    _waterCups = 0;
    notifyListeners();
    await _prefs.setInt('user_water', 0);
    HapticFeedback.mediumImpact();
  }

  Future<void> updateSleep(int hours) async {
    _sleepHours = hours;
    notifyListeners();
    await _prefs.setInt('user_sleep', hours);
  }

  Future<void> updateCycleDays(int days) async {
    _daysUntilCycle = days;
    notifyListeners();
    await _prefs.setInt('user_cycle', days);
  }

  Future<void> resetCycle() async {
    _daysUntilCycle = 28;
    notifyListeners();
    await _prefs.setInt('user_cycle', 28);
    HapticFeedback.heavyImpact();
  }

  Future<void> addMeditationMinutes(int mins) async {
    _meditationMinutes += mins;
    notifyListeners();
    await _prefs.setInt('user_meditation', _meditationMinutes);
    HapticFeedback.vibrate();
  }

  Future<void> toggleLocation() async {
    _isSharingLocation = !_isSharingLocation;
    if (_isSharingLocation) updateLocation();
    notifyListeners();
    await _prefs.setBool('user_location', _isSharingLocation);
    HapticFeedback.selectionClick();
  }

  Future<void> updateGeminiApiKey(String key) async {
    await _prefs.setString('gemini_api_key', key.trim());
    notifyListeners();
  }
}
