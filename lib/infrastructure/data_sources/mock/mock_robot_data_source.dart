import 'dart:async';
import '../../../shared/models/robot_status.dart';
import '../../../shared/models/mission_update.dart';
import '../../../shared/models/enums.dart';
import '../../../core/constants/app_constants.dart';

class MockRobotDataSource {
  RobotStatus _status = RobotStatus.initial.copyWith(
    batteryPercent: 78,
    mode: RobotMode.online,
    missionState: MissionState.idle,
    isConnected: true,
  );

  final StreamController<RobotStatus> _statusController =
      StreamController<RobotStatus>.broadcast();

  final StreamController<MissionUpdate> _missionController =
      StreamController<MissionUpdate>.broadcast();

  final StreamController<bool> _rfidController =
      StreamController<bool>.broadcast();

  Timer? _batteryTimer;
  Timer? _stepTimer;
  int _batteryDrain = 0;
  String? _activeMissionOrderId;

  /// Index into `_missionSteps` ? tracks where we are so we can
  /// pause on fault and resume from the same spot.
  int _stepIndex = 0;

  /// Whether the sequence is currently paused by a fault.
  bool _paused = false;

  /// The state the robot was in *before* the fault, so we can restore it.
  MissionState? _preBlockState;

  /// RFID verification attempt counter.  Max [kMaxRfidAttempts] tries.
  int _rfidAttempts = 0;
  static const int kMaxRfidAttempts = 3;

  static const _missionSteps = <(MissionState, String, int)>[
    (MissionState.preparingOrder, 'Preparing your Order?', 3000),
    (MissionState.navigatingToUser, 'Robot is on its way to you!', 6000),
    (MissionState.arrived, 'Robot has arrived at your location.', 3500),
    (
      MissionState.awaitingRfid,
      'Please tap your RFID card on the robot.',
      2000,
    ),
    // After awaitingRfid the RFID auto-verify fires (special handling)
  ];

  MockRobotDataSource() {
    _startBatteryDrain();
  }

  Stream<RobotStatus> get statusStream => _statusController.stream;
  Stream<MissionUpdate> get missionStream => _missionController.stream;
  Stream<bool> get rfidStream => _rfidController.stream;

  void _startBatteryDrain() {
    _batteryTimer = Timer.periodic(
      Duration(seconds: kBatteryUpdateIntervalSec),
      (_) {
        _batteryDrain++;
        if (_batteryDrain % 15 == 0) {
          final newBattery = (_status.batteryPercent - 1).clamp(0, 100);
          _status = _status.copyWith(batteryPercent: newBattery);
          _emitStatus();
        }
      },
    );
  }

  void _emitStatus() {
    if (!_statusController.isClosed) {
      _statusController.add(_status);
    }
  }

  void _emitMission(MissionUpdate update) {
    if (!_missionController.isClosed) {
      _missionController.add(update);
    }
  }

