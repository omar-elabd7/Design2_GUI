import 'package:equatable/equatable.dart';
import 'enums.dart';

class TeleopCommand extends Equatable {
  const TeleopCommand({
    required this.direction,
    required this.vx,
    required this.vy,
    required this.w,
  });

  final TeleopDirection direction;

  final int vx;

  final int vy;

  final int w;

  static const TeleopCommand stop = TeleopCommand(
    direction: TeleopDirection.stop,
    vx: 0,
    vy: 0,
    w: 0,
  );

  Map<String, dynamic> toMap() {
    return {
      'type': 'teleop.command',
      'direction': direction.name,
      'vx': vx,
      'vy': vy,
      'w': w,
    };
  }

  @override
  List<Object?> get props => [direction, vx, vy, w];
}
