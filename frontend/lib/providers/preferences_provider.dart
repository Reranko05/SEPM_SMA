import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import '../models/user_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesProvider extends ChangeNotifier {
  final ApiService api;
  AuthProvider? _auth;
  bool loading = false;

  PreferencesProvider({required this.api}) {
    loadSmaActive();
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
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<UserPreferences?> getPreferences(String username) async {
    loading = true;
    notifyListeners();
    try {
      final data = await api.getJson('/api/preferences?username=${Uri.encodeComponent(username)}', auth: true);
      if (data is Map<String, dynamic>) {
        return UserPreferences.empty(username)
          ..dietType = data['dietType'] ?? 'OMNIVORE'
          ..calorieLimit = (data['calorieLimit'] ?? 2000) as int
          ..budget = (data['budget'] ?? 15.0).toDouble()
          ..spiceLevel = (data['spiceLevel'] ?? 3) as int
          ..proteinGoalGrams = (data['proteinGoalGrams'] ?? 50) as int
          ..carbsLimitGrams = (data['carbsLimitGrams'] ?? 300) as int;
      }
      return null;
    } catch (e) {
      return null;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
