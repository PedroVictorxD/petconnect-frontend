import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'dart:math';
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

class _RegisterScreenState extends State<RegisterScreen> with TickerProviderStateMixin {
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

  // Animação
  AnimationController? _pawAnimationController;
  final List<_Paw> _paws = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }
  
  void _initializeAnimations() {
    _pawAnimationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final size = MediaQuery.of(context).size;
      for (int i = 0; i < 30; i++) {
        _paws.add(_Paw.create(size, _random));
      }
      setState(() {});
    });
  }

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
    _pawAnimationController?.dispose();
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
    if (_selectedUserType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione um tipo de usuário.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final String dtype = _selectedUserType!.toUpperCase();
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

    if (mounted) {
      if (success && authProvider.currentUser != null) {
        _navigateToHome(authProvider.currentUser!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Erro ao registrar. Verifique os dados.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // Fundo com gradiente
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
            ),
          ),

          // Animação de Patinhas
          if (_pawAnimationController != null)
            AnimatedBuilder(
              animation: _pawAnimationController!,
              builder: (context, child) {
                return CustomPaint(
                  painter: _PawPrintPainter(_paws, _pawAnimationController!.value),
                );
              },
            ),

          // Formulário central
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _buildGlassmorphismContainer(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _buildFormFields(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassmorphismContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: child,
        ),
      ),
    );
  }

  List<Widget> _buildFormFields() {
    final authProvider = Provider.of<AuthProvider>(context);
    
    List<Widget> fields = [
      // Logo e Título
      const Icon(Icons.pets, color: Colors.white, size: 48),
      const SizedBox(height: 16),
      const Text(
        'Criar Conta',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      const SizedBox(height: 32),

      // Botão Selecionar Tipo
      _buildUserTypeButton(),
      const SizedBox(height: 24),

      // Campos Comuns
      _buildTextField(
        controller: _nameController,
        label: 'Nome',
        icon: Icons.person_outline,
        validator: (v) => (v == null || v.length < 3) ? 'Nome inválido' : null,
      ),
      const SizedBox(height: 16),
      _buildTextField(
        controller: _emailController,
        label: 'Email',
        icon: Icons.email_outlined,
        keyboardType: TextInputType.emailAddress,
        validator: (v) => (v == null || !v.contains('@')) ? 'Email inválido' : null,
      ),
      const SizedBox(height: 16),
      _buildTextField(
        controller: _passwordController,
        label: 'Senha',
        icon: Icons.lock_outline,
        obscureText: _obscurePassword,
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.white70,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        validator: (v) => (v == null || v.length < 6) ? 'Senha muito curta (mín. 6)' : null,
      ),
      const SizedBox(height: 16),
      _buildTextField(
        controller: _phoneController,
        label: 'Telefone',
        icon: Icons.phone_outlined,
        keyboardType: TextInputType.phone,
        formatter: _phoneFormatter,
        validator: (v) => (v == null || v.length < 14) ? 'Telefone inválido' : null,
      ),
      const SizedBox(height: 16),
      _buildTextField(
        controller: _locationController,
        label: 'Localização',
        icon: Icons.location_on_outlined,
        validator: (v) {
          if (v == null || v.trim().isEmpty) {
            return 'Campo obrigatório';
          }
          return null;
        },
      ),
    ];

    // Campos Condicionais
    if (_selectedUserType == 'veterinario') {
      fields.addAll([
        const SizedBox(height: 16),
        _buildTextField(
          controller: _crmvController,
          label: 'CRMV',
          icon: Icons.medical_information_outlined,
          formatter: _crmvFormatter,
           validator: (v) => (v == null || v.isEmpty) ? 'CRMV obrigatório' : null,
        ),
      ]);
    } else if (_selectedUserType == 'lojista') {
      fields.addAll([
        const SizedBox(height: 16),
        _buildTextField(
          controller: _cnpjController,
          label: 'CNPJ',
          icon: Icons.business_center_outlined,
          formatter: _cnpjFormatter,
           validator: (v) => (v == null || v.length < 18) ? 'CNPJ inválido' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _responsibleNameController,
          label: 'Nome do Responsável',
          icon: Icons.badge_outlined,
          validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
        ),
        const SizedBox(height: 16),
         _buildTextField(
          controller: _storeTypeController,
          label: 'Tipo de Loja',
          icon: Icons.store_outlined,
          validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
        ),
         const SizedBox(height: 16),
         _buildTextField(
          controller: _operatingHoursController,
          label: 'Horário de Funcionamento',
          icon: Icons.access_time_outlined,
          validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
        ),
      ]);
    }

    // Botões
    fields.addAll([
      const SizedBox(height: 32),
      authProvider.isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF9370DB),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Cadastrar', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
      const SizedBox(height: 16),
      TextButton(
        onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
        child: const Text(
          'Já tem uma conta? Faça login',
          style: TextStyle(color: Colors.white70),
        ),
      ),
    ]);

    return fields;
  }

  Widget _buildUserTypeButton() {
    return OutlinedButton.icon(
      icon: const Icon(Icons.person_search_outlined, color: Colors.white),
      label: Text(
        _selectedUserType == null
            ? 'Selecionar Tipo de Usuário *'
            : 'Tipo: ${_selectedUserType![0].toUpperCase()}${_selectedUserType!.substring(1)}',
        style: const TextStyle(color: Colors.white),
      ),
      onPressed: () async {
        final selected = await showGeneralDialog<String>(
          context: context,
          barrierDismissible: true,
          barrierLabel: '',
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (context, animation1, animation2) => const SizedBox(),
          transitionBuilder: (context, a1, a2, widget) {
            final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
            return Transform(
              transform: Matrix4.translationValues(0.0, curvedValue * -200, 0.0),
              child: Opacity(
                opacity: a1.value,
                child: const UserTypeSelectionScreen(),
              ),
            );
          },
        );
        if (selected != null) {
          setState(() => _selectedUserType = selected);
        }
      },
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        side: BorderSide(color: Colors.white.withOpacity(0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    MaskTextInputFormatter? formatter,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: formatter != null ? [formatter] : [],
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.7)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF9370DB)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
    );
  }
}


