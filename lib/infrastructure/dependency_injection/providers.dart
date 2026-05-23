import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/repositories/auth_repository.dart';
import '../../shared/repositories/product_repository.dart';
import '../../shared/repositories/order_repository.dart';
import '../../shared/repositories/robot_repository.dart';
import '../../shared/repositories/worker_control_repository.dart';
import '../data_sources/mock/mock_auth_data_source.dart';
import '../data_sources/mock/mock_product_data_source.dart';
import '../data_sources/mock/mock_order_data_source.dart';
import '../data_sources/mock/mock_robot_data_source.dart';
import '../data_sources/mock/mock_worker_control_data_source.dart';
import '../repositories/auth_repository_impl.dart';
import '../repositories/product_repository_impl.dart';
import '../repositories/order_repository_impl.dart';
import '../repositories/robot_repository_impl.dart';
import '../repositories/worker_control_repository_impl.dart';

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

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(mockAuthDataSourceProvider));
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(ref.watch(mockProductDataSourceProvider));
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepositoryImpl(ref.watch(mockOrderDataSourceProvider));
});

final robotRepositoryProvider = Provider<RobotRepository>((ref) {
  return RobotRepositoryImpl(ref.watch(mockRobotDataSourceProvider));
});

final workerControlRepositoryProvider = Provider<WorkerControlRepository>((ref) {
  return WorkerControlRepositoryImpl(
      ref.watch(mockWorkerControlDataSourceProvider));
});
