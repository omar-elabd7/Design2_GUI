import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../shared/models/product.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/errors/app_exceptions.dart';

class LiveProductDataSource {
  List<Product>? _cache;

  Future<List<Product>> getProducts() async {
    final res = await http
        .get(Uri.parse('$kBaseUrl$kProductsEndpoint'))
        .timeout(kHttpTimeout);

    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List<dynamic>;
      _cache = list
          .map((e) => Product.fromMap(e as Map<String, dynamic>))
          .toList();
      return _cache!;
    }
    throw const NetworkException('Failed to load products');
  }

  Future<Product?> getProductById(String id) async {
    final products = _cache ?? await getProducts();
    try {
      return products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Stock is managed server-side — no-op on client.
  Future<void> decrementStock(String productId, int quantity) async {}
}
