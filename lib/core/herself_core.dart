import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:convert';
import 'notification_service.dart';
import 'package:intl/intl.dart';

class TaskItem {
  final String id;
  final String title;
  final DateTime? reminderTime;
  bool reminderTriggered;

  TaskItem({
    required this.id,
    required this.title,
    this.reminderTime,
    this.reminderTriggered = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'reminderTime': reminderTime?.toIso8601String(),
    'reminderTriggered': reminderTriggered,
  };

  factory TaskItem.fromMap(Map<String, dynamic> map) => TaskItem(
    id: map['id'],
    title: map['title'],
    reminderTime: map['reminderTime'] != null
        ? DateTime.tryParse(map['reminderTime'])
        : null,
    reminderTriggered: map['reminderTriggered'] ?? false,
  );
}

class DailyHealthLog {
  final String date;
  final int waterCups;
  final int sleepHours;

  DailyHealthLog({
    required this.date,
    required this.waterCups,
    required this.sleepHours,
  });

  Map<String, dynamic> toMap() => {
    'date': date,
    'waterCups': waterCups,
    'sleepHours': sleepHours,
  };

  factory DailyHealthLog.fromMap(Map<String, dynamic> map) => DailyHealthLog(
    date: map['date'],
    waterCups: map['waterCups'] ?? 0,
    sleepHours: map['sleepHours'] ?? 0,
  );
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
  DateTime? _lastPeriodDate;
  int _cycleLength;
  int _periodDuration;
  bool _isSharingLocation;
  String _currentCoordinates = "Unknown";
  DateTime _lastOpened;
  List<InteractionLog> _history = [];
  int _meditationMinutes = 0;
  List<DailyHealthLog> _healthLogs = [];

  // Behavior Learning Fields
  List<String> _moodHistory = [];
  List<int> _energyHistory = [];
  Map<String, int> _moduleUsageCount = {};
  String _lastUsedModule = "";

  final SharedPreferences _prefs;

  String get name => _name;
  String get mood => _mood;
  int get energyLevel => _energyLevel;
  List<TaskItem> get tasks => _tasks;
  int get waterCups => _waterCups;
  List<EmergencyContact> get emergencyContacts => _emergencyContacts;
  int get sleepHours => _sleepHours;
  int get daysUntilCycle => _daysUntilCycle;
  DateTime? get lastPeriodDate => _lastPeriodDate;
  int get cycleLength => _cycleLength;
  int get periodDuration => _periodDuration;
  bool get isSharingLocation => _isSharingLocation;
  String get currentCoordinates => _currentCoordinates;
  int get meditationMinutes => _meditationMinutes;
  List<DailyHealthLog> get healthLogs => _healthLogs;


  List<String> get moodHistory => _moodHistory;
  List<int> get energyHistory => _energyHistory;
  Map<String, int> get moduleUsageCount => _moduleUsageCount;
  String get lastUsedModule => _lastUsedModule;
  String? get geminiApiKey => _prefs.getString('gemini_api_key');

