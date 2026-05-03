import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/preferences_provider.dart';
import '../providers/recommendation_provider.dart';
import '../providers/cart_provider.dart';
import '../services/auth_provider.dart';

class SMADashboard extends StatefulWidget {
  const SMADashboard({super.key});

  @override
  State<SMADashboard> createState() => _SMADashboardState();
}

class _SMADashboardState extends State<SMADashboard> {
  bool _autoFilling = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prefsProv = Provider.of<PreferencesProvider>(context, listen: false);
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.username != null && auth.username!.isNotEmpty) {
        prefsProv.getPreferences(auth.username!);
      }
    });
  }

  String _buildUpcomingMealText(BuildContext context) {
    final now = DateTime.now();
    final prefs = Provider.of<PreferencesProvider>(context);
    final List<Map<String, dynamic>> candidates = [];
    if (prefs.scheduleBreakfast) candidates.add({'name': 'Breakfast', 'time': prefs.breakfastTime});
    if (prefs.scheduleLunch) candidates.add({'name': 'Lunch', 'time': prefs.lunchTime});
    if (prefs.scheduleSnacks) candidates.add({'name': 'Snacks', 'time': prefs.snacksTime});
    if (prefs.scheduleDinner) candidates.add({'name': 'Dinner', 'time': prefs.dinnerTime});

    if (candidates.isEmpty) return 'No meals scheduled';

    DateTime? bestDt;
    String bestName = '';
    for (final c in candidates) {
      final TimeOfDay t = c['time'] as TimeOfDay;
      DateTime dt = DateTime(now.year, now.month, now.day, t.hour, t.minute);
      String when = 'Today';
      if (!dt.isAfter(now)) {
        dt = dt.add(const Duration(days: 1));
        when = 'Tomorrow';
      }
      if (bestDt == null || dt.isBefore(bestDt)) {
        bestDt = dt;
        bestName = c['name'] as String;
      }
    }

    if (bestDt == null) return 'No meals scheduled';
    // find the TimeOfDay to format
    final timeOfDay = TimeOfDay(hour: bestDt.hour, minute: bestDt.minute);
    final whenText = (bestDt.day == now.day) ? 'Today' : 'Tomorrow';
    final formatted = timeOfDay.format(context);
    return '$bestName • $whenText $formatted';
  }

  
  @override
  Widget build(BuildContext context) {
    final pref = Provider.of<PreferencesProvider>(context);
    final rec = Provider.of<RecommendationProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SMA Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [
            // 🔥 SMA TOGGLE CARD
            _sectionCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'SMA Active',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Switch(
                    value: pref.smaActive,
                    onChanged: (v) => pref.setSmaActive(v),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 🔥 UPCOMING MEAL
            _sectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Upcoming Meal',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(_buildUpcomingMealText(context)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 🔥 ACTION BUTTONS (Preferences)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => Navigator.pushNamed(context, '/preferences'),
                    child: const Text('Preferences'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 🔥 TEST AUTO FILL (simulate scheduler)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: (_autoFilling || auth.username == null || auth.username!.isEmpty)
                    ? null
                    : () async {
                        setState(() => _autoFilling = true);
                        try {
                          final prefsProv = Provider.of<PreferencesProvider>(context, listen: false);
                          final cart = Provider.of<CartProvider>(context, listen: false);

                          // ensure we have preferences cached or fetch them explicitly
                          if (prefsProv.preferences == null && auth.username != null) {
                            await prefsProv.getPreferences(auth.username!);
                          }

                          // reuse existing recommendation flow
                          await rec.fetchRecommendation(auth.username!);

                          final meals = rec.meals;
                          if (meals.isEmpty) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No recommendations found')));
                          } else {
                            int added = 0;
                            for (final m in meals) {
                              try {
                                await cart.add(m);
                                added++;
                              } catch (e) {
                                // continue on per-item error
                              }
                            }
                            // ignore: avoid_print
                            print('Test Auto Fill added ${meals.length} meals: ${meals.map((e) => e.name).join(', ')}');
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Auto-filled cart with $added items')));
                          }
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
                        } finally {
                          if (mounted) setState(() => _autoFilling = false);
                        }
                      },
                child: _autoFilling ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Instant Fill'),
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 NUTRITION HEADER
            Text(
              'Nutrition Summary',
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 12),

            // 🔥 NUTRITION CARDS
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Calories',
                    value: (pref.preferences != null) ? '${pref.preferences!.calorieLimit}' : '-',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    title: 'Protein',
                    value: (pref.preferences != null) ? '${pref.preferences!.proteinGoalGrams}g' : '-',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    title: 'Carbs',
                    value: (pref.preferences != null) ? '${pref.preferences!.carbsLimitGrams}g' : '-',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 Reusable section card
  Widget _sectionCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: child,
    );
  }
}

// 🔥 Small stat card
class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}