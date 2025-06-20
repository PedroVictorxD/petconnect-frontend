import 'package:flutter/material.dart';
import '../../../shared/themes/app_theme.dart';

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header/Navigation
            _buildHeader(context),
            
            // Hero Section
            _buildHeroSection(context),
            
            // Features Section
            _buildFeaturesSection(context),
            
            // How it works Section
            _buildHowItWorksSection(context),
            
            // CTA Section
            _buildCTASection(context),
            
            // Footer
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.pets,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Pet Connect',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          // Navigation Buttons
          Row(
            children: [
              OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: Text('Entrar'),
              ),
              SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: Text('Cadastrar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withOpacity(0.1),
            AppTheme.primaryLightColor.withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        children: [
          // Main Heading
          Text(
            'Conectando o Mundo Pet',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: AppTheme.textPrimaryColor,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          
          // Subtitle
          Text(
            'A plataforma completa para tutores, veterinários e lojistas cuidarem dos seus pets com qualidade e confiança.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondaryColor,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
          ),
          SizedBox(height: 40),
          
          // CTA Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text('Começar Agora'),
              ),
              SizedBox(width: 20),
              OutlinedButton(
                onPressed: () => _scrollToFeatures(context),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text('Saiba Mais'),
              ),
            ],
          ),
          SizedBox(height: 60),
          
          // Hero Image with Pet Icons
          Container(
            width: 400,
            height: 250,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle
                Container(
                  width: 300,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                // Pet icons arranged in a circle
                Positioned(
                  top: 20,
                  left: 50,
                  child: _buildPetIcon(Icons.pets, 'Cachorro', AppTheme.primaryColor),
                ),
                Positioned(
                  top: 40,
                  right: 60,
                  child: _buildPetIcon(Icons.pets, 'Gato', AppTheme.secondaryColor),
                ),
                Positioned(
                  bottom: 30,
                  left: 80,
                  child: _buildPetIcon(Icons.pets, 'Ave', AppTheme.accentColor),
                ),
                Positioned(
                  bottom: 50,
                  right: 80,
                  child: _buildPetIcon(Icons.pets, 'Peixe', AppTheme.infoColor),
                ),
                // Center icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetIcon(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Column(
        children: [
          Text(
            'Por que escolher o Pet Connect?',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: AppTheme.textPrimaryColor,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            'Oferecemos soluções completas para todos os envolvidos no cuidado dos pets',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 60),
          
          // Features Grid
          Row(
            children: [
              Expanded(
                child: _buildFeatureCard(
                  context,
                  icon: Icons.person,
                  title: 'Para Tutores',
                  description: 'Encontre veterinários e produtos de qualidade para seu pet.',
                  color: AppTheme.primaryColor,
                  petIcon: Icons.pets,
                ),
              ),
              SizedBox(width: 24),
              Expanded(
                child: _buildFeatureCard(
                  context,
                  icon: Icons.local_hospital,
                  title: 'Para Veterinários',
                  description: 'Gerencie seus serviços e conecte-se com tutores.',
                  color: AppTheme.secondaryColor,
                  petIcon: Icons.medical_services,
                ),
              ),
              SizedBox(width: 24),
              Expanded(
                child: _buildFeatureCard(
                  context,
                  icon: Icons.store,
                  title: 'Para Lojistas',
                  description: 'Venda seus produtos e alcance mais clientes.',
                  color: AppTheme.accentColor,
                  petIcon: Icons.shopping_bag,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required IconData petIcon,
  }) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            // Main icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                size: 40,
                color: color,
              ),
            ),
            SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            // Pet icon decoration
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    petIcon,
                    size: 16,
                    color: color,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Pet Friendly',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHowItWorksSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      color: AppTheme.backgroundColor,
      child: Column(
        children: [
          Text(
            'Como Funciona',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: AppTheme.textPrimaryColor,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 60),
          
          // Steps
          Row(
            children: [
              Expanded(
                child: _buildStepCard(
                  context,
                  number: '1',
                  title: 'Cadastre-se',
                  description: 'Crie sua conta escolhendo seu perfil: Tutor, Veterinário ou Lojista.',
                  icon: Icons.person_add,
                ),
              ),
              SizedBox(width: 24),
              Expanded(
                child: _buildStepCard(
                  context,
                  number: '2',
                  title: 'Configure seu Perfil',
                  description: 'Adicione suas informações específicas e comece a usar a plataforma.',
                  icon: Icons.settings,
                ),
              ),
              SizedBox(width: 24),
              Expanded(
                child: _buildStepCard(
                  context,
                  number: '3',
                  title: 'Conecte-se',
                  description: 'Encontre serviços, produtos e outros usuários da comunidade pet.',
                  icon: Icons.connect_without_contact,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(BuildContext context, {
    required String number,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Column(
      children: [
        // Number circle with icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 15,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                number,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Positioned(
                bottom: 8,
                child: Icon(
                  icon,
                  color: Colors.white.withOpacity(0.8),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCTASection(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryDarkColor,
          ],
        ),
      ),
      child: Column(
        children: [
          // Pet icons decoration
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSmallPetIcon(Icons.pets, Colors.white.withOpacity(0.8)),
              SizedBox(width: 20),
              _buildSmallPetIcon(Icons.favorite, Colors.white.withOpacity(0.8)),
              SizedBox(width: 20),
              _buildSmallPetIcon(Icons.pets, Colors.white.withOpacity(0.8)),
            ],
          ),
          SizedBox(height: 30),
          Text(
            'Pronto para começar?',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            'Junte-se à comunidade Pet Connect e descubra uma nova forma de cuidar dos pets.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/register'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.pets, size: 20),
                SizedBox(width: 8),
                Text('Criar Conta Grátis'),
              ],
            ),
          ),
          SizedBox(height: 30),
          // Bottom pet icons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSmallPetIcon(Icons.favorite, Colors.white.withOpacity(0.6)),
              SizedBox(width: 20),
              _buildSmallPetIcon(Icons.pets, Colors.white.withOpacity(0.6)),
              SizedBox(width: 20),
              _buildSmallPetIcon(Icons.favorite, Colors.white.withOpacity(0.6)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallPetIcon(IconData icon, Color color) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(
        icon,
        color: color,
        size: 16,
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      color: AppTheme.textPrimaryColor,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.pets,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Pet Connect',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              // Social Links
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.facebook, color: Colors.white),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.phone, color: Colors.white),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.email, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24),
          Divider(color: Colors.white.withOpacity(0.3)),
          SizedBox(height: 24),
          Text(
            '© 2024 Pet Connect. Todos os direitos reservados.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _scrollToFeatures(BuildContext context) {
    // Implementar scroll suave para a seção de features
    // Por enquanto, apenas navega para o registro
    Navigator.pushNamed(context, '/register');
  }
} 