  Future<void> sendOrder({
    required String orderId,
    required String userId,
    required String authorizedRfid,
    required List<Map<String, dynamic>> items,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _activeMissionOrderId = orderId;
    _stepIndex = 0;
    _paused = false;
    _preBlockState = null;
    _rfidAttempts = 0;

    _status = _status.copyWith(
      missionState: MissionState.missionReceived,
      activeOrderId: orderId,
    );
    _emitStatus();
    _emitMission(
      MissionUpdate(
        orderId: orderId,
        state: MissionState.missionReceived,
        message: 'Mission received!',
        timestamp: DateTime.now(),
      ),
    );

    _scheduleNextStep(orderId);
  }

  /// Schedules the next step in the mission sequence.
  /// Each step checks `_paused` before advancing ? if a fault is active
  /// the timer simply doesn't fire and the sequence halts.
  void _scheduleNextStep(String orderId) {
    if (_stepIndex < _missionSteps.length) {
      final (state, message, waitMs) = _missionSteps[_stepIndex];
      _stepTimer?.cancel();
      _stepTimer = Timer(Duration(milliseconds: waitMs), () {
        if (_activeMissionOrderId != orderId) return;
        if (_paused) return; // fault active ? stay halted

        _status = _status.copyWith(missionState: state);
        _emitStatus();
        _emitMission(
          MissionUpdate(
            orderId: orderId,
            state: state,
            message: message,
            timestamp: DateTime.now(),
          ),
        );

        _stepIndex++;
        _scheduleNextStep(orderId);
      });
    } else {
      // All pre-RFID steps done ? schedule the post-RFID tail
      _schedulePostRfidSequence(orderId);
    }
  }

  /// Handles RFID verification ? storage open ? delivery complete ? RTB ? idle.
  void _schedulePostRfidSequence(String orderId) {
    final tail = <(MissionState, StorageState?, String, int)>[
      (
        MissionState.rfidVerified,
        StorageState.opening,
        'RFID verified - unlocking storage.',
        12000,
      ),
      (
        MissionState.storageOpened,
        StorageState.open,
        'Storage compartment opened.',
        4000,
      ),
      (
        MissionState.deliveryComplete,
        StorageState.closing,
        'Delivery complete!',
        6000,
      ),
      (
        MissionState.returningToBase,
        StorageState.closed,
        'Robot returning to base.',
        5000,
      ),
    ];

    int i = 0;
    void scheduleNext() {
      if (i >= tail.length) {
        // Final: idle
        _stepTimer = Timer(const Duration(seconds: 4), () {
          _activeMissionOrderId = null;
          _status = _status.copyWith(
            missionState: MissionState.idle,
            clearActiveOrder: true,
          );
          _emitStatus();
        });
        return;
      }
      final (state, storage, message, waitMs) = tail[i];
      _stepTimer?.cancel();
      _stepTimer = Timer(Duration(milliseconds: waitMs), () {
        if (_activeMissionOrderId != orderId) return;
        if (_paused) return;

        // Special: emit RFID success right before rfidVerified
        if (state == MissionState.rfidVerified) {
          _rfidController.add(true);
        }

        _status = _status.copyWith(missionState: state, storageState: storage);
        _emitStatus();
        _emitMission(
          MissionUpdate(
            orderId: orderId,
            state: state,
            message: message,
            timestamp: DateTime.now(),
          ),
        );

        i++;
        scheduleNext();
      });
    }

    scheduleNext();
  }

  Future<void> setRobotMode(RobotMode mode) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _status = _status.copyWith(mode: mode);
    _emitStatus();
  }

  void simulateObstacle(String orderId) {
    _stepTimer?.cancel();
    _paused = true;
    _preBlockState = _status.missionState;

    _status = _status.copyWith(
      missionState: MissionState.obstacleBlocked,
      faultType: FaultType.obstacleBlocked,
    );
    _emitStatus();
    _emitMission(
      MissionUpdate(
        orderId: orderId,
        state: MissionState.obstacleBlocked,
        message: 'Robot blocked by obstacle. Mission paused.',
        timestamp: DateTime.now(),
        faultType: FaultType.obstacleBlocked,
      ),
    );
  }

  void simulateLowBattery() {
    _status = _status.copyWith(
      batteryPercent: 15,
      faultType: FaultType.lowBattery,
    );
    _emitStatus();
  }

  void simulateRfidFail(String orderId) {
    _rfidAttempts++;
    _stepTimer?.cancel();
    _paused = true;
    _preBlockState = _status.missionState;

    _rfidController.add(false);

    final lockedOut = _rfidAttempts >= kMaxRfidAttempts;
    final msg = lockedOut
        ? 'RFID failed $_rfidAttempts/$kMaxRfidAttempts - maximum attempts reached. Mission aborted.'
        : 'RFID verification failed - attempt $_rfidAttempts/$kMaxRfidAttempts.';

    if (lockedOut) {
      _status = _status.copyWith(
        missionState: MissionState.failed,
        faultType: FaultType.rfidFailed,
        clearActiveOrder: true,
      );
    } else {
      _status = _status.copyWith(
        missionState: MissionState.rfidFailed,
        faultType: FaultType.rfidFailed,
      );
    }

    _emitStatus();
    _emitMission(
      MissionUpdate(
        orderId: orderId,
        state: _status.missionState,
        message: msg,
        timestamp: DateTime.now(),
        faultType: FaultType.rfidFailed,
      ),
    );
  }

