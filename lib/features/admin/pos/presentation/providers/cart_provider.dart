import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffee_house_pos/features/customer/cart/data/models/order_item_model.dart';
import 'package:coffee_house_pos/features/customer/cart/data/models/selected_addon_model.dart';
import 'package:coffee_house_pos/core/constants/app_constants.dart';

/// Cart item for POS with all details
class CartItem {
  final String productId;
  final String productName;
  final String variantName;
  final double variantPrice;
  final List<SelectedAddOn> addons;
  int quantity;
  final String? notes;

  CartItem({
    required this.productId,
    required this.productName,
    required this.variantName,
    required this.variantPrice,
    this.addons = const [],
    this.quantity = 1,
    this.notes,
  });

  double get itemTotal {
    final addonTotal = addons.fold<double>(
      0,
      (sum, addon) => sum + addon.additionalPrice,
    );
    return (variantPrice + addonTotal) * quantity;
  }

  CartItem copyWith({
    String? productId,
    String? productName,
    String? variantName,
    double? variantPrice,
    List<SelectedAddOn>? addons,
    int? quantity,
    String? notes,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      variantName: variantName ?? this.variantName,
      variantPrice: variantPrice ?? this.variantPrice,
      addons: addons ?? this.addons,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
    );
  }

  OrderItem toOrderItem() {
    return OrderItem(
      id: productId,
      productId: productId,
      productName: productName,
      selectedSize: variantName,
      basePrice: variantPrice,
      addOns: addons,
      quantity: quantity,
      notes: notes,
    );
  }
}

/// Cart state
class CartState {
  final List<CartItem> items;
  final double subtotal;
  final double taxAmount;
  final double total;

  CartState({
    this.items = const [],
    this.subtotal = 0,
    this.taxAmount = 0,
    this.total = 0,
  });

  CartState copyWith({
    List<CartItem>? items,
    double? subtotal,
    double? taxAmount,
    double? total,
  }) {
    return CartState(
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      total: total ?? this.total,
    );
  }

  factory CartState.calculate(List<CartItem> items) {
    final subtotal = items.fold<double>(
      0,
      (sum, item) => sum + item.itemTotal,
    );
    final taxAmount = subtotal * AppConstants.ppnRate;
    final total = subtotal + taxAmount;

    return CartState(
      items: items,
      subtotal: subtotal,
      taxAmount: taxAmount,
      total: total,
    );
  }
}

/// Cart notifier
class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(CartState());

  void addItem(CartItem item) {
    final items = [...state.items, item];
    state = CartState.calculate(items);
  }

  void removeItem(int index) {
    if (index < 0 || index >= state.items.length) return;

    final items = [...state.items];
    items.removeAt(index);
    state = CartState.calculate(items);
  }

  void updateQuantity(int index, int quantity) {
    if (index < 0 || index >= state.items.length) return;

    if (quantity <= 0) {
      removeItem(index);
      return;
    }

    final items = [...state.items];
    items[index] = items[index].copyWith(quantity: quantity);
    state = CartState.calculate(items);
  }

  void incrementQuantity(int index) {
    if (index < 0 || index >= state.items.length) return;

    final items = [...state.items];
    items[index] = items[index].copyWith(quantity: items[index].quantity + 1);
    state = CartState.calculate(items);
  }

  void decrementQuantity(int index) {
    if (index < 0 || index >= state.items.length) return;

    final items = [...state.items];
    final currentQuantity = items[index].quantity;

    if (currentQuantity <= 1) {
      removeItem(index);
      return;
    }

    items[index] = items[index].copyWith(quantity: currentQuantity - 1);
    state = CartState.calculate(items);
  }

  void updateNotes(int index, String notes) {
    if (index < 0 || index >= state.items.length) return;

    final items = [...state.items];
    items[index] = items[index].copyWith(notes: notes);
    state = CartState.calculate(items);
  }

  void clear() {
    state = CartState();
  }

  List<OrderItem> toOrderItems() {
    return state.items.map((item) => item.toOrderItem()).toList();
  }
}

/// Cart provider
final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});
