import 'package:flutter/material.dart';
import 'package:petconnect_frontend/features/auth/auth_service.dart';

class RouteGuard extends StatefulWidget {
  final Widget child;

  const RouteGuard({Key? key, required this.child}) : super(key: key);

  @override
  _RouteGuardState createState() => _RouteGuardState();
}

class _RouteGuardState extends State<RouteGuard> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _authService.isAuthenticated(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Enquanto verifica a autenticação, mostramos um loader.
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          if (snapshot.hasData && snapshot.data == true) {
            // Se autenticado, mostra a página solicitada.
            return widget.child;
          } else {
            // Se não estiver autenticado, redireciona para o login.
            // Usamos um post-frame callback para garantir que o build atual termine
            // antes de tentarmos navegar.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacementNamed('/login');
            });
            // Retorna um container vazio enquanto o redirecionamento acontece.
            return const Scaffold(body: SizedBox.shrink());
          }
        }
      },
    );
  }
} 