import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/preferences_provider.dart';
import '../providers/recommendation_provider.dart';
import '../services/auth_provider.dart';

class SMADashboard extends StatefulWidget {
  const SMADashboard({super.key});

  @override
  State<SMADashboard> createState() => _SMADashboardState();
}

class _SMADashboardState extends State<SMADashboard> {
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
                children: const [
                  Text(
                    'Upcoming Meal',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text('Dinner • Today 7:00 PM'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 🔥 ACTION BUTTONS
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      if (auth.username == null || auth.username!.isEmpty) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please log in to get suggestions'),
                          ),
                        );
                        return;
                      }

                      try {
                        await rec.fetchRecommendation(auth.username!);

                        if (!mounted) return;
                        Navigator.pushNamed(context, '/recommendation');
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed: $e')),
                        );
                      }
                    },
                    child: const Text('Get Suggestions'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () =>
                        Navigator.pushNamed(context, '/preferences'),
                    child: const Text('Preferences'),
                  ),
                ),
              ],
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
                  child: Builder(builder: (context) {
                    final prefsProv = Provider.of<PreferencesProvider>(context, listen: false);
                    final auth = Provider.of<AuthProvider>(context, listen: false);
                    final future = (auth.username != null) ? prefsProv.getPreferences(auth.username!) : Future.value(null);
                    return FutureBuilder<dynamic>(
                      future: future,
                      builder: (c, snap) {
                        final p = snap.data;
                        final calories = (p != null && p.calorieLimit != null) ? '${p.calorieLimit}' : '-';
                        return _StatCard(title: 'Calories', value: calories);
                      },
                    );
                  }),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Builder(builder: (context) {
                    final prefsProv = Provider.of<PreferencesProvider>(context, listen: false);
                    final auth = Provider.of<AuthProvider>(context, listen: false);
                    final future = (auth.username != null) ? prefsProv.getPreferences(auth.username!) : Future.value(null);
                    return FutureBuilder<dynamic>(
                      future: future,
                      builder: (c, snap) {
                        final p = snap.data;
                        final protein = (p != null && p.proteinGoalGrams != null) ? '${p.proteinGoalGrams}g' : '-';
                        return _StatCard(title: 'Protein', value: protein);
                      },
                    );
                  }),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Builder(builder: (context) {
                    final prefsProv = Provider.of<PreferencesProvider>(context, listen: false);
                    final auth = Provider.of<AuthProvider>(context, listen: false);
                    final future = (auth.username != null) ? prefsProv.getPreferences(auth.username!) : Future.value(null);
                    return FutureBuilder<dynamic>(
                      future: future,
                      builder: (c, snap) {
                        final p = snap.data;
                        final carbs = (p != null && p.carbsLimitGrams != null) ? '${p.carbsLimitGrams}g' : '-';
                        return _StatCard(title: 'Carbs', value: carbs);
                      },
                    );
                  }),
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