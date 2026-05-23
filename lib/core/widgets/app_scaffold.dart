import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.sidebar,
    this.topBar,
    this.backgroundColor,
  });

  final Widget body;
  final Widget? sidebar;
  final Widget? topBar;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.backgroundDark,
      body: Column(
        children: [
          if (topBar != null) topBar!,
          Expanded(
            child: Row(
              children: [
                if (sidebar != null) sidebar!,
                Expanded(child: body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
