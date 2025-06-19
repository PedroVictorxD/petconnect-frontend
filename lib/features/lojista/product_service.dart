import '../../core/api/api_client.dart';
import '../auth/auth_service.dart';
import '../../core/models/user.dart';
import 'dart:convert';

class ProductService {
  final ApiClient _api = ApiClient(baseUrl: 'http://localhost:8080/api');

  Future<List<Map<String, dynamic>>> fetchProdutos() async {
    final token = await AuthService().getToken();
    final response = await _api.get('/lojista/produtos', headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Ajuste conforme o formato real da resposta da API
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    } else {
      throw Exception('Erro ao buscar produtos: ${response.body}');
    }
  }

  Future<void> cadastrarProduto(Map<String, dynamic> produto) async {
    final token = await AuthService().getToken();
    final response = await _api.post('/lojista/produtos',
      body: jsonEncode(produto),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Erro ao cadastrar produto: ${response.body}');
    }
  }

  Future<void> editarProduto(String id, Map<String, dynamic> produto) async {
    final token = await AuthService().getToken();
    final response = await _api.post('/lojista/produtos/$id',
      body: jsonEncode(produto),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Erro ao editar produto: ${response.body}');
    }
  }

  Future<void> removerProduto(String id) async {
    final token = await AuthService().getToken();
    final response = await _api.get('/lojista/produtos/$id/delete', headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });
    if (response.statusCode != 200) {
      throw Exception('Erro ao remover produto: ${response.body}');
    }
  }

  // Métodos para cadastrar, editar e remover produtos podem ser adicionados aqui
} 