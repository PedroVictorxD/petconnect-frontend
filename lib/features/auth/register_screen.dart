import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';
import '../tutor/tutor_home_screen.dart';
import '../veterinario/vet_home_screen.dart';
import '../lojista/lojista_home_screen.dart';
import '../admin/admin_home_screen.dart';
import 'user_type_selection.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _crmvController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _responsibleNameController = TextEditingController();
  final _storeTypeController = TextEditingController();
  final _operatingHoursController = TextEditingController();
  
  bool _obscurePassword = true;
  String? _selectedUserType;

  final _phoneFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: { "#": RegExp(r'[0-9]') },
  );
  final _cnpjFormatter = MaskTextInputFormatter(
    mask: '##.###.###/####-##',
    filter: { "#": RegExp(r'[0-9]') },
  );
  final _crmvFormatter = MaskTextInputFormatter(
    mask: 'AA-#####',
    filter: { "A": RegExp(r'[A-Za-z]'), "#": RegExp(r'[0-9]') },
  );

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _crmvController.dispose();
    _cnpjController.dispose();
    _responsibleNameController.dispose();
    _storeTypeController.dispose();
    _operatingHoursController.dispose();
    super.dispose();
  }

  void _navigateToHome(User user) {
    Widget homeScreen;
    
    if (user.isVeterinario) {
      homeScreen = const VetHomeScreen();
    } else if (user.isLojista) {
      homeScreen = const LojistaHomeScreen();
    } else if (user.isAdmin) {
      homeScreen = const AdminHomeScreen();
    } else {
      homeScreen = const TutorHomeScreen();
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => homeScreen),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    // Converte o tipo de usuário para o formato esperado pelo backend (primeira letra maiúscula)
    final String dtype = _selectedUserType![0].toUpperCase() + _selectedUserType!.substring(1);

    final user = User(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      phone: _phoneController.text.trim(),
      location: _locationController.text.trim(),
      dtype: dtype,
      crmv: _selectedUserType == 'veterinario' ? _crmvController.text.trim() : null,
      cnpj: _selectedUserType == 'lojista' ? _cnpjController.text.trim() : null,
      responsibleName: _selectedUserType == 'lojista' ? _responsibleNameController.text.trim() : null,
      storeType: _selectedUserType == 'lojista' ? _storeTypeController.text.trim() : null,
      operatingHours: _selectedUserType == 'lojista' ? _operatingHoursController.text.trim() : null,
    );

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.register(user, _selectedUserType!);

    if (success && authProvider.currentUser != null) {
      _navigateToHome(authProvider.currentUser!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Erro ao registrar'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro'),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: const Color(0xFF667eea),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: const Icon(
                              Icons.pets,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Título
                          const Text(
                            'Criar Conta',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2d3748),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Botão para selecionar tipo de usuário
                          ElevatedButton.icon(
                            icon: const Icon(Icons.person_outline),
                            label: Text(
                              _selectedUserType == null
                                  ? 'Selecionar Tipo de Usuário'
                                  : 'Tipo: ${_selectedUserType![0].toUpperCase()}${_selectedUserType!.substring(1)}',
                            ),
                            onPressed: () async {
                              final selected = await showDialog<String>(
                                context: context,
                                builder: (context) => const UserTypeSelectionScreen(),
                              );
                              if (selected != null) {
                                setState(() {
                                  _selectedUserType = selected;
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Nome
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Nome',
                              hintText: 'Ex: João da Silva',
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira seu nome';
                              }
                              if (!RegExp(r"^[A-Za-zÀ-ÿ'\-\s]{3,}$").hasMatch(value)) {
                                return 'Nome deve ter pelo menos 3 letras. Ex: João da Silva';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Email
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'Ex: joao@email.com',
                              prefixIcon: const Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira seu email';
                              }
                              if (!RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(value)) {
                                return 'Digite um email válido. Ex: joao@email.com';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Senha
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Senha',
                              hintText: 'Mínimo 6 caracteres',
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira sua senha';
                              }
                              if (!RegExp(r'^.{6,}$').hasMatch(value)) {
                                return 'A senha deve ter pelo menos 6 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Telefone
                          TextFormField(
                            controller: _phoneController,
                            inputFormatters: [_phoneFormatter],
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'Telefone',
                              hintText: '(84) 98888-5496',
                              prefixIcon: const Icon(Icons.phone),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira seu telefone';
                              }
                              if (!_phoneFormatter.isFill()) {
                                return 'Telefone deve estar no formato (84) 98888-5496';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Localização
                          TextFormField(
                            controller: _locationController,
                            decoration: InputDecoration(
                              labelText: 'Localização',
                              hintText: 'Ex: Fortaleza, CE',
                              prefixIcon: const Icon(Icons.location_on),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira sua localização';
                              }
                              if (!RegExp(r'^[A-Za-zÀ-ÿ0-9,\s-]{2,}$').hasMatch(value)) {
                                return 'Ex: Fortaleza, CE';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Campos específicos para veterinário
                          if (_selectedUserType == 'veterinario') ...[
                            TextFormField(
                              controller: _crmvController,
                              inputFormatters: [_crmvFormatter],
                              decoration: InputDecoration(
                                labelText: 'CRMV',
                                hintText: 'Ex: SP-12345',
                                prefixIcon: const Icon(Icons.medical_services),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, insira seu CRMV';
                                }
                                if (!_crmvFormatter.isFill()) {
                                  return 'CRMV deve ser como SP-12345';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Campos específicos para lojista
                          if (_selectedUserType == 'lojista') ...[
                            TextFormField(
                              controller: _cnpjController,
                              inputFormatters: [_cnpjFormatter],
                              decoration: InputDecoration(
                                labelText: 'CNPJ',
                                hintText: 'Ex: 12.345.678/0001-99',
                                prefixIcon: const Icon(Icons.business),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, insira o CNPJ';
                                }
                                if (!_cnpjFormatter.isFill()) {
                                  return 'CNPJ deve ser como 12.345.678/0001-99';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _responsibleNameController,
                              decoration: InputDecoration(
                                labelText: 'Nome do Responsável',
                                hintText: 'Ex: Maria Oliveira',
                                prefixIcon: const Icon(Icons.person),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, insira o nome do responsável';
                                }
                                if (!RegExp(r"^[A-Za-zÀ-ÿ'\-\s]{3,}$").hasMatch(value)) {
                                  return 'Nome do responsável deve ter pelo menos 3 letras. Ex: Maria Oliveira';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _storeTypeController,
                              decoration: InputDecoration(
                                labelText: 'Tipo de Loja',
                                hintText: 'Ex: Petshop',
                                prefixIcon: const Icon(Icons.store),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, insira o tipo de loja';
                                }
                                if (!RegExp(r'^[A-Za-zÀ-ÿ\s]{3,}$').hasMatch(value)) {
                                  return 'Tipo de loja deve ter pelo menos 3 letras. Ex: Petshop';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _operatingHoursController,
                              decoration: InputDecoration(
                                labelText: 'Horário de Funcionamento',
                                hintText: 'Ex: Segunda a Sexta, 8h às 18h',
                                prefixIcon: const Icon(Icons.access_time),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Botão de registro
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              return SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: authProvider.isLoading ? null : _register,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF667eea),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: authProvider.isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : const Text(
                                          'Cadastrar',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),

                          // Link para login
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Já tem uma conta? Faça login',
                              style: TextStyle(
                                color: Color(0xFF667eea),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 