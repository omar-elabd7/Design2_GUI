import 'package:equatable/equatable.dart';
import 'enums.dart';

class StorageStateModel extends Equatable {
  const StorageStateModel({required this.state, required this.updatedAt});

  final StorageState state;
  final DateTime updatedAt;

  static StorageStateModel get initial =>
      StorageStateModel(state: StorageState.closed, updatedAt: DateTime.now());

  Map<String, dynamic> toMap() {
    return {'state': state.name, 'updated_at': updatedAt.toIso8601String()};
  }

  factory StorageStateModel.fromMap(Map<String, dynamic> map) {
    return StorageStateModel(
      state: StorageState.values.byName(map['state'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  @override
  List<Object?> get props => [state, updatedAt];
}
