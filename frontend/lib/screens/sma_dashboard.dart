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
      appBar: AppBar(title: const Text('SMA Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                title: const Text('SMA Active'),
                trailing: Switch(
                  value: pref.smaActive,
                  onChanged: (v) => pref.setSmaActive(v),
                ),
              ),
            ),
            const SizedBox(height: 12),

            const Card(
              child: ListTile(
                title: Text('Upcoming: Dinner'),
                subtitle: Text('Today • 19:00'),
              ),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    if (auth.username == null || auth.username!.isEmpty) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please log in to get suggestions')),
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
                        SnackBar(content: Text('Failed to fetch suggestions: $e')),
                      );
                    }
                  },
                  child: const Text('Get Suggestions Now'),
                ),

                OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, '/preferences'),
                  child: const Text('Set Preferences'),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              'Nutrition Summary',
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 8),

            const Wrap(
              spacing: 12,
              children: [
                Text('Calories: 0'),
                Text('Protein: 0g'),
                Text('Carbs: 0g'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}