import 'dart:convert';
import 'package:petconnect_frontend/core/api/api_client.dart';
import 'package:petconnect_frontend/core/api/endpoints.dart';
import 'package:petconnect_frontend/core/models/user.dart';

class UserService {
  final ApiClient _apiClient = ApiClient();

  Future<List<User>> getUsers() async {
    final response = await _apiClient.get(Endpoints.adminUsers);

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);

      if (responseBody['success'] == true && responseBody['data'] != null) {
        // A API retorna um objeto de paginação, os usuários estão em 'content'
        final List<dynamic> userList = responseBody['data']['content'];
        return userList.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception(responseBody['message'] ?? 'Falha ao buscar usuários.');
      }
    } else {
      throw Exception('Erro ao buscar usuários.');
    }
  }

  // Placeholder para futuras implementações
  Future<User> addUser(User user) async {
    // Lógica para chamar POST /api/admin/users
    await Future.delayed(const Duration(seconds: 1));
    return user;
  }

  Future<User> updateUser(String userId, User user) async {
    // Lógica para chamar PUT /api/admin/users/{userId}
    await Future.delayed(const Duration(seconds: 1));
    return user;
  }

  Future<void> deleteUser(String userId) async {
    // Lógica para chamar DELETE /api/admin/users/{userId}
    await Future.delayed(const Duration(seconds: 1));
  }
} 