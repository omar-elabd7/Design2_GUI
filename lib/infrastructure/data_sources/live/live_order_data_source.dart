import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../shared/models/order.dart';
import '../../../shared/models/enums.dart';
import '../../../shared/dto/create_order_request_dto.dart';
import '../../../shared/dto/create_order_response_dto.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/errors/app_exceptions.dart';

class LiveOrderDataSource {
  Future<CreateOrderResponseDto> createOrder(
    CreateOrderRequestDto request,
  ) async {
    final res = await http
        .post(
          Uri.parse('$kBaseUrl$kOrdersEndpoint'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(request.toMap()),
        )
        .timeout(kHttpTimeout);

    if (res.statusCode == 200) {
      final map = jsonDecode(res.body) as Map<String, dynamic>;
      return CreateOrderResponseDto.fromMap(map);
    }

    // Surface server error messages to the UI
    String detail = 'Failed to create order';
    try {
      final err = jsonDecode(res.body) as Map<String, dynamic>;
      detail = err['detail'] as String? ?? detail;
    } catch (_) {}

    if (res.statusCode == 422) throw OutOfStockException(detail);
    throw OrderException(detail);
  }

  Future<Order?> getOrderById(String id) async => null;

  Future<List<Order>> getOrdersByUser(String userId) async => [];

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {}
}
