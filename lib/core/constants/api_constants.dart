const String kBaseUrl = 'http://192.168.1.100:8000';
const String kWebSocketUrl = 'ws://192.168.1.100:8000/ws';

const String kLoginEndpoint = '/auth/login';
const String kProductsEndpoint = '/products';
const String kOrdersEndpoint = '/orders';
const String kRobotModeEndpoint = '/robot/mode';
const String kStorageOpenEndpoint = '/robot/storage/open';
const String kStorageCloseEndpoint = '/robot/storage/close';

const String kWsTelemetryBattery = 'telemetry.battery';
const String kWsTelemetryMission = 'telemetry.mission';
const String kWsTelemetryFault = 'telemetry.fault';
const String kWsTelemetryPose = 'telemetry.pose';
const String kWsRobotRfidResult = 'robot.rfid_result';
const String kWsRobotStorageState = 'robot.storage_state';
const String kWsTeleopCommand = 'teleop.command';

const Duration kHttpTimeout = Duration(seconds: 10);
const Duration kWebSocketReconnectDelay = Duration(seconds: 3);
