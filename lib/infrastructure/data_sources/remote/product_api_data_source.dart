import '../../../shared/models/product.dart';
import '../../../core/errors/app_exceptions.dart';

class ProductApiDataSource {
  Future<List<Product>> getProducts() async {
    throw const NetworkException('Real backend not connected yet');
  }

  Future<Product?> getProductById(String id) async {
    throw const NetworkException('Real backend not connected yet');
  }

  Future<void> decrementStock(String productId, int quantity) async {
    throw const NetworkException('Real backend not connected yet');
  }
}
