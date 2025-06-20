// endpoints.dart
// Centraliza os endpoints da API

class Endpoints {
  static const String baseUrl = 'http://localhost:8080';

  // Auth
  static const String login = '/api/auth/login';

  // Admin
  static const String adminDashboard = '/api/admin/dashboard';
  static const String adminUsers = '/api/admin/users';

  // Produtos
  static const String produtos = '/api/produtos';

  // Serviços
  static const String servicos = '/api/servicos';
} 