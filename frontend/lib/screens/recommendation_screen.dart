import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recommendation_provider.dart';
import '../services/auth_provider.dart';
import '../widgets/recommendation_card.dart';
import '../providers/cart_provider.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  State<RecommendationScreen> createState() =>
      _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  @override
  void initState() {
    super.initState();
    final auth =
        Provider.of<AuthProvider>(context, listen: false);

    if (auth.username != null) {
      Provider.of<RecommendationProvider>(context,
              listen: false)
          .fetchRecommendation(auth.username!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final provider =
        Provider.of<RecommendationProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Recommendations')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // 🔥 Loading
            if (provider.loading)
              const Center(child: CircularProgressIndicator()),

            // 🔥 Empty
            if (!provider.loading && provider.meals.isEmpty)
              _emptyState(),

            // 🔥 Recommendations
            if (provider.meals.isNotEmpty)
              ...provider.meals.take(3).toList().asMap().entries.map((entry) {
                final index = entry.key;
                final m = entry.value;
                final isBest = index == 0;

                return Padding(
                  padding:
                      const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // 🔥 BEST BADGE
                      if (isBest)
                        Container(
                          margin:
                              const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius:
                                BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'BEST MATCH',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                      RecommendationCard(meal: m),

                      const SizedBox(height: 8),

                      // 🔥 ADD BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final cart =
                                Provider.of<CartProvider>(
                              context,
                              listen: false,
                            );

                            try {
                              await cart.add(m);
                              if (mounted) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Added ${m.name}')),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Failed: $e')),
                                );
                              }
                            }
                          },
                          child: const Text('Add to Cart'),
                        ),
                      ),
                    ],
                  ),
                );
              }),

            const SizedBox(height: 12),

            // 🔥 REFRESH BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: provider.loading
                    ? null
                    : () async {
                        if (auth.username == null ||
                            auth.username!.isEmpty) {
                          if (mounted) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Please log in')),
                            );
                          }
                          return;
                        }

                        await provider.fetchRecommendation(
                            auth.username!);
                      },
                child: const Text('Get New Recommendation'),
              ),
            ),

            const SizedBox(height: 8),

            // 🔥 ADD BEST CTA
            if (provider.meals.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () async {
                    final best = provider.meals.first;
                    final cart =
                        Provider.of<CartProvider>(context,
                            listen: false);

                    try {
                      await cart.add(best);
                      if (mounted) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          SnackBar(
                              content:
                                  Text('Added ${best.name}')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          SnackBar(
                              content:
                                  Text('Failed: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Add Best to Cart'),
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // 🔥 EMPTY STATE
  Widget _emptyState() {
    return Column(
      children: const [
        SizedBox(height: 40),
        Icon(Icons.restaurant_outlined,
            size: 80, color: Colors.grey),
        SizedBox(height: 10),
        Text(
          'No recommendations available',
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}