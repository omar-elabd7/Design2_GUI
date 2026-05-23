import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Customer shell ? now a simple pass-through.
///
/// The new V1 screens (CustomerHomeScreen, etc.) handle their own
/// sidebar, header, and right rail internally.
class CustomerShellScreen extends ConsumerWidget {
  final Widget child;

  const CustomerShellScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return child;
  }
}

