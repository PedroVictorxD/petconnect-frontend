import 'package:petconnect_frontend/core/api/api_client.dart';
import 'package:petconnect_frontend/core/models/servico.dart';

class ServiceService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Servico>> getServices() async {
    // Lógica para chamar GET /api/servicos
    await Future.delayed(const Duration(seconds: 1));
    print('Faking fetch for services...');
    return []; // Retorna lista vazia por enquanto
  }

  Future<Servico> addService(Servico servico) async {
    // Lógica para chamar POST /api/servicos
    await Future.delayed(const Duration(seconds: 1));
    print('Faking add for service: ${servico.nome}');
    return servico;
  }

  Future<Servico> updateService(String serviceId, Servico servico) async {
    // Lógica para chamar PUT /api/servicos/{serviceId}
    await Future.delayed(const Duration(seconds: 1));
    print('Faking update for service: ${servico.nome}');
    return servico;
  }

  Future<void> deleteService(String serviceId) async {
    // Lógica para chamar DELETE /api/servicos/{serviceId}
    await Future.delayed(const Duration(seconds: 1));
    print('Faking delete for service ID: $serviceId');
  }
} 