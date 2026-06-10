import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/repositories/auth_repository.dart';
import '../../shared/repositories/product_repository.dart';
import '../../shared/repositories/order_repository.dart';
import '../../shared/repositories/robot_repository.dart';
import '../../shared/repositories/worker_control_repository.dart';
import '../../core/constants/api_constants.dart';
// Mock sources
import '../data_sources/mock/mock_auth_data_source.dart';
import '../data_sources/mock/mock_product_data_source.dart';
import '../data_sources/mock/mock_order_data_source.dart';
import '../data_sources/mock/mock_robot_data_source.dart';
import '../data_sources/mock/mock_worker_control_data_source.dart';
// Live sources
import '../data_sources/live/live_auth_data_source.dart';
import '../data_sources/live/live_product_data_source.dart';
import '../data_sources/live/live_order_data_source.dart';
import '../data_sources/live/live_robot_repository_impl.dart';
import '../data_sources/realtime/websocket_client.dart';
// Repository implementations
import '../repositories/auth_repository_impl.dart';
import '../repositories/live_auth_repository_impl.dart';
import '../repositories/product_repository_impl.dart';
import '../repositories/live_product_repository_impl.dart';
import '../repositories/order_repository_impl.dart';
import '../repositories/live_order_repository_impl.dart';
import '../repositories/robot_repository_impl.dart';
import '../repositories/worker_control_repository_impl.dart';
import '../repositories/live_worker_control_repository_impl.dart';
import '../data_sources/live/live_worker_control_data_source.dart';

// ─── WebSocket Client (live mode only) ────────────────────────────────────────
final webSocketClientProvider = Provider<WebSocketClient>((ref) {
  final client = WebSocketClient();
  ref.onDispose(client.dispose);
  // Auto-connect when first accessed
  client.connect();
  return client;
});

// ─── Mock Data Sources ────────────────────────────────────────────────────────
final mockAuthDataSourceProvider = Provider<MockAuthDataSource>((ref) {
  return MockAuthDataSource();
});

final mockProductDataSourceProvider = Provider<MockProductDataSource>((ref) {
  return MockProductDataSource();
});

final mockOrderDataSourceProvider = Provider<MockOrderDataSource>((ref) {
  final productSource = ref.watch(mockProductDataSourceProvider);
  return MockOrderDataSource(productSource);
});

final mockRobotDataSourceProvider = Provider<MockRobotDataSource>((ref) {
  final source = MockRobotDataSource();
  ref.onDispose(source.dispose);
  return source;
});

final mockWorkerControlDataSourceProvider =
    Provider<MockWorkerControlDataSource>((ref) {
      final source = MockWorkerControlDataSource();
      ref.onDispose(source.dispose);
      return source;
    });

// ─── Live Data Sources ────────────────────────────────────────────────────────
final liveAuthDataSourceProvider = Provider<LiveAuthDataSource>((ref) {
  return LiveAuthDataSource();
});

final liveProductDataSourceProvider = Provider<LiveProductDataSource>((ref) {
  return LiveProductDataSource();
});

final liveOrderDataSourceProvider = Provider<LiveOrderDataSource>((ref) {
  return LiveOrderDataSource();
});

// ─── Repositories  (auto-switch via kUseLiveBackend) ─────────────────────────

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (kUseLiveBackend) {
    return LiveAuthRepositoryImpl(ref.watch(liveAuthDataSourceProvider));
  }
  return AuthRepositoryImpl(ref.watch(mockAuthDataSourceProvider));
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  if (kUseLiveBackend) {
    return LiveProductRepositoryImpl(ref.watch(liveProductDataSourceProvider));
  }
  return ProductRepositoryImpl(ref.watch(mockProductDataSourceProvider));
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  if (kUseLiveBackend) {
    return LiveOrderRepositoryImpl(ref.watch(liveOrderDataSourceProvider));
  }
  return OrderRepositoryImpl(ref.watch(mockOrderDataSourceProvider));
});

final robotRepositoryProvider = Provider<RobotRepository>((ref) {
  if (kUseLiveBackend) {
    return LiveRobotRepositoryImpl(ref.watch(webSocketClientProvider));
  }
  return RobotRepositoryImpl(ref.watch(mockRobotDataSourceProvider));
});

final workerControlRepositoryProvider = Provider<WorkerControlRepository>((
  ref,
) {
  if (kUseLiveBackend) {
    final ws = ref.watch(webSocketClientProvider);
    return LiveWorkerControlRepositoryImpl(LiveWorkerControlDataSource(ws));
  }
  return WorkerControlRepositoryImpl(
    ref.watch(mockWorkerControlDataSourceProvider),
  );
});
