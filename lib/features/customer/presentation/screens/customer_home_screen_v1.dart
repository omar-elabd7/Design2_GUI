import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../robot_status/presentation/providers/robot_status_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/product_filter_provider.dart';
import '../widgets/customer_sidebar.dart';
import '../widgets/customer_header.dart';
import '../widgets/hero_delivery_banner.dart';
import '../widgets/search_filter_bar.dart';
import '../widgets/fruit_product_card.dart';
import '../widgets/cart_summary_card.dart';
import '../widgets/robot_live_status_card.dart';
import '../widgets/active_order_card.dart';
import '../widgets/rfid_security_card.dart';
import '../../../../shared/models/enums.dart';
import '../../../../shared/models/robot_status.dart';

class CustomerHomeScreen extends ConsumerWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider);
    final user = ref.watch(authStateProvider).user!;
    final robotStatus = ref.watch(robotStatusProvider);
    final cart = ref.watch(cartProvider);
    final filteredAsync = ref.watch(filteredProductsProvider);

    final bg = isDark ? AppColors.backgroundDark : AppColors.lightBackground;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // -- Subtle grid background -------------------------------------
          Positioned.fill(child: _GridBg(isDark: isDark)),

          // -- Ambient glows ----------------------------------------------
          Positioned(
            top: -100,
            right: -60,
            child: _AmbientGlow(
              radius: 280,
              color:
                  AppColors.primary.withValues(alpha: isDark ? 0.08 : 0.04),
            ),
          ),
          Positioned(
            bottom: -80,
            left: 200,
            child: _AmbientGlow(
              radius: 220,
              color: AppColors.primaryLight
                  .withValues(alpha: isDark ? 0.06 : 0.03),
            ),
          ),

          // -- 3-column layout --------------------------------------------
          Row(
            children: [
              // -- Column 1: Sidebar ------------------------------------
              CustomerSidebar(isDark: isDark),

              // -- Column 2: Main content -------------------------------
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 24, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting
                      CustomerHeader(
                        userName: user.name,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 22),

                      // Hero banner
                      HeroDeliveryBanner(
                        isDark: isDark,
                        isRobotOnline: robotStatus.mode == RobotMode.online ||
                            robotStatus.mode == RobotMode.autonomous,
                        avgDeliveryMin: 4,
                        onStartOrder: () {
                          // Scroll grid into view / focus search
                        },
                      ),
                      const SizedBox(height: 20),

                      // Search + Filters
                      SearchFilterBar(isDark: isDark),
                      const SizedBox(height: 16),

                      // Products grid
                      Expanded(
                        child: filteredAsync.when(
                          loading: () => const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                          error: (e, _) => Center(
                            child: Text(
                              'Error loading products: $e',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.danger,
                              ),
                            ),
                          ),
                          data: (products) {
                            if (products.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.search_off_rounded,
                                      size: 48,
                                      color: isDark
                                          ? AppColors.textMuted
                                          : AppColors.lightTextMuted,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No fruits match your search',
                                      style:
                                          AppTextStyles.bodyMedium.copyWith(
                                        color: isDark
                                            ? AppColors.textSecondary
                                            : AppColors.lightTextSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return GridView.builder(
                              padding: const EdgeInsets.only(bottom: 16),
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 230,
                                mainAxisSpacing: 14,
                                crossAxisSpacing: 14,
                                childAspectRatio: 0.68,
                              ),
                              itemCount: products.length,
                              itemBuilder: (context, index) {
                                final product = products[index];
                                final cartEntry = cart
                                    .where(
                                        (e) => e.product.id == product.id)
                                    .firstOrNull;
                                final qty = cartEntry?.quantity ?? 0;

                                return FruitProductCard(
                                  product: product,
                                  cartQuantity: qty,
                                  isDark: isDark,
                                  onAddToCart: () => ref
                                      .read(cartProvider.notifier)
                                      .addProduct(product),
                                  onIncrement: () => ref
                                      .read(cartProvider.notifier)
                                      .updateQuantity(
                                          product.id, qty + 1),
                                  onDecrement: () => ref
                                      .read(cartProvider.notifier)
                                      .updateQuantity(
                                          product.id, qty - 1),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // -- Column 3: Right status rail --------------------------
              _RightRail(
                isDark: isDark,
                credits: user.credits,
                rfidCardId: user.rfidCardId,
                robotStatus: robotStatus,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// RIGHT RAIL
// ---------------------------------------------------------------------------

class _RightRail extends StatelessWidget {
  const _RightRail({
    required this.isDark,
    required this.credits,
    required this.rfidCardId,
    required this.robotStatus,
  });

  final bool isDark;
  final double credits;
  final String rfidCardId;
  final RobotStatus robotStatus;

  @override
  Widget build(BuildContext context) {
    final borderColor =
        isDark ? const Color(0xFF1A2540) : AppColors.lightCardBorder;

    return Container(
      width: 340,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0B1120).withValues(alpha: 0.50)
            : AppColors.lightSurfaceElevated.withValues(alpha: 0.50),
        border: Border(left: BorderSide(color: borderColor, width: 1)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            // Cart Summary
            CartSummaryCard(isDark: isDark, credits: credits),
            const SizedBox(height: 14),

            // Robot Live Status
            RobotLiveStatusCard(status: robotStatus, isDark: isDark),
            const SizedBox(height: 14),

            // Active Order
            // TODO: Wire real active order from provider
            ActiveOrderCard(isDark: isDark, activeOrder: null),
            const SizedBox(height: 14),

            // RFID Security
            RfidSecurityCard(
              isDark: isDark,
              rfidCardId: rfidCardId,
              isLinked: rfidCardId.isNotEmpty,
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// GRID BACKGROUND
// ---------------------------------------------------------------------------

class _GridBg extends StatelessWidget {
  const _GridBg({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _GridPainter(isDark: isDark));
}

class _GridPainter extends CustomPainter {
  final bool isDark;
  _GridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppColors.primary.withValues(alpha: isDark ? 0.025 : 0.02)
      ..strokeWidth = 0.5;

    final dotPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: isDark ? 0.07 : 0.05);

    const sp = 60.0;
    for (double x = 0; x < size.width; x += sp) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 0; y < size.height; y += sp) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
    for (double x = 0; x < size.width; x += sp) {
      for (double y = 0; y < size.height; y += sp) {
        canvas.drawCircle(Offset(x, y), 1.2, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_GridPainter o) => o.isDark != isDark;
}

// ---------------------------------------------------------------------------
// AMBIENT GLOW
// ---------------------------------------------------------------------------

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({required this.radius, required this.color});
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius,
      height: radius,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}
