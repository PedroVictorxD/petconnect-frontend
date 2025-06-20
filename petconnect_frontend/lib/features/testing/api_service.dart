import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://localhost:8080';

  Future<List<dynamic>> getProdutos(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/produtos'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json is Map && json['success'] == true && json['data'] != null) {
        return json['data'] as List;
      } else {
        throw Exception(json['message'] ?? 'Erro ao buscar produtos');
      }
    } else {
      throw Exception('Erro ao buscar produtos');
    }
  }

  Future<List<dynamic>> getServicos(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/servicos'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json is Map && json['success'] == true && json['data'] != null) {
        return json['data'] as List;
      } else {
        throw Exception(json['message'] ?? 'Erro ao buscar serviços');
      }
    } else {
      throw Exception('Erro ao buscar serviços');
    }
  }

  Future<void> cadastrarProduto({
    required String token,
    required String nome,
    required String descricao,
    required double preco,
    required String unidade,
    required String fotoUrl,
    required String lojistaId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/produtos'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "nome": nome,
        "description": descricao,
        "price": preco,
        "unitOfMeasure": unidade,
        "photoUrl": fotoUrl,
        "lojistaId": lojistaId,
      }),
    );
    final json = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (json['success'] == true) {
        // Produto cadastrado com sucesso
        return;
      } else {
        throw Exception(json['message'] ?? 'Erro ao cadastrar produto');
      }
    } else {
      throw Exception(json['message'] ?? 'Erro ao cadastrar produto');
    }
  }
} 