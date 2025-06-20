import 'dart:convert';
import 'package:petconnect_frontend/core/api/api_client.dart';
import 'package:petconnect_frontend/core/api/endpoints.dart';
import 'package:petconnect_frontend/core/models/produto.dart';

class ProductService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Produto>> getProducts() async {
    final response = await _apiClient.get(Endpoints.produtos);

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);

      if (responseBody['success'] == true && responseBody['data'] != null) {
        // A API pode ou não ter paginação, vamos tratar os dois casos.
        dynamic data = responseBody['data'];
        if (data is Map && data.containsKey('content')) {
          final List<dynamic> productList = data['content'];
          return productList.map((json) => Produto.fromJson(json)).toList();
        } else if (data is List) {
           return data.map((json) => Produto.fromJson(json as Map<String, dynamic>)).toList();
        } else {
           throw Exception('Formato de dados de produtos inesperado.');
        }
      } else {
        throw Exception(responseBody['message'] ?? 'Falha ao buscar produtos.');
      }
    } else {
      throw Exception('Erro ao buscar produtos.');
    }
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