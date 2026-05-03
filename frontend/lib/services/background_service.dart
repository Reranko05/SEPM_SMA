import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_service.dart';
import 'api_service.dart';

// Top-level callback required by android_alarm_manager_plus
@pragma('vm:entry-point')
Future<void> backgroundRecommendationCallback(int id) async {
  try {
    // Debug: indicate scheduler run
    // Note: keep this temporary for testing and revert after verification
    // ignore: avoid_print
    print('SCHEDULER TRIGGERED');
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    if (username == null || username.isEmpty) return;

    // Debug: which user is being processed
    // ignore: avoid_print
    print('SCHEDULER: username=$username');

    final api = ApiService();
    // fetch recommendation
    final data = await api.getJson('/api/recommendation?username=$username', auth: true);
    List<Map<String, dynamic>> meals = [];
    if (data == null) {
      meals = [];
    } else if (data is Map && data.containsKey('items')) {
      final items = data['items'] as List;
      meals = items.map((e) => e as Map<String, dynamic>).toList();
    } else if (data is List) {
      meals = (data as List).map((e) => e as Map<String, dynamic>).toList();
    } else if (data is Map) {
      meals = [data as Map<String, dynamic>];
    }

    if (meals.isNotEmpty) {
      // Debug: recommended meal names
      // ignore: avoid_print
      print('SCHEDULER: recommended=${meals.map((m) => m['name']).toList()}');

      // persist full recommendation list for app to pick up
      await prefs.setString('auto_reco', jsonEncode(meals));
      // debug: list of meal names
      // ignore: avoid_print
      print('Scheduler meals: ${meals.map((e) => e["name"]).toList()}');

      // show notification about the recommendation (use first meal name for brevity)
      final notifier = NotificationService();
      await notifier.init();
      await notifier.show(id, 'Your recommended meal is ready 🍽️', meals.first['name'] ?? 'Tap to view');

      // Auto-add all recommended meals to cart from background if user opted in.
      try {
        int added = 0;
        for (final m in meals) {
          try {
            await api.postJson('/api/cart?username=$username', m, auth: true);
            added++;
          } catch (e) {
            // continue on per-item error
          }
        }
        if (added > 0) {
          await prefs.setBool('auto_reco_added', true);
          await notifier.show(id + 1, 'Added to cart', '$added item(s) were added to your cart');
          // ignore: avoid_print
          print('SCHEDULER: added $added items to cart');
        }
      } catch (e) {
        // ignore background POST errors but keep the persisted recommendation
      }
    }
  } catch (e) {
    // ignore errors in background
  }
}
