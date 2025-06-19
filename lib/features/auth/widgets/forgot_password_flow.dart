import 'package:flutter/material.dart';
import '../../../core/utils/validators.dart';

class ForgotPasswordFlow extends StatefulWidget {
  @override
  State<ForgotPasswordFlow> createState() => _ForgotPasswordFlowState();
}

class _ForgotPasswordFlowState extends State<ForgotPasswordFlow> {
  final _emailController = TextEditingController();
  final _answerController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  int _step = 0;
  String? _question;
  String? _message;
  bool _isLoading = false;

  void _getSecurityQuestion() async {
    setState(() { _isLoading = true; _message = null; });
    // Simulação: normalmente faria uma chamada à API
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _isLoading = false;
      _question = 'Qual o nome do seu primeiro pet?'; // Exemplo
      _step = 1;
    });
  }

  void _validateAnswer() async {
    setState(() { _isLoading = true; _message = null; });
    // Simulação: normalmente faria uma chamada à API
    await Future.delayed(Duration(seconds: 1));
    if (_answerController.text.trim().toLowerCase() == 'rex') { // Exemplo
      setState(() { _step = 2; _isLoading = false; });
    } else {
      setState(() { _isLoading = false; _message = 'Resposta incorreta.'; });
    }
  }

  void _resetPassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() { _message = 'As senhas não coincidem.'; });
      return;
    }
    setState(() { _isLoading = true; _message = null; });
    // Simulação: normalmente faria uma chamada à API
    await Future.delayed(Duration(seconds: 1));
    setState(() { _isLoading = false; _message = 'Senha redefinida com sucesso!'; _step = 0; });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_step == 0) ...[
            Text('Informe seu e-mail para recuperar a senha:'),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'E-mail'),
              validator: validateEmail,
            ),
            SizedBox(height: 16),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _getSecurityQuestion,
                    child: Text('Avançar'),
                  ),
          ] else if (_step == 1) ...[
            Text('Responda à pergunta de segurança:'),
            SizedBox(height: 8),
            Text(_question ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
            TextFormField(
              controller: _answerController,
              decoration: InputDecoration(labelText: 'Resposta'),
            ),
            SizedBox(height: 16),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _validateAnswer,
                    child: Text('Avançar'),
                  ),
          ] else if (_step == 2) ...[
            Text('Redefina sua senha:'),
            TextFormField(
              controller: _newPasswordController,
              decoration: InputDecoration(labelText: 'Nova senha'),
              obscureText: true,
              validator: validatePassword,
            ),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(labelText: 'Confirmar nova senha'),
              obscureText: true,
            ),
            SizedBox(height: 16),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _resetPassword,
                    child: Text('Redefinir senha'),
                  ),
          ],
          if (_message != null) ...[
            SizedBox(height: 16),
            Text(_message!, style: TextStyle(color: _message!.contains('sucesso') ? Colors.green : Colors.red)),
          ],
        ],
      ),
    );
  }
} 