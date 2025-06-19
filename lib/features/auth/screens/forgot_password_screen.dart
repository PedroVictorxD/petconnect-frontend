import 'package:flutter/material.dart';
import '../widgets/forgot_password_flow.dart';

class ForgotPasswordScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Recuperar Senha')),
      body: Center(child: ForgotPasswordFlow()),
    );
  }
} 