import 'package:flutter/material.dart';
import 'package:petconnect_frontend/features/auth/auth_service.dart';
import 'package:petconnect_frontend/shared/widgets/custom_button.dart';
import 'package:petconnect_frontend/shared/widgets/custom_input.dart';

class DynamicRegisterForm extends StatefulWidget {
  const DynamicRegisterForm({Key? key}) : super(key: key);

  @override
  _DynamicRegisterFormState createState() => _DynamicRegisterFormState();
}

class _DynamicRegisterFormState extends State<DynamicRegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  String? _selectedUserType;
  final List<String> _userTypes = ['TUTOR', 'VETERINARIO', 'LOJISTA'];

  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedUserType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecione um tipo de perfil.')),
        );
        return;
      }

      setState(() { _isLoading = true; });

      final userData = {
        'fullName': _fullNameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'userType': _selectedUserType!,
      };

      try {
        final message = await _authService.register(userData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        _formKey.currentState?.reset();
        _fullNameController.clear();
        _emailController.clear();
        _passwordController.clear();
        setState(() {
          _selectedUserType = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst("Exception: ", ""))),
        );
      } finally {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomInput(
            controller: _fullNameController,
            label: 'Nome completo',
            validator: (value) => (value?.isEmpty ?? true) ? 'Campo obrigatório' : null,
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          CustomInput(
            controller: _passwordController,
            label: 'Senha',
            obscureText: true,
            validator: (value) => (value?.isEmpty ?? true) ? 'Campo obrigatório' : null,
          ),
          const SizedBox(height: 24),
          
          // Novo seletor de perfil animado
          Text(
            'Selecione o tipo de perfil',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          _buildProfileTypeSelector(),

          const SizedBox(height: 24),
          if (_isLoading)
            const CircularProgressIndicator()
          else
            CustomButton(
              text: 'Cadastrar',
              onPressed: _register,
            ),
        ],
      ),
    );
  }

  Widget _buildProfileTypeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildTypeCard(type: 'TUTOR', icon: Icons.pets, label: 'Tutor'),
        _buildTypeCard(type: 'VETERINARIO', icon: Icons.medical_services, label: 'Veterinário'),
        _buildTypeCard(type: 'LOJISTA', icon: Icons.store, label: 'Lojista'),
      ],
    );
  }

  Widget _buildTypeCard({required String type, required IconData icon, required String label}) {
    final bool isSelected = _selectedUserType == type;
    final Color color = isSelected ? Theme.of(context).primaryColor : Colors.grey;
    final Color contentColor = isSelected ? Colors.white : Colors.black87;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedUserType = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: color.withOpacity(0.7),
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: contentColor),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: contentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
