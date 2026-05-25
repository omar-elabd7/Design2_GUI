import '../../shared/repositories/order_repository.dart';
import '../../shared/models/order.dart';
import '../../shared/models/enums.dart';
import '../../shared/dto/create_order_request_dto.dart';
import '../../shared/dto/create_order_response_dto.dart';
import '../data_sources/live/live_order_data_source.dart';

class LiveOrderRepositoryImpl implements OrderRepository {
  final LiveOrderDataSource _dataSource;

  LiveOrderRepositoryImpl(this._dataSource);

  @override
  Future<CreateOrderResponseDto> createOrder(CreateOrderRequestDto request) {
    return _dataSource.createOrder(request);
  }

  @override
  Future<Order?> getOrderById(String id) => _dataSource.getOrderById(id);

  @override
  Future<List<Order>> getOrdersByUser(String userId) =>
      _dataSource.getOrdersByUser(userId);

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) =>
      _dataSource.updateOrderStatus(orderId, status);
}
