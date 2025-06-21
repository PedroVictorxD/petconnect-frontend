import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await ApiService.login(email, password);
      if (user != null) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Email ou senha incorretos';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Erro ao fazer login: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Registro
  Future<bool> register(User user, String userType) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      User? createdUser;
      
      switch (userType) {
        case 'tutor':
          createdUser = await ApiService.createTutor(user);
          break;
        case 'veterinario':
          createdUser = await ApiService.createVeterinario(user);
          break;
        case 'lojista':
          createdUser = await ApiService.createLojista(user);
          break;
        case 'admin':
          createdUser = await ApiService.createAdmin(user);
          break;
      }

      if (createdUser != null) {
        _currentUser = createdUser;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Erro ao criar usuário';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Erro ao registrar: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  void logout() {
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  // Limpar erro
  void clearError() {
    _error = null;
    notifyListeners();
  }
} 