import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/widgets/app_button.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_item_tile.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Your Cart'),
        backgroundColor: AppColors.backgroundMid,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: cart.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: AppColors.textMuted,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: AppTextStyles.headlineMedium,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add some fruits to get started',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(kLargePadding),
                    itemCount: cart.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: kSmallPadding),
                    itemBuilder: (context, index) {
                      final entry = cart[index];
                      return CartItemTile(
                        entry: entry,
                        onIncrement: () => ref
                            .read(cartProvider.notifier)
                            .updateQuantity(
                              entry.product.id,
                              entry.quantity + 1,
                            ),
                        onDecrement: () => ref
                            .read(cartProvider.notifier)
                            .updateQuantity(
                              entry.product.id,
                              entry.quantity - 1,
                            ),
                        onRemove: () => ref
                            .read(cartProvider.notifier)
                            .removeProduct(entry.product.id),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(kLargePadding),
                  decoration: const BoxDecoration(
                    color: AppColors.backgroundMid,
                    border: Border(top: BorderSide(color: AppColors.divider)),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total', style: AppTextStyles.labelMedium),
                          Text(
                            Formatters.formatPrice(total),
                            style: AppTextStyles.headlineLarge.copyWith(
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      AppButton(
                        label: 'Proceed to Checkout',
                        icon: Icons.payment,
                        onPressed: () => context.push(RouteNames.checkout),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
