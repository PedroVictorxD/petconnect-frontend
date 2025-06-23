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
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    await _loadUserFromStorage();
  }

  Future<void> _loadUserFromStorage() async {
    try {
      print('AuthProvider: Carregando dados da sessão...');
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('currentUser');
    final token = prefs.getString('token');
    final userType = prefs.getString('userType');

      print('AuthProvider: Dados encontrados - User: ${userJson != null}, Token: ${token != null}, Type: $userType');

    if (userJson != null && token != null && userType != null) {
      _currentUser = User.fromJson(json.decode(userJson));
      _token = token;
      _userType = userType;
      ApiService.setAuthToken(_token);
        print('AuthProvider: Sessão restaurada com sucesso');
      notifyListeners();
      } else {
        print('AuthProvider: Nenhuma sessão encontrada');
      }
    } catch (e) {
      print('AuthProvider: Erro ao carregar dados da sessão: $e');
      // Se houver erro ao carregar, limpar dados corrompidos
      await _clearStoredData();
    }
  }

  Future<void> _clearStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUser');
    await prefs.remove('token');
    await prefs.remove('userType');
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

        // Salvar dados na sessão
        await _saveUserToStorage();

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
      _error = "Email ou senha inválidos";
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Erro ao realizar login: $e';
      notifyListeners();
      return false;
    }
  }

  // Registro com login automático
  Future<bool> register(User user, String userType) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      User? createdUser;
      
      // Criar usuário no backend
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
        default:
          throw Exception('Tipo de usuário inválido');
      }

      if (createdUser != null) {
        // Após registro bem-sucedido, fazer login automático
        final loginSuccess = await login(user.email, user.password);
        
        if (loginSuccess) {
          _userType = userType;
          await _saveUserToStorage();
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          // Se o login automático falhar, ainda salvar o usuário criado
        _currentUser = createdUser;
          _userType = userType;
          await _saveUserToStorage();
        _isLoading = false;
        notifyListeners();
        return true;
        }
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

  Future<void> _saveUserToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (_currentUser != null) {
        await prefs.setString('currentUser', json.encode(_currentUser!.toJson()));
      }
      
      if (_token != null) {
        await prefs.setString('token', _token!);
      }
      
      if (_userType != null) {
        await prefs.setString('userType', _userType!);
      }
    } catch (e) {
      print('Erro ao salvar dados da sessão: $e');
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _token = null;
    _userType = null;
    ApiService.setAuthToken(null);
    
    await _clearStoredData();
    notifyListeners();
  }

  // Limpar erro
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Verificar se a sessão ainda é válida
  Future<bool> validateSession() async {
    if (!isAuthenticated) return false;
    
    try {
      // Aqui você pode adicionar uma chamada para verificar se o token ainda é válido
      // Por exemplo, fazer uma chamada para um endpoint que requer autenticação
      // Por enquanto, vamos apenas verificar se temos os dados básicos
      return _currentUser != null && _token != null && _userType != null;
    } catch (e) {
      print('Erro ao validar sessão: $e');
      await logout();
      return false;
    }
  }

  // Validar sessão com chamada para o backend
  Future<bool> validateSessionWithBackend() async {
    if (!isAuthenticated) {
      print('AuthProvider: Usuário não autenticado');
      return false;
    }
    
    try {
      print('AuthProvider: Validando token com backend...');
      // Fazer uma chamada para um endpoint que requer autenticação
      // Se a chamada falhar com 401, significa que o token expirou
      final response = await ApiService.validateToken();
      print('AuthProvider: Resposta da validação: $response');
      
      if (response == true) {
        print('AuthProvider: Token válido');
        return true;
      } else {
        print('AuthProvider: Token inválido');
        await logout();
        return false;
      }
    } catch (e) {
      print('AuthProvider: Erro ao validar token: $e');
      await logout();
      return false;
    }
  }

  // Atualizar dados do usuário
  Future<void> refreshUserData() async {
    if (!isAuthenticated) return;
    
    try {
      // Aqui você pode implementar uma chamada para buscar dados atualizados do usuário
      // Por enquanto, vamos apenas salvar os dados atuais
      await _saveUserToStorage();
    } catch (e) {
      print('Erro ao atualizar dados do usuário: $e');
    }
  }
} 