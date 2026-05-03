import 'package:flutter/material.dart';
import '../models/meal.dart';

class RecommendationCard extends StatelessWidget {
  final Meal meal;
  const RecommendationCard({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(meal.name, style: theme.textTheme.titleMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(children: [Flexible(child: Text('Calories: ${meal.calories}', style: theme.textTheme.bodyMedium)), const SizedBox(width: 12), Flexible(child: Text('Price: ₹${meal.price.toStringAsFixed(0)}', style: theme.textTheme.bodyMedium))]),
          const SizedBox(height: 8),
          Row(children: [Flexible(child: Text('Rating: ${meal.rating}', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]))), const SizedBox(width: 12), Flexible(child: Text('Diet: ${meal.dietType}', style: theme.textTheme.bodyMedium))]),
        ]),
      ),
    );
  }
}