  /// Simulates a **correct** RFID scan.  Clears the fault, resets attempts,
  /// and resumes the post-RFID sequence (storage open ? delivery ? RTB).
  void simulateCorrectRfid(String orderId) {
    // Only meaningful while in awaitingRfid or rfidFailed state
    if (_status.missionState != MissionState.awaitingRfid &&
        _status.missionState != MissionState.rfidFailed) {
      return;
    }

    _stepTimer?.cancel();
    _paused = false;
    _preBlockState = null;
    _rfidAttempts = 0;

    _rfidController.add(true);

    _status = _status.copyWith(
      missionState: MissionState.rfidVerified,
      faultType: FaultType.none,
      storageState: StorageState.opening,
    );
    _emitStatus();
    _emitMission(
      MissionUpdate(
        orderId: orderId,
        state: MissionState.rfidVerified,
        message: 'RFID verified - unlocking storage.',
        timestamp: DateTime.now(),
      ),
    );

    // Skip directly to the post-rfidVerified tail (storage opened onward)
    _schedulePostVerifiedTail(orderId);
  }

  /// Tail sequence starting *after* rfidVerified (storage opened ? complete ? RTB ? idle).
  void _schedulePostVerifiedTail(String orderId) {
    final tail = <(MissionState, StorageState?, String, int)>[
      (
        MissionState.storageOpened,
        StorageState.open,
        'Storage compartment opened.',
        4000,
      ),
      (
        MissionState.deliveryComplete,
        StorageState.closing,
        'Delivery complete!',
        6000,
      ),
      (
        MissionState.returningToBase,
        StorageState.closed,
        'Robot returning to base.',
        5000,
      ),
    ];

    int i = 0;
    void scheduleNext() {
      if (i >= tail.length) {
        _stepTimer = Timer(const Duration(seconds: 4), () {
          _activeMissionOrderId = null;
          _status = _status.copyWith(
            missionState: MissionState.idle,
            clearActiveOrder: true,
          );
          _emitStatus();
        });
        return;
      }
      final (state, storage, message, waitMs) = tail[i];
      _stepTimer?.cancel();
      _stepTimer = Timer(Duration(milliseconds: waitMs), () {
        if (_activeMissionOrderId != orderId) return;
        if (_paused) return;

        _status = _status.copyWith(missionState: state, storageState: storage);
        _emitStatus();
        _emitMission(
          MissionUpdate(
            orderId: orderId,
            state: state,
            message: message,
            timestamp: DateTime.now(),
          ),
        );

        i++;
        scheduleNext();
      });
    }

    scheduleNext();
  }

  /// Returns the number of RFID attempts used so far.
  int get rfidAttempts => _rfidAttempts;

  /// Maximum allowed RFID attempts.
  int get maxRfidAttempts => kMaxRfidAttempts;

  void simulateOutOfStock(String orderId) {
    _stepTimer?.cancel();
    _paused = true;
    _status = _status.copyWith(
      missionState: MissionState.failed,
      faultType: FaultType.outOfStock,
      clearActiveOrder: true,
    );
    _emitStatus();
  }

  void resetFault() {
    if (!_paused) {
      _status = _status.copyWith(faultType: FaultType.none);
      _emitStatus();
      return;
    }

    // Resume from the state before the fault
    _paused = false;
    final resumeState = _preBlockState ?? _status.missionState;
    _preBlockState = null;

    _status = _status.copyWith(
      missionState: resumeState,
      faultType: FaultType.none,
    );
    _emitStatus();

    final orderId = _activeMissionOrderId;
    if (orderId != null) {
      _emitMission(
        MissionUpdate(
          orderId: orderId,
          state: resumeState,
          message: 'Fault cleared - mission resumed.',
          timestamp: DateTime.now(),
        ),
      );
      // Re-schedule the next step from where we left off
      _scheduleNextStep(orderId);
    }
  }

  void dispose() {
    _batteryTimer?.cancel();
    _stepTimer?.cancel();
    _statusController.close();
    _missionController.close();
    _rfidController.close();
  }
}
