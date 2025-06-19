import '../../core/api/api_client.dart';
import '../auth/auth_service.dart';
import 'dart:convert';

class ServiceService {
  final ApiClient _api = ApiClient(baseUrl: 'http://localhost:8080/api');

  Future<List<Map<String, dynamic>>> fetchServicos() async {
    final token = await AuthService().getToken();
    final response = await _api.get('/veterinario/servicos', headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    } else {
      throw Exception('Erro ao buscar serviços: ${response.body}');
    }
  }

  Future<void> cadastrarServico(Map<String, dynamic> servico) async {
    final token = await AuthService().getToken();
    final response = await _api.post('/veterinario/servicos',
      body: jsonEncode(servico),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Erro ao cadastrar serviço: ${response.body}');
    }
  }

  Future<void> editarServico(String id, Map<String, dynamic> servico) async {
    final token = await AuthService().getToken();
    final response = await _api.post('/veterinario/servicos/$id',
      body: jsonEncode(servico),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Erro ao editar serviço: ${response.body}');
    }
  }

  Future<void> removerServico(String id) async {
    final token = await AuthService().getToken();
    final response = await _api.get('/veterinario/servicos/$id/delete', headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });
    if (response.statusCode != 200) {
      throw Exception('Erro ao remover serviço: ${response.body}');
    }
  }
} 