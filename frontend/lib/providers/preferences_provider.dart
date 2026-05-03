import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import '../models/user_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesProvider extends ChangeNotifier {
  final ApiService api;
  AuthProvider? _auth;
  bool loading = false;
  UserPreferences? _prefs;
  // schedule fields (loaded from SharedPreferences)
  bool scheduleBreakfast = false;
  bool scheduleLunch = false;
  bool scheduleSnacks = false;
  bool scheduleDinner = false;
  TimeOfDay breakfastTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay lunchTime = const TimeOfDay(hour: 13, minute: 0);
  TimeOfDay snacksTime = const TimeOfDay(hour: 16, minute: 0);
  TimeOfDay dinnerTime = const TimeOfDay(hour: 19, minute: 0);

  PreferencesProvider({required this.api}) {
    loadSmaActive();
    loadSchedule();
  }

  // load persisted SMA active flag
  void loadSmaActive() async {
    try {
      final sp = await SharedPreferences.getInstance();
      _smaActive = sp.getBool('sma_active') ?? false;
      notifyListeners();
    } catch (_) {}
  }

  // expose setter that persists the flag
  Future<void> setSmaActive(bool v) async {
    _smaActive = v;
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setBool('sma_active', v);
    } catch (_) {}
    notifyListeners();
  }

  bool get smaActive => _smaActive;
  bool _smaActive = false;

  void updateAuth(AuthProvider auth) {
    _auth = auth;
  }

  Future<void> savePreferences(UserPreferences prefs) async {
    loading = true;
    notifyListeners();
    try {
      await api.postJson('/api/preferences', prefs.toJson(), auth: true);
      _prefs = prefs;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<UserPreferences?> getPreferences(String username) async {
    if (loading) return null;
    loading = true;
    try {
      final data = await api.getJson('/api/preferences?username=${Uri.encodeComponent(username)}', auth: true);
      if (data is Map<String, dynamic>) {
        final p = UserPreferences.empty(username)
          ..dietType = data['dietType'] ?? 'OMNIVORE'
          ..calorieLimit = (data['calorieLimit'] ?? 2000) as int
          ..budget = (data['budget'] ?? 500.0).toDouble()
          ..spiceLevel = (data['spiceLevel'] ?? 3) as int
          ..proteinGoalGrams = (data['proteinGoalGrams'] ?? 50) as int
          ..carbsLimitGrams = (data['carbsLimitGrams'] ?? 300) as int;
        _prefs = p;
        // refresh local schedule values when preferences are fetched
        await loadSchedule();
        return p;
      }
      return null;
    } catch (e) {
      return null;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  UserPreferences? get preferences => _prefs;

  void clearPreferences() {
    _prefs = null;
    notifyListeners();
  }

  Future<void> loadSchedule() async {
    try {
      final sp = await SharedPreferences.getInstance();
      scheduleBreakfast = sp.getBool('scheduleBreakfast') ?? false;
      scheduleLunch = sp.getBool('scheduleLunch') ?? false;
      scheduleSnacks = sp.getBool('scheduleSnacks') ?? false;
      scheduleDinner = sp.getBool('scheduleDinner') ?? false;
      final b = sp.getString('time_breakfast');
      if (b != null) {
        final parts = b.split(':');
        breakfastTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
      final l = sp.getString('time_lunch');
      if (l != null) {
        final parts = l.split(':');
        lunchTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
      final s = sp.getString('time_snacks');
      if (s != null) {
        final parts = s.split(':');
        snacksTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
      final d = sp.getString('time_dinner');
      if (d != null) {
        final parts = d.split(':');
        dinnerTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
      notifyListeners();
    } catch (_) {}
  }
}
