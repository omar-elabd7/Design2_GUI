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
      name: 'Banana',
      price: 3.0,
      stock: 15,
      imageUrl: '',
      unit: 'kg',
      category: 'Tropical',
      description: 'Sweet & Creamy',
      emoji: '🍌',
    ),
    const Product(
      id: 'prod_003',
      name: 'Orange',
      price: 4.5,
      stock: 10,
      imageUrl: '',
      unit: 'kg',
      category: 'Citrus',
      description: 'Sweet & Fresh',
      emoji: '🍊',
    ),
    const Product(
      id: 'prod_004',
      name: 'Mango',
      price: 8.0,
      stock: 8,
      imageUrl: '',
      unit: 'kg',
      category: 'Tropical',
      description: 'Rich & Fragrant',
      emoji: '🥭',
    ),
    const Product(
      id: 'prod_005',
      name: 'Grapes',
      price: 12.0,
      stock: 5,
      imageUrl: '',
      unit: 'kg',
      category: 'Berries',
      description: 'Plump & Sweet',
      emoji: '🍇',
    ),
    const Product(
      id: 'prod_006',
      name: 'Strawberry',
      price: 15.0,
      stock: 0,
      imageUrl: '',
      unit: 'pack',
      category: 'Berries',
      description: 'Fragrant & Bright',
      emoji: '🍓',
    ),
    const Product(
      id: 'prod_007',
      name: 'Watermelon',
      price: 6.0,
      stock: 4,
      imageUrl: '',
      unit: 'piece',
      category: 'Seasonal',
      description: 'Cool & Hydrating',
      emoji: '🍉',
    ),
    const Product(
      id: 'prod_008',
      name: 'Pineapple',
      price: 9.0,
      stock: 6,
      imageUrl: '',
      unit: 'piece',
      category: 'Tropical',
      description: 'Tangy & Tropical',
      emoji: '🍍',
    ),
    const Product(
      id: 'prod_009',
      name: 'Lemon',
      price: 2.5,
      stock: 25,
      imageUrl: '',
      unit: 'kg',
      category: 'Citrus',
      description: 'Zesty & Tart',
      emoji: '🍋',
    ),
    const Product(
      id: 'prod_010',
      name: 'Peach',
      price: 7.0,
      stock: 3,
      imageUrl: '',
      unit: 'kg',
      category: 'Seasonal',
      description: 'Soft & Velvety',
      emoji: '🍑',
    ),
    const Product(
      id: 'prod_011',
      name: 'Cherry',
      price: 18.0,
      stock: 2,
      imageUrl: '',
      unit: 'pack',
      category: 'Berries',
      description: 'Bold & Tart',
      emoji: '🍒',
    ),
    const Product(
      id: 'prod_012',
      name: 'Kiwi',
      price: 6.5,
      stock: 12,
      imageUrl: '',
      unit: 'kg',
      category: 'Tropical',
      description: 'Tangy & Bright',
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
