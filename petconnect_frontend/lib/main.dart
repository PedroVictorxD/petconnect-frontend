import 'package:flutter/material.dart';
import 'package:petconnect_frontend/core/utils/route_guard.dart';
import 'package:petconnect_frontend/features/auth/screens/forgot_password_screen.dart';
import 'package:petconnect_frontend/features/auth/screens/login_screen.dart';
import 'package:petconnect_frontend/features/auth/screens/register_screen.dart';
import 'package:petconnect_frontend/features/home/screens/admin_home_screen.dart';
import 'package:petconnect_frontend/features/home/screens/lojista_home_screen.dart';
import 'package:petconnect_frontend/features/home/screens/tutor_home_screen.dart';
import 'package:petconnect_frontend/features/home/screens/veterinario_home_screen.dart';
import 'package:petconnect_frontend/features/landing/screens/landing_page.dart';
import 'package:petconnect_frontend/shared/themes/app_theme.dart';

void main() {
  runApp(const PetConnectApp());
}

class PetConnectApp extends StatelessWidget {
  const PetConnectApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pet Connect',
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        // Rotas Públicas
        '/': (context) => LandingPage(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/forgot-password': (context) => ForgotPasswordScreen(),

        // Rotas Protegidas
        '/admin': (context) => RouteGuard(child: AdminHomeScreen()),
        '/tutor': (context) => RouteGuard(child: TutorHomeScreen()),
        '/veterinario': (context) => RouteGuard(child: VeterinarioHomeScreen()),
        '/lojista': (context) => RouteGuard(child: LojistaHomeScreen()),
      },
    );
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
