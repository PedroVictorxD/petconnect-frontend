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

  // Criar pet
  Future<bool> createPet(Pet pet) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final createdPet = await ApiService.createPet(pet);
      if (createdPet != null) {
        _pets.add(createdPet);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Erro ao criar pet';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Erro ao criar pet: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Atualizar pet
  Future<bool> updatePet(int id, Pet pet) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final updatedPet = await ApiService.updatePet(id, pet);
      if (updatedPet != null) {
        final index = _pets.indexWhere((p) => p.id == id);
        if (index != -1) {
          _pets[index] = updatedPet;
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _error = 'Erro ao atualizar pet';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Erro ao atualizar pet: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Deletar pet
  Future<bool> deletePet(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final success = await ApiService.deletePet(id);
      if (success) {
        _pets.removeWhere((p) => p.id == id);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _error = 'Erro ao deletar pet';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Erro ao deletar pet: $e';
      _isLoading = false;
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
} 