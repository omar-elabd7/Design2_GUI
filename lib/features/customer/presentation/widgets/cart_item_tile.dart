import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/formatters.dart';
import '../providers/cart_provider.dart';

class CartItemTile extends StatelessWidget {
  const CartItemTile({
    super.key,
    required this.entry,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  final CartEntry entry;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: kDefaultPadding,
        vertical: kSmallPadding + 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(kCardBorderRadius),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Text(
            _fruitEmoji(entry.product.name),
            style: const TextStyle(fontSize: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.product.name, style: AppTextStyles.headlineSmall),
                Text(
                  '${Formatters.formatPrice(entry.product.price)} / ${entry.product.unit}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: onDecrement,
                icon: const Icon(Icons.remove_circle_outline, size: 20),
                color: AppColors.textSecondary,
                splashRadius: 18,
              ),
              SizedBox(
                width: 32,
                child: Text(
                  '${entry.quantity}',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headlineSmall,
                ),
              ),
              IconButton(
                onPressed: onIncrement,
                icon: const Icon(Icons.add_circle_outline, size: 20),
                color: AppColors.primary,
                splashRadius: 18,
              ),
            ],
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 72,
            child: Text(
              Formatters.formatPrice(entry.subtotal),
              textAlign: TextAlign.end,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.secondary,
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline, size: 18),
            color: AppColors.danger,
            splashRadius: 16,
          ),
        ],
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
