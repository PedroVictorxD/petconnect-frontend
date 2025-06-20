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
        '/admin': (context) => RouteGuard(child: _WithDrawer(child: AdminHomeScreen())),
        '/tutor': (context) => RouteGuard(child: _WithDrawer(child: TutorHomeScreen())),
        '/veterinario': (context) => RouteGuard(child: _WithDrawer(child: VeterinarioHomeScreen())),
        '/lojista': (context) => RouteGuard(child: _WithDrawer(child: LojistaHomeScreen())),
      },
    );
  }
}

class _WithDrawer extends StatelessWidget {
  final Widget child;
  const _WithDrawer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _AppDrawer(),
      body: child,
    );
  }
}

class _AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.pets, color: AppTheme.primaryColor, size: 36),
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pet Connect', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Navegação TEMPORÁRIA', style: TextStyle(color: Colors.orange[200], fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _DrawerTile(
            icon: Icons.dashboard,
            label: 'Admin',
            onTap: () => Navigator.pushReplacementNamed(context, '/admin'),
          ),
          _DrawerTile(
            icon: Icons.person,
            label: 'Tutor',
            onTap: () => Navigator.pushReplacementNamed(context, '/tutor'),
          ),
          _DrawerTile(
            icon: Icons.medical_services,
            label: 'Veterinário',
            onTap: () => Navigator.pushReplacementNamed(context, '/veterinario'),
          ),
          _DrawerTile(
            icon: Icons.store,
            label: 'Lojista',
            onTap: () => Navigator.pushReplacementNamed(context, '/lojista'),
          ),
          const Spacer(),
          const Divider(),
          _DrawerTile(
            icon: Icons.logout,
            label: 'Sair',
            onTap: () => Navigator.pushReplacementNamed(context, '/login'),
            color: AppTheme.errorColor,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _DrawerTile({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppTheme.primaryColor),
      title: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: color ?? AppTheme.textPrimaryColor)),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      hoverColor: AppTheme.primaryColor.withOpacity(0.08),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
    );
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
