import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'dart:ui';
import '../../providers/auth_provider.dart';
import '../tutor/tutor_home_screen.dart';
import '../veterinario/vet_home_screen.dart';
import '../lojista/lojista_home_screen.dart';
import '../admin/admin_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  // Animações
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _pawController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pawAnimation;

  // Patinhas flutuantes
  final List<_Paw> _paws = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    
    // Inicializar animações
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pawController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Configurar animações
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _pawAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pawController, curve: Curves.easeInOut),
    );

    // Iniciar animações
    _startAnimations();
    _generatePaws();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _slideController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _scaleController.forward();
    _pawController.repeat();
  }

  void _generatePaws() {
    for (int i = 0; i < 15; i++) {
      _paws.add(_Paw(
        position: Offset(
          _random.nextDouble() * 400,
          _random.nextDouble() * 800,
        ),
        scale: _random.nextDouble() * 0.5 + 0.3,
        opacity: _random.nextDouble() * 0.3 + 0.1,
        speed: _random.nextDouble() * 2 + 1,
      ));
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _pawController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _navigateToHome(String? userType) {
    Widget homeScreen;
    
    switch (userType) {
      case 'VETERINARIO':
        homeScreen = const VetHomeScreen();
        break;
      case 'LOJISTA':
        homeScreen = const LojistaHomeScreen();
        break;
      case 'ADMIN':
        homeScreen = const AdminHomeScreen();
        break;
      case 'TUTOR':
      default:
        homeScreen = const TutorHomeScreen();
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => homeScreen),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && authProvider.userType != null) {
      _navigateToHome(authProvider.userType);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Erro ao fazer login'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fundo animado com patinhas
          Container(
            width: double.infinity,
            height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
                  Color(0xFFf093fb),
                ],
                stops: [0.0, 0.6, 1.0],
          ),
        ),
            child: CustomPaint(
              painter: _PawPrintPainter(_paws, _pawAnimation.value),
            ),
          ),
          
          // Conteúdo principal
          SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: _buildLoginCard(),
                      ),
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

  Widget _buildLoginCard() {
    return Container(
                    padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withOpacity(0.1),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                // Logo animado
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 1000),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        width: 100,
                        height: 100,
                            decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF667eea).withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            )
                          ],
                            ),
                            child: const Icon(
                          Icons.pets_rounded,
                          size: 50,
                              color: Colors.white,
                            ),
                      ),
                    );
                  },
                          ),
                          const SizedBox(height: 24),
                          
                          // Título
                          const Text(
                            'PetConnect',
                            style: TextStyle(
                    fontSize: 32,
                              fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                Text(
                            'Faça login para continuar',
                            style: TextStyle(
                              fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                const SizedBox(height: 40),

                // Campo de email animado
                          TextFormField(
                            controller: _emailController,
                  decoration: _buildInputDecoration(
                              labelText: 'Email',
                    prefixIcon: Icons.email_outlined,
                              ),
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => (value == null || !value.contains('@'))
                      ? 'Digite um email válido'
                      : null,
                          ),
                const SizedBox(height: 20),

                // Campo de senha animado
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                  decoration: _buildInputDecoration(
                              labelText: 'Senha',
                    prefixIcon: Icons.lock_outline,
                              suffixIcon: IconButton(
                                icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: Colors.white.withOpacity(0.7),
                                ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                              ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) => (value == null || value.length < 6)
                      ? 'A senha deve ter pelo menos 6 caracteres'
                      : null,
                ),
                const SizedBox(height: 32),

                // Botão de login animado
                _buildAnimatedButton(),
                          const SizedBox(height: 24),

                          // Link para registro
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Não tem uma conta? ',
                              style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/register'),
                      child: const Text(
                        'Cadastre-se',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  ],
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String labelText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
      prefixIcon: Icon(prefixIcon, color: Colors.white.withOpacity(0.8)),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
      ),
    );
  }

  Widget _buildAnimatedButton() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667eea).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _isLoading ? null : _login,
                child: Center(
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Entrar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Classes para as patinhas animadas
class _Paw {
  Offset position;
  double scale;
  double opacity;
  double speed;

  _Paw({
    required this.position,
    required this.scale,
    required this.opacity,
    required this.speed,
  });
}

class _PawPrintPainter extends CustomPainter {
  final List<_Paw> paws;
  final double animationValue;
  final Random _random = Random();

  _PawPrintPainter(this.paws, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (var paw in paws) {
      final paint = Paint()
        ..color = Colors.white.withOpacity(paw.opacity * animationValue)
        ..style = PaintingStyle.fill;
      
      final angle = _random.nextDouble() * 0.5 - 0.25;
      final offset = Offset(
        paw.position.dx + (animationValue * paw.speed * 10),
        paw.position.dy - (animationValue * paw.speed * 5),
      );

      canvas.save();
      canvas.translate(offset.dx, offset.dy);
      canvas.rotate(angle);
      canvas.scale(paw.scale);
      
      _drawIndividualPaw(canvas, Offset.zero, paint);
      canvas.restore();
    }
  }

  void _drawIndividualPaw(Canvas canvas, Offset center, Paint paint) {
    // Palma
    final mainPad = Rect.fromCenter(center: center, width: 20, height: 18);
    canvas.drawRRect(RRect.fromRectAndRadius(mainPad, const Radius.circular(5)), paint);
    // Dedos
    canvas.drawCircle(center + const Offset(0, -14), 5, paint);
    canvas.drawCircle(center + const Offset(-10, -8), 4.5, paint);
    canvas.drawCircle(center + const Offset(10, -8), 4.5, paint);
    canvas.drawCircle(center + const Offset(-6, 2), 4, paint);
    canvas.drawCircle(center + const Offset(6, 2), 4, paint);
  }

  @override
  bool shouldRepaint(covariant _PawPrintPainter oldDelegate) => true;
} 