import '../models/order.dart';
import '../models/enums.dart';
import '../dto/create_order_request_dto.dart';
import '../dto/create_order_response_dto.dart';

abstract interface class OrderRepository {
  Future<CreateOrderResponseDto> createOrder(CreateOrderRequestDto request);
  Future<Order?> getOrderById(String id);
  Future<List<Order>> getOrdersByUser(String userId);
  Future<void> updateOrderStatus(String orderId, OrderStatus status);
}
