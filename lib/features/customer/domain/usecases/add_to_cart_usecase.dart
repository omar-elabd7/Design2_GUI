import '../../../../shared/models/product.dart';
import '../../presentation/providers/cart_provider.dart';

class AddToCartUsecase {
  final CartNotifier _cart;

  AddToCartUsecase(this._cart);

  void call(Product product, int quantity) {
    _cart.addProduct(product);
  }
}
