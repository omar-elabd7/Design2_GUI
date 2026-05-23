import '../../shared/repositories/product_repository.dart';
import '../../shared/models/product.dart';
import '../data_sources/mock/mock_product_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  final MockProductDataSource _mockDataSource;

  ProductRepositoryImpl(this._mockDataSource);

  @override
  Future<List<Product>> getProducts() => _mockDataSource.getProducts();

  @override
  Future<Product?> getProductById(String id) =>
      _mockDataSource.getProductById(id);

  @override
  Future<void> decrementStock(String productId, int quantity) =>
      _mockDataSource.decrementStock(productId, quantity);
}
