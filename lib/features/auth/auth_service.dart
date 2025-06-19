import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';

class AuthResult {
  final bool success;
  final String? message;
  final String? route;
  AuthResult({required this.success, this.message, this.route});
}

class AuthService {
  final ApiClient _api = ApiClient(baseUrl: 'http://localhost:8080/api');
  Map<String, dynamic>? _currentUser;

  Map<String, dynamic>? get currentUser => _currentUser;

  Future<AuthResult> login(String email, String password) async {
    try {
      final response = await _api.post(Endpoints.login, body: jsonEncode({
        'username': email,
        'password': password,
      }), headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'] ?? data['accessToken'] ?? data['data']?['accessToken'];
        final user = data['user'] ?? data['data']?['user'];
        final userType = user?['userType'];
        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
        }
        _currentUser = user;
        String? route;
        switch (userType) {
          case 'ADMIN':
            route = '/admin';
            break;
          case 'TUTOR':
            route = '/tutor';
            break;
          case 'VETERINARIO':
            route = '/veterinario';
            break;
          case 'LOJISTA':
            route = '/lojista';
            break;
          default:
            return AuthResult(success: false, message: 'Tipo de usuário desconhecido.');
        }
        return AuthResult(success: true, route: route);
      } else {
        return AuthResult(success: false, message: 'Erro ao logar: ${response.body}');
      }
    } catch (e) {
      return AuthResult(success: false, message: 'Erro de conexão');
    }
  }

  Future<AuthResult> register(String fullName, String email, String password, String userType) async {
    try {
      final response = await _api.post(Endpoints.register, body: jsonEncode({
        'username': email,
        'email': email,
        'password': password,
        'fullName': fullName,
        'userType': userType,
      }), headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 201 || response.statusCode == 200) {
        return AuthResult(success: true, message: 'Cadastro realizado com sucesso!');
      } else {
        return AuthResult(success: false, message: 'Erro ao cadastrar: ${response.body}');
      }
    } catch (e) {
      return AuthResult(success: false, message: 'Erro de conexão');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, dynamic>?> getUserData() async {
    return _currentUser;
  }

  // Adicione métodos para recuperação de senha, etc.
} 