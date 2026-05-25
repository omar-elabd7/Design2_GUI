import '../../shared/repositories/product_repository.dart';
import '../../shared/models/product.dart';
import '../data_sources/live/live_product_data_source.dart';

class LiveProductRepositoryImpl implements ProductRepository {
  final LiveProductDataSource _dataSource;

  LiveProductRepositoryImpl(this._dataSource);

  @override
  Future<List<Product>> getProducts() => _dataSource.getProducts();

  @override
  Future<Product?> getProductById(String id) => _dataSource.getProductById(id);

  @override
  Future<void> decrementStock(String productId, int quantity) =>
      _dataSource.decrementStock(productId, quantity);
}
