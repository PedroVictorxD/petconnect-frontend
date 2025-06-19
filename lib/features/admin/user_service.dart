import '../../core/api/api_client.dart';
import '../auth/auth_service.dart';
import 'dart:convert';

class UserService {
  final ApiClient _api = ApiClient(baseUrl: 'http://localhost:8080/api');

  Future<List<Map<String, dynamic>>> fetchUsers() async {
    final token = await AuthService().getToken();
    final response = await _api.get('/admin/users', headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    } else {
      throw Exception('Erro ao buscar usuários: ${response.body}');
    }
  }

  Future<void> createUser(Map<String, dynamic> user) async {
    final token = await AuthService().getToken();
    final response = await _api.post('/admin/users',
      body: jsonEncode(user),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Erro ao criar usuário: ${response.body}');
    }
  }

  Future<void> updateUser(String id, Map<String, dynamic> user) async {
    final token = await AuthService().getToken();
    final response = await _api.post('/admin/users/$id',
      body: jsonEncode(user),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar usuário: ${response.body}');
    }
  }

  Future<void> deleteUser(String id) async {
    final token = await AuthService().getToken();
    final response = await _api.get('/admin/users/$id/delete', headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });
    if (response.statusCode != 200) {
      throw Exception('Erro ao deletar usuário: ${response.body}');
    }
  }
} 