import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/models/product.dart';
import '../../../../core/widgets/app_button.dart';

class ProductTile extends StatelessWidget {
  const ProductTile({
    super.key,
    required this.product,
    required this.onAddToCart,
    this.cartQuantity = 0,
    this.onIncrement,
    this.onDecrement,
  });

  final Product product;
  final VoidCallback onAddToCart;
  final int cartQuantity;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(kCardBorderRadius),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: Text(
                  _fruitEmoji(product.name),
                  style: const TextStyle(fontSize: 48),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(product.name, style: AppTextStyles.headlineSmall),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Formatters.formatPrice(product.price),
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.secondary),
                ),
                Text(
                  'per ${product.unit}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (!product.isAvailable)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Out of Stock',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.danger),
                ),
              )
            else
              Text(
                'In stock: ${product.stock}',
                style: AppTextStyles.labelSmall
                    .copyWith(color: AppColors.success),
              ),
            const SizedBox(height: 10),
            if (cartQuantity == 0)
              AppButton(
                label: 'Add to Cart',
                onPressed: product.isAvailable ? onAddToCart : null,
                icon: Icons.add_shopping_cart,
                isExpanded: true,
                small: true,
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton.filled(
                    onPressed: onDecrement,
                    icon: const Icon(Icons.remove, size: 16),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      foregroundColor: AppColors.textPrimary,
                      minimumSize: const Size(32, 32),
                    ),
                  ),
                  Text('$cartQuantity', style: AppTextStyles.headlineSmall),
                  IconButton.filled(
                    onPressed: onIncrement,
                    icon: const Icon(Icons.add, size: 16),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                      minimumSize: const Size(32, 32),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _fruitEmoji(String name) {
    switch (name.toLowerCase()) {
      case 'apple':
        return '';
      case 'banana':
        return '';
      case 'orange':
        return '';
      case 'mango':
        return '';
      case 'grapes':
        return '';
      case 'strawberry':
        return '';
      case 'watermelon':
        return '';
      case 'pineapple':
        return '';
      default:
        return '';
    }
  }
}