  final StreamController<TaskItem> _reminderStreamController =
      StreamController.broadcast();
  Stream<TaskItem> get reminderStream => _reminderStreamController.stream;

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
      _lastPeriodDate = _parseSafeDate(_prefs.getString('last_period_date')),
      _cycleLength = _prefs.getInt('cycle_length') ?? 28,
      _periodDuration = _prefs.getInt('period_duration') ?? 5,
      _isSharingLocation = _prefs.getBool('user_location') ?? true,
      _lastOpened = _parseSafeDate(_prefs.getString('last_opened')) {
    _meditationMinutes = _prefs.getInt('user_meditation') ?? 0;
    _healthLogs = (_prefs.getStringList('health_logs_v1') ?? [])
        .map((item) {
          try { return DailyHealthLog.fromMap(jsonDecode(item)); }
          catch (_) { return null; }
        })
        .whereType<DailyHealthLog>()
        .toList();
    // Add default contacts if list is empty
    if (_emergencyContacts.isEmpty) {
      _emergencyContacts = [
        EmergencyContact(id: '1', name: 'Mom', phone: '1234567890'),
        EmergencyContact(id: '2', name: 'Police', phone: '100'),
      ];
    }



    // Load Learning Data
    _moodHistory = _prefs.getStringList('behavior_mood_history') ?? [];
    _energyHistory = (_prefs.getStringList('behavior_energy_history') ?? [])
        .map((e) => int.tryParse(e) ?? 7)
        .toList();
    _lastUsedModule = _prefs.getString('behavior_last_module') ?? "";
    
    final usageStr = _prefs.getString('behavior_module_usage') ?? "{}";
    try {
      _moduleUsageCount = Map<String, int>.from(jsonDecode(usageStr));
    } catch (_) {
      _moduleUsageCount = {};
    }

    _autoUpdateCycleAndWater();
    if (_isSharingLocation) updateLocation();
    _startReminderChecker();
  }

