import 'package:flutter/material.dart';
import 'dart:math';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with TickerProviderStateMixin {
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
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pawController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    // Configurar animações
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
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
    await Future.delayed(const Duration(milliseconds: 500));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _slideController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _scaleController.forward();
    _pawController.repeat();
  }

  void _generatePaws() {
    for (int i = 0; i < 25; i++) {
      _paws.add(_Paw(
        position: Offset(
          _random.nextDouble() * 500,
          _random.nextDouble() * 1000,
        ),
        scale: _random.nextDouble() * 0.6 + 0.2,
        opacity: _random.nextDouble() * 0.4 + 0.1,
        speed: _random.nextDouble() * 3 + 1,
      ));
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _pawController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fundo animado
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
                  Color(0xFFf5576c),
            ],
                stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
            child: AnimatedBuilder(
              animation: _pawAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: _PawPrintPainter(_paws, _pawAnimation.value),
                );
              },
            ),
          ),
          
          // Conteúdo principal
          SafeArea(
              child: SingleChildScrollView(
                  child: Column(
                    children: [
                  // Header
                  _buildHeader(),
                  
                  // Hero Section
                  _buildHeroSection(),
                  
                  // Features Section
                  _buildFeaturesSection(),
                  
                  // How it works
                  _buildHowItWorksSection(),
                  
                  // CTA Section
                  _buildCTASection(),
                  
                  // Footer
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                  Icons.pets_rounded,
                  color: Colors.white,
                  size: 24,
                        ),
                      ),
              const SizedBox(width: 12),
              const Text(
                          'PetConnect',
                          style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                            fontWeight: FontWeight.bold,
                ),
                              ),
                            ],
                          ),
          
          // Navigation
          Row(
            children: [
              _buildNavButton('Login', () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              )),
              const SizedBox(width: 16),
              _buildNavButton('Cadastre-se', () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterScreen()),
              ), true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(String text, VoidCallback onPressed, [bool isPrimary = false]) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isPrimary ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          border: isPrimary ? null : Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Text(
          text,
                          style: TextStyle(
            color: isPrimary ? const Color(0xFF667eea) : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
                          ),
        ),
                        ),
    );
  }

  Widget _buildHeroSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
                        child: FadeTransition(
                          opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
                          child: Column(
                            children: [
                const Text(
                  'Conectando o Mundo Pet',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                Text(
                  'A plataforma completa que une tutores, veterinários e lojistas em um só lugar. Cuide do seu pet com facilidade e segurança.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 18,
                    height: 1.5,
                          ),
                  textAlign: TextAlign.center,
                      ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildHeroButton(
                      'Começar Agora',
                      Icons.rocket_launch_rounded,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                          ),
                      true,
                      ),
                    const SizedBox(width: 20),
                    _buildHeroButton(
                      'Saiba Mais',
                      Icons.info_rounded,
                      () => _scrollToFeatures(),
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

  Widget _buildHeroButton(String text, IconData icon, VoidCallback onPressed, [bool isPrimary = false]) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: isPrimary ? Colors.white : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30),
          border: isPrimary ? null : Border.all(color: Colors.white.withOpacity(0.3)),
          boxShadow: isPrimary ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isPrimary ? const Color(0xFF667eea) : Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: isPrimary ? const Color(0xFF667eea) : Colors.white,
          fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 60),
      padding: const EdgeInsets.all(24),
      child: Column(
      children: [
          const Text(
            'Por que escolher o PetConnect?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          Row(
            children: [
              Expanded(child: _buildFeatureCard(
                Icons.pets_rounded,
                'Gestão Completa',
                'Cadastre e gerencie seus pets com facilidade. Acompanhe vacinas, consultas e cuidados.',
                Colors.blue,
              )),
              const SizedBox(width: 24),
              Expanded(child: _buildFeatureCard(
                Icons.local_hospital_rounded,
                'Serviços Veterinários',
                'Encontre veterinários qualificados e agende consultas com praticidade.',
                Colors.green,
              )),
              const SizedBox(width: 24),
              Expanded(child: _buildFeatureCard(
                Icons.shopping_bag_rounded,
                'Produtos Pet',
                'Compre ração, brinquedos e acessórios de qualidade em nossa rede de lojas.',
                Colors.orange,
              )),
      ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksSection() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 60),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            'Como Funciona',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          Row(
            children: [
              Expanded(child: _buildStepCard('1', 'Cadastre-se', 'Crie sua conta gratuitamente e escolha seu perfil')),
              const SizedBox(width: 24),
              Expanded(child: _buildStepCard('2', 'Conecte-se', 'Encontre veterinários, lojas e outros tutores')),
              const SizedBox(width: 24),
              Expanded(child: _buildStepCard('3', 'Cuide', 'Gerencie a saúde e bem-estar do seu pet')),
            ],
                  ),
                ],
              ),
    );
  }

  Widget _buildStepCard(String step, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
            child: Center(
              child: Text(
                step,
                style: const TextStyle(
                      color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
                    ),
                  ),
          const SizedBox(height: 20),
                        Text(
                          title,
                          style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
            textAlign: TextAlign.center,
                        ),
          const SizedBox(height: 12),
                        Text(
                          description,
                          style: TextStyle(
              color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCTASection() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 60),
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const Text(
            'Pronto para começar?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Junte-se a milhares de tutores que já confiam no PetConnect',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildHeroButton(
            'Criar Conta Gratuita',
            Icons.person_add_rounded,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RegisterScreen()),
            ),
            true,
                        ),
                      ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Divider(color: Colors.white24),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.pets_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'PetConnect',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                '© 2024 PetConnect. Todos os direitos reservados.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
          ),
        );
  }

  void _scrollToFeatures() {
    // Implementar scroll para a seção de features
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
        paw.position.dx + (animationValue * paw.speed * 15),
        paw.position.dy - (animationValue * paw.speed * 8),
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