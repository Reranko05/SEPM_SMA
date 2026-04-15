import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/restaurant.dart';
import 'menu_screen.dart';
import '../services/auth_provider.dart';

class RestaurantsScreen extends StatefulWidget {
  const RestaurantsScreen({super.key});

  @override
  State<RestaurantsScreen> createState() => _RestaurantsScreenState();
}

class _RestaurantsScreenState extends State<RestaurantsScreen> {
  bool loading = true;
  String? error;
  List<Restaurant> restaurants = [];

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  Future<void> _loadRestaurants() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final api = auth.api;
      final data = await api.getJson('/api/restaurants');
      if (data is List) {
        restaurants = data.map((e) {
          final m = Map<String, dynamic>.from(e as Map);
          return Restaurant(
              id: m['id']?.toString() ?? '',
              name: m['name']?.toString() ?? 'Unknown',
              imageUrl: m['imageUrl'] ?? m['image'] ?? 'https://picsum.photos/seed/${m['id'] ?? 'r'}/200/200',
              rating: (m['rating'] is num) ? (m['rating'] as num).toDouble() : 4.0,
              cuisine: m['cuisine']?.toString() ?? 'Various');
        }).toList();
      } else {
        error = 'Invalid response';
      }
    } catch (e) {
      error = e.toString();
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Restaurants')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? Center(child: Text('Error: $error'))
                : ListView.builder(
                    itemCount: restaurants.length,
                    itemBuilder: (_, i) {
                      final r = restaurants[i];
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MenuScreen(restaurantId: r.id, restaurantName: r.name))),
                          child: Column(children: [
                            ClipRRect(borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)), child: Image.network(r.imageUrl, height: 140, width: double.infinity, fit: BoxFit.cover)),
                            ListTile(title: Text(r.name), subtitle: Text('${r.cuisine} • 30-45 min'), trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)), child: Text('${r.rating} ⭐')))
                          ]),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
