import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tzdata.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(const InitializationSettings(android: android, iOS: ios));
    // On Android 13+ request POST_NOTIFICATIONS permission if available
    try {
      final androidImpl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidImpl?.requestNotificationsPermission();
    } catch (_) {}
  }

  Future<void> show(int id, String title, String body) async {
    const android = AndroidNotificationDetails('sma_channel', 'SMA', importance: Importance.max);
    const ios = DarwinNotificationDetails();
    await _plugin.show(id, title, body, const NotificationDetails(android: android, iOS: ios));
  }

  Future<void> schedule(int id, String title, String body, DateTime at) async {
    final when = tz.TZDateTime.from(at, tz.local);
    await _plugin.zonedSchedule(id, title, body, when, const NotificationDetails(android: AndroidNotificationDetails('sma_channel', 'SMA')), androidAllowWhileIdle: true, uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime);
  }
}
 
