import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';

class CartProvider extends ChangeNotifier {
  final ApiService api;
  AuthProvider? _auth;

  CartProvider({required this.api});

  void updateAuth(AuthProvider auth) {
    _auth = auth;
  }

  final Map<String, _CartItem> _items = {};

  Map<String, _CartItem> get items => Map.unmodifiable(_items);

  Future<void> add(Meal meal) async {
    // optimistically add locally
    if (_items.containsKey(meal.id)) {
      _items[meal.id]!.quantity++;
    } else {
      _items[meal.id] = _CartItem(meal: meal, quantity: 1);
    }
    notifyListeners();

    try {
      final username = _auth?.username;
      final path = username != null ? '/api/cart?username=${Uri.encodeComponent(username)}' : '/api/cart';
      await api.postJson(path, meal.toJson(), auth: true);
    } catch (e) {
      // rollback on error
      if (_items.containsKey(meal.id)) {
        final ci = _items[meal.id]!;
        ci.quantity--;
        if (ci.quantity <= 0) _items.remove(meal.id);
      }
      notifyListeners();
      rethrow;
    }
  }

  Future<void> remove(String id) async {
    // optimistic remove: keep previous state to rollback on error
    final prev = _items.containsKey(id) ? _CartItem(meal: _items[id]!.meal, quantity: _items[id]!.quantity) : null;
    _items.remove(id);
    notifyListeners();
    try {
      final username = _auth?.username;
      final path = username != null ? '/api/cart/${Uri.encodeComponent(id)}?username=${Uri.encodeComponent(username)}' : '/api/cart/${Uri.encodeComponent(id)}';
      await api.deleteJson(path, auth: true);
    } catch (e) {
      // rollback
      if (prev != null) _items[id] = prev;
      notifyListeners();
      rethrow;
    }
  }

  void setQuantity(String id, int qty) {
    if (!_items.containsKey(id)) return;
    if (qty <= 0) {
      // call remove which is async and handles optimistic update
      remove(id);
    } else {
      _items[id]!.quantity = qty;
      notifyListeners();
    }
  }

  double get totalPrice => _items.values.fold(0.0, (s, it) => s + it.meal.price * it.quantity);

  int get totalCount => _items.values.fold(0, (s, it) => s + it.quantity);

  void clear() {
    _clearServer();
  }

  Future<void> _clearServer() async {
    try {
      final username = _auth?.username;
      final path = username != null ? '/api/cart?username=${Uri.encodeComponent(username)}' : '/api/cart';
      await api.deleteJson(path, auth: true);
      _items.clear();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> fetchCart() async {
    // load server cart (demo backend returns single meal or 404)
    try {
      final username = _auth?.username;
      final path = username != null ? '/api/cart?username=${Uri.encodeComponent(username)}' : '/api/cart';
      final data = await api.getJson(path, auth: true);
      _items.clear();
      if (data is Map<String, dynamic>) {
        try {
          final meal = Meal.fromJson(data);
          _items[meal.id] = _CartItem(meal: meal, quantity: 1);
        } catch (_) {}
      } else if (data is List) {
        for (final e in data) {
          try {
            final item = e as Map<String, dynamic>;
            final meal = Meal.fromJson(item);
            final qty = (item['quantity'] is int) ? item['quantity'] as int : int.tryParse('${item['quantity']}') ?? 1;
            if (!_items.containsKey(meal.id)) _items[meal.id] = _CartItem(meal: meal, quantity: qty);
            else _items[meal.id]!.quantity += qty;
          } catch (_) {}
        }
      }
      notifyListeners();
    } catch (_) {}
  }
}

class _CartItem {
  final Meal meal;
  int quantity;
  _CartItem({required this.meal, required this.quantity});
}
