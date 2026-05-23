import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/splash/presentation/screens/transition_splash_screen.dart';
import '../../features/customer/presentation/screens/customer_home_screen_v1.dart';
import '../../features/customer/presentation/screens/cart_screen.dart';
import '../../features/customer/presentation/screens/checkout_screen.dart';
import '../../features/customer/presentation/screens/order_tracking_screen.dart';
import '../../features/worker/presentation/screens/worker_dashboard_screen.dart';
import '../../features/debug/presentation/screens/debug_panel_screen.dart';
import '../../features/shell/presentation/screens/customer_shell_screen.dart';
import '../../features/shell/presentation/screens/worker_shell_screen.dart';
import '../../shared/models/enums.dart';
import 'route_names.dart';

/// Notifier that the router listens to for redirect re-evaluation.
/// Fires whenever the auth state changes (login / logout / credit update).
final _routerNotifier = Provider<_AuthChangeNotifier>((ref) {
  final notifier = _AuthChangeNotifier();
  ref.listen(authStateProvider, (_, __) => notifier.notify());
  return notifier;
});

class _AuthChangeNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.read(_routerNotifier);

  return GoRouter(
    initialLocation: RouteNames.splash,
    refreshListenable: notifier,
    redirect: (context, state) {
      final user = ref.read(authStateProvider).user;
      final loc = state.matchedLocation;

      // Always allow splash / transition splash to run
      if (loc == RouteNames.splash ||
          loc == RouteNames.transitionSplash) {
        return null;
      }

      final isAuthPage = loc == RouteNames.login;

      if (user == null) {
        // If going to login already or transition splash, allow
        return isAuthPage ? null : RouteNames.login;
      }

      if (isAuthPage) {
        return user.role == UserRole.customer
            ? RouteNames.customerHome
            : RouteNames.workerDashboard;
      }

      if (user.role == UserRole.customer &&
          loc.startsWith('/worker')) {
        return RouteNames.customerHome;
      }

      if (user.role == UserRole.worker &&
          loc.startsWith('/customer')) {
        return RouteNames.workerDashboard;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.transitionSplash,
        builder: (context, state) {
          final nextRoute =
              state.uri.queryParameters['next'] ?? RouteNames.login;
          final subtitle =
              state.uri.queryParameters['subtitle'] ?? 'Preparing systems...';
          return TransitionSplashScreen(
            nextRoute: nextRoute,
            subtitle: subtitle,
          );
        },
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => CustomerShellScreen(child: child),
        routes: [
          GoRoute(
            path: RouteNames.customerHome,
            builder: (context, state) => const CustomerHomeScreen(),
          ),
          GoRoute(
            path: RouteNames.products,
            redirect: (_, __) => RouteNames.customerHome,
          ),
          GoRoute(
            path: RouteNames.cart,
            builder: (context, state) => const CartScreen(),
          ),
          GoRoute(
            path: RouteNames.checkout,
            builder: (context, state) => const CheckoutScreen(),
          ),
          GoRoute(
            path: '${RouteNames.orderTracking}/:orderId',
            builder: (context, state) {
              final orderId = state.pathParameters['orderId'] ?? '';
              return OrderTrackingScreen(orderId: orderId);
            },
          ),
          GoRoute(
            path: RouteNames.orderTracking,
            builder: (context, state) => const OrderTrackingScreen(orderId: ''),
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) => WorkerShellScreen(child: child),
        routes: [
          GoRoute(
            path: RouteNames.workerDashboard,
            builder: (context, state) => const WorkerDashboardScreen(),
          ),
          GoRoute(
            path: RouteNames.workerControl,
            builder: (context, state) => const WorkerDashboardScreen(),
          ),
          GoRoute(
            path: RouteNames.debug,
            builder: (context, state) => const DebugPanelScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Route not found: ${state.uri}'))),
  );
});
