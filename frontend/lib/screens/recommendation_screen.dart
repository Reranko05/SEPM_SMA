import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recommendation_provider.dart';
import '../services/auth_provider.dart';
import '../widgets/recommendation_card.dart';
import '../providers/cart_provider.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});
  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.username != null) {
      Provider.of<RecommendationProvider>(context, listen: false).fetchRecommendation(auth.username!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final provider = Provider.of<RecommendationProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Recommendations')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          if (provider.loading) const CircularProgressIndicator(),
          if (!provider.loading && provider.meals.isEmpty) const Text('No recommendation available.'),
          if (provider.meals.isNotEmpty)
            ...provider.meals.take(3).map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(children: [
                    RecommendationCard(meal: m),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final cart = Provider.of<CartProvider>(context, listen: false);
                            try {
                              await cart.add(m);
                              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added ${m.name} to cart')));
                            } catch (e) {
                              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add ${m.name}: $e')));
                            }
                          },
                          child: const Text('Add to Cart'),
                        ),
                      )
                    ])
                  ]),
                )).toList(),
          const SizedBox(height: 12),
            Row(children: [
            Expanded(
                child: ElevatedButton(
                    onPressed: provider.loading
                        ? null
                        : () async {
                            if (auth.username == null || auth.username!.isEmpty) {
                              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in to get recommendations')));
                              return;
                            }
                            await provider.fetchRecommendation(auth.username!);
                          },
                    child: const Text('Get New Recommendation'))),
          ]),
          const SizedBox(height: 8),
          if (provider.meals.isNotEmpty)
            ElevatedButton(
              onPressed: () async {
                final best = provider.meals.first;
                final cart = Provider.of<CartProvider>(context, listen: false);
                try {
                  await cart.add(best);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added ${best.name} to cart')));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add ${best.name}: $e')));
                }
              },
              child: const Text('Add To Cart (Best)'))
        ]),
      ),
    );
  }
}

