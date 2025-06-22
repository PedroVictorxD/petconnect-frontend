import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  String? _token;
  String? _userType;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  String? get token => _token;
  String? get userType => _userType;
  bool get isAuthenticated => _token != null && _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;

  AuthProvider() {
    _loadUserFromStorage();
  }

  Future<void> _loadUserFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('currentUser');
    final token = prefs.getString('token');
    final userType = prefs.getString('userType');

    if (userJson != null && token != null && userType != null) {
      _currentUser = User.fromJson(json.decode(userJson));
      _token = token;
      _userType = userType;
      ApiService.setAuthToken(_token);
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await ApiService.login(email, password);
      if (response != null && response['token'] != null && response['user'] != null) {
        _currentUser = response['user'];
        _token = response['token'];
        _userType = _currentUser?.dtype;
        ApiService.setAuthToken(_token);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('currentUser', json.encode(_currentUser!.toJson()));
        if (_userType != null) {
          await prefs.setString('userType', _userType!);
        }

        _isLoading = false;
        notifyListeners();
        return true;
      }
        _isLoading = false;
      _error = "Email ou senha inválidos";
        notifyListeners();
        return false;
    } catch (e) {
      _isLoading = false;
      _error = 'Erro ao realizar login: $e';
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
      String? createdToken;
      // Supondo que o backend retorne token e user, ajuste conforme necessário
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
        _userType = userType;
        // Se o backend retornar token, salve aqui também
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('currentUser', json.encode(_currentUser!.toJson()));
        await prefs.setString('userType', _userType!);
        // Se houver token, salve também
        if (_token != null) {
          await prefs.setString('token', _token!);
        }
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

  Future<void> logout() async {
    _currentUser = null;
    _token = null;
    _userType = null;
    ApiService.setAuthToken(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUser');
    await prefs.remove('token');
    await prefs.remove('userType');
    notifyListeners();
  }

  // Limpar erro
  void clearError() {
    _error = null;
    notifyListeners();
  }
} 