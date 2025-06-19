// api_client.dart
// Centraliza as requisições HTTP para a API

import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;
  final http.Client _client;

  ApiClient({required this.baseUrl}) : _client = http.Client();

  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await _client.get(url);
  }

  Future<http.Response> post(String endpoint, {Object? body}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await _client.post(url, body: body);
  }

  // Adicione outros métodos (put, delete) conforme necessário
} 