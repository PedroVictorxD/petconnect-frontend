import 'dart:convert';
import 'package:petconnect_frontend/core/api/api_client.dart';
import 'package:petconnect_frontend/core/api/endpoints.dart';
import 'package:petconnect_frontend/core/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<User> login(String email, String password) async {
    final response = await _apiClient.post(
      Endpoints.login,
      body: {'email': email, 'password': password},
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);

      if (responseBody['success'] == true && responseBody['data'] != null) {
        final data = responseBody['data'];
        final accessToken = data['accessToken'];
        final userJson = data['user'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', accessToken);
        await prefs.setString('user', jsonEncode(userJson));

        return User.fromJson(userJson);
      } else {
        throw Exception(responseBody['message'] ?? 'Falha no login.');
      }
    } else {
      final responseBody = jsonDecode(response.body);
      throw Exception(responseBody['message'] ?? 'Erro ao conectar com o servidor.');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('user');
  }

  Future<String> register(Map<String, dynamic> userData) async {
    final response = await _apiClient.post(
      Endpoints.register,
      body: userData,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
       final responseBody = jsonDecode(response.body);
       return responseBody['message'] ?? 'Cadastro realizado com sucesso!';
    } else {
       final responseBody = jsonDecode(response.body);
       throw Exception(responseBody['message'] ?? 'Falha no cadastro.');
    }
  }

  Future<User?> getAuthenticatedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');
    if (userString != null) {
      return User.fromJson(jsonDecode(userString));
    }
    return null;
  }

   Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken') != null;
  }

  Future<Map<String, dynamic>> getTutorDashboard({int pagina = 0, int tamanho = 10}) async {
    final response = await _apiClient.get('/api/tutor/dashboard?pagina=$pagina&tamanho=$tamanho');
    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody['success'] == true && responseBody['data'] != null) {
        return responseBody['data'] as Map<String, dynamic>;
      } else {
        throw Exception(responseBody['message'] ?? 'Falha ao buscar dashboard do tutor.');
      }
    } else {
      throw Exception('Erro ao buscar dashboard do tutor.');
    }
  }
} 