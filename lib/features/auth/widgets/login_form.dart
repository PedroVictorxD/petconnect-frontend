import 'package:flutter/material.dart';
import '../../../core/utils/validators.dart';
import '../auth_service.dart';

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  String? _email;
  String? _password;
  bool _isLoading = false;
  String? _message;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
      _message = null;
    });
    final result = await AuthService().login(_email!, _password!);
    setState(() {
      _isLoading = false;
      if (result.success) {
        Navigator.pushReplacementNamed(context, result.route!);
      } else {
        _message = result.message;
      }
    });
  }

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
          _isLoading
              ? CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _login,
                  child: Text('Entrar'),
                ),
          if (_message != null) ...[
            SizedBox(height: 16),
            Text(_message!, style: TextStyle(color: Colors.red)),
          ],
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/register'),
            child: Text('Cadastre-se'),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
            child: Text('Esqueci minha senha'),
          ),
        ],
      ),
    );
  }
} 