import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/rendering.dart';

import '../../models/pet.dart';
import '../../models/product.dart';
import '../../models/user.dart';
import '../../models/vet_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';

// --- WIDGET PRINCIPAL ---

class TutorHomeScreen extends StatefulWidget {
  const TutorHomeScreen({super.key});

  @override
  State<TutorHomeScreen> createState() => _TutorHomeScreenState();
}

class _TutorHomeScreenState extends State<TutorHomeScreen> with TickerProviderStateMixin {
  // --- VARIÁVEIS DE ESTADO ---

  // Formulário de Pet
  final _petFormKey = GlobalKey<FormState>();
  final _petNameController = TextEditingController();
  final _petBreedController = TextEditingController();
  final _petAgeController = TextEditingController();
  final _petWeightController = TextEditingController();
  final _petPhotoUrlController = TextEditingController();
  String _petType = 'Cachorro';
  String _petActivityLevel = 'Médio';

  // Calculadora
  final _calculatorWeightController = TextEditingController();
  String _calculatorPetType = 'Cachorro';
  String _calculatorLifeStage = 'Adulto';
  String _calculatorActivityLevel = 'Médio';
  double? _dailyFoodAmount;
  Pet? _selectedPetForCalc;
  bool _useSelectedPetData = false;

  // UI
  String _selectedSection = 'pets';
  List<Offset> _pawPrints = [];

  // Animação do Fundo
  AnimationController? _pawAnimationController;
  final List<_Paw> _paws = [];
  final Random _random = Random();

  // --- CICLO DE VIDA ---

