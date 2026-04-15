import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'recommendation_screen.dart';
import 'restaurants_screen.dart';
import 'sma_dashboard.dart';
import 'cart_screen.dart';
import '../providers/cart_provider.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final restaurants = [
      {'name': 'Pizza Hut', 'image': 'https://picsum.photos/seed/1/600/300', 'rating': '4.0', 'cuisine': 'Pizza'},
      {'name': 'Madhuban', 'image': 'https://picsum.photos/seed/2/600/300', 'rating': '4.4', 'cuisine': 'Vegetarian'},
      {'name': 'Green Bowl', 'image': 'https://picsum.photos/seed/3/600/300', 'rating': '4.3', 'cuisine': 'Healthy'},
      {'name': 'Spice Route', 'image': 'https://picsum.photos/seed/4/600/300', 'rating': '4.7', 'cuisine': 'Indian'},
      {'name': 'Sushi Point', 'image': 'https://picsum.photos/seed/5/600/300', 'rating': '4.5', 'cuisine': 'Japanese'},
      {'name': 'Taco Town', 'image': 'https://picsum.photos/seed/6/600/300', 'rating': '4.1', 'cuisine': 'Mexican'},
      {'name': 'Burger Lane', 'image': 'https://picsum.photos/seed/7/600/300', 'rating': '4.2', 'cuisine': 'Burgers'},
      {'name': 'Pasta Palace', 'image': 'https://picsum.photos/seed/8/600/300', 'rating': '4.0', 'cuisine': 'Italian'},
      {'name': 'Sweet Tooth', 'image': 'https://picsum.photos/seed/9/600/300', 'rating': '4.6', 'cuisine': 'Desserts'},
      {'name': 'Kebab Corner', 'image': 'https://picsum.photos/seed/10/600/300', 'rating': '4.3', 'cuisine': 'Grill'},
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('SMA Home'), backgroundColor: Colors.transparent, elevation: 0, foregroundColor: Colors.black),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFFFF2EE), borderRadius: BorderRadius.circular(12)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('Deliver to', style: TextStyle(color: Colors.grey)), Text('Connaught Place', style: TextStyle(fontWeight: FontWeight.bold))]),
              TextButton(onPressed: () {}, child: const Text('Manage', style: TextStyle(color: Colors.orange)))
            ]),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: restaurants.length,
              itemBuilder: (_, i) {
                final r = restaurants[i];
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RestaurantsScreen())),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(children: [
                      ClipRRect(borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)), child: Image.network(r['image']!, height: 140, width: double.infinity, fit: BoxFit.cover)),
                      ListTile(
                        title: Text(r['name']!),
                        subtitle: Text('${r['cuisine']} • 30-45 min • ₹300 for two'),
                        trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(8)), child: Text(r['rating']!, style: const TextStyle(color: Colors.orange))),
                      )
                    ]),
                  ),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}
