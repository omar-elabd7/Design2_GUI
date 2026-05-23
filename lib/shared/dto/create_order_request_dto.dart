class CartItemDto {
  const CartItemDto({required this.productId, required this.quantity});

  final String productId;
  final int quantity;

  Map<String, dynamic> toMap() {
    return {'product_id': productId, 'quantity': quantity};
  }
}

class CreateOrderRequestDto {
  const CreateOrderRequestDto({
    required this.userId,
    required this.assignedRfid,
    required this.items,
  });

  final String userId;
  final String assignedRfid;
  final List<CartItemDto> items;

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'assigned_rfid': assignedRfid,
      'items': items.map((e) => e.toMap()).toList(),
    };
  }
}
