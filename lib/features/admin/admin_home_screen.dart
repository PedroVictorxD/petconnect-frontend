import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../models/user.dart';
import '../../models/pet.dart';
import '../../models/product.dart';
import '../../models/vet_service.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _selectedSection = 'users';

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
      dataProvider.loadAllUsers();
      dataProvider.loadPets();
      dataProvider.loadProducts();
      dataProvider.loadVetServices();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Painel do Administrador', style: TextStyle(fontWeight: FontWeight.bold)),
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
          if (dataProvider.isLoading && dataProvider.allUsers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return FadeTransition(
            opacity: _fadeAnimation,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeader(authProvider),
                const SizedBox(height: 24),
                _buildStatsGrid(dataProvider),
                const SizedBox(height: 24),
                _buildSectionToggle(),
                const SizedBox(height: 16),
                _buildAnimatedContent(dataProvider),
              ],
            ),
          );
        },
      ),
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
          const CircleAvatar(radius: 28, backgroundColor: Colors.white, child: Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF667eea), size: 30)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Olá, ${authProvider.currentUser?.name ?? 'Admin'}!', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 2),
                Text(authProvider.currentUser?.email ?? '', style: TextStyle(color: Colors.white.withOpacity(0.85))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(DataProvider dataProvider) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(Icons.people_alt_rounded, 'Usuários', dataProvider.allUsers.length.toString(), Colors.blue),
        _buildStatCard(Icons.pets_rounded, 'Pets', dataProvider.pets.length.toString(), Colors.orange),
        _buildStatCard(Icons.shopping_bag_rounded, 'Produtos', dataProvider.products.length.toString(), Colors.green),
        _buildStatCard(Icons.medical_services_rounded, 'Serviços', dataProvider.vetServices.length.toString(), Colors.purple),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: color.withOpacity(0.8)), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildSectionToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          _buildToggleButton('users', 'Usuários', Icons.people_outline),
          _buildToggleButton('pets', 'Pets', Icons.pets_outlined),
          _buildToggleButton('products', 'Produtos', Icons.shopping_bag_outlined),
          _buildToggleButton('services', 'Serviços', Icons.medical_services_outlined),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String section, String title, IconData icon) {
    final bool isSelected = _selectedSection == section;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedSection = section),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: isSelected ? const Color(0xFF667eea) : Colors.transparent, borderRadius: BorderRadius.circular(10)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.grey.shade700),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.grey.shade700, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedContent(DataProvider dataProvider) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: Container(
        key: ValueKey<String>(_selectedSection),
        child: switch (_selectedSection) {
          'users' => _buildUsersTable(dataProvider.allUsers),
          'pets' => _buildPetsTable(dataProvider.pets),
          'products' => _buildProductsTable(dataProvider.products),
          'services' => _buildVetServicesTable(dataProvider.vetServices),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
  
  Widget _buildTableContainer(List<DataColumn> columns, List<DataRow> rows, {String emptyMessage = "Nenhum dado encontrado."}) {
    if(rows.isEmpty) {
      return Center(child: Padding(padding: const EdgeInsets.all(32.0), child: Text(emptyMessage, style: const TextStyle(color: Colors.grey))));
    }
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: columns,
          rows: rows,
          columnSpacing: 24,
          headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
          headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
    );
  }

  Widget _buildUsersTable(List<User> users) {
    return _buildTableContainer(
      [
        const DataColumn(label: Text('Nome')),
        const DataColumn(label: Text('Email')),
        const DataColumn(label: Text('Telefone')),
        const DataColumn(label: Text('Tipo')),
      ],
      users.map((user) => DataRow(cells: [
        DataCell(Text(user.name)),
        DataCell(Text(user.email)),
        DataCell(Text(user.phone ?? '-')),
        DataCell(Text(user.isLojista ? 'Lojista' : (user.isVeterinario ? 'Veterinário' : 'Tutor'))),
      ])).toList(),
      emptyMessage: "Nenhum usuário encontrado."
    );
  }

  Widget _buildPetsTable(List<Pet> pets) {
    return _buildTableContainer(
      [
        const DataColumn(label: Text('ID')),
        const DataColumn(label: Text('Nome')),
        const DataColumn(label: Text('Espécie')),
        const DataColumn(label: Text('Raça')),
        const DataColumn(label: Text('Idade')),
      ],
      pets.map((pet) => DataRow(cells: [
        DataCell(Text(pet.id.toString())),
        DataCell(Text(pet.name)),
        DataCell(Text(pet.species)),
        DataCell(Text(pet.breed ?? 'N/A')),
        DataCell(Text(pet.age.toString())),
      ])).toList(),
      emptyMessage: "Nenhum pet encontrado."
    );
  }

  Widget _buildProductsTable(List<Product> products) {
    return _buildTableContainer(
      [
        const DataColumn(label: Text('Nome')),
        const DataColumn(label: Text('Preço')),
        const DataColumn(label: Text('Vendedor')),
      ],
      products.map((product) => DataRow(cells: [
        DataCell(Text(product.name)),
        DataCell(Text('R\$ ${product.price.toStringAsFixed(2)}')),
        DataCell(Text(product.ownerName ?? '-')),
      ])).toList(),
      emptyMessage: "Nenhum produto encontrado."
    );
  }

  Widget _buildVetServicesTable(List<VetService> services) {
    return _buildTableContainer(
      [
        const DataColumn(label: Text('Nome')),
        const DataColumn(label: Text('Preço')),
        const DataColumn(label: Text('Fornecedor')),
      ],
      services.map((service) => DataRow(cells: [
        DataCell(Text(service.name)),
        DataCell(Text('R\$ ${service.price.toStringAsFixed(2)}')),
        DataCell(Text(service.ownerName ?? '-')),
      ])).toList(),
      emptyMessage: "Nenhum serviço encontrado."
    );
  }
} 