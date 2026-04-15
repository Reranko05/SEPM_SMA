import 'package:flutter/material.dart';
import '../models/meal.dart';

class RecommendationCard extends StatelessWidget {
  final Meal meal;
  const RecommendationCard({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(meal.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(children: [Flexible(child: Text('Calories: ${meal.calories}')), const SizedBox(width: 12), Flexible(child: Text('Price: \$${meal.price.toStringAsFixed(2)}'))]),
          const SizedBox(height: 8),
          Row(children: [Flexible(child: Text('Rating: ${meal.rating}')), const SizedBox(width: 12), Flexible(child: Text('Diet: ${meal.dietType}'))]),
        ]),
      ),
    );
  }
}
