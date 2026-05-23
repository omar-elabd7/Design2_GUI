import '../models/product.dart';

abstract interface class ProductRepository {
  Future<List<Product>> getProducts();
  Future<Product?> getProductById(String id);
  Future<void> decrementStock(String productId, int quantity);
}
