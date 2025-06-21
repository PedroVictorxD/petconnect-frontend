import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/pet.dart';
import '../models/product.dart';
import '../models/vet_service.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080';
  
  // Headers padrão
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };

  // Autenticação
  static Future<User?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Erro no login: $e');
      return null;
    }
  }

  // Usuários
  static Future<User?> createTutor(User user) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/tutores'),
        headers: _headers,
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Erro ao criar tutor: $e');
      return null;
    }
  }

  static Future<User?> createVeterinario(User user) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/veterinarios'),
        headers: _headers,
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Erro ao criar veterinário: $e');
      return null;
    }
  }

  static Future<User?> createLojista(User user) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/lojistas'),
        headers: _headers,
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Erro ao criar lojista: $e');
      return null;
    }
  }

  static Future<User?> createAdmin(User user) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admins'),
        headers: _headers,
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Erro ao criar admin: $e');
      return null;
    }
  }

  static Future<List<User>> getAllUsers() async {
    try {
      final responses = await Future.wait([
        http.get(Uri.parse('$baseUrl/admins'), headers: _headers),
        http.get(Uri.parse('$baseUrl/api/tutores'), headers: _headers),
        http.get(Uri.parse('$baseUrl/api/lojistas'), headers: _headers),
        http.get(Uri.parse('$baseUrl/api/veterinarios'), headers: _headers),
      ]);

      List<User> allUsers = [];
      for (var response in responses) {
        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          allUsers.addAll(data.map((json) => User.fromJson(json)));
        } else {
          // Lidar com respostas de erro individuais se necessário
          print('Erro ao buscar um tipo de usuário: ${response.statusCode}');
        }
      }
      return allUsers;
    } catch (e) {
      print('Erro ao buscar todos os usuários: $e');
      return [];
    }
  }

  // Pets
  static Future<List<Pet>> getPets({int? tutorId}) async {
    try {
      final url = tutorId != null 
          ? '$baseUrl/api/pets?tutorId=$tutorId'
          : '$baseUrl/api/pets';
      
      final response = await http.get(Uri.parse(url), headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Pet.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Erro ao buscar pets: $e');
      return [];
    }
  }

  static Future<Pet?> createPet(Pet pet) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/pets'),
        headers: _headers,
        body: jsonEncode(pet.toJson()),
      );

      if (response.statusCode == 200) {
        return Pet.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Erro ao criar pet: $e');
      return null;
    }
  }

  static Future<Pet?> updatePet(int id, Pet pet) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/pets/$id'),
        headers: _headers,
        body: jsonEncode(pet.toJson()),
      );
      if (response.statusCode == 200) {
        return Pet.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Erro ao atualizar pet: $e');
      return null;
    }
  }

  static Future<bool> deletePet(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/pets/$id'),
        headers: _headers,
      );
      return response.statusCode == 204; // No Content
    } catch (e) {
      print('Erro ao deletar pet: $e');
      return false;
    }
  }

  // Produtos
  static Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/products'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Erro ao buscar produtos: $e');
      return [];
    }
  }

  static Future<Product?> createProduct(Product product) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/products'),
        headers: _headers,
        body: jsonEncode(product.toJson()),
      );

      if (response.statusCode == 200) {
        return Product.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Erro ao criar produto: $e');
      return null;
    }
  }

  static Future<Product?> updateProduct(int id, Product product) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/products/$id'),
        headers: _headers,
        body: jsonEncode(product.toJson()),
      );
      if (response.statusCode == 200) {
        return Product.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Erro ao atualizar produto: $e');
      return null;
    }
  }

  static Future<bool> deleteProduct(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/products/$id'),
        headers: _headers,
      );
      return response.statusCode == 204;
    } catch (e) {
      print('Erro ao deletar produto: $e');
      return false;
    }
  }

  // Serviços Veterinários
  static Future<List<VetService>> getVetServices() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/services'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => VetService.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Erro ao buscar serviços: $e');
      return [];
    }
  }

  static Future<VetService?> createVetService(VetService service) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/services'),
        headers: _headers,
        body: jsonEncode(service.toJson()),
      );

      if (response.statusCode == 200) {
        return VetService.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Erro ao criar serviço: $e');
      return null;
    }
  }

  static Future<VetService?> updateVetService(int id, VetService service) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/services/$id'),
        headers: _headers,
        body: jsonEncode(service.toJson()),
      );
      if (response.statusCode == 200) {
        return VetService.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Erro ao atualizar serviço: $e');
      return null;
    }
  }

  static Future<bool> deleteVetService(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/services/$id'),
        headers: _headers,
      );
      return response.statusCode == 204;
    } catch (e) {
      print('Erro ao deletar serviço: $e');
      return false;
    }
  }
} 