import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/product.dart';

class CartEntry {
  const CartEntry({required this.product, required this.quantity});
  final Product product;
  final int quantity;

  double get subtotal => product.price * quantity;

  CartEntry copyWith({Product? product, int? quantity}) {
    return CartEntry(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}

class CartNotifier extends StateNotifier<List<CartEntry>> {
  CartNotifier() : super([]);

  void addProduct(Product product) {
    final index = state.indexWhere((e) => e.product.id == product.id);
    if (index != -1) {
      final updated = List<CartEntry>.from(state);
      updated[index] = updated[index].copyWith(
        quantity: updated[index].quantity + 1,
      );
      state = updated;
    } else {
      state = [...state, CartEntry(product: product, quantity: 1)];
    }
  }

  void removeProduct(String productId) {
    state = state.where((e) => e.product.id != productId).toList();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeProduct(productId);
      return;
    }
    final updated = state.map((e) {
      if (e.product.id == productId) return e.copyWith(quantity: quantity);
      return e;
    }).toList();
    state = updated;
  }

  void clearCart() {
    state = [];
  }

  double get total =>
      state.fold(0.0, (sum, e) => sum + e.subtotal);

  int get totalItems =>
      state.fold(0, (sum, e) => sum + e.quantity);

  bool get isEmpty => state.isEmpty;
}

final cartProvider =
    StateNotifierProvider<CartNotifier, List<CartEntry>>((ref) {
  return CartNotifier();
});

final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0.0, (sum, e) => sum + e.subtotal);
});

final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (sum, e) => sum + e.quantity);
});
