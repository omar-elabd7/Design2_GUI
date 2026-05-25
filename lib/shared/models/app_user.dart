import 'package:equatable/equatable.dart';
import 'enums.dart';

class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.username,
    required this.passwordHash,
    required this.name,
    required this.role,
    required this.rfidCardId,
    required this.credits,
  });

  final String id;
  final String username;
  final String passwordHash;
  final String name;
  final UserRole role;
  final String rfidCardId;
  final double credits;

  AppUser copyWith({
    String? id,
    String? username,
    String? passwordHash,
    String? name,
    UserRole? role,
    String? rfidCardId,
    double? credits,
  }) {
    return AppUser(
      id: id ?? this.id,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      name: name ?? this.name,
      role: role ?? this.role,
      rfidCardId: rfidCardId ?? this.rfidCardId,
      credits: credits ?? this.credits,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password_hash': passwordHash,
      'name': name,
      'role': role.name,
      'rfid_card_id': rfidCardId,
      'credits': credits,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String,
      username: map['username'] as String,
      passwordHash: map['password_hash'] as String? ?? '',
      name: map['name'] as String,
      role: UserRole.values.byName(map['role'] as String),
      rfidCardId: map['rfid_card_id'] as String,
      credits: (map['credits'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [id, username, name, role, rfidCardId, credits];
}
