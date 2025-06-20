import 'dart:convert';
import 'package:petconnect_frontend/core/api/api_client.dart';
import 'package:petconnect_frontend/core/api/endpoints.dart';
import 'package:petconnect_frontend/core/models/servico.dart';

class ServiceService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Servico>> getServices() async {
    final response = await _apiClient.get(Endpoints.servicos);
    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody['success'] == true && responseBody['data'] != null) {
        dynamic data = responseBody['data'];
        if (data is Map && data.containsKey('content')) {
          final List<dynamic> serviceList = data['content'];
          return serviceList.map((json) => Servico.fromJson(json)).toList();
        } else if (data is List) {
          return data.map((json) => Servico.fromJson(json as Map<String, dynamic>)).toList();
        } else {
          throw Exception('Formato de dados de serviços inesperado.');
        }
      } else {
        throw Exception(responseBody['message'] ?? 'Falha ao buscar serviços.');
      }
    } else {
      throw Exception('Erro ao buscar serviços.');
    }
  }

  Future<Servico> addService(Servico servico) async {
    final response = await _apiClient.post(
      Endpoints.servicos,
      body: servico.toJson(),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseBody = jsonDecode(response.body);
      if (responseBody['success'] == true && responseBody['data'] != null) {
        return Servico.fromJson(responseBody['data']);
      } else {
        throw Exception(responseBody['message'] ?? 'Falha ao cadastrar serviço.');
      }
    } else {
      throw Exception('Erro ao cadastrar serviço.');
    }
  }

  Future<Servico> updateService(String serviceId, Servico servico) async {
    final response = await _apiClient.post(
      '${Endpoints.servicos}/$serviceId',
      body: servico.toJson(),
    );
    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody['success'] == true && responseBody['data'] != null) {
        return Servico.fromJson(responseBody['data']);
      } else {
        throw Exception(responseBody['message'] ?? 'Falha ao atualizar serviço.');
      }
    } else {
      throw Exception('Erro ao atualizar serviço.');
    }
  }

  Future<void> deleteService(String serviceId) async {
    final response = await _apiClient.post(
      '${Endpoints.servicos}/$serviceId/delete',
      body: {},
    );
    if (response.statusCode != 200) {
      throw Exception('Erro ao remover serviço.');
    }
  }

  Future<void> cadastrarVeterinarioDominio(Map<String, dynamic> payload) async {
    final response = await _apiClient.post(
      '/api/veterinario/veterinarios',
      body: payload,
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      final responseBody = jsonDecode(response.body);
      throw Exception(responseBody['message'] ?? 'Erro ao cadastrar veterinário de domínio.');
    }
  }

  Future<Map<String, dynamic>> getVeterinarioDashboard(String veterinarioId) async {
    final response = await _apiClient.get('/api/veterinario/dashboard/$veterinarioId');
    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody['success'] == true && responseBody['data'] != null) {
        return responseBody['data'] as Map<String, dynamic>;
      } else {
        throw Exception(responseBody['message'] ?? 'Falha ao buscar dashboard do veterinário.');
      }
    } else {
      throw Exception('Erro ao buscar dashboard do veterinário.');
    }
  }
} 