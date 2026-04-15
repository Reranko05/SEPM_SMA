import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/preferences_provider.dart';
import '../services/auth_provider.dart';
import '../models/user_preferences.dart';
import '../services/notification_service.dart';
import '../providers/recommendation_provider.dart';
import '../providers/cart_provider.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import 'package:android_intent_plus/android_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import '../services/background_service.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});
  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final _calCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  String diet = 'OMNIVORE';
  double spice = 3;
  TimeOfDay breakfast = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay lunch = const TimeOfDay(hour: 13, minute: 0);
  TimeOfDay snacks = const TimeOfDay(hour: 16, minute: 0);
  TimeOfDay dinner = const TimeOfDay(hour: 19, minute: 0);
  bool scheduleBreakfast = false;
  bool scheduleLunch = false;
  bool scheduleSnacks = false;
  bool scheduleDinner = false;

  @override
  void dispose() {
    _calCtrl.dispose();
    _budgetCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.username == null) return;
    final prefsProv = Provider.of<PreferencesProvider>(context, listen: false);
    final saved = await prefsProv.getPreferences(auth.username!);
    if (saved != null && mounted) {
      setState(() {
        diet = saved.dietType;
        _calCtrl.text = saved.calorieLimit.toString();
        _budgetCtrl.text = saved.budget.toString();
        spice = saved.spiceLevel.toDouble();
      });
    }
    // load local schedule settings
    try {
      final sp = await SharedPreferences.getInstance();
      setState(() {
        scheduleBreakfast = sp.getBool('scheduleBreakfast') ?? false;
        scheduleLunch = sp.getBool('scheduleLunch') ?? false;
        scheduleSnacks = sp.getBool('scheduleSnacks') ?? false;
        scheduleDinner = sp.getBool('scheduleDinner') ?? false;
        final b = sp.getString('time_breakfast');
        if (b != null) breakfast = TimeOfDay(hour: int.parse(b.split(':')[0]), minute: int.parse(b.split(':')[1]));
        final l = sp.getString('time_lunch');
        if (l != null) lunch = TimeOfDay(hour: int.parse(l.split(':')[0]), minute: int.parse(l.split(':')[1]));
        final s = sp.getString('time_snacks');
        if (s != null) snacks = TimeOfDay(hour: int.parse(s.split(':')[0]), minute: int.parse(s.split(':')[1]));
        final d = sp.getString('time_dinner');
        if (d != null) dinner = TimeOfDay(hour: int.parse(d.split(':')[0]), minute: int.parse(d.split(':')[1]));
      });
    } catch (_) {}
  }

  void _save() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final prefsProvider = Provider.of<PreferencesProvider>(context, listen: false);
    final notif = NotificationService();
    final recProv = Provider.of<RecommendationProvider>(context, listen: false);
    final cartProv = Provider.of<CartProvider>(context, listen: false);
    if (auth.username == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not logged in')));
      return;
    }
    final prefs = UserPreferences(
      username: auth.username!,
      dietType: diet,
      calorieLimit: int.tryParse(_calCtrl.text) ?? 2000,
      budget: double.tryParse(_budgetCtrl.text) ?? 15.0,
      spiceLevel: spice.toInt(),
    );
    try {
      await prefsProvider.savePreferences(prefs);
      // schedule notifications 1 hour before each enabled meal
      Future<void> trySchedule(bool enabled, TimeOfDay t, int id, String label) async {
        if (!enabled) return;
        final now = DateTime.now();
        var scheduled = DateTime(now.year, now.month, now.day, t.hour, t.minute);
        var notifyAt = scheduled.subtract(const Duration(hours: 1));
        if (notifyAt.isBefore(now)) notifyAt = notifyAt.add(const Duration(days: 1));
        await notif.schedule(
          id,
          'Your meal is ready 🍽️',
          'Tap to view $label recommendation',
          notifyAt,
        );
        // schedule background callback to fetch recommendation and persist it
        try {
          await AndroidAlarmManager.oneShotAt(notifyAt, id, backgroundRecommendationCallback, exact: true, wakeup: true);
        } catch (e) {
          // ignore alarm scheduling errors; UI already scheduled a local notification
          print('Alarm scheduling failed: $e');
        }
      }
      try {
        await trySchedule(scheduleBreakfast, breakfast, 1001, 'Breakfast');
        await trySchedule(scheduleLunch, lunch, 1002, 'Lunch');
        await trySchedule(scheduleSnacks, snacks, 1003, 'Snacks');
        await trySchedule(scheduleDinner, dinner, 1004, 'Dinner');
      } on PlatformException catch (e) {
        // Exact alarms may be blocked on newer Android versions. Prompt user to allow exact alarms.
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Exact Alarms Blocked'),
            content: Text('The system blocked scheduling exact alarms: ${e.message}\n\nPlease enable "Allow exact alarms" for this app in system settings.'),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  if (Platform.isAndroid) {
                    try {
                      final intent = AndroidIntent(action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM');
                      await intent.launch();
                    } catch (_) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open system settings. Please enable exact alarms manually.')));
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enable exact alarms in your device settings.')));
                  }
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to schedule notifications: $e')));
      }
      // persist schedule settings locally so edit form can prefill
      try {
        final sp = await SharedPreferences.getInstance();
        await sp.setBool('scheduleBreakfast', scheduleBreakfast);
        await sp.setBool('scheduleLunch', scheduleLunch);
        await sp.setBool('scheduleSnacks', scheduleSnacks);
        await sp.setBool('scheduleDinner', scheduleDinner);
        await sp.setString('time_breakfast', '${breakfast.hour}:${breakfast.minute}');
        await sp.setString('time_lunch', '${lunch.hour}:${lunch.minute}');
        await sp.setString('time_snacks', '${snacks.hour}:${snacks.minute}');
        await sp.setString('time_dinner', '${dinner.hour}:${dinner.minute}');
      } catch (_) {}
      if (mounted) {
        // Show confirmation dialog instead of navigating to recommendations
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Preferences Saved'),
            content: const Text('Your preferences have been saved and will be used for future recommendations.'),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
            ],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final prefsProvider = Provider.of<PreferencesProvider>(context);
    final enabled = prefsProvider.smaActive;
    return Scaffold(
      appBar: AppBar(title: const Text('Preferences')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(children: [
            if (!enabled)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(children: const [Icon(Icons.info_outline), SizedBox(width: 8), Expanded(child: Text('SMA is turned off — enable SMA from the dashboard to edit preferences'))]),
              ),
            AbsorbPointer(
              absorbing: !enabled,
              child: Opacity(
                opacity: enabled ? 1.0 : 0.5,
                child: Column(children: [
            TextField(controller: TextEditingController(text: auth.username ?? ''), decoration: const InputDecoration(labelText: 'Username'), enabled: false),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(value: diet, items: const [DropdownMenuItem(value: 'OMNIVORE', child: Text('Omnivore')), DropdownMenuItem(value: 'VEGETARIAN', child: Text('Vegetarian')), DropdownMenuItem(value: 'VEGAN', child: Text('Vegan'))], onChanged: (v) => setState(() => diet = v ?? 'OMNIVORE')),
            const SizedBox(height: 8),
            TextField(controller: _calCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Calorie Limit')),
            const SizedBox(height: 8),
            TextField(controller: _budgetCtrl, keyboardType: TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Budget')),
            const SizedBox(height: 8),
            Row(children: [const Text('Spice'), Expanded(child: Slider(value: spice, min: 1, max: 5, divisions: 4, onChanged: (v) => setState(() => spice = v)))]),
            const SizedBox(height: 16),
            const Align(alignment: Alignment.centerLeft, child: Text('Meal Schedule', style: TextStyle(fontWeight: FontWeight.bold))),
            const SizedBox(height: 8),
            _buildScheduleRow('Breakfast', scheduleBreakfast, breakfast, (v) => setState(() => scheduleBreakfast = v), () async { final t = await showTimePicker(context: context, initialTime: breakfast); if (t != null) setState(() => breakfast = t); }),
            _buildScheduleRow('Lunch', scheduleLunch, lunch, (v) => setState(() => scheduleLunch = v), () async { final t = await showTimePicker(context: context, initialTime: lunch); if (t != null) setState(() => lunch = t); }),
            _buildScheduleRow('Snacks', scheduleSnacks, snacks, (v) => setState(() => scheduleSnacks = v), () async { final t = await showTimePicker(context: context, initialTime: snacks); if (t != null) setState(() => snacks = t); }),
            _buildScheduleRow('Dinner', scheduleDinner, dinner, (v) => setState(() => scheduleDinner = v), () async { final t = await showTimePicker(context: context, initialTime: dinner); if (t != null) setState(() => dinner = t); }),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: prefsProvider.loading || !enabled ? null : _save, child: prefsProvider.loading ? const CircularProgressIndicator() : const Text('Save Preferences'))
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildScheduleRow(String label, bool enabled, TimeOfDay time, ValueChanged<bool> onToggle, VoidCallback onPick) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(child: Text(label)),
        Text(time.format(context)),
        IconButton(icon: const Icon(Icons.access_time), onPressed: onPick),
        Switch(value: enabled, onChanged: onToggle),
      ]),
    );
  }
}
