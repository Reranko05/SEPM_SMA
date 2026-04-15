import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';


class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Cart (${cart.totalCount})')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          if (cart.items.isEmpty) Expanded(child: Center(child: Text('Your cart is empty'))),
          if (cart.items.isNotEmpty)
            Expanded(
              child: ListView(
                children: cart.items.values.map((it) {
                  return ListTile(
                    title: Text(it.meal.name),
                    subtitle: Text('${it.quantity} × \$${it.meal.price.toStringAsFixed(2)}'),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(icon: Icon(Icons.remove), onPressed: () => cart.setQuantity(it.meal.id, it.quantity - 1)),
                      Text('${it.quantity}'),
                      IconButton(icon: Icon(Icons.add), onPressed: () => cart.setQuantity(it.meal.id, it.quantity + 1)),
                      IconButton(icon: Icon(Icons.delete), onPressed: () async {
                        try {
                          await cart.remove(it.meal.id);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Removed ${it.meal.name}')));
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to remove ${it.meal.name}: $e')));
                        }
                      }),
                    ]),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 8),
          Text('Total: \$${cart.totalPrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: cart.items.isEmpty
                ? null
                : () {
                    cart.clear();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order placed successfully!')));
                  },
            child: const Text('Place Order'),
          )
        ]),
      ),
    );
  }
}
