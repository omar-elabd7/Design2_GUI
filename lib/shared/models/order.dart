import 'package:equatable/equatable.dart';
import 'enums.dart';
import 'order_item.dart';

class Order extends Equatable {
  const Order({
    required this.id,
    required this.userId,
    required this.assignedRfid,
    required this.items,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String assignedRfid;
  final List<OrderItem> items;
  final double totalPrice;
  final OrderStatus status;
  final DateTime createdAt;

  Order copyWith({
    String? id,
    String? userId,
    String? assignedRfid,
    List<OrderItem>? items,
    double? totalPrice,
    OrderStatus? status,
    DateTime? createdAt,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      assignedRfid: assignedRfid ?? this.assignedRfid,
      items: items ?? this.items,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'assigned_rfid': assignedRfid,
      'items': items.map((e) => e.toMap()).toList(),
      'total_price': totalPrice,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      assignedRfid: map['assigned_rfid'] as String,
      items: (map['items'] as List<dynamic>)
          .map((e) => OrderItem.fromMap(e as Map<String, dynamic>))
          .toList(),
      totalPrice: (map['total_price'] as num).toDouble(),
      status: OrderStatus.values.byName(map['status'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  @override
  List<Object?> get props => [id, userId, status, totalPrice, createdAt];
}
