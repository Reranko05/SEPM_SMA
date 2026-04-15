import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import '../models/meal.dart';

class RecommendationProvider extends ChangeNotifier {
  final ApiService api;
  AuthProvider? _auth;
  bool loading = false;
  List<Meal> meals = [];

  RecommendationProvider({required this.api});

  void updateAuth(AuthProvider auth) {
    _auth = auth;
  }

  Future<void> fetchRecommendation(String username) async {
    loading = true;
    notifyListeners();
    try {
      final data = await api.getJson('/api/recommendation?username=$username', auth: true);
      // backend may return list or single item
      if (data.isEmpty) {
        meals = [];
      } else if (data is Map && data.containsKey('items')) {
        meals = (data['items'] as List).map((e) => Meal.fromJson(e as Map<String, dynamic>)).toList();
      } else if (data is List) {
        meals = (data as List).map((e) => Meal.fromJson(e as Map<String, dynamic>)).toList();
        meals.shuffle(); // present in random order so "Get New Recommendation" can vary
      } else if (data is Map) {
        meals = [Meal.fromJson(Map<String, dynamic>.from(data))];
      } else {
        meals = [];
      }
      // Debug log and immediate notify so UI updates as soon as meals are available
      // ignore: avoid_print
      print('RecommendationProvider: fetched ${meals.length} meals');
      notifyListeners();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> placeOrderForMeal(Meal meal) async {
    loading = true;
    notifyListeners();
    try {
      await api.postJson('/api/order', {'mealId': meal.id}, auth: true);
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
