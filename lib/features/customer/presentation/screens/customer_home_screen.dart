import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/customer_products_provider.dart';
import '../widgets/credit_card_widget.dart';
import '../widgets/product_tile.dart';
import 'cart_screen.dart';

class CustomerHomeScreen extends ConsumerWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user!;
    final productsAsync = ref.watch(customerProductsProvider);
    final cart = ref.watch(cartProvider);
    final cartCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Padding(
        padding: const EdgeInsets.all(kLargePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hello, ${user.name.split(' ').first}!',
                          style: AppTextStyles.displayMedium),
                      const SizedBox(height: 4),
                      Text('What fruits would you like today?',
                          style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                SizedBox(
                  width: 300,
                  height: 140,
                  child: CreditCardWidget(
                    name: user.name,
                    credits: user.credits,
                    rfidCardId: user.rfidCardId,
                  ),
                ),
              ],
            ),
            const SizedBox(height: kLargePadding),
            Row(
              children: [
                const Text('Available Fruits', style: AppTextStyles.headlineLarge),
                const Spacer(),
                if (cartCount > 0)
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    ),
                    icon: const Icon(Icons.shopping_cart, size: 18),
                    label: Text('Cart ($cartCount)'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: AppColors.textOnPrimary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: kDefaultPadding),
            Expanded(
              child: productsAsync.when(
                loading: () => const AppFullPageLoader(message: 'Loading products?'),
                error: (e, _) => Center(
                  child: Text('Error: $e',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.danger)),
                ),
                data: (products) => GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final cartEntry = cart
                        .where((e) => e.product.id == product.id)
                        .firstOrNull;
                    final qty = cartEntry?.quantity ?? 0;

                    return ProductTile(
                      product: product,
                      cartQuantity: qty,
                      onAddToCart: () =>
                          ref.read(cartProvider.notifier).addProduct(product),
                      onIncrement: () =>
                          ref.read(cartProvider.notifier).updateQuantity(
                                product.id,
                                qty + 1,
                              ),
                      onDecrement: () =>
                          ref.read(cartProvider.notifier).updateQuantity(
                                product.id,
                                qty - 1,
                              ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
