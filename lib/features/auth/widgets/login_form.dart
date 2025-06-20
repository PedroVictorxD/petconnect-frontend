import 'package:flutter/material.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/themes/app_theme.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_input.dart';
import '../auth_service.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final user = await _authService.login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        if (mounted) {
          // Navega para a tela apropriada com base no tipo de usuário
          switch (user.userType) {
            case 'ADMIN':
              Navigator.of(context).pushReplacementNamed('/admin');
              break;
            case 'TUTOR':
              Navigator.of(context).pushReplacementNamed('/tutor');
              break;
            case 'VETERINARIO':
              Navigator.of(context).pushReplacementNamed('/veterinario');
              break;
            case 'LOJISTA':
              Navigator.of(context).pushReplacementNamed('/lojista');
              break;
            default:
              // Caso o tipo de usuário seja desconhecido ou não manuseado
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tipo de usuário desconhecido.')),
              );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString().replaceFirst("Exception: ", ""))),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomInput(
            controller: _emailController,
            label: 'E-mail',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty || !value.contains('@')) {
                return 'Por favor, insira um e-mail válido.';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          CustomInput(
            controller: _passwordController,
            label: 'Senha',
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira sua senha.';
              }
              return null;
            },
          ),
          const SizedBox(height: 30),
          if (_isLoading)
            const CircularProgressIndicator()
          else
            CustomButton(
              text: 'Entrar',
              onPressed: _login,
            ),
        ],
      ),
    );
  }
} 