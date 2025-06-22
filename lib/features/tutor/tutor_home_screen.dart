import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../models/pet.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../models/product.dart';
import '../../models/vet_service.dart';
import 'dart:math';

class TutorHomeScreen extends StatefulWidget {
  const TutorHomeScreen({super.key});

  @override
  State<TutorHomeScreen> createState() => _TutorHomeScreenState();
}

class _TutorHomeScreenState extends State<TutorHomeScreen> with TickerProviderStateMixin {
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

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _selectedSection = 'pets';
  bool _isCalculatorExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      dataProvider.loadPets(tutorId: authProvider.currentUser?.id);
      dataProvider.loadProducts();
      dataProvider.loadVetServices();
    });
  }

  @override
  void dispose() {
    _petNameController.dispose();
    _petBreedController.dispose();
    _petAgeController.dispose();
    _petWeightController.dispose();
    _petPhotoUrlController.dispose();
    _calculatorWeightController.dispose();
    _animationController.dispose();
    super.dispose();
  }

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

  // --- ADD PET ---
  void _showAddPetDialog() {
    _clearPetForm();
    showDialog(
      context: context,
      builder: (context) => _buildPetFormDialog(
        title: 'Adicionar Novo Pet',
        onSave: _addPet,
      ),
    );
  }

  Future<void> _addPet() async {
    if (!_petFormKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    // 1. Pega o usuário logado
    final User tutor = authProvider.currentUser!;

    final pet = Pet(
      name: _petNameController.text,
      type: _petType,
      breed: _petBreedController.text,
      age: int.tryParse(_petAgeController.text) ?? 0,
      weight: double.tryParse(_petWeightController.text.replaceAll(',', '.')) ?? 0.0,
      activityLevel: _petActivityLevel,
      photoUrl: _petPhotoUrlController.text,
      // 3. Associa o tutor como um Map com o id
      tutor: {
        'id': tutor.id,
        'name': tutor.name,
        'email': tutor.email,
      },
    );

    final success = await dataProvider.createPet(pet);

    if (mounted) {
      Navigator.pop(context);
      _showFeedback('Pet adicionado com sucesso!', success, dataProvider.error);
    }
  }

  // --- EDIT PET ---
  void _showEditPetDialog(Pet pet) {
    _clearPetForm();
    _petNameController.text = pet.name;
    _petBreedController.text = pet.breed ?? '';
    _petAgeController.text = pet.age.toString();
    _petWeightController.text = pet.weight.toString().replaceAll('.', ',');
    _petPhotoUrlController.text = pet.photoUrl ?? '';
    _petType = pet.type;
    _petActivityLevel = pet.activityLevel ?? 'Médio';
    showDialog(
      context: context,
      builder: (context) => _buildPetFormDialog(
        title: 'Editar Pet',
        onSave: () => _updatePet(pet),
      ),
    );
  }

  Future<void> _updatePet(Pet oldPet) async {
    if (!_petFormKey.currentState!.validate()) return;
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final updatedPet = Pet(
      id: oldPet.id,
      name: _petNameController.text,
      type: _petType,
      breed: _petBreedController.text,
      age: int.tryParse(_petAgeController.text) ?? 0,
      weight: double.tryParse(_petWeightController.text.replaceAll('.', ',')) ?? 0.0,
      activityLevel: _petActivityLevel,
      photoUrl: _petPhotoUrlController.text,
      tutor: oldPet.tutor,
    );
    final success = await dataProvider.updatePet(updatedPet.id!, updatedPet);
    if (mounted) {
      Navigator.pop(context);
      _showFeedback('Pet atualizado com sucesso!', success, dataProvider.error);
    }
  }

  // --- DELETE PET ---
  void _handleDeletePet(int petId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem certeza de que deseja remover este pet?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final dataProvider = Provider.of<DataProvider>(context, listen: false);
              final success = await dataProvider.deletePet(petId);
              if (mounted) _showFeedback('Pet removido com sucesso!', success, dataProvider.error);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _showFeedback(String message, bool success, String? error) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(success ? message : error ?? 'Ocorreu um erro.'),
      backgroundColor: success ? Colors.green : Colors.red,
    ));
  }

  void _calculateFood() {
    final weight = double.tryParse(_calculatorWeightController.text);
    if (weight == null || weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, insira um peso válido.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Fórmulas de Necessidade Energética de Repouso (NER) variam por espécie
    // Cães: NER = 70 * (peso^0.75)
    // Gatos: NER = 70 * (peso^0.67)
    final exponent = _calculatorPetType == 'Cachorro' ? 0.75 : 0.67;
    final rer = 70 * pow(weight, exponent);

    // Fatores de Necessidade Energética Diária (NED)
    double multiplier = 1.0; 

    if (_calculatorPetType == 'Cachorro') {
      switch (_calculatorLifeStage) {
        case 'Filhote':
          multiplier = 3.0; // Varia muito com a idade, 3.0 é uma média inicial
          break;
        case 'Adulto':
          switch (_calculatorActivityLevel) {
            case 'Baixo': multiplier = 1.4; break;
            case 'Médio': multiplier = 1.6; break;
            case 'Alto': multiplier = 1.8; break;
          }
          break;
        case 'Idoso':
          multiplier = 1.2;
          break;
      }
    } else { // Gato
      switch (_calculatorLifeStage) {
        case 'Filhote':
          multiplier = 2.5;
          break;
        case 'Adulto':
           switch (_calculatorActivityLevel) {
            case 'Baixo': multiplier = 1.2; break; // Gato castrado/interno
            case 'Médio': multiplier = 1.4; break; // Ativo
            case 'Alto': multiplier = 1.6; break; // Muito ativo
          }
          break;
        case 'Idoso':
          multiplier = 1.1;
          break;
      }
    }
    
    final der = rer * multiplier;
    final foodAmount = der / 3.5; // Assumindo 3.5 kcal/g para ração seca

    setState(() => _dailyFoodAmount = foodAmount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Painel do Tutor', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: Consumer2<AuthProvider, DataProvider>(
        builder: (context, authProvider, dataProvider, child) {
          if (dataProvider.isLoading && dataProvider.pets.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildHeader(authProvider),
                const SizedBox(height: 24),
                _buildFoodCalculator(),
                const SizedBox(height: 8),
                _buildSectionToggle(dataProvider),
                const SizedBox(height: 8),
                Expanded(
                  child: _buildContent(dataProvider),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: _selectedSection == 'pets'
          ? FloatingActionButton.extended(
              onPressed: _showAddPetDialog,
              label: const Text('Adicionar Pet'),
              icon: const Icon(Icons.add),
              backgroundColor: const Color(0xFF667eea),
            )
          : null,
    );
  }

  Widget _buildHeader(AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: const Color(0xFF667eea).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 28, backgroundColor: Colors.white, child: Icon(Icons.person_outline_rounded, color: Color(0xFF667eea), size: 30)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Olá, ${authProvider.currentUser?.name ?? 'Tutor'}!', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 2),
                Text(authProvider.currentUser?.email ?? '', style: TextStyle(color: Colors.white.withOpacity(0.85))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodCalculator() {
    return Card(
      elevation: _isCalculatorExpanded ? 6 : 2,
      shadowColor: _isCalculatorExpanded ? const Color(0xFF667eea).withOpacity(0.5) : Colors.black12,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        onExpansionChanged: (expanded) => setState(() => _isCalculatorExpanded = expanded),
        leading: const Icon(Icons.calculate_outlined, color: Color(0xFF667eea)),
        title: const Text('Calculadora de Ração', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text('Estime a porção diária do seu pet'),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _calculatorPetType,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Pet',
                          border: OutlineInputBorder(),
                        ),
                        items: ['Cachorro', 'Gato']
                            .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                            .toList(),
                        onChanged: (v) => setState(() => _calculatorPetType = v!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _calculatorWeightController,
                        decoration: const InputDecoration(
                          labelText: 'Peso (kg)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.line_weight)
                        ),
                        keyboardType: TextInputType.number
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: DropdownButtonFormField<String>(value: _calculatorLifeStage, decoration: const InputDecoration(labelText: 'Fase da Vida', border: OutlineInputBorder()), items: ['Filhote', 'Adulto', 'Idoso'].map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(), onChanged: (v) => setState(() => _calculatorLifeStage = v!))),
                  const SizedBox(width: 12),
                  Expanded(child: DropdownButtonFormField<String>(value: _calculatorActivityLevel, decoration: const InputDecoration(labelText: 'Nível de Atividade', border: OutlineInputBorder()), items: ['Baixo', 'Médio', 'Alto'].map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(), onChanged: (v) => setState(() => _calculatorActivityLevel = v!))),
                ]),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _calculateFood,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Calcular'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF764ba2), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15), textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                if (_dailyFoodAmount != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: Text('Recomendação diária: ${_dailyFoodAmount!.toStringAsFixed(0)} gramas', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                  ),
                ]
              ],
            ),
          )
        ],
      ),
    );
  }
  
  Widget _buildSectionToggle(DataProvider dataProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          _buildToggleButton('pets', 'Meus Pets', Icons.pets_rounded, dataProvider.pets.length),
          _buildToggleButton('products', 'Produtos', Icons.shopping_bag_outlined, dataProvider.products.length),
          _buildToggleButton('services', 'Serviços', Icons.medical_services_outlined, dataProvider.vetServices.length),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String section, String title, IconData icon, int count) {
    final bool isSelected = _selectedSection == section;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedSection = section),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: isSelected ? const Color(0xFF667eea) : Colors.transparent, borderRadius: BorderRadius.circular(10)),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.grey.shade700, size: 28),
              const SizedBox(height: 4),
              Text('$title ($count)', style: TextStyle(color: isSelected ? Colors.white : Colors.grey.shade700, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(DataProvider dataProvider) {
    switch (_selectedSection) {
      case 'pets':
        return _buildPetGrid(dataProvider.pets, dataProvider.isLoading);
      case 'products':
        return _buildProductList(dataProvider.products, dataProvider.isLoading);
      case 'services':
        return _buildVetServiceList(dataProvider.vetServices, dataProvider.isLoading);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPetGrid(List<Pet> pets, bool isLoading) {
    if (isLoading && pets.isEmpty) return const Center(child: CircularProgressIndicator());
    if (pets.isEmpty) return const Center(child: Text('Nenhum pet cadastrado.'));

    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: pets.length,
      itemBuilder: (context, index) {
        final pet = pets[index];
        return _buildPetCard(pet);
      },
    );
  }

  Widget _buildPetCard(Pet pet) {
    return Card(
      elevation: 4,
      shadowColor: Colors.grey.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => _showPetDetails(pet),
        borderRadius: BorderRadius.circular(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: (pet.photoUrl != null && pet.photoUrl!.isNotEmpty)
                  ? Image.network(
                      pet.photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildPetPlaceholderIcon(),
                    )
                  : _buildPetPlaceholderIcon(),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pet.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 4),
                    Text(pet.breed ?? pet.type, style: TextStyle(color: Colors.grey.shade600)),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blueGrey),
                          onPressed: () => _showEditPetDialog(pet),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _handleDeletePet(pet.id!),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetPlaceholderIcon() {
    return Container(
      color: Colors.grey.shade200,
      child: Icon(Icons.pets_rounded, size: 60, color: Colors.grey.shade400),
    );
  }

  Widget _buildProductList(List<Product> products, bool isLoading) {
    if (isLoading && products.isEmpty) return const Center(child: CircularProgressIndicator());
    if (products.isEmpty) return const Center(child: Text('Nenhum produto disponível.'));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) => _buildProductCard(products[index]),
    );
  }

  Widget _buildVetServiceList(List<VetService> services, bool isLoading) {
    if (isLoading && services.isEmpty) return const Center(child: CircularProgressIndicator());
    if (services.isEmpty) return const Center(child: Text('Nenhum serviço disponível.'));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: services.length,
      itemBuilder: (context, index) => _buildVetServiceCard(services[index]),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF764ba2).withOpacity(0.1),
          child: (product.imageUrl != null && product.imageUrl!.isNotEmpty)
              ? ClipOval(child: Image.network(product.imageUrl!, fit: BoxFit.cover, width: 40, height: 40))
              : const Icon(Icons.shopping_bag, color: Color(0xFF764ba2)),
        ),
        title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('R\$ ${product.price.toStringAsFixed(2)}'),
        onTap: () => _showProductDetails(product),
      ),
    );
  }

  Widget _buildVetServiceCard(VetService service) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        leading: CircleAvatar(backgroundColor: const Color(0xFF667eea).withOpacity(0.1), child: const Icon(Icons.medical_services, color: Color(0xFF667eea))),
        title: Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('R\$ ${service.price.toStringAsFixed(2)}'),
        onTap: () => _showVetServiceDetails(service),
      ),
    );
  }

  // --- SHOW DETAILS ---

  void _showPetDetails(Pet pet) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              (pet.photoUrl != null && pet.photoUrl!.isNotEmpty)
                ? CircleAvatar(backgroundImage: NetworkImage(pet.photoUrl!))
                : CircleAvatar(child: Icon(pet.type == 'Cachorro' ? Icons.pets : Icons.cruelty_free)),
              const SizedBox(width: 10),
              Text(pet.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(Icons.pets, 'Espécie', pet.type),
                if (pet.breed != null && pet.breed!.isNotEmpty)
                  _buildDetailRow(Icons.loyalty, 'Raça', pet.breed!),
                _buildDetailRow(Icons.cake, 'Idade', '${pet.age} anos'),
                _buildDetailRow(Icons.monitor_weight, 'Peso', '${pet.weight} kg'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            )
          ],
        );
      },
    );
  }

  void _showProductDetails(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF764ba2).withOpacity(0.1),
            child: (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                ? ClipOval(child: Image.network(product.imageUrl!, fit: BoxFit.cover, width: 40, height: 40))
                : const Icon(Icons.shopping_bag, color: Color(0xFF764ba2)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)))
        ]),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              _buildDetailRow(Icons.description, 'Descrição', product.description ?? 'Não informada'),
              _buildDetailRow(Icons.attach_money, 'Preço', 'R\$ ${product.price.toStringAsFixed(2)}'),
              const Divider(height: 20),
              _buildDetailRow(Icons.store, 'Vendido por', product.ownerName ?? 'Não informado'),
              _buildDetailRow(Icons.location_on, 'Localização', product.ownerLocation ?? 'Não informada'),
              _buildDetailRow(Icons.phone, 'Contato', product.ownerPhone ?? 'Não informado'),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Fechar'))],
      ),
    );
  }

  void _showVetServiceDetails(VetService service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [const Icon(Icons.medical_services, color: Colors.teal), const SizedBox(width: 8), Text(service.name)]),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              _buildDetailRow(Icons.description, 'Descrição', service.description ?? 'Não informada'),
              _buildDetailRow(Icons.attach_money, 'Preço', 'R\$ ${service.price.toStringAsFixed(2)}'),
              const Divider(height: 20),
              _buildDetailRow(Icons.store, 'Oferecido por', service.ownerName ?? 'Não informado'),
              _buildDetailRow(Icons.location_on, 'Localização', service.ownerLocation ?? 'Não informada'),
              _buildDetailRow(Icons.phone, 'Contato', service.ownerPhone ?? 'Não informado'),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Fechar'))],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(color: Colors.grey.shade800)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetFormDialog({required String title, required VoidCallback onSave}) {
    return AlertDialog(
      title: Text(title),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: StatefulBuilder(
        builder: (context, setDialogState) {
          return Form(
            key: _petFormKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(controller: _petNameController, decoration: const InputDecoration(labelText: 'Nome do Pet'), validator: (v) => v!.isEmpty ? 'Obrigatório' : null),
                  DropdownButtonFormField<String>(
                    value: _petType,
                    decoration: const InputDecoration(labelText: 'Espécie'),
                    items: ['Cachorro', 'Gato'].map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
                    onChanged: (newValue) => setDialogState(() => _petType = newValue!),
                  ),
                  TextFormField(controller: _petBreedController, decoration: const InputDecoration(labelText: 'Raça')),
                  TextFormField(controller: _petAgeController, decoration: const InputDecoration(labelText: 'Idade (anos)'), keyboardType: TextInputType.number),
                  TextFormField(controller: _petWeightController, decoration: const InputDecoration(labelText: 'Peso (kg)'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Obrigatório' : null),
                  DropdownButtonFormField<String>(
                    value: _petActivityLevel,
                    decoration: const InputDecoration(labelText: 'Nível de Atividade'),
                    items: ['Baixo', 'Médio', 'Alto'].map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
                    onChanged: (newValue) => setDialogState(() => _petActivityLevel = newValue!),
                  ),
                  TextFormField(
                    controller: _petPhotoUrlController,
                    decoration: const InputDecoration(labelText: 'URL da Foto do Pet'),
                    keyboardType: TextInputType.url,
                  ),
                ],
              ),
            ),
          );
        },
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(onPressed: onSave, child: const Text('Salvar')),
      ],
    );
  }
} 