import 'package:equatable/equatable.dart';
import 'enums.dart';

class MissionUpdate extends Equatable {
  const MissionUpdate({
    required this.orderId,
    required this.state,
    required this.message,
    required this.timestamp,
    this.faultType,
  });

  final String orderId;
  final MissionState state;
  final String message;
  final DateTime timestamp;
  final FaultType? faultType;

  Map<String, dynamic> toMap() {
    return {
      'order_id': orderId,
      'state': state.name,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'fault_type': faultType?.name,
    };
  }

  factory MissionUpdate.fromMap(Map<String, dynamic> map) {
    return MissionUpdate(
      orderId: map['order_id'] as String,
      state: MissionState.values.byName(map['state'] as String),
      message: map['message'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      faultType: map['fault_type'] != null
          ? FaultType.values.byName(map['fault_type'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [orderId, state, timestamp];
}
