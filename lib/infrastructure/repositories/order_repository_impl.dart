import '../../shared/repositories/order_repository.dart';
import '../../shared/models/order.dart';
import '../../shared/models/enums.dart';
import '../../shared/dto/create_order_request_dto.dart';
import '../../shared/dto/create_order_response_dto.dart';
import '../data_sources/mock/mock_order_data_source.dart';

class OrderRepositoryImpl implements OrderRepository {
  final MockOrderDataSource _mockDataSource;
  final Map<String, double> _userCreditsCache = {};

  OrderRepositoryImpl(this._mockDataSource);

  void cacheUserCredits(String userId, double credits) {
    _userCreditsCache[userId] = credits;
  }

  @override
  Future<CreateOrderResponseDto> createOrder(CreateOrderRequestDto request) {
    final credits = _userCreditsCache[request.userId] ?? 0;
    return _mockDataSource.createOrder(request, credits);
  }

  @override
  Future<Order?> getOrderById(String id) => _mockDataSource.getOrderById(id);

  @override
  Future<List<Order>> getOrdersByUser(String userId) =>
      _mockDataSource.getOrdersByUser(userId);

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) =>
      _mockDataSource.updateOrderStatus(orderId, status);
}
