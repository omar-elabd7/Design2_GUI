import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/product_filter_provider.dart';

/// Search bar + category chips + sort dropdown row.
class SearchFilterBar extends ConsumerStatefulWidget {
  const SearchFilterBar({super.key, required this.isDark});
  final bool isDark;

  @override
  ConsumerState<SearchFilterBar> createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends ConsumerState<SearchFilterBar> {
  late final TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(selectedCategoryProvider);
    final sort = ref.watch(selectedSortProvider);
    final d = widget.isDark;

    final inputFill = d ? const Color(0xFF141D2E) : AppColors.lightInputFill;
    final inputBorder = d ? AppColors.cardBorder : AppColors.lightInputBorder;
    final textColor = d ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final hintColor = d ? AppColors.textMuted : AppColors.lightTextMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // -- Search + Sort row --------------------------------------------
        Row(
          children: [
            // Search field
            Expanded(
              child: SizedBox(
                height: 42,
                child: TextField(
                  controller: _searchCtrl,
                  style: AppTextStyles.bodyMedium.copyWith(color: textColor),
                  onChanged: (v) =>
                      ref.read(searchQueryProvider.notifier).state = v,
                  decoration: InputDecoration(
                    hintText: 'Search fruits...',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: hintColor,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: hintColor,
                      size: 18,
                    ),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.close, size: 16, color: hintColor),
                            onPressed: () {
                              _searchCtrl.clear();
                              ref.read(searchQueryProvider.notifier).state = '';
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: inputFill,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: inputBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: inputBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Sort dropdown
            _SortDropdown(sort: sort, isDark: d),
          ],
        ),

        const SizedBox(height: 12),

        // -- Category chips -----------------------------------------------
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: kProductCategories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final cat = kProductCategories[i];
              final isActive = cat == selected;
              return _CategoryChip(
                label: cat,
                isActive: isActive,
                isDark: d,
                onTap: () =>
                    ref.read(selectedCategoryProvider.notifier).state = cat,
              );
            },
          ),
        ),
      ],
    );
  }
}

// --- Category chip -----------------------------------------------------------

class _CategoryChip extends StatefulWidget {
  const _CategoryChip({
    required this.label,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  @override
  State<_CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<_CategoryChip> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          decoration: BoxDecoration(
            color: widget.isActive
                ? AppColors.primary
                : _hovering
                    ? AppColors.primary.withValues(alpha: 0.10)
                    : (widget.isDark
                        ? const Color(0xFF141D2E)
                        : AppColors.lightInputFill),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isActive
                  ? AppColors.primary
                  : (widget.isDark
                      ? AppColors.cardBorder
                      : AppColors.lightInputBorder),
            ),
          ),
          child: Center(
            child: Text(
              widget.label,
              style: AppTextStyles.labelMedium.copyWith(
                color: widget.isActive
                    ? Colors.white
                    : (widget.isDark
                        ? AppColors.textSecondary
                        : AppColors.lightTextSecondary),
                fontWeight:
                    widget.isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- Sort dropdown -----------------------------------------------------------

class _SortDropdown extends ConsumerWidget {
  const _SortDropdown({required this.sort, required this.isDark});
  final ProductSort sort;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bg = isDark ? const Color(0xFF141D2E) : AppColors.lightInputFill;
    final border = isDark ? AppColors.cardBorder : AppColors.lightInputBorder;
    final textColor =
        isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ProductSort>(
          value: sort,
          icon: Icon(Icons.unfold_more_rounded, size: 16, color: textColor),
          dropdownColor: isDark ? const Color(0xFF1A2535) : Colors.white,
          style: AppTextStyles.labelMedium.copyWith(color: textColor),
          items: const [
            DropdownMenuItem(
              value: ProductSort.popularity,
              child: Text('Popularity'),
            ),
            DropdownMenuItem(
              value: ProductSort.priceAsc,
              child: Text('Price ...'),
            ),
            DropdownMenuItem(
              value: ProductSort.priceDesc,
              child: Text('Price ...'),
            ),
            DropdownMenuItem(
              value: ProductSort.availability,
              child: Text('Availability'),
            ),
          ],
          onChanged: (v) {
            if (v != null) {
              ref.read(selectedSortProvider.notifier).state = v;
            }
          },
        ),
      ),
    );
  }
}
