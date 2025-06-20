import 'package:flutter/material.dart';
import '../../../shared/themes/app_theme.dart';

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeroSection(context),
                  const SizedBox(height: 40),
                  _buildProfileCards(context),
                  const SizedBox(height: 60),
                  _buildHowItWorksSection(context),
                  const SizedBox(height: 60),
                  _buildFooterLinks(context),
                ],
              ),
            ),
          ),
        ],
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

  Widget _buildProfileCards(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _profileCard(
            context,
            icon: Icons.pets,
            title: 'Para Tutores',
            description: 'Encontre veterinários e produtos de qualidade para seu pet.',
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 24),
          _profileCard(
            context,
            icon: Icons.medical_services,
            title: 'Para Veterinários',
            description: 'Gerencie seus serviços e conecte-se com tutores.',
            color: AppTheme.secondaryColor,
          ),
          const SizedBox(width: 24),
          _profileCard(
            context,
            icon: Icons.store,
            title: 'Para Lojistas',
            description: 'Venda seus produtos e alcance mais clientes.',
            color: AppTheme.accentColor,
          ),
        ],
      ),
    );
  }

  Widget _profileCard(BuildContext context, {required IconData icon, required String title, required String description, required Color color}) {
    return Expanded(
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: color.withOpacity(0.08),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: color,
                child: Icon(icon, color: Colors.white, size: 36),
              ),
              const SizedBox(height: 18),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: color)),
              const SizedBox(height: 10),
              Text(description, style: TextStyle(color: AppTheme.textPrimaryColor, fontSize: 15), textAlign: TextAlign.center),
            ],
          ),
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

  Widget _buildFooterLinks(BuildContext context) {
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