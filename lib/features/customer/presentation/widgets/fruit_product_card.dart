import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/models/product.dart';

/// Premium dark-glass fruit card with hover effects.
///
/// Shows: emoji image, stock chip, name, category + description, price,
/// quantity stepper, add-to-cart button.
class FruitProductCard extends StatefulWidget {
  const FruitProductCard({
    super.key,
    required this.product,
    required this.cartQuantity,
    required this.isDark,
    required this.onAddToCart,
    required this.onIncrement,
    required this.onDecrement,
  });

  final Product product;
  final int cartQuantity;
  final bool isDark;
  final VoidCallback onAddToCart;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  State<FruitProductCard> createState() => _FruitProductCardState();
}

class _FruitProductCardState extends State<FruitProductCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final d = widget.isDark;
    final inCart = widget.cartQuantity > 0;

    final cardBg = d
        ? const Color(0xFF131B2E).withValues(alpha: 0.92)
        : Colors.white.withValues(alpha: 0.95);

    final borderColor = _hovering
        ? AppColors.primary.withValues(alpha: d ? 0.55 : 0.40)
        : (d ? AppColors.cardBorder : AppColors.lightCardBorder);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            if (_hovering)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: d ? 0.18 : 0.10),
                blurRadius: 28,
                offset: const Offset(0, 6),
              )
            else
              BoxShadow(
                color: Colors.black.withValues(alpha: d ? 0.25 : 0.05),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -- Stock chip + emoji image --------------------------------
              _StockRow(product: p, isDark: d),
              const SizedBox(height: 4),

              // -- Emoji image centered -----------------------------------
              Expanded(
                child: Center(
                  child: AnimatedScale(
                    scale: _hovering ? 1.08 : 1.0,
                    duration: const Duration(milliseconds: 220),
                    child: Text(
                      p.emoji,
                      style: const TextStyle(fontSize: 54),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // -- Name ---------------------------------------------------
              Text(
                p.name,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: d ? AppColors.textPrimary : AppColors.lightTextPrimary,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),

              // -- Category + description ---------------------------------
              Text(
                '${p.category} · ${p.description}',
                style: AppTextStyles.labelSmall.copyWith(
                  color:
                      d ? AppColors.textSecondary : AppColors.lightTextSecondary,
                  fontSize: 10,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),

              // -- Price --------------------------------------------------
              Text(
                '${p.price.toStringAsFixed(0)} EGP',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),

              // -- Action row ---------------------------------------------
              if (!p.isAvailable)
                _OutOfStockLabel(isDark: d)
              else if (inCart)
                _QuantityStepper(
                  quantity: widget.cartQuantity,
                  isDark: d,
                  onIncrement: widget.onIncrement,
                  onDecrement: widget.onDecrement,
                )
              else
                _AddToCartButton(isDark: d, onTap: widget.onAddToCart),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Stock chip row ----------------------------------------------------------

class _StockRow extends StatelessWidget {
  const _StockRow({required this.product, required this.isDark});
  final Product product;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color fgColor;
    if (!product.isAvailable) {
      bgColor = AppColors.danger.withValues(alpha: 0.12);
      fgColor = AppColors.danger;
    } else if (product.stock <= 3) {
      bgColor = AppColors.warning.withValues(alpha: 0.12);
      fgColor = AppColors.warning;
    } else {
      bgColor = AppColors.success.withValues(alpha: 0.12);
      fgColor = AppColors.success;
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            product.stockLabel,
            style: AppTextStyles.labelSmall.copyWith(
              color: fgColor,
              fontWeight: FontWeight.w600,
              fontSize: 9,
            ),
          ),
        ),
        const Spacer(),
        if (product.isAvailable)
          Text(
            '${product.stock} left',
            style: AppTextStyles.labelSmall.copyWith(
              color: isDark ? AppColors.textMuted : AppColors.lightTextMuted,
              fontSize: 9,
            ),
          ),
      ],
    );
  }
}

// --- Add to cart button ------------------------------------------------------

class _AddToCartButton extends StatefulWidget {
  const _AddToCartButton({required this.isDark, required this.onTap});
  final bool isDark;
  final VoidCallback onTap;

  @override
  State<_AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<_AddToCartButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _hover
                  ? [AppColors.primary, AppColors.primaryLight]
                  : [AppColors.primaryDark, AppColors.primary],
            ),
            borderRadius: BorderRadius.circular(11),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: _hover ? 0.40 : 0.22),
                blurRadius: _hover ? 14 : 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_shopping_cart_rounded, size: 14, color: Colors.white),
              SizedBox(width: 6),
              Text(
                'Add to Cart',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Quantity stepper --------------------------------------------------------

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.isDark,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int quantity;
  final bool isDark;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.primary.withValues(alpha: 0.10)
            : AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.30),
        ),
      ),
      child: Row(
        children: [
          // Decrement
          _StepperBtn(
            icon: quantity == 1
                ? Icons.delete_outline_rounded
                : Icons.remove_rounded,
            onTap: onDecrement,
            iconColor: quantity == 1 ? AppColors.danger : AppColors.primary,
          ),
          // Quantity display
          Expanded(
            child: Center(
              child: Text(
                '$quantity',
                style: AppTextStyles.labelLarge.copyWith(
                  color:
                      isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          // Increment
          _StepperBtn(
            icon: Icons.add_rounded,
            onTap: onIncrement,
            iconColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _StepperBtn extends StatelessWidget {
  const _StepperBtn({
    required this.icon,
    required this.onTap,
    required this.iconColor,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 40,
          height: 36,
          child: Icon(icon, size: 16, color: iconColor),
        ),
      ),
    );
  }
}

// --- Out of stock label ------------------------------------------------------

class _OutOfStockLabel extends StatelessWidget {
  const _OutOfStockLabel({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: AppColors.danger.withValues(alpha: 0.22),
        ),
      ),
      child: Center(
        child: Text(
          'Out of Stock',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.danger.withValues(alpha: 0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
