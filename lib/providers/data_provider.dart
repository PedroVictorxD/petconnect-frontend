import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../models/product.dart';
import '../models/vet_service.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class DataProvider extends ChangeNotifier {
  List<Pet> _pets = [];
  List<Product> _products = [];
  List<VetService> _vetServices = [];
  List<User> _allUsers = [];
  List<Product> _allProducts = [];
  List<VetService> _allVetServices = [];
  bool _isLoading = false;
  String? _error;

  List<Pet> get pets => _pets;
  List<Product> get products => _products;
  List<VetService> get vetServices => _vetServices;
  List<User> get allUsers => _allUsers;
  List<Product> get allProducts => _allProducts;
  List<VetService> get allVetServices => _allVetServices;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Carregar todos os usuários
  Future<void> loadAllUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allUsers = await ApiService.getAllUsers();
      _allProducts = await ApiService.getAllProducts();
      _allVetServices = await ApiService.getAllVetServices();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao carregar usuários: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Carregar pets
  Future<void> loadPets({int? tutorId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _pets = await ApiService.getPets(tutorId: tutorId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao carregar pets: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Carregar pets de um tutor específico
  Future<void> fetchPetsForTutor(int tutorId) async {
    _isLoading = true;
    _error = null;
    try {
      _pets.clear();
      _pets.addAll(await ApiService.getPets(tutorId: tutorId));
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao carregar pets do tutor: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Carregar produtos
  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _products.clear();
      _products.addAll(await ApiService.getProducts());
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao carregar produtos: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Carregar serviços
  Future<void> fetchServices() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _vetServices.clear();
      _vetServices.addAll(await ApiService.getVetServices());
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao carregar serviços: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- MÉTODO CENTRALIZADO PARA CARREGAR DADOS DO TUTOR ---
  Future<void> fetchAllDataForTutor(int tutorId) async {
    // Evita múltiplas chamadas se já estiver carregando
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    // Notifica o início do carregamento. Faz isso de forma assíncrona
    // para não causar erro de "setState() or markNeedsBuild() called during build".
    Future.microtask(() => notifyListeners());

    try {
      // Busca todos os dados em paralelo para mais eficiência
      final petsData = ApiService.getPets(tutorId: tutorId);
      final productsData = ApiService.getAllProducts();
      final servicesData = ApiService.getAllVetServices();

      // Aguarda todas as chamadas terminarem
      final results = await Future.wait([petsData, productsData, servicesData]);

      // Atribui os resultados de forma segura e limita a 4 itens
      List<Pet> pets = results[0] as List<Pet>;
      List<Product> products = results[1] as List<Product>;
      List<VetService> services = results[2] as List<VetService>;

      // Limita a 4 itens e adiciona imagens padrão se necessário
      _pets = _limitAndAddDefaultImages(pets, 4);
      _products = _limitAndAddDefaultProductImages(products, 4);
      _vetServices = _limitAndAddDefaultServiceImages(services, 4);

    } catch (e) {
      _error = 'Erro ao carregar os dados: $e';
    } finally {
      _isLoading = false;
      // Notifica a UI que o carregamento terminou (com sucesso ou erro)
      notifyListeners();
    }
  }

  // Método para limitar pets e adicionar imagens padrão
  List<Pet> _limitAndAddDefaultImages(List<Pet> pets, int limit) {
    final limitedPets = pets.take(limit).toList();
    
    // URLs de imagens padrão para pets
    final defaultPetImages = [
      'https://images.unsplash.com/photo-1552053831-71594a27632d?w=400&h=400&fit=crop', // Cachorro fofo
      'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400&h=400&fit=crop', // Gato fofo
      'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?w=400&h=400&fit=crop', // Cachorro brincalhão
      'https://images.unsplash.com/photo-1513360371669-4adf3dd7dff8?w=400&h=400&fit=crop', // Gato elegante
    ];

    for (int i = 0; i < limitedPets.length; i++) {
      if (limitedPets[i].photoUrl == null || limitedPets[i].photoUrl!.isEmpty) {
        limitedPets[i] = Pet(
          id: limitedPets[i].id,
          name: limitedPets[i].name,
          type: limitedPets[i].type,
          breed: limitedPets[i].breed,
          age: limitedPets[i].age,
          weight: limitedPets[i].weight,
          tutor: limitedPets[i].tutor,
          tutorId: limitedPets[i].tutorId,
          photoUrl: defaultPetImages[i % defaultPetImages.length],
          activityLevel: limitedPets[i].activityLevel,
          notes: limitedPets[i].notes,
          atendido: limitedPets[i].atendido,
          ownerId: limitedPets[i].ownerId,
          ownerName: limitedPets[i].ownerName,
          ownerPhone: limitedPets[i].ownerPhone,
        );
      }
    }
    
    return limitedPets;
  }

  // Método para limitar produtos e adicionar imagens padrão
  List<Product> _limitAndAddDefaultProductImages(List<Product> products, int limit) {
    final limitedProducts = products.take(limit).toList();
    
    // URLs de imagens padrão para produtos pet
    final defaultProductImages = [
      'https://images.unsplash.com/photo-1601758228041-3caa5d9c6c5f?w=400&h=400&fit=crop', // Ração premium
      'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?w=400&h=400&fit=crop', // Brinquedos
      'https://images.unsplash.com/photo-1601758228041-3caa5d9c6c5f?w=400&h=400&fit=crop', // Petiscos
      'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?w=400&h=400&fit=crop', // Acessórios
    ];

    for (int i = 0; i < limitedProducts.length; i++) {
      if (limitedProducts[i].imageUrl == null || limitedProducts[i].imageUrl!.isEmpty) {
        limitedProducts[i] = Product(
          id: limitedProducts[i].id,
          name: limitedProducts[i].name,
          description: limitedProducts[i].description,
          price: limitedProducts[i].price,
          imageUrl: defaultProductImages[i % defaultProductImages.length],
          ownerId: limitedProducts[i].ownerId,
          ownerName: limitedProducts[i].ownerName,
          ownerPhone: limitedProducts[i].ownerPhone,
        );
      }
    }
    
    return limitedProducts;
  }

  // Método para limitar serviços e adicionar imagens padrão
  List<VetService> _limitAndAddDefaultServiceImages(List<VetService> services, int limit) {
    final limitedServices = services.take(limit).toList();
    
    // URLs de imagens padrão para serviços veterinários
    final defaultServiceImages = [
      'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400&h=400&fit=crop', // Consulta veterinária
      'https://images.unsplash.com/photo-1576201836106-db1758fd1c97?w=400&h=400&fit=crop', // Vacinação
      'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400&h=400&fit=crop', // Cirurgia
      'https://images.unsplash.com/photo-1576201836106-db1758fd1c97?w=400&h=400&fit=crop', // Exames
    ];

    for (int i = 0; i < limitedServices.length; i++) {
      if (limitedServices[i].imageUrl == null || limitedServices[i].imageUrl!.isEmpty) {
        limitedServices[i] = VetService(
          id: limitedServices[i].id,
          name: limitedServices[i].name,
          description: limitedServices[i].description,
          price: limitedServices[i].price,
          imageUrl: defaultServiceImages[i % defaultServiceImages.length],
          ownerId: limitedServices[i].ownerId,
          ownerName: limitedServices[i].ownerName,
          ownerPhone: limitedServices[i].ownerPhone,
        );
      }
    }
    
    return limitedServices;
  }

  // --- MÉTODOS DE MANIPULAÇÃO DE DADOS REATORIZADOS ---

  /// Adiciona um novo pet e recarrega todos os dados para manter a consistência.
  Future<bool> createPet(Pet pet, int tutorId) async {
    try {
      final createdPet = await ApiService.createPet(pet);
      if (createdPet != null) {
        // Em vez de manipular a lista local, busca a lista fresca do servidor.
        await fetchAllDataForTutor(tutorId);
        return true;
      }
      _error = 'Falha ao criar o pet no servidor.';
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Erro de conexão ao criar o pet: $e';
        notifyListeners();
        return false;
      }
  }

  /// Deleta um pet e recarrega todos os dados.
  Future<bool> deletePet(int petId, int tutorId) async {
    try {
      final success = await ApiService.deletePet(petId);
      if (success) {
        // Busca a lista fresca do servidor para garantir consistência.
        await fetchAllDataForTutor(tutorId);
        return true;
      }
      _error = 'Falha ao deletar o pet no servidor.';
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Erro de conexão ao deletar o pet: $e';
      notifyListeners();
      return false;
    }
  }

  /// Deleta um pet a partir do painel de admin.
  Future<bool> deletePetFromAdmin(int petId) async {
    try {
      final success = await ApiService.deletePet(petId);
      if (success) {
        _pets.removeWhere((p) => p.id == petId);
        notifyListeners();
        return true;
      }
      _error = 'Falha ao deletar o pet no servidor.';
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Erro de conexão ao deletar o pet: $e';
      notifyListeners();
      return false;
    }
  }

  /// Atualiza um pet e recarrega todos os dados para manter a consistência.
  Future<bool> updatePet(Pet pet, int tutorId) async {
    try {
      // O ID do pet não pode ser nulo para uma atualização.
      if (pet.id == null) {
        _error = 'ID do pet inválido para atualização.';
        notifyListeners();
        return false;
      }
      final updatedPet = await ApiService.updatePet(pet.id!, pet);
      if (updatedPet != null) {
        // Recarrega os dados para refletir a mudança.
        await fetchAllDataForTutor(tutorId);
        return true;
      }
      _error = 'Falha ao atualizar o pet no servidor.';
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Erro de conexão ao atualizar o pet: $e';
      notifyListeners();
      return false;
    }
  }

  // Carregar produtos
  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await ApiService.getProducts();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao carregar produtos: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Criar produto
  Future<bool> createProduct(Product product) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final createdProduct = await ApiService.createProduct(product);
      if (createdProduct != null) {
        _products.add(createdProduct);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Erro ao criar produto';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Erro ao criar produto: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Atualizar produto
  Future<bool> updateProduct(Product product) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedProduct = await ApiService.updateProduct(product);
      if (updatedProduct != null) {
        final index = _allProducts.indexWhere((p) => p.id == product.id);
        if (index != -1) {
          _allProducts[index] = updatedProduct;
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _error = 'Erro ao atualizar produto';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Erro ao atualizar produto: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Deletar produto
  Future<bool> deleteProduct(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final success = await ApiService.deleteProduct(id);
      if (success) {
        _products.removeWhere((p) => p.id == id);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _error = 'Erro ao deletar produto';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Erro ao deletar produto: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Carregar serviços veterinários
  Future<void> loadVetServices() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _vetServices = await ApiService.getVetServices();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao carregar serviços: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Criar serviço veterinário
  Future<bool> createVetService(VetService service) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final createdService = await ApiService.createVetService(service);
      if (createdService != null) {
        _vetServices.add(createdService);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Erro ao criar serviço';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Erro ao criar serviço: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Atualizar serviço veterinário
  Future<bool> updateVetService(VetService service) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedService = await ApiService.updateVetService(service);
      if (updatedService != null) {
        final index = _allVetServices.indexWhere((s) => s.id == service.id);
        if (index != -1) {
          _allVetServices[index] = updatedService;
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _error = 'Erro ao atualizar serviço';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Erro ao atualizar serviço: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Deletar serviço veterinário
  Future<bool> deleteVetService(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final success = await ApiService.deleteVetService(id);
      if (success) {
        _vetServices.removeWhere((s) => s.id == id);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _error = 'Erro ao deletar serviço';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Erro ao deletar serviço: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Limpar erro
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Limpar dados
  void clearData() {
    _pets.clear();
    _products.clear();
    _vetServices.clear();
    _allUsers.clear();
    _allProducts.clear();
    _allVetServices.clear();
    notifyListeners();
  }

  // Deletar genérico
  Future<bool> deleteData(String type, int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await ApiService.deleteData(type, id);
      if (success) {
        // Remover da lista local
        switch(type) {
          case 'user': _allUsers.removeWhere((item) => item.id == id); break;
          case 'pet': _pets.removeWhere((item) => item.id == id); break;
          case 'product': _allProducts.removeWhere((item) => item.id == id); break;
          case 'vet-service': _allVetServices.removeWhere((item) => item.id == id); break;
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
       _error = 'Erro ao deletar $type';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Erro ao deletar $type: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUser(User user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedUser = await ApiService.updateUser(user);
      if (updatedUser != null) {
        final index = _allUsers.indexWhere((u) => u.id == user.id);
        if (index != -1) {
          _allUsers[index] = updatedUser;
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _error = 'Erro ao atualizar usuário';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Erro ao atualizar usuário: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUserWithMap(int userId, Map<String, dynamic> updateData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedUser = await ApiService.updateUserWithMap(userId, updateData);
      if (updatedUser != null) {
        final index = _allUsers.indexWhere((u) => u.id == userId);
        if (index != -1) {
          _allUsers[index] = updatedUser;
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _error = 'Erro ao atualizar usuário';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Erro ao atualizar usuário: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Deletar usuário (Admin)
  Future<bool> deleteUser(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final success = await ApiService.deleteUser(id);
      if (success) {
        _allUsers.removeWhere((u) => u.id == id);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _error = 'Erro ao deletar usuário';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Erro ao deletar usuário: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
} 