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
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
            tooltip: 'Sair',
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
    final stats = [
        _buildStatCard(Icons.people_alt_rounded, 'Usuários', dataProvider.allUsers.length.toString(), Colors.blue),
        _buildStatCard(Icons.pets_rounded, 'Pets', dataProvider.pets.length.toString(), Colors.orange),
        _buildStatCard(Icons.shopping_bag_rounded, 'Produtos', dataProvider.products.length.toString(), Colors.green),
        _buildStatCard(Icons.medical_services_rounded, 'Serviços', dataProvider.vetServices.length.toString(), Colors.purple),
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: stats.map((card) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final idealWidth = (constraints.maxWidth - 16 * 3) / 4;
            return ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: idealWidth > 100 ? idealWidth : 100,
              ),
              child: card,
            );
          },
        );
      }).toList(),
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
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
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
          'products' => _buildProductsTable(dataProvider.allProducts),
          'services' => _buildVetServicesTable(dataProvider.allVetServices),
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
        const DataColumn(label: Text('Ações')),
      ],
      users.map((user) => DataRow(cells: [
        DataCell(Text(user.name)),
        DataCell(Text(user.email)),
        DataCell(Text(user.phone ?? '-')),
        DataCell(Text(user.dtype ?? 'Tutor')),
        DataCell(Row(
          children: [
            IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _editUser(user)),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red), 
              onPressed: () => _deleteItem(context, 'usuário', user.id!, (id) => Provider.of<DataProvider>(context, listen: false).deleteUser(id)),
            ),
          ],
        )),
      ])).toList(),
      emptyMessage: "Nenhum usuário encontrado."
    );
  }

  Widget _buildPetsTable(List<Pet> pets) {
    return _buildTableContainer(
      [
        const DataColumn(label: Text('Nome')),
        const DataColumn(label: Text('Tipo')),
        const DataColumn(label: Text('Raça')),
        const DataColumn(label: Text('Dono')),
        const DataColumn(label: Text('Ações')),
      ],
      pets.map((pet) => DataRow(cells: [
        DataCell(Text(pet.name)),
        DataCell(Text(pet.type)),
        DataCell(Text(pet.breed ?? '-')),
        DataCell(Text(pet.tutor?['name'] ?? 'Não informado')),
        DataCell(Row(
          children: [
            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteItem(context, 'pet', pet.id!, (id) => Provider.of<DataProvider>(context, listen: false).deletePetFromAdmin(id))),
          ],
        )),
      ])).toList(),
      emptyMessage: "Nenhum pet encontrado."
    );
  }

  Widget _buildProductsTable(List<Product> products) {
    return _buildTableContainer(
      [
        const DataColumn(label: Text('Nome')),
        const DataColumn(label: Text('Descrição')),
        const DataColumn(label: Text('Preço')),
        const DataColumn(label: Text('Ações')),
      ],
      products.map((product) => DataRow(cells: [
        DataCell(Text(product.name)),
        DataCell(SizedBox(width: 200, child: Text(product.description ?? '', overflow: TextOverflow.ellipsis))),
        DataCell(Text('R\$ ${product.price.toStringAsFixed(2)}')),
        DataCell(Row(
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _editProduct(product),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteItem(context, 'produto', product.id!, (id) => Provider.of<DataProvider>(context, listen: false).deleteProduct(id)),
            ),
          ],
        )),
      ])).toList(),
      emptyMessage: "Nenhum produto encontrado."
    );
  }

  Widget _buildVetServicesTable(List<VetService> services) {
    return _buildTableContainer(
      [
        const DataColumn(label: Text('Nome')),
        const DataColumn(label: Text('Descrição')),
        const DataColumn(label: Text('Preço')),
        const DataColumn(label: Text('Ações')),
      ],
      services.map((service) => DataRow(cells: [
        DataCell(Text(service.name)),
        DataCell(SizedBox(width: 200, child: Text(service.description ?? '', overflow: TextOverflow.ellipsis))),
        DataCell(Text('R\$ ${service.price.toStringAsFixed(2)}')),
        DataCell(Row(
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _editService(service),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteItem(context, 'serviço', service.id!, (id) => Provider.of<DataProvider>(context, listen: false).deleteVetService(id)),
            ),
          ],
        )),
      ])).toList(),
      emptyMessage: "Nenhum serviço encontrado."
    );
  }

  void _editUser(User user) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final phoneController = TextEditingController(text: user.phone);
    
    // Controllers para campos específicos
    final crmvController = TextEditingController(text: user.dtype == 'Veterinario' ? (user as dynamic).crmv ?? '' : '');
    final cnpjController = TextEditingController(text: user.dtype == 'Lojista' ? (user as dynamic).cnpj ?? '' : '');
    final responsibleNameController = TextEditingController(text: user.dtype == 'Lojista' ? (user as dynamic).responsibleName ?? '' : '');
    final storeTypeController = TextEditingController(text: user.dtype == 'Lojista' ? (user as dynamic).storeType ?? '' : '');
    final operatingHoursController = TextEditingController(text: user.dtype == 'Lojista' ? (user as dynamic).operatingHours ?? '' : '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar ${user.dtype ?? 'Usuário'}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: InputDecoration(labelText: 'Nome')),
                TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
                TextField(controller: phoneController, decoration: InputDecoration(labelText: 'Telefone')),
                
                // Campos específicos para Veterinário
                if (user.dtype == 'Veterinario') ...[
                  const SizedBox(height: 16),
                  TextField(controller: crmvController, decoration: InputDecoration(labelText: 'CRMV')),
                ],
                
                // Campos específicos para Lojista
                if (user.dtype == 'Lojista') ...[
                  const SizedBox(height: 16),
                  TextField(controller: cnpjController, decoration: InputDecoration(labelText: 'CNPJ')),
                  TextField(controller: responsibleNameController, decoration: InputDecoration(labelText: 'Nome do Responsável')),
                  TextField(controller: storeTypeController, decoration: InputDecoration(labelText: 'Tipo de Loja')),
                  TextField(controller: operatingHoursController, decoration: InputDecoration(labelText: 'Horário de Funcionamento')),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                // Criar Map com os dados atualizados
                final Map<String, dynamic> updateData = {
                  'name': nameController.text,
                  'email': emailController.text,
                  'phone': phoneController.text,
                };
                
                // Adicionar campos específicos baseados no tipo
                if (user.dtype == 'Veterinario') {
                  updateData['crmv'] = crmvController.text;
                } else if (user.dtype == 'Lojista') {
                  updateData['cnpj'] = cnpjController.text;
                  updateData['responsibleName'] = responsibleNameController.text;
                  updateData['storeType'] = storeTypeController.text;
                  updateData['operatingHours'] = operatingHoursController.text;
                }

                final dataProvider = Provider.of<DataProvider>(context, listen: false);
                final success = await dataProvider.updateUserWithMap(user.id!, updateData);

                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Usuário atualizado com sucesso!' : 'Erro ao atualizar usuário.'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              },
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _editProduct(Product product) {
    final nameController = TextEditingController(text: product.name);
    final descriptionController = TextEditingController(text: product.description);
    final priceController = TextEditingController(text: product.price.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Produto'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: InputDecoration(labelText: 'Nome')),
                TextField(controller: descriptionController, decoration: InputDecoration(labelText: 'Descrição')),
                TextField(controller: priceController, decoration: InputDecoration(labelText: 'Preço'), keyboardType: TextInputType.numberWithOptions(decimal: true)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                final updatedProduct = Product(
                  id: product.id,
                  name: nameController.text,
                  description: descriptionController.text,
                  price: double.tryParse(priceController.text) ?? product.price,
                );

                final dataProvider = Provider.of<DataProvider>(context, listen: false);
                final success = await dataProvider.updateProduct(updatedProduct);

                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Produto atualizado com sucesso!' : 'Erro ao atualizar produto.'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              },
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _editService(VetService service) {
    final nameController = TextEditingController(text: service.name);
    final descriptionController = TextEditingController(text: service.description);
    final priceController = TextEditingController(text: service.price.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Serviço'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: InputDecoration(labelText: 'Nome')),
                TextField(controller: descriptionController, decoration: InputDecoration(labelText: 'Descrição')),
                TextField(controller: priceController, decoration: InputDecoration(labelText: 'Preço'), keyboardType: TextInputType.numberWithOptions(decimal: true)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                final updatedService = VetService(
                  id: service.id,
                  name: nameController.text,
                  description: descriptionController.text,
                  price: double.tryParse(priceController.text) ?? service.price,
                );

                final dataProvider = Provider.of<DataProvider>(context, listen: false);
                final success = await dataProvider.updateVetService(updatedService);

                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Serviço atualizado com sucesso!' : 'Erro ao atualizar serviço.'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              },
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _deleteItem(BuildContext context, String itemType, int itemId, Future<bool> Function(int) deleteFunction) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirmar Exclusão'),
        content: Text('Tem certeza de que deseja excluir este $itemType?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await deleteFunction(itemId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? '$itemType excluído com sucesso.' : 'Erro ao excluir o $itemType.'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
} 