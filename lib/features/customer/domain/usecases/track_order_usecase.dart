import '../../../../shared/models/order.dart';
import '../../../../shared/repositories/order_repository.dart';

class TrackOrderUsecase {
  final OrderRepository _repo;

  TrackOrderUsecase(this._repo);

  Future<Order?> call(String orderId) => _repo.getOrderById(orderId);
}
