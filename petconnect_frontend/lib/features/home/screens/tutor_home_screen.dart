import 'package:flutter/material.dart';
import 'package:petconnect_frontend/features/auth/auth_service.dart';

class TutorHomeScreen extends StatelessWidget {
  const TutorHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard do Tutor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authService.logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Bem-vindo, Tutor!'),
      ),
    );
  }
} 