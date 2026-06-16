// ─── Backend Mode ─────────────────────────────────────────────────────────────
/// true  = talk to real Pi backend on Wi-Fi  (production)
/// false = talk to sim_server.py on localhost (offline dev / testing)
const bool kUseLiveBackend = true;

// ─── URLs (auto-selected by flag above) ───────────────────────────────────────
const String _kSimBase = 'http://localhost:8000';
const String _kPiBase = 'http://172.20.10.2:8000';

const String kBaseUrl = kUseLiveBackend ? _kPiBase : _kSimBase;
const String kWebSocketUrl = kUseLiveBackend
    ? 'ws://172.20.10.2:8000/ws'
    : 'ws://localhost:8000/ws';

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
