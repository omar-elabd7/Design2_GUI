import '../../../../shared/models/product.dart';
import '../../../../shared/repositories/product_repository.dart';

class GetProductsUsecase {
  final ProductRepository _repo;

  GetProductsUsecase(this._repo);

  Future<List<Product>> call() => _repo.getProducts();
}
