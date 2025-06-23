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
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const LandingPage(),
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