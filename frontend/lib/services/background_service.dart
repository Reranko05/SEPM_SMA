import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_service.dart';
import 'api_service.dart';

// Top-level callback required by android_alarm_manager_plus
@pragma('vm:entry-point')
Future<void> backgroundRecommendationCallback(int id) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    if (username == null || username.isEmpty) return;

    final api = ApiService(baseUrl: 'http://192.168.29.196:8080');
    // fetch recommendation
    final data = await api.getJson('/api/recommendation?username=$username', auth: true);
    Map<String, dynamic>? mealJson;
    if (data.isEmpty) {
      mealJson = null;
    } else if (data is Map && data.containsKey('items')) {
      final items = data['items'] as List;
      if (items.isNotEmpty) mealJson = items.first as Map<String, dynamic>;
    } else if (data is List && data.isNotEmpty) {
      mealJson = (data as List).first as Map<String, dynamic>;
    } else if (data is Map) {
      mealJson = data as Map<String, dynamic>;
    }

    if (mealJson != null) {
      // persist recommendation for app to pick up
      await prefs.setString('auto_reco', jsonEncode(mealJson));
      // show notification
      final notifier = NotificationService();
      await notifier.init();
      await notifier.show(id, 'Your recommended meal is ready 🍽️', mealJson['name'] ?? 'Tap to view');

      // Auto-add to cart from background if user opted in. This posts the meal
      // to the backend cart endpoint and sets a local flag so the UI can react.
      try {
        await api.postJson('/api/cart?username=$username', mealJson, auth: true);
        await prefs.setBool('auto_reco_added', true);
        await notifier.show(id + 1, 'Added to cart', '${mealJson['name']} was added to your cart');
      } catch (e) {
        // ignore background POST errors but keep the persisted recommendation
      }
    }
  } catch (e) {
    // ignore errors in background
  }
}
