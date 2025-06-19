import 'package:flutter/material.dart';
import '../../features/auth/auth_service.dart';

class RouteGuard {
  static Future<String?> checkAccess(BuildContext context, String route) async {
    final authService = AuthService();
    final token = await authService.getToken();
    
    if (token == null) {
      return '/login';
    }

    final user = await authService.getUserData();
    if (user == null) {
      return '/login';
    }

    final userType = user['userType'];
    
    // Verificar se o usuário tem acesso à rota baseado no seu tipo
    switch (route) {
      case '/admin':
        if (userType != 'ADMIN') {
          return _getDefaultRoute(userType);
        }
        break;
      case '/tutor':
        if (userType != 'TUTOR') {
          return _getDefaultRoute(userType);
        }
        break;
      case '/veterinario':
        if (userType != 'VETERINARIO') {
          return _getDefaultRoute(userType);
        }
        break;
      case '/lojista':
        if (userType != 'LOJISTA') {
          return _getDefaultRoute(userType);
        }
        break;
    }
    
    return null; // Acesso permitido
  }

  static String _getDefaultRoute(String userType) {
    switch (userType) {
      case 'ADMIN':
        return '/admin';
      case 'TUTOR':
        return '/tutor';
      case 'VETERINARIO':
        return '/veterinario';
      case 'LOJISTA':
        return '/lojista';
      default:
        return '/login';
    }
  }
} 