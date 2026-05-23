import '../../../shared/models/order.dart';
import '../../../shared/models/order_item.dart';
import '../../../shared/models/enums.dart';
import '../../../shared/dto/create_order_request_dto.dart';
import '../../../shared/dto/create_order_response_dto.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/utils/helpers.dart';
import '../mock/mock_product_data_source.dart';

class MockOrderDataSource {
  final MockProductDataSource _productDataSource;
  final List<Order> _orders = [];

  MockOrderDataSource(this._productDataSource);

  Future<CreateOrderResponseDto> createOrder(
    CreateOrderRequestDto request,
    double currentCredits,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));

    double total = 0;
    final orderItems = <OrderItem>[];

    for (final cartItem in request.items) {
      final product = await _productDataSource.getProductById(cartItem.productId);
      if (product == null) {
        throw OrderException('Product ${cartItem.productId} not found');
      }
      if (product.stock < cartItem.quantity) {
        throw OutOfStockException(product.name);
      }
      final subtotal = product.price * cartItem.quantity;
      total += subtotal;
      orderItems.add(OrderItem(
        id: Helpers.generateId(),
        orderId: '',
        productId: product.id,
        productName: product.name,
        unitPrice: product.price,
        quantity: cartItem.quantity,
      ));
    }

    if (currentCredits < total) {
      throw const InsufficientCreditsException();
    }

    final orderId = Helpers.generateId();
    final finalItems = orderItems.map((i) {
      return OrderItem(
        id: i.id,
        orderId: orderId,
        productId: i.productId,
        productName: i.productName,
        unitPrice: i.unitPrice,
        quantity: i.quantity,
      );
    }).toList();

    final order = Order(
      id: orderId,
      userId: request.userId,
      assignedRfid: request.assignedRfid,
      items: finalItems,
      totalPrice: total,
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
    );

    _orders.add(order);

    for (final cartItem in request.items) {
      await _productDataSource.decrementStock(cartItem.productId, cartItem.quantity);
    }

    return CreateOrderResponseDto(
      order: order,
      remainingCredits: currentCredits - total,
    );
  }

  Future<Order?> getOrderById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<Order>> getOrdersByUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _orders.where((o) => o.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(status: status);
    }
  }
}
