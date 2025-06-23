import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';

import '../../models/pet.dart';
import '../../models/product.dart';
import '../../models/vet_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';

class TutorHomeScreen extends StatefulWidget {
  const TutorHomeScreen({super.key});

  @override
  State<TutorHomeScreen> createState() => _TutorHomeScreenState();
}

class _TutorHomeScreenState extends State<TutorHomeScreen> with TickerProviderStateMixin {
  // --- STATE ---
  String _selectedSection = 'pets';

  // Animação do Fundo
  AnimationController? _pawAnimationController;
  final List<_Paw> _paws = [];
  final Random _random = Random();

  // Formulário de Pet
  final GlobalKey<FormState> _petFormKey = GlobalKey<FormState>();
  final TextEditingController _petNameController = TextEditingController();
  final TextEditingController _petBreedController = TextEditingController();
  final TextEditingController _petAgeController = TextEditingController();
  final TextEditingController _petWeightController = TextEditingController();
  final TextEditingController _petPhotoUrlController = TextEditingController();
  String _petType = 'Cachorro';
  String _petActivityLevel = 'Médio';

  // Calculadora
  final _foodCalculatorFormKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  String _calculatorPetSize = 'Pequeno';
  String _calculatorActivityLevel = 'Médio';
  String _result = '';
  String _calculatorPetType = 'Cachorro';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadData();
  }
  
  void _initializeAnimations() {
    _pawAnimationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    // Gerar patinhas flutuantes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final size = MediaQuery.of(context).size;
      for (int i = 0; i < 20; i++) {
        _paws.add(_Paw(
          position: Offset(
            _random.nextDouble() * size.width,
            _random.nextDouble() * size.height,
          ),
          scale: _random.nextDouble() * 0.5 + 0.3,
          opacity: _random.nextDouble() * 0.3 + 0.1,
          speed: _random.nextDouble() * 20 + 10, // Velocidade ajustada
        ));
      }
    });
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id;
      if (userId != null) {
        dataProvider.fetchAllDataForTutor(userId);
      }
    });
  }

  @override
  void dispose() {
    _pawAnimationController?.dispose();
    _petNameController.dispose();
    _petBreedController.dispose();
    _petAgeController.dispose();
    _petWeightController.dispose();
    _petPhotoUrlController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id;
    if (userId != null) {
      await dataProvider.fetchAllDataForTutor(userId);
    }
  }

  // --- MÉTODOS DE CRUD DE PET ---

  void _clearPetForm() {
    _petFormKey.currentState?.reset();
    _petNameController.clear();
    _petBreedController.clear();
    _petAgeController.clear();
    _petWeightController.clear();
    _petPhotoUrlController.clear();
    setState(() {
      _petType = 'Cachorro';
      _petActivityLevel = 'Médio';
    });
  }

  void _showPetFormDialog({Pet? pet}) {
    _clearPetForm();
    if (pet != null) {
      _petNameController.text = pet.name;
      _petBreedController.text = pet.breed ?? '';
      _petAgeController.text = pet.age.toString();
      _petWeightController.text = pet.weight.toString();
      _petPhotoUrlController.text = pet.photoUrl ?? '';
      _petType = pet.type;
      _petActivityLevel = pet.activityLevel ?? 'Médio';
    }

    _showAnimatedDialog(
      title: pet == null ? 'Adicionar Novo Pet' : 'Editar Pet',
      content: _buildPetForm(),
      onSave: () => _savePet(pet),
    );
  }

  Future<void> _savePet(Pet? existingPet) async {
    if (!_petFormKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    if (user == null || user.id == null) return;

    final petData = Pet(
      id: existingPet?.id,
      name: _petNameController.text,
      breed: _petBreedController.text,
      age: int.tryParse(_petAgeController.text) ?? 0,
      weight: double.tryParse(_petWeightController.text.replaceAll(',', '.')) ?? 0.0,
      type: _petType,
      activityLevel: _petActivityLevel,
      photoUrl: _petPhotoUrlController.text,
      tutorId: user.id,
    );

    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    bool success;
    if (existingPet == null) {
      success = await dataProvider.createPet(petData, user.id!);
    } else {
      success = await dataProvider.updatePet(petData, user.id!);
    }

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Pet salvo com sucesso!' : dataProvider.error ?? 'Ocorreu um erro.'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _handleDeletePet(Pet pet) {
    if (pet.id == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza de que deseja excluir ${pet.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Fecha o dialog de confirmação
              await _deletePet(pet.id!);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePet(int petId) async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id;

    if (userId == null) return;

    final success = await dataProvider.deletePet(petId, userId);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Pet excluído com sucesso!' : dataProvider.error ?? 'Erro ao excluir pet.'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  // --- WIDGETS DE UI ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF667eea),
      body: Stack(
        children: [
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
                ],
              ),
            ),
          ),
          
          // Animação de Patinhas
          AnimatedBuilder(
            animation: _pawAnimationController!,
            builder: (context, child) {
              return CustomPaint(
                painter: _PawPainter(paws: _paws, animationValue: _pawAnimationController!.value),
                child: Container(),
              );
            },
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildInfoCards(),
                const SizedBox(height: 20),
                _buildSectionSelector(),
                const SizedBox(height: 10),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshData,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: _buildSelectedSection(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  Widget _buildSelectedSection() {
    final dataProvider = Provider.of<DataProvider>(context);
    switch (_selectedSection) {
      case 'pets':
        return _buildPetGrid(dataProvider.pets);
      case 'products':
        return _buildProductGrid(dataProvider.products);
      case 'services':
        return _buildServiceGrid(dataProvider.vetServices);
      default:
        return _buildPetGrid(dataProvider.pets);
    }
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.white.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.7)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPetGrid(List<Pet> pets) {
    if (pets.isEmpty) {
      return _buildEmptyState('Nenhum pet encontrado.', Icons.pets);
    }
    return GridView.builder(
      key: const PageStorageKey<String>('petsGrid'),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        childAspectRatio: 2 / 2.2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: pets.length,
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, index) {
        return _buildPetCard(pets[index]);
      },
    );
  }

  Widget _buildProductGrid(List<Product> products) {
    if (products.isEmpty) {
      return _buildEmptyState('Nenhum produto encontrado.', Icons.shopping_bag);
    }
    return GridView.builder(
      key: const PageStorageKey<String>('productsGrid'),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        childAspectRatio: 2 / 2.2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: products.length,
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, index) {
        return _buildProductCard(products[index]);
      },
    );
  }

  Widget _buildServiceGrid(List<VetService> services) {
    if (services.isEmpty) {
      return _buildEmptyState('Nenhum serviço encontrado.', Icons.medical_services);
    }
    return GridView.builder(
      key: const PageStorageKey<String>('servicesGrid'),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        childAspectRatio: 2 / 2.2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: services.length,
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, index) {
        return _buildServiceCard(services[index]);
      },
    );
  }

  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          onPressed: () => _showPetFormDialog(),
          heroTag: 'add_fab',
          tooltip: 'Adicionar Pet',
          backgroundColor: const Color(0xFF764ba2),
          child: const Icon(Icons.add, color: Colors.white),
        ),
        const SizedBox(height: 10),
        FloatingActionButton(
          onPressed: _showFoodCalculatorDialog,
          heroTag: 'calculator_fab',
          tooltip: 'Calculadora de Ração',
          backgroundColor: const Color(0xFFa777e3),
          child: const Icon(Icons.calculate, color: Colors.white),
        ),
      ],
    );
  }

  void _showPetDetailsDialog(Pet pet) {
    _showAnimatedDialog(
      title: pet.name,
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (pet.photoUrl != null && pet.photoUrl!.isNotEmpty)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    pet.photoUrl!,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                          color: Colors.white,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading pet image: $error');
                      return const Icon(
                        Icons.pets,
                        size: 150,
                        color: Colors.grey,
                      );
                    },
                  ),
                ),
              ),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.pets, 'Tipo:', pet.type),
            _buildDetailRow(Icons.pets, 'Raça:', pet.breed ?? 'Não informada'),
            _buildDetailRow(Icons.cake, 'Idade:', '${pet.age} anos'),
            _buildDetailRow(Icons.fitness_center, 'Peso:', '${pet.weight} kg'),
            _buildDetailRow(Icons.directions_run, 'Nível de Atividade:', pet.activityLevel ?? 'Não informado'),
            if (pet.notes != null && pet.notes!.isNotEmpty)
              _buildDetailRow(Icons.note, 'Notas:', pet.notes!),
          ],
        ),
      ),
      onSave: null, // No save button for details view
    );
  }

  void _showProductDetailsDialog(Product product) {
    _showAnimatedDialog(
      title: product.name,
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (product.imageUrl != null && product.imageUrl!.isNotEmpty)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    product.imageUrl!,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Carregando...',
                              style: TextStyle(color: Colors.white.withOpacity(0.7)),
                            ),
                          ],
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading product image: $error');
                      print('URL: ${product.imageUrl}');
                      return Container(
                        color: Colors.black.withOpacity(0.2),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_bag,
                                size: 80,
                                color: Colors.white30,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Imagem não carregou',
                                style: TextStyle(color: Colors.white30, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.description, 'Descrição:', product.description ?? 'Não informado'),
            _buildDetailRow(Icons.price_change, 'Preço:', 'R\$ ${product.price.toStringAsFixed(2)}'),
            _buildDetailRow(Icons.straighten, 'Unidade:', product.measurementUnit ?? 'Não informado'),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),
            Text('Vendido por:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.9))),
            const SizedBox(height: 5),
            _buildDetailRow(Icons.store, 'Loja:', product.ownerName ?? 'Não informado'),
            _buildDetailRow(Icons.location_on, 'Localização:', product.ownerLocation ?? 'Não informado'),
            if (product.ownerPhone != null)
              ListTile(
                leading: const Icon(Icons.phone, color: Colors.white70),
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(product.ownerPhone!, style: const TextStyle(color: Colors.white)),
                    const SizedBox(width: 8),
                    const Icon(Icons.message, color: Colors.greenAccent, size: 18),
                  ],
                ),
                subtitle: Text(
                  'Clique no número para abrir o WhatsApp',
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                ),
                onTap: () => _launchWhatsApp(product.ownerPhone!),
              ),
          ],
        ),
      ),
      onSave: null,
    );
  }

  void _showServiceDetailsDialog(VetService service) {
    _showAnimatedDialog(
      title: service.name,
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
             if (service.imageUrl != null && service.imageUrl!.isNotEmpty)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    service.imageUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Carregando...',
                              style: TextStyle(color: Colors.white.withOpacity(0.7)),
                            ),
                          ],
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading service image: $error');
                      print('URL: ${service.imageUrl}');
                      return Container(
                        color: Colors.black.withOpacity(0.2),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.medical_services,
                                size: 80,
                                color: Colors.white30,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Imagem não carregou',
                                style: TextStyle(color: Colors.white30, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.description, 'Descrição:', service.description ?? 'Não informado'),
            _buildDetailRow(Icons.price_change, 'Preço:', 'R\$ ${service.price.toStringAsFixed(2)}'),
             const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),
            Text('Oferecido por:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.9))),
             _buildDetailRow(Icons.person, 'Veterinário:', service.ownerName ?? 'Não informado'),
             _buildDetailRow(Icons.badge, 'CRMV:', service.ownerCrmv ?? 'Não informado'),
             _buildDetailRow(Icons.location_on, 'Localização:', service.ownerLocation ?? 'Não informado'),
             _buildDetailRow(Icons.access_time, 'Horário:', service.operatingHours ?? 'Não informado'),
              if (service.ownerPhone != null)
              ListTile(
                leading: const Icon(Icons.phone, color: Colors.white70),
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(service.ownerPhone!, style: const TextStyle(color: Colors.white)),
                    const SizedBox(width: 8),
                    const Icon(Icons.message, color: Colors.greenAccent, size: 18),
                  ],
                ),
                subtitle: Text(
                  'Clique no número para abrir o WhatsApp',
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                ),
                onTap: () => _launchWhatsApp(service.ownerPhone!),
              ),
          ],
        ),
      ),
      onSave: null,
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.white),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Padding(
      padding: const EdgeInsets.only(top: 50.0, left: 20, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Olá, ${user?.name ?? 'Tutor'}!',
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const Text(
                  'Gerencie seus pets e explore!',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
            tooltip: 'Sair',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCards() {
    final dataProvider = Provider.of<DataProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: _buildPetInfoCard(dataProvider)),
          const SizedBox(width: 15),
          Expanded(child: _buildProductInfoCard(dataProvider)),
          const SizedBox(width: 15),
          Expanded(child: _buildServiceInfoCard(dataProvider)),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required Widget child, required GestureTapCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: child,
      ),
    );
  }

  Widget _buildPetInfoCard(DataProvider dataProvider) {
    return _buildInfoCard(
      onTap: () => setState(() => _selectedSection = 'pets'),
      child: Column(
        children: [
          const Icon(Icons.pets, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(
            '${dataProvider.pets.length}',
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          const SizedBox(height: 4),
          const Text(
            'Meus Pets',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfoCard(DataProvider dataProvider) {
    return _buildInfoCard(
      onTap: () => setState(() => _selectedSection = 'products'),
      child: Column(
        children: [
          const Icon(Icons.shopping_bag, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(
            '${dataProvider.products.length}',
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          const SizedBox(height: 4),
          const Text(
            'Produtos',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceInfoCard(DataProvider dataProvider) {
    return _buildInfoCard(
      onTap: () => setState(() => _selectedSection = 'services'),
      child: Column(
        children: [
          const Icon(Icons.medical_services, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(
            '${dataProvider.vetServices.length}',
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          const SizedBox(height: 4),
          const Text(
            'Serviços',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSectionButton('pets', 'Pets', Icons.pets),
          _buildSectionButton('products', 'Produtos', Icons.shopping_bag),
          _buildSectionButton('services', 'Serviços', Icons.medical_services),
        ],
      ),
    );
  }

  Widget _buildSectionButton(String section, String label, IconData icon) {
    final isSelected = _selectedSection == section;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedSection = section),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF764ba2) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.white70),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPetCard(Pet pet) {
    return Card(
      elevation: 8,
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: (pet.photoUrl != null && pet.photoUrl!.isNotEmpty)
                  ? Image.network(
                      pet.photoUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Carregando...',
                                style: TextStyle(color: Colors.white.withOpacity(0.7)),
                              ),
                            ],
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading pet image: $error');
                        print('URL: ${pet.photoUrl}');
                        return Container(
                          color: Colors.black.withOpacity(0.2),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.pets,
                                  size: 80,
                                  color: Colors.white30,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Imagem não carregou',
                                  style: TextStyle(color: Colors.white30, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.black.withOpacity(0.2),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.pets,
                              size: 80,
                              color: Colors.white30,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Sem imagem',
                              style: TextStyle(color: Colors.white30, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pet.breed ?? 'Sem raça definida',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.black.withOpacity(0.2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: const Icon(Icons.visibility, color: Colors.white70),
                    onPressed: () => _showPetDetailsDialog(pet),
                    tooltip: 'Visualizar',
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white70),
                    onPressed: () => _showPetFormDialog(pet: pet),
                    tooltip: 'Editar',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _handleDeletePet(pet),
                    tooltip: 'Excluir',
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      elevation: 8,
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                  ? Image.network(
                      product.imageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Carregando...',
                                style: TextStyle(color: Colors.white.withOpacity(0.7)),
                              ),
                            ],
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading product image: $error');
                        print('URL: ${product.imageUrl}');
                        return Container(
                          color: Colors.black.withOpacity(0.2),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_bag,
                                  size: 80,
                                  color: Colors.white30,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Imagem não carregou',
                                  style: TextStyle(color: Colors.white30, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.black.withOpacity(0.2),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_bag,
                              size: 80,
                              color: Colors.white30,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Sem imagem',
                              style: TextStyle(color: Colors.white30, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'R\$ ${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.black.withOpacity(0.2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: const Icon(Icons.visibility, color: Colors.white70),
                    onPressed: () => _showProductDetailsDialog(product),
                    tooltip: 'Visualizar',
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_shopping_cart, color: Colors.white70),
                    onPressed: () {
                      // Lógica para adicionar ao carrinho, se aplicável
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Funcionalidade de carrinho não implementada.')));
                    },
                    tooltip: 'Adicionar ao carrinho',
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(VetService service) {
    return Card(
      elevation: 8,
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: (service.imageUrl != null && service.imageUrl!.isNotEmpty)
                  ? Image.network(
                      service.imageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Carregando...',
                                style: TextStyle(color: Colors.white.withOpacity(0.7)),
                              ),
                            ],
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading service image: $error');
                        print('URL: ${service.imageUrl}');
                        return Container(
                          color: Colors.black.withOpacity(0.2),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.medical_services,
                                  size: 80,
                                  color: Colors.white30,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Imagem não carregou',
                                  style: TextStyle(color: Colors.white30, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.black.withOpacity(0.2),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.medical_services,
                              size: 80,
                              color: Colors.white30,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Sem imagem',
                              style: TextStyle(color: Colors.white30, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'R\$ ${service.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.black.withOpacity(0.2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: const Icon(Icons.visibility, color: Colors.white70),
                    onPressed: () => _showServiceDetailsDialog(service),
                    tooltip: 'Visualizar',
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today, color: Colors.white70),
                    onPressed: () {
                      // Lógica para agendar, se aplicável
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Funcionalidade de agendamento não implementada.')));
                    },
                    tooltip: 'Agendar',
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // --- MÉTODOS DE AÇÃO (Lançadores) ---
  Future<void> _launchWhatsApp(String phoneNumber) async {
    final String cleanPhoneNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final String whatsappUrl = "https://wa.me/55$cleanPhoneNumber"; // Adiciona o código do Brasil (55)

    final Uri uri = Uri.parse(whatsappUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível abrir o WhatsApp para o número $phoneNumber')),
        );
      }
    }
  }

  Future<void> _launchPhone(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (!await launchUrl(phoneUri)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível ligar para $phoneNumber')),
      );
      }
    }
  }

  // --- CALCULADORA DE RAÇÃO ---
  void _showFoodCalculatorDialog() {
    _showAnimatedDialog(
      title: 'Calculadora de Ração',
      content: StatefulBuilder(builder: (context, setModalState) {
        return _buildFoodCalculatorForm(setModalState);
      }),
      onSave: null
    );
  }
  
  Widget _buildFoodCalculatorForm(StateSetter setModalState) {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final pets = dataProvider.pets;
    return SizedBox(
      width: 400,
      child: Form(
        key: _foodCalculatorFormKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (pets.isNotEmpty) ...[
                DropdownButtonFormField<Pet>(
                  value: null,
                  hint: const Text('Usar pet cadastrado', style: TextStyle(color: Colors.white70)),
                  items: pets.map((pet) => DropdownMenuItem(
                    value: pet,
                    child: Text('${pet.name} (${pet.weight}kg, ${pet.type})'),
                  )).toList(),
                  onChanged: (Pet? selectedPet) {
                    if (selectedPet != null) {
                      setModalState(() {
                        _weightController.text = selectedPet.weight.toString();
                        _calculatorPetType = selectedPet.type;
                        if (selectedPet.type == 'Cachorro') {
                          _calculatorPetSize = _getPetSize(selectedPet.weight);
                        }
                        _calculatorActivityLevel = selectedPet.activityLevel ?? 'Médio';
                        _result = '';
                      });
                    }
                  },
                  style: const TextStyle(color: Colors.white),
                  dropdownColor: const Color(0xFF6A5ACD),
                  decoration: _inputDecoration('Selecione um Pet', Icons.pets),
                ),
                const SizedBox(height: 16),
              ],

              _buildDropdownFormField(
                value: _calculatorPetType,
                items: ['Cachorro', 'Gato'],
                onChanged: (value) => setModalState(() {
                  _calculatorPetType = value!;
                  _result = '';
                }),
                labelText: 'Tipo de Animal',
                icon: Icons.pets,
              ),
              const SizedBox(height: 16),

              _buildTextFormField(
                controller: _weightController,
                labelText: 'Peso do Pet (kg)',
                icon: Icons.scale,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),

              if (_calculatorPetType == 'Cachorro') ...[
                _buildDropdownFormField(
                  value: _calculatorPetSize,
                  items: ['Pequeno', 'Médio', 'Grande'],
                  onChanged: (value) => setModalState(() {
                    _calculatorPetSize = value!;
                     _result = '';
                  }),
                  labelText: 'Porte do Pet',
                  icon: Icons.height,
                ),
                const SizedBox(height: 16),
              ],
              
              _buildDropdownFormField(
                value: _calculatorActivityLevel,
                items: ['Baixo', 'Médio', 'Alto'],
                onChanged: (value) => setModalState(() {
                  _calculatorActivityLevel = value!;
                  _result = '';
                }),
                labelText: 'Nível de Atividade',
                icon: Icons.directions_run,
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: () {
                  if (_foodCalculatorFormKey.currentState!.validate()) {
                    _calculateFood(setModalState);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9370DB),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Calcular'),
              ),

              if (_result.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _result,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _calculateFood(StateSetter setModalState) {
    final double weight = double.tryParse(_weightController.text.replaceAll(',', '.')) ?? 0;
    if (weight <= 0) return;

    double baseAmount;

    if (_calculatorPetType == 'Gato') {
      baseAmount = weight * 15;
    } else {
      if (_calculatorPetSize == 'Pequeno') {
        baseAmount = weight * 30;
      } else if (_calculatorPetSize == 'Médio') {
        baseAmount = weight * 25;
      } else {
        baseAmount = weight * 20;
      }
    }

    double activityMultiplier = 1.0;
    if (_calculatorActivityLevel == 'Baixo') {
      activityMultiplier = 0.8;
    } else if (_calculatorActivityLevel == 'Alto') {
      activityMultiplier = 1.2;
    }

    final totalAmount = baseAmount * activityMultiplier;
    
    setModalState(() {
      _result = 'Recomendação: ${totalAmount.toStringAsFixed(0)}g por dia, divididos em 2-3 refeições.';
    });
  }

  String _getPetSize(double weight) {
    if (weight < 10) return 'Pequeno';
    if (weight < 25) return 'Médio';
    return 'Grande';
  }

  // --- DIALOGS E FORMULÁRIOS ---
  void _showAnimatedDialog({
    required String title,
    required Widget content,
    VoidCallback? onSave,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation1, animation2) => const SizedBox(),
      transitionBuilder: (context, a1, a2, widget) {
        final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
          child: Opacity(
            opacity: a1.value,
            child: AlertDialog(
              title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              backgroundColor: const Color(0xFF3a3a5c).withOpacity(0.95),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
              content: content,
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Fechar', style: TextStyle(color: Colors.white70)),
                ),
                if (onSave != null)
                  ElevatedButton(
                    onPressed: onSave,
                    child: const Text('Salvar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667eea),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPetForm() {
    return Form(
      key: _petFormKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextFormField(
                controller: _petNameController,
                labelText: 'Nome do Pet',
                icon: Icons.pets),
            const SizedBox(height: 16),
            _buildTextFormField(
                controller: _petBreedController,
                labelText: 'Raça',
                icon: Icons.loyalty),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextFormField(
                    controller: _petAgeController,
                    labelText: 'Idade',
                    icon: Icons.cake,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextFormField(
                    controller: _petWeightController,
                    labelText: 'Peso (kg)',
                    icon: Icons.scale,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _petPhotoUrlController,
              labelText: 'URL da Foto',
              icon: Icons.image,
              keyboardType: TextInputType.url,
              isOptional: true),
            const SizedBox(height: 16),
            _buildDropdownFormField(
              value: _petType,
              items: ['Cachorro', 'Gato'],
              onChanged: (value) => setState(() => _petType = value!),
              labelText: 'Tipo',
              icon: Icons.pets,
            ),
            const SizedBox(height: 16),
            _buildDropdownFormField(
              value: _petActivityLevel,
              items: ['Baixo', 'Médio', 'Alto'],
              onChanged: (value) => setState(() => _petActivityLevel = value!),
              labelText: 'Nível de Atividade',
              icon: Icons.directions_run,
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
      prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
      filled: true,
      fillColor: Colors.black.withOpacity(0.15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: const Color(0xFF9370DB), width: 2),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType? keyboardType,
    bool isOptional = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(labelText, icon),
      validator: (v) {
        if (!isOptional && (v == null || v.isEmpty)) {
          return 'Campo obrigatório';
        }
        return null;
      },
    );
  }

  Widget _buildDropdownFormField({
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
    required String labelText,
    required IconData icon,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      dropdownColor: const Color(0xFF6A5ACD),
      decoration: _inputDecoration(labelText, icon),
    );
  }
}

// --- CLASSES AUXILIARES (Animação) ---

class _Paw {
  Offset position;
  final double scale;
  final double opacity;
  final double speed;

  _Paw(
      {required this.position,
      required this.scale,
      required this.opacity,
      required this.speed});

  void update(Size size) {
    position = Offset(position.dx, position.dy - speed * 0.1);
    if (position.dy < -50) {
      position = Offset(Random().nextDouble() * size.width, size.height + 50);
    }
  }
}

class _PawPainter extends CustomPainter {
  final List<_Paw> paws;
  final double animationValue;

  _PawPainter({required this.paws, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    for (final paw in paws) {
      paw.update(size);

      paint.color = Colors.white.withOpacity(paw.opacity);

      final pawSize = 20.0 * paw.scale;
      final center = paw.position;

      final mainPad = RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: pawSize, height: pawSize * 0.9),
        Radius.circular(pawSize * 0.3),
      );
      canvas.drawRRect(mainPad, paint);

      final toeSize = pawSize * 0.25;
      final toeY = center.dy - (pawSize * 0.6);
      final toeY2 = toeY - toeSize * 0.5;
      
      canvas.drawCircle(Offset(center.dx - pawSize * 0.4, toeY), toeSize, paint);
      canvas.drawCircle(Offset(center.dx + pawSize * 0.4, toeY), toeSize, paint);
      canvas.drawCircle(Offset(center.dx - pawSize * 0.15, toeY2), toeSize, paint);
      canvas.drawCircle(Offset(center.dx + pawSize * 0.15, toeY2), toeSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PawPainter oldDelegate) => true;
} 