import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/product.dart';
import 'customer_products_provider.dart';

// -- Search query -------------------------------------------------------------

final searchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

// -- Category filter ----------------------------------------------------------

const kAllCategory = 'All';
const kProductCategories = [
  kAllCategory,
  'Citrus',
  'Tropical',
  'Berries',
  'Seasonal',
  'Classic',
];

final selectedCategoryProvider = StateProvider.autoDispose<String>(
  (ref) => kAllCategory,
);

// -- Sort ---------------------------------------------------------------------

enum ProductSort { priceAsc, priceDesc, popularity, availability }

final selectedSortProvider = StateProvider.autoDispose<ProductSort>(
  (ref) => ProductSort.popularity,
);

// -- Filtered + sorted products -----------------------------------------------

final filteredProductsProvider =
    Provider.autoDispose<AsyncValue<List<Product>>>((ref) {
      final productsAsync = ref.watch(customerProductsProvider);
      final query = ref.watch(searchQueryProvider).toLowerCase();
      final category = ref.watch(selectedCategoryProvider);
      final sort = ref.watch(selectedSortProvider);

      return productsAsync.whenData((products) {
        var filtered = products.toList();

        // Category filter
        if (category != kAllCategory) {
          filtered = filtered.where((p) => p.category == category).toList();
        }

        // Search filter
        if (query.isNotEmpty) {
          filtered = filtered.where((p) {
            return p.name.toLowerCase().contains(query) ||
                p.category.toLowerCase().contains(query) ||
                p.description.toLowerCase().contains(query);
          }).toList();
        }

        // Sort
        switch (sort) {
          case ProductSort.priceAsc:
            filtered.sort((a, b) => a.price.compareTo(b.price));
          case ProductSort.priceDesc:
            filtered.sort((a, b) => b.price.compareTo(a.price));
          case ProductSort.availability:
            filtered.sort((a, b) => b.stock.compareTo(a.stock));
          case ProductSort.popularity:
            // keep original order (mock popularity)
            break;
        }

        return filtered;
      });
    });
