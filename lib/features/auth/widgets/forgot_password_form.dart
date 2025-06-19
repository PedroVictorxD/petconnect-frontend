import 'package:flutter/material.dart';

class ForgotPasswordForm extends StatefulWidget {
  @override
  _ForgotPasswordFormState createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  String? _email;
  bool _isLoading = false;
  String? _message;

  Future<void> _sendRecovery() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
      _message = null;
    });
    // Aqui você pode chamar o AuthService para enviar o e-mail de recuperação
    await Future.delayed(Duration(seconds: 2)); // Simulação
    setState(() {
      _isLoading = false;
      _message = 'Se o e-mail existir, um link foi enviado.';
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
            validator: (value) => value == null || value.isEmpty ? 'Informe o e-mail' : null,
            onSaved: (value) => _email = value,
          ),
          SizedBox(height: 16),
          _isLoading
              ? CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _sendRecovery,
                  child: Text('Enviar link de recuperação'),
                ),
          if (_message != null) ...[
            SizedBox(height: 16),
            Text(_message!, style: TextStyle(color: Colors.green)),
          ],
        ],
      ),
    );
  }
} 