import '../models/order.dart';

class CreateOrderResponseDto {
  const CreateOrderResponseDto({
    required this.order,
    required this.remainingCredits,
  });

  final Order order;
  final double remainingCredits;

  factory CreateOrderResponseDto.fromMap(Map<String, dynamic> map) {
    return CreateOrderResponseDto(
      order: Order.fromMap(map['order'] as Map<String, dynamic>),
      remainingCredits: (map['remaining_credits'] as num).toDouble(),
    );
  }
}
