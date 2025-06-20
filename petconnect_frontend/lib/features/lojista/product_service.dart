import 'package:petconnect_frontend/core/api/api_client.dart';
import 'package:petconnect_frontend/core/models/produto.dart';

class ProductService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Produto>> getProducts() async {
    // Lógica para chamar GET /api/produtos
    await Future.delayed(const Duration(seconds: 1));
    print('Faking fetch for products...');
    return []; // Retorna lista vazia por enquanto
  }

  Future<Produto> addProduct(Produto product) async {
    // Lógica para chamar POST /api/produtos
    await Future.delayed(const Duration(seconds: 1));
    print('Faking add for product: ${product.nome}');
    return product;
  }

  Future<Produto> updateProduct(String productId, Produto product) async {
    // Lógica para chamar PUT /api/produtos/{productId}
    await Future.delayed(const Duration(seconds: 1));
    print('Faking update for product: ${product.nome}');
    return product;
  }

  Future<void> deleteProduct(String productId) async {
    // Lógica para chamar DELETE /api/produtos/{productId}
    await Future.delayed(const Duration(seconds: 1));
    print('Faking delete for product ID: $productId');
  }
} 