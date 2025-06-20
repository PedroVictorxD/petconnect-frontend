import 'package:flutter/material.dart';
import '../../../shared/themes/app_theme.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_input.dart';

class ForgotPasswordForm extends StatefulWidget {
  @override
  _ForgotPasswordFormState createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _message;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendRecovery() async {
    if (!_formKey.currentState!.validate()) return;
    
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
          CustomInput(
            label: 'E-mail',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Informe o e-mail';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Por favor, insira um email válido';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          CustomButton(
            text: 'Enviar link de recuperação',
            isLoading: _isLoading,
            onPressed: _sendRecovery,
          ),
          if (_message != null) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.successColor.withOpacity(0.3)),
              ),
              child: Text(
                _message!,
                style: TextStyle(
                  color: AppTheme.successColor,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
} 