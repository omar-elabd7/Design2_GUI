import '../../../shared/models/product.dart';

class MockProductDataSource {
  final List<Product> _products = [
    const Product(
      id: 'prod_001',
      name: 'Apple',
      price: 5.0,
      stock: 20,
      imageUrl: '',
      unit: 'kg',
      category: 'Classic',
      description: 'Crisp & Juicy',
      emoji: '🍎',
    ),
    const Product(
      id: 'prod_002',
      name: 'Orange',
      price: 4.5,
      stock: 20,
      imageUrl: '',
      unit: 'kg',
      category: 'Citrus',
      description: 'Sweet & Fresh',
      emoji: '🍊',
    ),
    const Product(
      id: 'prod_003',
      name: 'Kiwi',
      price: 6.0,
      stock: 20,
      imageUrl: '',
      unit: 'kg',
      category: 'Tropical',
      description: 'Tangy & Sweet',
      emoji: '🥝',
    ),
  ];

  Future<List<Product>> getProducts() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.unmodifiable(_products);
  }

  Future<Product?> getProductById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> decrementStock(String productId, int quantity) async {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final current = _products[index];
      final newStock = (current.stock - quantity).clamp(0, 9999);
      _products[index] = current.copyWith(stock: newStock);
    }
  }
}
