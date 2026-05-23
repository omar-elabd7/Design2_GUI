import '../../../../shared/dto/create_order_request_dto.dart';
import '../../../../shared/dto/create_order_response_dto.dart';
import '../../../../shared/repositories/order_repository.dart';

class CreateOrderUsecase {
  final OrderRepository _repo;

  CreateOrderUsecase(this._repo);

  Future<CreateOrderResponseDto> call(CreateOrderRequestDto request) =>
      _repo.createOrder(request);
}
