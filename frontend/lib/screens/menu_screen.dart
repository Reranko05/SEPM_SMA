import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/meal.dart';
import '../providers/cart_provider.dart';
import '../services/auth_provider.dart';

class MenuScreen extends StatefulWidget {
  final String restaurantId;
  final String restaurantName;
  const MenuScreen({super.key, required this.restaurantId, required this.restaurantName});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  bool loading = true;
  List<Meal> meals = [];
  String? error;

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final api = auth.api;
      final data = await api.getJson('/api/restaurants/${widget.restaurantId}/menu');
      if (data is List) {
        meals = data.map((e) => Meal.fromJson(e as Map<String, dynamic>)).toList();
      } else if (data is Map && data.containsKey('items')) {
        meals = (data['items'] as List).map((e) => Meal.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        error = 'Invalid menu response';
      }
    } catch (e) {
      error = e.toString();
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.restaurantName)),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? Center(child: Text('Error: $error'))
                : ListView.builder(
                    itemCount: meals.length,
                    itemBuilder: (_, i) {
                      final m = meals[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(children: [
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(m.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                Text('${m.calories} kcal • ${m.dietType}'),
                              ]),
                            ),
                            Column(children: [
                                    Text('\$${m.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    ElevatedButton(
                                      onPressed: () async {
                                        try {
                                          await cart.add(m);
                                          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added ${m.name} to cart')));
                                        } catch (e) {
                                          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add ${m.name}: $e')));
                                        }
                                      },
                                      child: const Text('Add'))
                                  ])
                          ]),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
