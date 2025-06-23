import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/data_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/tutor/tutor_home_screen.dart';
import 'features/lojista/lojista_home_screen.dart';
import 'features/veterinario/vet_home_screen.dart';
import 'features/admin/admin_home_screen.dart';
import 'features/landing/landing_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DataProvider()),
      ],
      child: MaterialApp(
        title: 'PetConnect',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/tutor': (context) => const TutorHomeScreen(),
          '/lojista': (context) => const LojistaHomeScreen(),
          '/veterinario': (context) => const VetHomeScreen(),
          '/admin': (context) => const AdminHomeScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Aguardar um pouco para garantir que o AuthProvider foi inicializado
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Verificar se há dados de sessão salvos
    if (authProvider.isAuthenticated) {
      // Validar token com o backend
      final isValid = await authProvider.validateSessionWithBackend();
      
      if (isValid) {
        // Token válido, redirecionar para a tela apropriada
        _redirectToUserScreen(authProvider.userType);
      } else {
        // Token inválido, limpar dados e ir para landing
        await authProvider.logout();
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LandingPage()),
          );
        }
      }
    }
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _redirectToUserScreen(String? userType) {
    if (!mounted) return;
    
    String route;
    switch (userType?.toLowerCase()) {
      case 'tutor':
        route = '/tutor';
        break;
      case 'lojista':
        route = '/lojista';
        break;
      case 'veterinario':
        route = '/veterinario';
        break;
      case 'admin':
        route = '/admin';
        break;
      default:
        route = '/';
        break;
    }
    
    Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Carregando...', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      );
    }
    
    return const LandingPage();
  }
} 