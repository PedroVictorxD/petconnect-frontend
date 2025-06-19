import 'package:flutter/material.dart';
import '../widgets/register_form_dynamic.dart';

class RegisterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastro')),
      body: Center(child: RegisterFormDynamic()),
    );
  }
} 