import 'package:equatable/equatable.dart';
import 'enums.dart';

class TeleopCommand extends Equatable {
  const TeleopCommand({
    required this.direction,
    required this.linearSpeed,
    required this.angularSpeed,
  });

  final TeleopDirection direction;
  final double linearSpeed;
  final double angularSpeed;

  static const TeleopCommand stop = TeleopCommand(
    direction: TeleopDirection.stop,
    linearSpeed: 0.0,
    angularSpeed: 0.0,
  );

  Map<String, dynamic> toMap() {
    return {
      'type': 'teleop.command',
      'direction': direction.name,
      'linear_speed': linearSpeed,
      'angular_speed': angularSpeed,
    };
  }

  @override
  List<Object?> get props => [direction, linearSpeed, angularSpeed];
}