  void _startReminderChecker() {
    Timer.periodic(const Duration(seconds: 30), (timer) {
      final now = DateTime.now();
      for (var task in _tasks) {
        if (task.reminderTime != null && !task.reminderTriggered) {
          if (now.isAfter(task.reminderTime!)) {
            task.reminderTriggered = true;
            _reminderStreamController.add(task);
            _saveTasks();
            notifyListeners();
          }
        }
      }
    });
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
      // Save yesterday's health data before resetting
      final yesterdayStr = DateFormat('yyyy-MM-dd').format(
        nowDate.subtract(const Duration(days: 1)),
      );
      final alreadyLogged = _healthLogs.any((l) => l.date == yesterdayStr);
      if (!alreadyLogged && (_waterCups > 0 || _sleepHours > 0)) {
        _healthLogs.add(DailyHealthLog(
          date: yesterdayStr,
          waterCups: _waterCups,
          sleepHours: _sleepHours,
        ));
        // Keep only last 30 days
        if (_healthLogs.length > 30) {
          _healthLogs = _healthLogs.sublist(_healthLogs.length - 30);
        }
        _saveHealthLogs();
      }

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

  void _saveHealthLogs() async {
    final list = _healthLogs.map((l) => jsonEncode(l.toMap())).toList();
    await _prefs.setStringList('health_logs_v1', list);
  }

  /// Save today's health snapshot (called when user logs water or sleep)
  Future<void> saveTodayHealthLog() async {
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _healthLogs.removeWhere((l) => l.date == todayStr);
    _healthLogs.add(DailyHealthLog(
      date: todayStr,
      waterCups: _waterCups,
      sleepHours: _sleepHours,
    ));
    if (_healthLogs.length > 30) {
      _healthLogs = _healthLogs.sublist(_healthLogs.length - 30);
    }
    _saveHealthLogs();
    notifyListeners();
  }

  /// Get the last N days of health logs (most recent first)
  List<DailyHealthLog> getRecentLogs(int days) {
    final now = DateTime.now();
    final result = <DailyHealthLog>[];
    for (int i = days - 1; i >= 0; i--) {
      final dateStr = DateFormat('yyyy-MM-dd').format(
        now.subtract(Duration(days: i)),
      );
      final log = _healthLogs.where((l) => l.date == dateStr).firstOrNull;
      result.add(log ?? DailyHealthLog(date: dateStr, waterCups: 0, sleepHours: 0));
    }
    return result;
  }

  double getAverageWater({int days = 7}) {
    final logs = getRecentLogs(days).where((l) => l.waterCups > 0).toList();
    if (logs.isEmpty) return 0;
    return logs.map((l) => l.waterCups).reduce((a, b) => a + b) / logs.length;
  }

  double getAverageSleep({int days = 7}) {
    final logs = getRecentLogs(days).where((l) => l.sleepHours > 0).toList();
    if (logs.isEmpty) return 0;
    return logs.map((l) => l.sleepHours).reduce((a, b) => a + b) / logs.length;
  }

  String getHealthInsight() {
    final avgWater = getAverageWater();
    final avgSleep = getAverageSleep();
    final phase = getCyclePhase();

    if (avgSleep > 0 && avgSleep < 6) {
      return '😴 You\'ve been averaging ${avgSleep.toStringAsFixed(1)}h sleep. Try to get 7-8 hours for better energy and recovery.';
    }
    if (avgWater > 0 && avgWater < 4) {
      return '💧 Your hydration has been low (${avgWater.toStringAsFixed(1)} cups/day). Aim for 8 cups to stay energized!';
    }
    if (phase == 'menstrual') {
      return '🌸 You\'re in your menstrual phase. Stay hydrated, rest well, and consider gentle movement like yoga.';
    }
    if (phase == 'ovulatory') {
      return '⚡ You\'re in your ovulatory phase — peak energy! Great time for challenging workouts.';
    }
    if (avgSleep >= 7 && avgWater >= 6) {
      return '🌟 Amazing! Your sleep and hydration are on point. Keep up the great work!';
    }
    if (phase == 'luteal') {
      return '🧘 Luteal phase — you may feel lower energy soon. Prioritize sleep and moderate exercise.';
    }
    return '💪 Keep tracking your health daily! Consistency is key to understanding your body.';
  }

  /// Returns current menstrual cycle phase
  String getCyclePhase() {
    if (_lastPeriodDate == null) return 'unknown';
    final daysSinceStart = DateTime.now().difference(_lastPeriodDate!).inDays;
    final dayInCycle = daysSinceStart % _cycleLength;

    if (dayInCycle < _periodDuration) return 'menstrual';
    if (dayInCycle < (_cycleLength * 0.45).round()) return 'follicular';
    if (dayInCycle < (_cycleLength * 0.6).round()) return 'ovulatory';
    return 'luteal';
  }

  int getDayInCycle() {
    if (_lastPeriodDate == null) return 0;
    final daysSinceStart = DateTime.now().difference(_lastPeriodDate!).inDays;
    return (daysSinceStart % _cycleLength) + 1;
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

    // New Behavior Tracking
    recordModuleUsage(moduleName);
  }

  void recordModuleUsage(String module) {
    _moduleUsageCount[module] = (_moduleUsageCount[module] ?? 0) + 1;
    _lastUsedModule = module;
    notifyListeners();
    
    _prefs.setString('behavior_module_usage', jsonEncode(_moduleUsageCount));
    _prefs.setString('behavior_last_module', _lastUsedModule);
  }

  void recordMood(String mood) {
    _moodHistory.add(mood);
    if (_moodHistory.length > 20) _moodHistory.removeAt(0); // Keep last 20
    notifyListeners();
    _prefs.setStringList('behavior_mood_history', _moodHistory);
  }

  void recordEnergy(int energy) {
    _energyHistory.add(energy);
    if (_energyHistory.length > 20) _energyHistory.removeAt(0); // Keep last 20
    notifyListeners();
    _prefs.setStringList(
      'behavior_energy_history', 
      _energyHistory.map((e) => e.toString()).toList()
    );
  }

  String getSuggestedModule() {
    // 1. Check specific mood-based habit from history (Contextual)
    // "What do I usually do when I feel X?"
    Map<String, int> moodSpecificUsage = {};
    for (var log in _history) {
      if (log.mood == _mood) {
        moodSpecificUsage[log.module] = (moodSpecificUsage[log.module] ?? 0) + 1;
      }
    }
    if (moodSpecificUsage.isNotEmpty) {
       var sorted = moodSpecificUsage.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
       return sorted.first.key;
    }

    // 2. Check overall most used module (Habitual)
    if (_moduleUsageCount.isNotEmpty) {
      var sortedUsage = _moduleUsageCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      // If the top used module has significant usage (> 3 times), suggest it
      if (sortedUsage.first.value > 3) {
        return sortedUsage.first.key;
      }
    }

    // 3. Fallback to Rule-based (Cold Start)
    if (_mood == 'stressed' || _mood == 'tired') return 'HerTalk';
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
    await _prefs.setString('user_mood', newMood);
    recordMood(newMood); // Track history
    HapticFeedback.selectionClick();
  }

  Future<void> updateEnergy(int level) async {
    _energyLevel = level;
    notifyListeners();
    await _prefs.setInt('user_energy', level);
    recordEnergy(level); // Track history
  }

  Future<void> addTask(String title, {DateTime? reminder}) async {
    final sanitized = title.trim();
    if (sanitized.isEmpty) return;
    final idStr = DateTime.now().millisecondsSinceEpoch.toString();
    final newTask = TaskItem(
      id: idStr,
      title: sanitized,
      reminderTime: reminder,
    );
    _tasks.add(newTask);
    notifyListeners();
    _saveTasks();
    HapticFeedback.lightImpact();

    if (reminder != null && reminder.isAfter(DateTime.now())) {
      try {
        await NotificationService().scheduleNotification(
          id: int.parse(
            idStr.substring(idStr.length - 8),
          ), // Integers only for IDs
          title: "Daily Planner Reminder",
          body: title,
          scheduledDate: reminder,
        );
      } catch (e) {
        debugPrint("Failed to schedule notification: $e");
      }
    }
  }

  Future<void> removeTask(String id) async {
    final task = _tasks.firstWhere(
      (t) => t.id == id,
      orElse: () => TaskItem(id: '', title: ''),
    );
    if (task.id.isNotEmpty && task.reminderTime != null) {
      try {
        // Try to cancel notification using the same ID derivation
        final notifId = int.parse(task.id.substring(task.id.length - 8));
        await NotificationService().cancelNotification(notifId);
      } catch (e) {
        debugPrint("Failed to cancel notification: $e");
      }
    }

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
      await saveTodayHealthLog();
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
    await saveTodayHealthLog();
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

  Future<void> updateLastPeriodDate(DateTime date) async {
    _lastPeriodDate = date;
    notifyListeners();
    await _prefs.setString('last_period_date', date.toIso8601String());
  }

  Future<void> updateCycleLength(int length) async {
    _cycleLength = length;
    notifyListeners();
    await _prefs.setInt('cycle_length', length);
  }

  Future<void> updatePeriodDuration(int duration) async {
    _periodDuration = duration;
    notifyListeners();
    await _prefs.setInt('period_duration', duration);
  }

  Future<void> logPeriodStart() async {
    _lastPeriodDate = DateTime.now();
    _daysUntilCycle = _cycleLength;
    notifyListeners();
    await _prefs.setString(
      'last_period_date',
      _lastPeriodDate!.toIso8601String(),
    );
    await _prefs.setInt('user_cycle', _cycleLength);
    HapticFeedback.heavyImpact();
  }

  DateTime? getNextPeriodDate() {
    if (_lastPeriodDate == null) return null;
    return _lastPeriodDate!.add(Duration(days: _cycleLength));
  }

  int getDaysUntilNextPeriod() {
    final nextDate = getNextPeriodDate();
    if (nextDate == null) return 0;
    final diff = nextDate.difference(DateTime.now()).inDays;
    return diff > 0 ? diff : 0;
  }

  bool isOnPeriod() {
    if (_lastPeriodDate == null) return false;
    final daysSinceStart = DateTime.now().difference(_lastPeriodDate!).inDays;
    return daysSinceStart >= 0 && daysSinceStart < _periodDuration;
  }

  int getCurrentPeriodDay() {
    if (!isOnPeriod()) return 0;
    return DateTime.now().difference(_lastPeriodDate!).inDays + 1;
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
