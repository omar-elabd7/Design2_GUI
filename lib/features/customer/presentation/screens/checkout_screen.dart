import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/glass_panel.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../shared/models/enums.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../robot_status/presentation/providers/robot_status_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/checkout_provider.dart';

// -------------------------------------------------------------------------------
// CheckoutScreen -- Premium glassmorphism checkout with dark/light theme
// -------------------------------------------------------------------------------

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen>
    with TickerProviderStateMixin {
  bool _hasNavigated = false;

  late final AnimationController _fadeCtrl;
  late final AnimationController _slideCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));

    _fadeCtrl.forward();
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider);
    final user = ref.watch(authStateProvider).user!;
    final cart = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);
    final checkoutState = ref.watch(checkoutProvider);
    final robotStatus = ref.watch(robotStatusProvider);
    final isRfidFaultActive = robotStatus.faultType == FaultType.rfidFailed;
    final canPay =
        user.credits >= total && cart.isNotEmpty && !isRfidFaultActive;

    // -- Error snackbar ----------------------------------------------------
    if (checkoutState.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(checkoutState.error!),
            backgroundColor: AppColors.danger,
          ),
        );
      });
    }

    // -- Navigate on success -----------------------------------------------
    if (checkoutState.order != null && !_hasNavigated) {
      _hasNavigated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final trackingPath =
            '${RouteNames.orderTracking}/${checkoutState.order!.id}';
        context.go(
          '${RouteNames.transitionSplash}'
          '?next=${Uri.encodeComponent(trackingPath)}'
          '&subtitle=Dispatching robot...',
        );
      });
    }

    final bg = isDark ? AppColors.backgroundDark : AppColors.lightBackground;
    final textPrimary = isDark
        ? AppColors.textPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.textSecondary
        : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // -- Background grid (dark only) ------------------------------
          if (isDark) const _NavGridBackground(),

          // -- Content --------------------------------------------------
          FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  children: [
                    // -- Top bar -----------------------------------------
                    _TopBar(isDark: isDark),
                    const SizedBox(height: 24),

                    // -- Main content row --------------------------------
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // -- LEFT: Order items -------------------------
                          Expanded(
                            flex: 5,
                            child: _OrderItemsPanel(
                              cart: cart,
                              isDark: isDark,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                            ),
                          ),
                          const SizedBox(width: 24),

                          // -- RIGHT: Payment summary --------------------
                          SizedBox(
                            width: 380,
                            child: _PaymentPanel(
                              userCredits: user.credits,
                              cart: cart,
                              total: total,
                              canPay: canPay,
                              isRfidFaultActive: isRfidFaultActive,
                              isLoading: checkoutState.isLoading,
                              isDark: isDark,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              onConfirm: () => ref
                                  .read(checkoutProvider.notifier)
                                  .placeOrder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// _TopBar
// -----------------------------------------------------------------------------
class _TopBar extends ConsumerWidget {
  const _TopBar({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textPrimary = isDark
        ? AppColors.textPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.textSecondary
        : AppColors.lightTextSecondary;

    return Row(
      children: [
        // Back button
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () =>
                context.canPop() ? context.pop() : context.go(RouteNames.cart),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? AppColors.cardBorder
                      : AppColors.lightCardBorder,
                ),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: textSecondary,
                size: 20,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Title
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Checkout',
              style: AppTextStyles.headlineLarge.copyWith(
                color: textPrimary,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Review your order before confirming',
              style: AppTextStyles.bodySmall.copyWith(color: textSecondary),
            ),
          ],
        ),
        const Spacer(),

        // Secure badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.success.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.verified_user_outlined,
                size: 16,
                color: AppColors.success,
              ),
              const SizedBox(width: 6),
              Text(
                'Secure Checkout',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // Theme toggle
        _ThemeToggle(isDark: isDark),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// _ThemeToggle
// -----------------------------------------------------------------------------
class _ThemeToggle extends ConsumerWidget {
  const _ThemeToggle({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref.read(themeModeProvider.notifier).state = !isDark,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.10),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              size: 18,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
            const SizedBox(width: 6),
            Text(
              isDark ? 'Dark' : 'Light',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// _OrderItemsPanel -- Left side: scrollable item table in glass panel
// -----------------------------------------------------------------------------
class _OrderItemsPanel extends StatelessWidget {
  const _OrderItemsPanel({
    required this.cart,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
  });

  final List<CartEntry> cart;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      isDark: isDark,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    size: 22,
                    color: AppColors.primaryLight,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Items',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: textPrimary,
                      ),
                    ),
                    Text(
                      '${cart.length} item${cart.length != 1 ? 's' : ''} in your basket',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Divider(
            height: 1,
            color: isDark ? AppColors.cardBorder : AppColors.lightCardBorder,
          ),

          // -- Column headers ------------------------------------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              children: [
                const SizedBox(width: 50),
                Expanded(
                  child: Text(
                    'Product',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: textSecondary,
                    ),
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Text(
                    'Unit',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: textSecondary,
                    ),
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: Text(
                    'Qty',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: textSecondary,
                    ),
                  ),
                ),
                SizedBox(
                  width: 90,
                  child: Text(
                    'Price',
                    textAlign: TextAlign.end,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: textSecondary,
                    ),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: Text(
                    'Subtotal',
                    textAlign: TextAlign.end,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: (isDark ? AppColors.cardBorder : AppColors.lightCardBorder)
                .withValues(alpha: 0.5),
          ),

          // -- Item rows -----------------------------------------------
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: cart.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                indent: 24,
                endIndent: 24,
                color:
                    (isDark ? AppColors.cardBorder : AppColors.lightCardBorder)
                        .withValues(alpha: 0.35),
              ),
              itemBuilder: (context, index) {
                final entry = cart[index];
                return _OrderItemRow(
                  entry: entry,
                  isDark: isDark,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// _OrderItemRow -- Single item row
// -----------------------------------------------------------------------------
class _OrderItemRow extends StatelessWidget {
  const _OrderItemRow({
    required this.entry,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
  });

  final CartEntry entry;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    final product = entry.product;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        children: [
          // Emoji avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              _fruitEmoji(product.name),
              style: const TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(width: 6),

          // Name + category
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: textPrimary,
                    fontSize: 14,
                  ),
                ),
                Text(
                  product.category,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          // Unit
          SizedBox(
            width: 60,
            child: Text(
              product.unit,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(color: textSecondary),
            ),
          ),

          // Quantity badge
          SizedBox(
            width: 50,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${entry.quantity}',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primaryLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),

          // Unit price
          SizedBox(
            width: 90,
            child: Text(
              Formatters.formatPrice(product.price),
              textAlign: TextAlign.end,
              style: AppTextStyles.bodySmall.copyWith(color: textSecondary),
            ),
          ),

          // Subtotal
          SizedBox(
            width: 100,
            child: Text(
              Formatters.formatPrice(entry.subtotal),
              textAlign: TextAlign.end,
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.secondary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// _PaymentPanel -- Right side: wallet, breakdown, confirm
// -----------------------------------------------------------------------------
class _PaymentPanel extends StatelessWidget {
  const _PaymentPanel({
    required this.userCredits,
    required this.cart,
    required this.total,
    required this.canPay,
    required this.isRfidFaultActive,
    required this.isLoading,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
    required this.onConfirm,
  });

  final double userCredits;
  final List<CartEntry> cart;
  final double total;
  final bool canPay;
  final bool isRfidFaultActive;
  final bool isLoading;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final remaining = userCredits - total;
    final hasEnough = userCredits >= total;
    final itemCount = cart.fold<int>(0, (sum, e) => sum + e.quantity);

    return Column(
      children: [
        // -- Wallet card ---------------------------------------------
        GlassPanel(
          isDark: isDark,
          glowColor: AppColors.primary,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 22,
                  color: AppColors.primaryLight,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Wallet',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Formatters.formatCredits(userCredits),
                      style: AppTextStyles.creditAmount.copyWith(
                        color: AppColors.primaryLight,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),
              // Status chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: (hasEnough ? AppColors.success : AppColors.danger)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  hasEnough ? 'Sufficient' : 'Low',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: hasEnough ? AppColors.success : AppColors.danger,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // -- Payment breakdown ---------------------------------------
        Expanded(
          child: GlassPanel(
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment Summary',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 20),

                _SummaryRow(
                  label: 'Items',
                  value: '$itemCount',
                  isDark: isDark,
                ),
                const SizedBox(height: 10),
                _SummaryRow(
                  label: 'Subtotal',
                  value: Formatters.formatPrice(total),
                  isDark: isDark,
                ),
                const SizedBox(height: 10),
                _SummaryRow(
                  label: 'Delivery Fee',
                  value: 'FREE',
                  isDark: isDark,
                  valueColor: AppColors.success,
                ),
                const SizedBox(height: 10),
                _SummaryRow(
                  label: 'Robot Service',
                  value: 'FREE',
                  isDark: isDark,
                  valueColor: AppColors.success,
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Divider(
                    color: isDark
                        ? AppColors.cardBorder
                        : AppColors.lightCardBorder,
                  ),
                ),

                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: textPrimary,
                      ),
                    ),
                    Text(
                      Formatters.formatPrice(total),
                      style: AppTextStyles.headlineLarge.copyWith(
                        color: AppColors.secondary,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // After payment
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'After Payment',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: textSecondary,
                      ),
                    ),
                    Text(
                      Formatters.formatCredits(remaining),
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: hasEnough ? textPrimary : AppColors.danger,
                      ),
                    ),
                  ],
                ),

                if (!hasEnough) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.danger.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          size: 18,
                          color: AppColors.danger,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Insufficient credits. You need ${Formatters.formatPrice(total - userCredits)} more.',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.danger,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const Spacer(),

                // ── RFID fault blocking banner ──────────────────────────
                if (isRfidFaultActive) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.danger.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.nfc_rounded,
                          size: 20,
                          color: AppColors.danger,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Orders temporarily blocked',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: AppColors.danger,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'An RFID fault is active. A storekeeper must clear the fault before new orders can be placed.',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.danger.withValues(
                                    alpha: 0.8,
                                  ),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // -- Delivery note ---------------------------------------
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.info.withValues(alpha: 0.20),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.smart_toy_outlined,
                        size: 18,
                        color: AppColors.info,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Pluto robot will deliver your order to the pickup zone.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.info,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // -- Confirm button --------------------------------------
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: Material(
                    color: canPay
                        ? AppColors.primary
                        : (isDark
                              ? AppColors.surface
                              : AppColors.lightInputFill),
                    borderRadius: BorderRadius.circular(14),
                    elevation: canPay ? 4 : 0,
                    shadowColor: AppColors.primary.withValues(alpha: 0.4),
                    child: InkWell(
                      onTap: canPay && !isLoading ? onConfirm : null,
                      borderRadius: BorderRadius.circular(14),
                      child: Center(
                        child: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle_rounded,
                                    size: 20,
                                    color: canPay
                                        ? Colors.white
                                        : textSecondary.withValues(alpha: 0.5),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Confirm & Pay',
                                    style: AppTextStyles.labelLarge.copyWith(
                                      color: canPay
                                          ? Colors.white
                                          : textSecondary.withValues(
                                              alpha: 0.5,
                                            ),
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Cancel link
                Center(
                  child: TextButton(
                    onPressed: () => context.canPop()
                        ? context.pop()
                        : context.go(RouteNames.cart),
                    child: Text(
                      'Cancel & return to cart',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: textSecondary,
                        decoration: TextDecoration.underline,
                        decorationColor: textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// _SummaryRow
// -----------------------------------------------------------------------------
class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.isDark,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool isDark;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final secColor = isDark
        ? AppColors.textSecondary
        : AppColors.lightTextSecondary;
    final priColor = isDark
        ? AppColors.textPrimary
        : AppColors.lightTextPrimary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium.copyWith(color: secColor)),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: valueColor ?? priColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// _NavGridBackground -- subtle navigation grid (dark mode only)
// -----------------------------------------------------------------------------
class _NavGridBackground extends StatelessWidget {
  const _NavGridBackground();

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(child: CustomPaint(painter: _NavGridPainter()));
  }
}

class _NavGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 40.0;
    final paint = Paint()
      ..color = const Color(0xFF1B8A5A).withValues(alpha: 0.04)
      ..strokeWidth = 0.5;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    final dotPaint = Paint()
      ..color = const Color(0xFF1B8A5A).withValues(alpha: 0.08);
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.2, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// -----------------------------------------------------------------------------
// Fruit emoji helper
// -----------------------------------------------------------------------------
String _fruitEmoji(String name) {
  switch (name.toLowerCase()) {
    case 'apple':
      return '🍎';
    case 'banana':
      return '🍌';
    case 'orange':
      return '🍊';
    case 'mango':
      return '🥭';
    case 'grapes':
      return '🍇';
    case 'strawberry':
      return '🍓';
    case 'watermelon':
      return '🍉';
    case 'pineapple':
      return '🍍';
    case 'lemon':
      return '🍋';
    case 'peach':
      return '🍑';
    case 'cherry':
      return '🍒';
    case 'kiwi':
      return '🥝';
    default:
      return '🛒';
  }
}