  @override
  void initState() {
    super.initState();
    _pawAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // A duração não importa pois a animação se repete
    )..addListener(_updatePawAnimation);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePaws();
      _pawAnimationController?.repeat();
      _refreshData();
    });
  }

  @override
  void dispose() {
    _pawAnimationController?.dispose();
    // Limpeza dos controllers
    _petNameController.dispose();
    _petBreedController.dispose();
    _petAgeController.dispose();
    _petWeightController.dispose();
    _petPhotoUrlController.dispose();
    _calculatorWeightController.dispose();
    super.dispose();
  }

  // --- MÉTODOS DE DADOS ---

  Future<void> _refreshData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final user = authProvider.currentUser;
    if (user != null && user.id != null) {
      await dataProvider.fetchPetsForTutor(user.id!);
      await dataProvider.fetchProducts();
      await dataProvider.fetchServices();
    }
  }

  void _savePet(Pet? existingPet) async {
    if (_petFormKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;
      if (user != null && user.id != null) {
        
        final petData = Pet(
          id: existingPet?.id,
          name: _petNameController.text,
          breed: _petBreedController.text,
          age: int.parse(_petAgeController.text),
          weight: double.parse(_petWeightController.text),
          type: _petType,
          activityLevel: _petActivityLevel,
          photoUrl: _petPhotoUrlController.text,
          tutor: {
            'id': user.id!,
            'name': user.name,
            'email': user.email,
            'phone': user.phone,
            'location': user.location,
            'dtype': user.dtype,
          },
        );

        if (existingPet == null) {
          await Provider.of<DataProvider>(context, listen: false).createPet(petData);
        } else if (petData.id != null) {
          await Provider.of<DataProvider>(context, listen: false).updatePet(petData.id!, petData);
        }

        Navigator.of(context).pop();
        _refreshData();
      }
    }
  }

  void _deletePet(int petId) async {
    await Provider.of<DataProvider>(context, listen: false).deletePet(petId);
    _refreshData();
    Navigator.of(context).pop(); // Fecha o dialog de confirmação ou o de edição
  }

  // --- MÉTODOS DE ANIMAÇÃO DE FUNDO ---
  void _initializePaws() {
    if (!mounted) return;
    final size = MediaQuery.of(context).size;
    setState(() {
      for (int i = 0; i < 40; i++) {
        _paws.add(_Paw(
          position: Offset(
            _random.nextDouble() * size.width,
            _random.nextDouble() * size.height,
          ),
          scale: _random.nextDouble() * 0.4 + 0.6, // Escala entre 0.6 e 1.0
          opacity: _random.nextDouble() * 0.04 + 0.02, // Opacidade entre 0.02 e 0.06
          speed: _random.nextDouble() * 15 + 10, // Velocidade entre 10 e 25
        ));
      }
    });
  }

  void _updatePawAnimation() {
    if (!mounted) return;
    final size = MediaQuery.of(context).size;
    const double frameTime = 1 / 60; 

    setState(() {
      for (var paw in _paws) {
        paw.position = paw.position.translate(0, -paw.speed * frameTime);
        if (paw.position.dy < -50) {
          paw.position = Offset(_random.nextDouble() * size.width, size.height + 50);
        }
      }
    });
  }

  // --- CONSTRUÇÃO DA UI ---

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0), // AppBar invisível
        child: AppBar(elevation: 0, backgroundColor: Colors.transparent),
      ),
      extendBody: true,
      body: Stack(
        children: [
          // Fundo com gradiente
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFFf093fb)],
                stops: [0.0, 0.6, 1.0],
              ),
            ),
          ),
          _buildPawPrintBackground(),

          // Conteúdo principal
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  _buildHeader(user),
                  const SizedBox(height: 24),
                  _buildSectionSelector(),
                  const SizedBox(height: 24),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                    child: LayoutBuilder(
                      builder: (context, constraints) => _buildCurrentSection(constraints: constraints)
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Botões flutuantes
          _buildFloatingActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader(User? user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bem-vindo(a) de volta,',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                if (user != null)
                  Text(
                    user.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 2, color: Colors.black26)],
                    ),
                  ),
              ],
            ),
            // Logo
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.pets, color: Colors.white, size: 28),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildStatsRow(),
      ],
    );
  }

  Widget _buildStatsRow() {
    final dataProvider = Provider.of<DataProvider>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatCard('Pets', dataProvider.pets.length.toString(), Icons.pets_rounded, const Color(0xFFf7797d)),
        _buildStatCard('Produtos', dataProvider.products.length.toString(), Icons.shopping_bag, const Color(0xFFFBD786)),
        _buildStatCard('Serviços', dataProvider.vetServices.length.toString(), Icons.medical_services, const Color(0xFF84fab0)),
      ],
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 8),
            Text(count, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildSelectorButton('pets', Icons.pets_rounded, 'Meus Pets'),
        _buildSelectorButton('products', Icons.shopping_bag, 'Produtos'),
        _buildSelectorButton('services', Icons.medical_services, 'Serviços'),
      ],
    );
  }

  Widget _buildSelectorButton(String section, IconData icon, String label) {
    final bool isSelected = _selectedSection == section;
    return GestureDetector(
      onTap: () => setState(() => _selectedSection = section),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFloatingActionButtons() {
    return Positioned(
      bottom: 24,
      left: 24,
      right: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FloatingActionButton.extended(
            heroTag: 'calculator_fab',
            onPressed: _showCalculatorDialog,
            icon: const Icon(Icons.calculate_outlined),
            label: const Text('Calculadora'),
            backgroundColor: const Color(0xFF7b4cfe).withOpacity(0.9),
            extendedPadding: const EdgeInsets.symmetric(horizontal: 20),
          ),
          FloatingActionButton.extended(
            heroTag: 'add_pet_fab',
            onPressed: () => _showPetFormDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Adicionar Pet'),
             backgroundColor: const Color(0xFF7b4cfe).withOpacity(0.9),
            extendedPadding: const EdgeInsets.symmetric(horizontal: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildPawPrintBackground() {
    return CustomPaint(
      painter: _PawPrintPainter(_paws),
      child: Container(),
    );
  }

  Widget _buildCurrentSection({required BoxConstraints constraints}) {
    final isDesktop = constraints.maxWidth > 1200;
    final isTablet = constraints.maxWidth > 600 && constraints.maxWidth <= 1200;

    switch (_selectedSection) {
      case 'pets':
        return _buildPetsSection(key: const ValueKey('pets'), isTablet: isTablet, isDesktop: isDesktop);
      case 'products':
        return _buildGridSection<Product>(key: const ValueKey('products'), constraints: constraints);
      case 'services':
        return _buildGridSection<VetService>(key: const ValueKey('services'), constraints: constraints);
      default:
        return const SizedBox.shrink();
    }
  }

  // --- SEÇÕES (PETS, PRODUTOS, SERVIÇOS) ---

  Widget _buildPetsSection({Key? key, bool isTablet = false, bool isDesktop = false}) {
    return Consumer<DataProvider>(
      key: key,
      builder: (context, dataProvider, child) {
        if (dataProvider.isLoading && dataProvider.pets.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (dataProvider.pets.isEmpty) {
          return _buildEmptyState(
            'Nenhum Pet Cadastrado',
            'Adicione seus pets para vê-los aqui!',
            Icons.pets_rounded,
          );
        }

        final double viewportFraction = isDesktop ? 0.3 : (isTablet ? 0.55 : 0.8);
        final double carouselHeight = isDesktop ? 340 : 280;

        return CarouselSlider.builder(
          itemCount: dataProvider.pets.length,
          itemBuilder: (context, index, realIndex) => _buildPetCard(dataProvider.pets[index]),
          options: CarouselOptions(
            height: carouselHeight,
            autoPlay: dataProvider.pets.length > 1,
            autoPlayInterval: const Duration(seconds: 8),
            autoPlayAnimationDuration: const Duration(milliseconds: 1500),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            viewportFraction: viewportFraction,
            aspectRatio: 16 / 9,
          ),
        );
      },
    );
  }

  Widget _buildGridSection<T>({Key? key, required BoxConstraints constraints}) {
    return Consumer<DataProvider>(
      key: key,
      builder: (context, dataProvider, child) {
        final List<T> items = T == Product ? dataProvider.products as List<T> : dataProvider.vetServices as List<T>;
        final String type = T == Product ? 'Produtos' : 'Serviços';

        if (dataProvider.isLoading) return const Center(child: CircularProgressIndicator());
        if (items.isEmpty) return _buildEmptyState('Nenhum(a) $type encontrado(a)', 'Volte mais tarde!', Icons.storefront);

        final isDesktop = constraints.maxWidth > 1200;
        final isTablet = constraints.maxWidth > 600 && constraints.maxWidth <= 1200;
        final double viewportFraction = isDesktop ? 0.3 : (isTablet ? 0.5 : 0.8);
        final double carouselHeight = isDesktop ? 340 : 260;

        return CarouselSlider.builder(
          itemCount: items.length,
          itemBuilder: (context, index, realIndex) {
            final item = items[index];
            if (item is Product) return _buildProductCard(item);
            if (item is VetService) return _buildServiceCard(item);
            return const SizedBox.shrink();
          },
          options: CarouselOptions(
            height: carouselHeight,
            autoPlay: items.length > 1,
            autoPlayInterval: const Duration(seconds: 8),
            autoPlayAnimationDuration: const Duration(milliseconds: 1500),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            viewportFraction: viewportFraction,
            aspectRatio: 16 / 9,
          ),
        );
      },
    );
  }

  // --- CARDS (PET, PRODUTO, SERVIÇO) ---

  Widget _buildPetCard(Pet pet) {
    return GestureDetector(
      onTap: () => _showPetPhotoDialog(pet),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 5,
        shadowColor: Colors.black.withOpacity(0.2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(pet.photoUrl != null && pet.photoUrl!.isNotEmpty ? pet.photoUrl! : _getDefaultPetImage(pet.type)),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      stops: const [0.0, 0.5],
                    ),
                  ),
                  alignment: Alignment.bottomLeft,
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    pet.name,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24, shadows: [
                      Shadow(blurRadius: 2.0, color: Colors.black, offset: Offset(1.0, 1.0))
                    ]),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildPetInfoRow(Icons.pets, '${pet.breed}, ${pet.type}'),
                      const SizedBox(height: 8),
                      _buildPetInfoRow(Icons.cake, '${pet.age} anos'),
                      const SizedBox(height: 8),
                      _buildPetInfoRow(Icons.fitness_center, '${pet.weight.toStringAsFixed(1)} kg'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () => _showProductDetailsDialog(product),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Image.network(
                product.imageUrl ?? 'https://via.placeholder.com/150',
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => const Icon(Icons.shopping_bag_outlined, size: 50, color: Colors.grey),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text('R\$ ${product.price.toStringAsFixed(2)}', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(VetService service) {
    return GestureDetector(
      onTap: () => _showServiceDetailsDialog(service),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Image.network(
                service.imageUrl ?? 'https://via.placeholder.com/150',
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => const Icon(Icons.medical_services_outlined, size: 50, color: Colors.grey),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text('R\$ ${service.price.toStringAsFixed(2)}', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES E DE UI ---

  Widget _buildPetInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _buildEmptyState(String title, String message, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  // --- MODAIS / DIÁLOGOS ---

  void _showPetFormDialog({Pet? pet}) {
    // Resetar o estado do formulário e preencher se for edição
    _petFormKey.currentState?.reset();
    _petNameController.text = pet?.name ?? '';
    _petBreedController.text = pet?.breed ?? '';
    _petAgeController.text = pet?.age?.toString() ?? '';
    _petWeightController.text = pet?.weight?.toString() ?? '';
    _petPhotoUrlController.text = pet?.photoUrl ?? '';
    _petType = pet?.type ?? 'Cachorro';
    _petActivityLevel = pet?.activityLevel ?? 'Médio';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 500),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 100 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  )
                ],
              ),
              child: SingleChildScrollView(
                child: _buildPetForm(pet, setModalState),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPetForm(Pet? pet, StateSetter setModalState) {
    return Form(
      key: _petFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(pet == null ? Icons.add_circle_outline : Icons.edit_outlined, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Text(
                pet == null ? 'Adicionar Pet' : 'Editar Pet',
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildCalcTextFormField(controller: _petNameController, label: 'Nome', icon: Icons.badge_outlined),
          const SizedBox(height: 12),
          _buildCalcTextFormField(controller: _petBreedController, label: 'Raça', icon: Icons.pets_outlined),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildCalcTextFormField(controller: _petAgeController, label: 'Idade', icon: Icons.cake_outlined, keyboardType: TextInputType.number)),
              const SizedBox(width: 12),
              Expanded(child: _buildCalcTextFormField(controller: _petWeightController, label: 'Peso (kg)', icon: Icons.fitness_center_outlined, keyboardType: const TextInputType.numberWithOptions(decimal: true))),
            ],
          ),
          const SizedBox(height: 12),
          _buildCalcTextFormField(controller: _petPhotoUrlController, label: 'URL da Foto', icon: Icons.link_outlined),
          const SizedBox(height: 12),
          _buildCalcDropdown(
            label: 'Tipo',
            value: _petType,
            items: ['Cachorro', 'Gato'],
            icon: Icons.pets,
            onChanged: (val) => setModalState(() => _petType = val!),
          ),
          const SizedBox(height: 12),
          _buildCalcDropdown(
            label: 'Nível de Atividade',
            value: _petActivityLevel,
            items: ['Baixo', 'Médio', 'Alto'],
            icon: Icons.directions_run,
            onChanged: (val) => setModalState(() => _petActivityLevel = val!),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (pet != null)
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showDeleteConfirmationDialog(context, pet.id!);
                  },
                  child: const Text('Excluir', style: TextStyle(color: Colors.redAccent)),
                ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => _savePet(pet),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7b4cfe),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(pet == null ? 'Adicionar' : 'Salvar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext parentContext, int petId) {
    showGeneralDialog(
      context: parentContext,
      barrierDismissible: true,
      barrierLabel: 'Fechar',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => Container(),
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: anim1.drive(Tween(begin: 0.8, end: 1.0).chain(CurveTween(curve: Curves.easeOutCubic))),
          child: FadeTransition(
            opacity: anim1,
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2c2f48).withOpacity(0.7),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 40),
                        const SizedBox(height: 16),
                        const Text(
                          'Confirmar Exclusão',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Tem certeza que deseja excluir este pet? Esta ação não pode ser desfeita.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Fecha o diálogo de confirmação
                                _deletePet(petId);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Excluir'),
                            ),
                          ],
                        ),
                      ],
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

  void _showCalculatorDialog() {
    // Limpar estado da calculadora ao abrir
    _calculatorWeightController.clear();
    _dailyFoodAmount = null;
    _selectedPetForCalc = null;
    _useSelectedPetData = false;
    _calculatorPetType = 'Cachorro';
    _calculatorLifeStage = 'Adulto';
    _calculatorActivityLevel = 'Médio';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 500),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 100 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  )
                ],
              ),
              child: SingleChildScrollView(
                child: _buildCalculatorForm(setModalState),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCalculatorForm(StateSetter setCalcState) {
    final pets = Provider.of<DataProvider>(context, listen: false).pets;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calculate_rounded, color: Colors.white, size: 28),
            SizedBox(width: 12),
            Text(
              'Calculadora de Ração',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (pets.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Pet>(
                hint: const Text('Ou selecione um pet salvo...', style: TextStyle(color: Colors.white70)),
                value: _selectedPetForCalc,
                isExpanded: true,
                dropdownColor: const Color(0xFF764ba2),
                icon: const Icon(Icons.pets, color: Colors.white),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                items: pets
                    .map((pet) => DropdownMenuItem(
                          value: pet,
                          child: Text(pet.name),
                        ))
                    .toList(),
                onChanged: (pet) {
                  if (pet == null) return;
                  setCalcState(() {
                    _selectedPetForCalc = pet;
                    _calculatorWeightController.text = pet.weight.toString();
                    _calculatorPetType = pet.type;
                    _calculatorActivityLevel = pet.activityLevel ?? 'Médio';
                    if (pet.age < 1) {
                      _calculatorLifeStage = 'Filhote';
                    } else if (pet.age > 7) {
                      _calculatorLifeStage = 'Idoso';
                    } else {
                      _calculatorLifeStage = 'Adulto';
                    }
                    _calculateFood(setCalcState);
                  });
                },
              ),
            ),
          ),
        const SizedBox(height: 16),
        _buildCalcTextFormField(
          controller: _calculatorWeightController,
          label: 'Peso (kg)',
          icon: Icons.fitness_center,
          onChanged: (_) => _calculateFood(setCalcState),
        ),
        const SizedBox(height: 12),
        _buildCalcDropdown(
          label: 'Tipo',
          value: _calculatorPetType,
          items: ['Cachorro', 'Gato'],
          icon: Icons.pets,
          onChanged: (val) {
            if (val == null) return;
            setCalcState(() {
              _calculatorPetType = val;
              _calculateFood(setCalcState);
            });
          },
        ),
        const SizedBox(height: 12),
        _buildCalcDropdown(
          label: 'Fase da Vida',
          value: _calculatorLifeStage,
          items: ['Filhote', 'Adulto', 'Idoso'],
          icon: Icons.cake,
          onChanged: (val) {
            if (val == null) return;
            setCalcState(() {
              _calculatorLifeStage = val;
              _calculateFood(setCalcState);
            });
          },
        ),
        const SizedBox(height: 12),
        _buildCalcDropdown(
          label: 'Nível de Atividade',
          value: _calculatorActivityLevel,
          items: ['Baixo', 'Médio', 'Alto'],
          icon: Icons.directions_run,
          onChanged: (val) {
            if (val == null) return;
            setCalcState(() {
              _calculatorActivityLevel = val;
              _calculateFood(setCalcState);
            });
          },
        ),
        const SizedBox(height: 24),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: ScaleTransition(scale: animation, child: child)),
          child: _dailyFoodAmount != null && _dailyFoodAmount! > 0
              ? Container(
                  key: ValueKey(_dailyFoodAmount),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Recomendação Diária',
                        style: TextStyle(
                          color: Color(0xFF667eea),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_dailyFoodAmount!.toStringAsFixed(0)}g',
                        style: const TextStyle(
                          color: Color(0xFF764ba2),
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('empty')),
        ),
      ],
    );
  }

  TextFormField _buildCalcTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    void Function(String)? onChanged,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white70),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildCalcDropdown({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF764ba2),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          style: const TextStyle(color: Colors.white, fontSize: 16),
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Row(
                      children: [
                        Icon(icon, color: Colors.white70, size: 20),
                        const SizedBox(width: 12),
                        Text(item),
                      ],
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  void _calculateFood(StateSetter setCalcState) {
    final weight = double.tryParse(_calculatorWeightController.text);
    if (weight == null || weight <= 0) {
      setCalcState(() => _dailyFoodAmount = null);
      return;
    }

    double baseMultiplier = _calculatorPetType == 'Gato' ? 50 : 60;

    switch (_calculatorLifeStage) {
      case 'Filhote':
        baseMultiplier *= 1.8;
        break;
      case 'Idoso':
        baseMultiplier *= 0.8;
        break;
      case 'Adulto':
      default:
        break;
    }

    switch (_calculatorActivityLevel) {
      case 'Baixo':
        baseMultiplier *= 0.85;
        break;
      case 'Alto':
        baseMultiplier *= 1.15;
        break;
      case 'Médio':
      default:
        break;
    }

    final result = weight * (baseMultiplier / 2);

    setCalcState(() {
      _dailyFoodAmount = result > 0 ? result : 0;
    });
  }

  String _getDefaultPetImage(String petType) {
    return petType == 'Gato'
        ? 'https://i.pinimg.com/736x/87/7b/0a/877b0a7df75e1a3f185ef3d201a0528e.jpg'
        : 'https://i.natgeofe.com/n/4f5aaece-3300-41a4-b2a8-ed2708a0a27c/domestic-dog_thumb_4x3.jpg';
  }

  void _showPetPhotoDialog(Pet pet) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Fechar',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => Container(),
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: anim1.drive(Tween(begin: 0.7, end: 1.0).chain(CurveTween(curve: Curves.easeOutCubic))),
          child: FadeTransition(
            opacity: anim1,
            child: _buildPetDetailsDialogContent(pet),
          ),
        );
      },
    );
  }

  Widget _buildPetDetailsDialogContent(Pet pet) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 400,
            decoration: BoxDecoration(
              color: const Color(0xFF3A3E59).withOpacity(0.6),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      child: Image.network(
                        pet.photoUrl != null && pet.photoUrl!.isNotEmpty ? pet.photoUrl! : _getDefaultPetImage(pet.type),
                        height: 300,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          height: 300,
                          color: Colors.grey.shade800,
                          child: const Icon(Icons.pets, size: 120, color: Colors.grey),
                        ),
                      ),
                    ),
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        pet.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDetailRow(Icons.pets, 'Raça', pet.breed ?? 'Não informado'),
                      _buildDetailRow(Icons.cake, 'Idade', '${pet.age} anos'),
                      _buildDetailRow(Icons.fitness_center, 'Peso', '${pet.weight.toStringAsFixed(1)} kg'),
                      _buildDetailRow(Icons.directions_run, 'Atividade', pet.activityLevel ?? 'Não informado'),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _showDeleteConfirmationDialog(context, pet.id!);
                            },
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            label: const Text('Excluir', style: TextStyle(color: Colors.redAccent)),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _showPetFormDialog(pet: pet);
                            },
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Editar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7b4cfe),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showProductDetailsDialog(Product product) {
    _showCustomDetailsDialog(
      context: context,
      title: product.name,
      imageUrl: product.imageUrl,
      imagePlaceholder: const Icon(Icons.shopping_bag_outlined, size: 60, color: Colors.grey),
      children: [
        _buildDetailRow(Icons.description, 'Descrição', product.description ?? 'Nenhuma descrição'),
        _buildDetailRow(Icons.price_change, 'Preço', 'R\$ ${product.price.toStringAsFixed(2)}'),
        _buildDetailRow(Icons.store, 'Vendido por', product.ownerName ?? 'Não informado'),
        _buildDetailRow(Icons.location_on, 'Localização', product.ownerLocation ?? 'Não informado'),
        if (product.ownerPhone != null)
          _buildWhatsAppButton(product.ownerPhone!),
      ],
    );
  }

  void _showServiceDetailsDialog(VetService service) {
    _showCustomDetailsDialog(
      context: context,
      title: service.name,
      imageUrl: service.imageUrl,
      imagePlaceholder: const Icon(Icons.local_hospital_outlined, size: 60, color: Colors.blueAccent),
      children: [
        _buildDetailRow(Icons.description, 'Descrição', service.description ?? 'Nenhuma descrição'),
        _buildDetailRow(Icons.price_change, 'Preço', 'R\$ ${service.price.toStringAsFixed(2)}'),
        _buildDetailRow(Icons.person, 'Oferecido por', service.ownerName ?? 'Não informado'),
        _buildDetailRow(Icons.location_on, 'Localização', service.ownerLocation ?? 'Não informado'),
        if (service.ownerCrmv != null)
          _buildDetailRow(Icons.badge, 'CRMV', service.ownerCrmv!),
        if (service.operatingHours != null)
          _buildDetailRow(Icons.access_time, 'Horário', service.operatingHours!),
        if (service.ownerPhone != null)
          _buildWhatsAppButton(service.ownerPhone!),
      ],
    );
  }

  void _showCustomDetailsDialog({
    required BuildContext context,
    required String title,
    String? imageUrl,
    required Widget imagePlaceholder,
    required List<Widget> children,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => Container(), // Page builder is not used
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.elasticOut),
          child: FadeTransition(
            opacity: CurvedAnimation(parent: anim1, curve: Curves.easeOut),
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              titlePadding: const EdgeInsets.all(0),
              contentPadding: const EdgeInsets.all(20),
              title: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    image: imageUrl != null && imageUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: imageUrl == null || imageUrl.isEmpty
                      ? Center(child: imagePlaceholder)
                      : Container(
                          alignment: Alignment.bottomLeft,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                            ),
                          ),
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              shadows: [Shadow(blurRadius: 2, color: Colors.black)],
                            ),
                          ),
                        ),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Fechar'),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatsAppButton(String phone) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Center(
        child: ElevatedButton.icon(
          onPressed: () => _launchWhatsApp(phone),
          icon: const Icon(Icons.message, color: Colors.white),
          label: const Text('Entrar em contato via WhatsApp'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF25D366),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
    );
  }

  void _launchWhatsApp(String phone) async {
    final whatsappUrl = 'https://wa.me/${phone.replaceAll(RegExp(r'[^\d]'), '')}';
    final uri = Uri.parse(whatsappUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o WhatsApp')),
      );
    }
  }
}

// --- CUSTOM PAINTER PARA AS PATINHAS ---

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
  final Random _random = Random();

  _PawPrintPainter(this.paws);

  @override
  void paint(Canvas canvas, Size size) {
    for (var paw in paws) {
      final paint = Paint()
        ..color = Colors.white.withOpacity(paw.opacity)
        ..style = PaintingStyle.fill;
      
      final angle = _random.nextDouble() * 0.5 - 0.25; // Pequena variação no ângulo

      canvas.save();
      canvas.translate(paw.position.dx, paw.position.dy);
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