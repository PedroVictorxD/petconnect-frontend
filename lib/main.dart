import 'package:flutter/material.dart';
import 'features/landing/screens/landing_page.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'features/home/screens/admin_home_screen.dart';
import 'features/home/screens/tutor_home_screen.dart';
import 'features/home/screens/veterinario_home_screen.dart';
import 'features/home/screens/lojista_home_screen.dart';
import 'core/utils/route_guard.dart';

void main() {
  runApp(PetConnectApp());
}

class PetConnectApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pet Connect',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      navigatorKey: navigatorKey,
      onGenerateRoute: (settings) {
        final route = settings.name;
        if (route == null) return null;

        // Rotas públicas que não precisam de autenticação
        if (['/', '/login', '/register', '/forgot-password'].contains(route)) {
          switch (route) {
            case '/':
              return MaterialPageRoute(builder: (context) => LandingPage());
            case '/login':
              return MaterialPageRoute(builder: (context) => LoginScreen());
            case '/register':
              return MaterialPageRoute(builder: (context) => RegisterScreen());
            case '/forgot-password':
              return MaterialPageRoute(builder: (context) => ForgotPasswordScreen());
          }
        }

        // Para rotas protegidas, verificar acesso de forma síncrona
        // e redirecionar se necessário
        switch (route) {
          case '/admin':
            return MaterialPageRoute(builder: (context) => _buildProtectedRoute(AdminHomeScreen(), route));
          case '/tutor':
            return MaterialPageRoute(builder: (context) => _buildProtectedRoute(TutorHomeScreen(), route));
          case '/veterinario':
            return MaterialPageRoute(builder: (context) => _buildProtectedRoute(VeterinarioHomeScreen(), route));
          case '/lojista':
            return MaterialPageRoute(builder: (context) => _buildProtectedRoute(LojistaHomeScreen(), route));
          default:
            return MaterialPageRoute(builder: (context) => LandingPage());
        }
      },
    );
  }

  Widget _buildProtectedRoute(Widget screen, String route) {
    return FutureBuilder<String?>(
      future: RouteGuard.checkAccess(navigatorKey.currentContext!, route),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        final redirectRoute = snapshot.data;
        if (redirectRoute != null && redirectRoute != route) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, redirectRoute);
          });
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        return screen;
      },
    );
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
