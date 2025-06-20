// api_client.dart
// Centraliza as requisições HTTP para a API

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'endpoints.dart';

class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<http.Response> post(String endpoint, {required Map<String, dynamic> body}) async {
    final url = Uri.parse('${Endpoints.baseUrl}$endpoint');
    final headers = await _getHeaders();

    return _client.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('${Endpoints.baseUrl}$endpoint');
    final headers = await _getHeaders();

    return _client.get(
      url,
      headers: headers,
    );
  }

  // Adicione outros métodos (put, delete) conforme necessário
} 