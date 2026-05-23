import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/order.dart';
import '../../../../shared/dto/create_order_request_dto.dart';
import '../../../../infrastructure/dependency_injection/providers.dart';
import '../../../../infrastructure/repositories/order_repository_impl.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'cart_provider.dart';

class CheckoutState {
  const CheckoutState({
    this.isLoading = false,
    this.order,
    this.error,
  });

  final bool isLoading;
  final Order? order;
  final String? error;

  CheckoutState copyWith({
    bool? isLoading,
    Order? order,
    String? error,
    bool clearError = false,
    bool clearOrder = false,
  }) {
    return CheckoutState(
      isLoading: isLoading ?? this.isLoading,
      order: clearOrder ? null : (order ?? this.order),
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  CheckoutNotifier(this._ref) : super(const CheckoutState());

  final Ref _ref;

  Future<void> placeOrder() async {
    final user = _ref.read(authStateProvider).user;
    if (user == null) return;

    final cart = _ref.read(cartProvider);
    if (cart.isEmpty) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final orderRepo = _ref.read(orderRepositoryProvider) as OrderRepositoryImpl;
      orderRepo.cacheUserCredits(user.id, user.credits);

      final items = cart
          .map((e) => CartItemDto(
                productId: e.product.id,
                quantity: e.quantity,
              ))
          .toList();

      final response = await orderRepo.createOrder(
        CreateOrderRequestDto(
          userId: user.id,
          assignedRfid: user.rfidCardId,
          items: items,
        ),
      );

      _ref.read(authStateProvider.notifier).updateCredits(response.remainingCredits);
      _ref.read(cartProvider.notifier).clearCart();

      final robotRepo = _ref.read(robotRepositoryProvider);
      await robotRepo.sendOrder(
        orderId: response.order.id,
        userId: user.id,
        authorizedRfid: user.rfidCardId,
        items: cart
            .map((e) => {'product_id': e.product.id, 'quantity': e.quantity})
            .toList(),
      );

      state = state.copyWith(isLoading: false, order: response.order);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void reset() {
    state = const CheckoutState();
  }
}

final checkoutProvider =
    StateNotifierProvider.autoDispose<CheckoutNotifier, CheckoutState>((ref) {
  return CheckoutNotifier(ref);
});
