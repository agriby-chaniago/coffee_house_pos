import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/cart_item_model.dart';

class CustomerCartNotifier extends StateNotifier<CustomerCartState> {
  CustomerCartNotifier() : super(CustomerCartState.initial()) {
    _loadCart();
  }

  static const String _cartBoxName = 'customer_cart';

  Future<void> _loadCart() async {
    try {
      final box = await Hive.openBox<CartItem>(_cartBoxName);
      final items = box.values.toList();
      state = state.copyWith(items: items);
    } catch (e) {
      // Handle error silently or log
    }
  }

  Future<void> _saveCart() async {
    try {
      final box = await Hive.openBox<CartItem>(_cartBoxName);
      await box.clear();
      for (final item in state.items) {
        await box.add(item);
      }
    } catch (e) {
      // Handle error
    }
  }

  void addItem(CartItem item) {
    // Check if same product with same size and addons exists
    final existingIndex = state.items.indexWhere((i) =>
        i.productId == item.productId &&
        i.size == item.size &&
        _addonsMatch(i.addons, item.addons));

    if (existingIndex != -1) {
      // Update quantity
      final existing = state.items[existingIndex];
      final updated = existing.copyWith(
        quantity: existing.quantity + item.quantity,
      );
      final newItems = List<CartItem>.from(state.items);
      newItems[existingIndex] = updated;
      state = state.copyWith(items: newItems);
    } else {
      // Add new item
      state = state.copyWith(items: [...state.items, item]);
    }

    _saveCart();
  }

  void updateItemQuantity(String itemId, int quantity) {
    if (quantity <= 0) {
      removeItem(itemId);
      return;
    }

    final newItems = state.items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    state = state.copyWith(items: newItems);
    _saveCart();
  }

  void removeItem(String itemId) {
    state = state.copyWith(
      items: state.items.where((item) => item.id != itemId).toList(),
    );
    _saveCart();
  }

  void updateItemNotes(String itemId, String notes) {
    final newItems = state.items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(notes: notes);
      }
      return item;
    }).toList();

    state = state.copyWith(items: newItems);
    _saveCart();
  }

  void updateItem(CartItem updatedItem) {
    final newItems = state.items.map((item) {
      if (item.id == updatedItem.id) {
        return updatedItem;
      }
      return item;
    }).toList();

    state = state.copyWith(items: newItems);
    _saveCart();
  }

  void clearCart() {
    state = CustomerCartState.initial();
    _saveCart();
  }

  bool _addonsMatch(List addons1, List addons2) {
    if (addons1.length != addons2.length) return false;

    final ids1 = addons1.map((a) => a.id).toSet();
    final ids2 = addons2.map((a) => a.id).toSet();

    return ids1.containsAll(ids2) && ids2.containsAll(ids1);
  }
}

class CustomerCartState {
  final List<CartItem> items;

  CustomerCartState({required this.items});

  factory CustomerCartState.initial() => CustomerCartState(items: []);

  double get subtotal {
    return items.fold(0, (sum, item) => sum + item.itemTotal);
  }

  double get tax {
    return subtotal * 0.11; // PPN 11%
  }

  double get total {
    return subtotal + tax;
  }

  CustomerCartState copyWith({List<CartItem>? items}) {
    return CustomerCartState(items: items ?? this.items);
  }
}

final customerCartProvider =
    StateNotifierProvider<CustomerCartNotifier, CustomerCartState>((ref) {
  return CustomerCartNotifier();
});
