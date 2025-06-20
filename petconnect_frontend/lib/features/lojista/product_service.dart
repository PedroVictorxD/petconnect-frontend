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
    final response = await _apiClient.post(
      Endpoints.produtos,
      body: product.toJson(),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseBody = jsonDecode(response.body);
      if (responseBody['success'] == true && responseBody['data'] != null) {
        return Produto.fromJson(responseBody['data']);
      } else {
        throw Exception(responseBody['message'] ?? 'Falha ao cadastrar produto.');
      }
    } else {
      throw Exception('Erro ao cadastrar produto.');
    }
  }

  Future<Produto> updateProduct(String productId, Produto product) async {
    final response = await _apiClient.post(
      '${Endpoints.produtos}/$productId',
      body: product.toJson(),
    );
    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody['success'] == true && responseBody['data'] != null) {
        return Produto.fromJson(responseBody['data']);
      } else {
        throw Exception(responseBody['message'] ?? 'Falha ao atualizar produto.');
      }
    } else {
      throw Exception('Erro ao atualizar produto.');
    }
  }

  Future<void> deleteProduct(String productId) async {
    final response = await _apiClient.post(
      '${Endpoints.produtos}/$productId/delete',
      body: {},
    );
    if (response.statusCode != 200) {
      throw Exception('Erro ao remover produto.');
    }
  }

  Future<void> cadastrarLojistaDominio(Map<String, dynamic> payload) async {
    final response = await _apiClient.post(
      '/api/lojistas',
      body: payload,
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      final responseBody = jsonDecode(response.body);
      throw Exception(responseBody['message'] ?? 'Erro ao cadastrar lojista de domínio.');
    }
  }
} 