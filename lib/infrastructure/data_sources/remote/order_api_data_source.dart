import '../../../shared/models/order.dart';
import '../../../shared/models/enums.dart';
import '../../../shared/dto/create_order_request_dto.dart';
import '../../../shared/dto/create_order_response_dto.dart';
import '../../../core/errors/app_exceptions.dart';

class OrderApiDataSource {
  Future<CreateOrderResponseDto> createOrder(CreateOrderRequestDto request) async {
    throw const NetworkException('Real backend not connected yet');
  }

  Future<Order?> getOrderById(String id) async {
    throw const NetworkException('Real backend not connected yet');
  }

  Future<List<Order>> getOrdersByUser(String userId) async {
    throw const NetworkException('Real backend not connected yet');
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    throw const NetworkException('Real backend not connected yet');
  }
}