// Classes de Animação
class _Paw {
  late Offset position;
  late double scale;
  late double opacity;
  late double speed;
  late double angle;

  _Paw.create(Size size, Random random) {
    position = Offset(random.nextDouble() * size.width, random.nextDouble() * size.height);
    scale = random.nextDouble() * 0.3 + 0.2;
    opacity = random.nextDouble() * 0.15 + 0.05;
    speed = random.nextDouble() * 20 + 10;
    angle = random.nextDouble() * 2 * pi;
  }
}

class _PawPrintPainter extends CustomPainter {
  final List<_Paw> paws;
  final double animationValue;

  _PawPrintPainter(this.paws, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    if (paws.isEmpty) return;

    for (final paw in paws) {
      final currentY = paw.position.dy - (animationValue * size.height * 0.2 * paw.speed / 20);
      final finalPosition = Offset(paw.position.dx, currentY % size.height);

      paint.color = Colors.white.withOpacity(paw.opacity);

      // Desenho da patinha
      final pawSize = 25.0 * paw.scale;
      final center = finalPosition;

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(paw.angle);
      canvas.translate(-center.dx, -center.dy);
      
      final mainPad = RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: pawSize, height: pawSize * 0.9),
        Radius.circular(pawSize * 0.3),
      );
      canvas.drawRRect(mainPad, paint);

      final toeSize = pawSize * 0.25;
      final toeY = center.dy - (pawSize * 0.6);
      canvas.drawCircle(Offset(center.dx - pawSize * 0.4, toeY), toeSize, paint);
      canvas.drawCircle(Offset(center.dx + pawSize * 0.4, toeY), toeSize, paint);
      canvas.drawCircle(Offset(center.dx - pawSize * 0.15, toeY - toeSize * 0.5), toeSize, paint);
      canvas.drawCircle(Offset(center.dx + pawSize * 0.15, toeY - toeSize * 0.5), toeSize, paint);
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _PawPrintPainter oldDelegate) => true;
} 