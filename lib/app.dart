import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'features/robot_status/presentation/providers/robot_status_provider.dart';
import 'infrastructure/dependency_injection/providers.dart';

class RoboFruitApp extends ConsumerWidget {
  const RoboFruitApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final isDark = ref.watch(themeModeProvider);

    // Eagerly initialize the WebSocket connection and robot-status stream.
    // Reading these providers here creates them immediately on app start so
    // WS messages are never missed due to lazy initialization.
    ref.watch(webSocketClientProvider);
    ref.watch(robotStatusProvider);

    return MaterialApp.router(
      title: 'Pluto',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
    );
  }
}
