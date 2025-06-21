import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../models/pet.dart';
import '../../models/product.dart';
import '../../models/vet_service.dart';
import 'dart:math';

class TutorHomeScreen extends StatefulWidget {
  const TutorHomeScreen({super.key});

  @override
  State<TutorHomeScreen> createState() => _TutorHomeScreenState();
}

class _TutorHomeScreenState extends State<TutorHomeScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();
  final _breedController = TextEditingController();
  final _notesController = TextEditingController();
  String _activityLevel = 'Médio';

  // State for food calculator
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
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Carregar dados
      dataProvider.loadPets(tutorId: authProvider.currentUser?.id);
      dataProvider.loadProducts();
      dataProvider.loadVetServices();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    _breedController.dispose();
    _notesController.dispose();
    _calculatorWeightController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _showAddPetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Novo Pet'),
        content: SizedBox(
          width: 500,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nome'), validator: (v) => v!.isEmpty ? 'Obrigatório' : null),
                  TextFormField(controller: _typeController, decoration: const InputDecoration(labelText: 'Tipo (Cachorro, Gato...)'), validator: (v) => v!.isEmpty ? 'Obrigatório' : null),
                  TextFormField(controller: _weightController, decoration: const InputDecoration(labelText: 'Peso (kg)'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Obrigatório' : null),
                  TextFormField(controller: _ageController, decoration: const InputDecoration(labelText: 'Idade'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Obrigatório' : null),
                  TextFormField(controller: _breedController, decoration: const InputDecoration(labelText: 'Raça')),
                  DropdownButtonFormField<String>(
                    value: _activityLevel,
                    decoration: const InputDecoration(labelText: 'Nível de Atividade'),
                    items: ['Baixo', 'Médio', 'Alto'].map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                    onChanged: (v) => setState(() => _activityLevel = v!),
                  ),
                  TextFormField(controller: _notesController, decoration: const InputDecoration(labelText: 'Observações'), maxLines: 3),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(onPressed: _addPet, child: const Text('Adicionar')),
        ],
      ),
    );
  }

  Future<void> _addPet() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    final pet = Pet(
      name: _nameController.text,
      type: _typeController.text,
      weight: double.parse(_weightController.text),
      age: int.parse(_ageController.text),
      activityLevel: _activityLevel,
      breed: _breedController.text,
      notes: _notesController.text,
      tutorId: authProvider.currentUser?.id,
    );

    final success = await dataProvider.createPet(pet);
    
    if (success) {
      Navigator.pop(context);
      _clearForm();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pet adicionado com sucesso!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(dataProvider.error ?? 'Erro ao adicionar pet'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _clearForm() {
    _nameController.clear();
    _typeController.clear();
    _weightController.clear();
    _ageController.clear();
    _breedController.clear();
    _notesController.clear();
    setState(() => _activityLevel = 'Médio');
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
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildHeader(authProvider),
                const SizedBox(height: 24),
                _buildFoodCalculator(),
                const SizedBox(height: 8),
                _buildSectionToggle(dataProvider),
                const SizedBox(height: 8),
                _buildAnimatedContent(dataProvider),
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

  Widget _buildAnimatedContent(DataProvider dataProvider) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: SlideTransition(position: Tween<Offset>(begin: const Offset(0.0, 0.1), end: Offset.zero).animate(animation), child: child)),
      child: Container(
        key: ValueKey<String>(_selectedSection),
        child: switch (_selectedSection) {
          'pets' => _buildContentList(dataProvider.pets, (item) => _buildPetCard(item as Pet, dataProvider), "Nenhum pet cadastrado ainda."),
          'products' => _buildContentList(dataProvider.products, (item) => _buildProductCard(item as Product, dataProvider), "Nenhum produto disponível."),
          'services' => _buildContentList(dataProvider.vetServices, (item) => _buildVetServiceCard(item as VetService, dataProvider), "Nenhum serviço disponível."),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }

  Widget _buildContentList(List<dynamic> items, Widget Function(dynamic item) cardBuilder, String emptyMessage) {
    if (items.isEmpty) {
      return Center(child: Padding(padding: const EdgeInsets.all(32.0), child: Text(emptyMessage, style: const TextStyle(color: Colors.grey))));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) => cardBuilder(items[index]),
    );
  }

  Widget _buildPetCard(Pet pet, DataProvider provider) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        leading: CircleAvatar(backgroundColor: const Color(0xFF667eea).withOpacity(0.1), child: const Icon(Icons.pets, color: Color(0xFF667eea))),
        title: Text(pet.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${pet.breed ?? 'Sem raça'} • ${pet.age} anos • ${pet.weight} kg'),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
        onTap: () => _showPetDetailsDialog(pet),
      ),
    );
  }

  Widget _buildProductCard(Product product, DataProvider provider) {
     return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        leading: CircleAvatar(backgroundColor: const Color(0xFF764ba2).withOpacity(0.1), child: const Icon(Icons.shopping_bag, color: Color(0xFF764ba2))),
        title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('R\$ ${product.price.toStringAsFixed(2)}'),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
        onTap: () => _showProductDetailsDialog(product),
      ),
    );
  }

  Widget _buildVetServiceCard(VetService service, DataProvider provider) {
     return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        leading: CircleAvatar(backgroundColor: Colors.teal.withOpacity(0.1), child: const Icon(Icons.medical_services, color: Colors.teal)),
        title: Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('R\$ ${service.price.toStringAsFixed(2)}'),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
        onTap: () => _showVetServiceDetailsDialog(service),
      ),
    );
  }

  void _showPetDetailsDialog(Pet pet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [const Icon(Icons.pets, color: Color(0xFF667eea)), const SizedBox(width: 8), Text(pet.name)]),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              _buildDetailRow(Icons.category, 'Tipo', pet.type),
              _buildDetailRow(Icons.monitor_weight, 'Peso', '${pet.weight} kg'),
              _buildDetailRow(Icons.cake, 'Idade', '${pet.age} anos'),
              _buildDetailRow(Icons.pets, 'Raça', pet.breed ?? 'Não informada'),
              _buildDetailRow(Icons.directions_run, 'Nível de Atividade', pet.activityLevel),
              if (pet.notes != null && pet.notes!.isNotEmpty)
                _buildDetailRow(Icons.notes, 'Observações', pet.notes!),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Fechar'))],
      ),
    );
  }

  void _showProductDetailsDialog(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [const Icon(Icons.shopping_bag, color: Color(0xFF764ba2)), const SizedBox(width: 8), Text(product.name)]),
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

  void _showVetServiceDetailsDialog(VetService service) {
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

  Widget _buildDetailRow(IconData icon, String title, String value) {
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
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(color: Colors.grey.shade800)),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 