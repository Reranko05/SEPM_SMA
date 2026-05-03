import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/meal.dart';
import '../providers/cart_provider.dart';
import '../services/auth_provider.dart';

class MenuScreen extends StatefulWidget {
  final String restaurantId;
  final String restaurantName;
  const MenuScreen({
    super.key,
    required this.restaurantId,
    required this.restaurantName,
  });

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
      final data =
          await api.getJson('/api/restaurants/${widget.restaurantId}/menu');

      if (data is List) {
        meals =
            data.map((e) => Meal.fromJson(e as Map<String, dynamic>)).toList();
      } else if (data is Map && data.containsKey('items')) {
        meals = (data['items'] as List)
            .map((e) => Meal.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        error = 'Invalid menu response';
      }
    } catch (e) {
      error = e.toString();
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restaurantName),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text('Error: $error'))
              : meals.isEmpty
                  ? _emptyState()
                  : Stack(
                      children: [
                        ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          itemCount: meals.length,
                          itemBuilder: (_, i) {
                            final m = meals[i];
                            return _menuCard(context, m, cart);
                          },
                        ),

                        // 🔥 Bottom cart bar (only if items exist)
                        if (cart.items.isNotEmpty)
                          Positioned(
                            bottom: 16,
                            left: 16,
                            right: 16,
                            child: _cartBar(context, cart),
                          ),
                      ],
                    ),
    );
  }

  // ================= UI COMPONENTS =================

  Widget _menuCard(BuildContext context, Meal m, CartProvider cart) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔥 IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              'https://picsum.photos/seed/${m.id}/200/200',
              height: 90,
              width: 90,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 90,
                width: 90,
                color: Colors.grey.shade200,
                child: const Icon(Icons.image_not_supported),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // 🔥 DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),

                Text(
                  '${m.calories} kcal • ${m.proteinGrams}g protein',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  m.dietType.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₹${m.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),

                    // 🔥 ADD BUTTON
                    SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor: Colors.green,
                        ),
                        onPressed: () async {
                          try {
                            await cart.add(m);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Added ${m.name}'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed: $e'),
                                ),
                              );
                            }
                          }
                        },
                        child: const Text('ADD'),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cartBar(BuildContext context, CartProvider cart) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      elevation: 6,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${cart.items.values.fold<int>(0, (s, it) => s + it.quantity)} items',
              style: const TextStyle(color: Colors.white),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              onPressed: () => Navigator.pushNamed(context, '/cart'),
              child: const Text('View Cart'),
            )
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.fastfood_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 12),
          Text('No items available'),
        ],
      ),
    );
  }
}