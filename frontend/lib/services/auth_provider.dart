import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService api;
  String? username;
  bool loading = false;

  AuthProvider({required this.api});

Future<void> login(String user, String pass) async {
  loading = true;
  notifyListeners();

  try {
    final res = await api.postJson(
      '/api/auth/login',
      {'username': user, 'password': pass},
    );

    print("API RESPONSE: $res"); // 👈 DEBUG

    if (res == null) {
      throw Exception("Null response from server");
    }

    if (res['token'] == null) {
      throw Exception("Token missing in response");
    }

    final token = res['token'] as String;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt', token);

    await prefs.setString('username', user);
    username = user;

  } catch (e, stack) {
    print("LOGIN ERROR: $e");
    print(stack);

    throw Exception("Login failed: $e"); // 👈 pass to UI

  } finally {
    loading = false;
    notifyListeners();
  }
}
  Future<void> register(String user, String pass) async {
    loading = true;
    notifyListeners();
    try {
      final res = await api.postJson('/api/auth/register', {'username': user, 'password': pass, 'fullName': user});
      final token = res['token'] as String?;
      if (token == null) throw Exception('Missing token');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt', token);
      await prefs.setString('username', user);
      username = user;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt');
    await prefs.remove('username');
    username = null;
    notifyListeners();
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');
    // If a JWT is present, user is logged-in. If not, but a username is persisted
    // (user previously logged in and we can't reach auth server), treat as
    // still logged-in locally so scheduled background behavior and UI remain available.
    if (token != null) return true;
    final user = prefs.getString('username');
    return user != null && user.isNotEmpty;
  }
}

