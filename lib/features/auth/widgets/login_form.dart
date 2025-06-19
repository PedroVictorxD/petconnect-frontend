import 'package:flutter/material.dart';
import '../../../core/utils/validators.dart';

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  String? _email;
  String? _password;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: 'E-mail'),
            validator: validateEmail,
            onSaved: (value) => _email = value,
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Senha'),
            obscureText: true,
            validator: validatePassword,
            onSaved: (value) => _password = value,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                // Chamar serviço de autenticação
              }
            },
            child: Text('Entrar'),
          ),
        ],
      ),
    );
  }
} 