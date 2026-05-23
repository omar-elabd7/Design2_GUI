import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../shared/models/enums.dart';
import 'route_names.dart';

class RouteGuards {
  static String? requireAuth(WidgetRef ref, String targetRoute) {
    final authState = ref.read(authStateProvider);
    if (authState.user == null) {
      return RouteNames.login;
    }
    return null;
  }

  static String? requireCustomer(WidgetRef ref) {
    final authState = ref.read(authStateProvider);
    if (authState.user == null) return RouteNames.login;
    if (authState.user!.role != UserRole.customer) return RouteNames.workerDashboard;
    return null;
  }

  static String? requireWorker(WidgetRef ref) {
    final authState = ref.read(authStateProvider);
    if (authState.user == null) return RouteNames.login;
    if (authState.user!.role != UserRole.worker) return RouteNames.customerHome;
    return null;
  }
}
