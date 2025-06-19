import 'package:flutter/material.dart';
import '../../../core/utils/validators.dart';
import '../auth_service.dart';

class RegisterForm extends StatefulWidget {
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  String? _fullName;
  String? _email;
  String? _password;
  String? _userType;
  bool _isLoading = false;
  String? _message;
  final List<String> _userTypes = ['TUTOR', 'VETERINARIO', 'LOJISTA'];

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
      _message = null;
    });
    final result = await AuthService().register(_fullName!, _email!, _password!, _userType!);
    setState(() {
      _isLoading = false;
      _message = result.message;
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
            decoration: InputDecoration(labelText: 'Nome completo'),
            validator: (value) => value == null || value.isEmpty ? 'Informe o nome completo' : null,
            onSaved: (value) => _fullName = value,
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Email'),
            validator: validateEmail,
            onSaved: (value) => _email = value,
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Senha'),
            obscureText: true,
            validator: validatePassword,
            onSaved: (value) => _password = value,
          ),
          DropdownButtonFormField<String>(
            value: _userType,
            decoration: InputDecoration(labelText: 'Tipo de usuário'),
            items: _userTypes.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _userType = value;
              });
            },
            validator: (value) => value == null ? 'Selecione o tipo de usuário' : null,
          ),
          SizedBox(height: 16),
          _isLoading
              ? CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _register,
                  child: Text('Cadastrar'),
                ),
          if (_message != null) ...[
            SizedBox(height: 16),
            Text(_message!, style: TextStyle(color: _message!.contains('sucesso') ? Colors.green : Colors.red)),
          ],
        ],
      ),
    );
  }
} 