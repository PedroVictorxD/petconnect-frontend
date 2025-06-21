import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../models/product.dart';

class LojistaHomeScreen extends StatefulWidget {
  const LojistaHomeScreen({super.key});

  @override
  State<LojistaHomeScreen> createState() => _LojistaHomeScreenState();
}

class _LojistaHomeScreenState extends State<LojistaHomeScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _measurementUnitController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
      dataProvider.loadProducts();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _measurementUnitController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Novo Produto'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SizedBox(
          width: 500,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nome do Produto'),
                    validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Descrição'),
                    maxLines: 2,
                  ),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: 'Preço (R\$)', prefixIcon: Icon(Icons.attach_money)),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                  ),
                  TextFormField(
                    controller: _measurementUnitController,
                    decoration: const InputDecoration(labelText: 'Unidade de Medida (kg, un, etc.)'),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: _addProduct,
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  Future<void> _addProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    final product = Product(
      name: _nameController.text,
      description: _descriptionController.text,
      price: double.parse(_priceController.text.replaceAll(',', '.')),
      measurementUnit: _measurementUnitController.text,
      ownerId: authProvider.currentUser?.id,
      ownerName: authProvider.currentUser?.name,
      ownerLocation: authProvider.currentUser?.location,
      ownerPhone: authProvider.currentUser?.phone,
    );

    final success = await dataProvider.createProduct(product);
    
    if (success) {
      Navigator.pop(context);
      _clearForm();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produto adicionado com sucesso!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(dataProvider.error ?? 'Erro ao adicionar produto'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _clearForm() {
    _nameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _measurementUnitController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Painel do Lojista', style: TextStyle(fontWeight: FontWeight.bold)),
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
          if (dataProvider.isLoading && dataProvider.products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final myProducts = dataProvider.products.where((p) => p.ownerId == authProvider.currentUser?.id).toList();

          return FadeTransition(
            opacity: _fadeAnimation,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildHeader(authProvider),
                const SizedBox(height: 24),
                _buildProductList(myProducts),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddProductDialog,
        label: const Text('Adicionar Produto'),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFF667eea),
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
          const CircleAvatar(radius: 28, backgroundColor: Colors.white, child: Icon(Icons.store_rounded, color: Color(0xFF667eea), size: 30)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Olá, ${authProvider.currentUser?.name ?? 'Lojista'}!',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  authProvider.currentUser?.email ?? '',
                  style: TextStyle(color: Colors.white.withOpacity(0.85)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(List<Product> products) {
    if (products.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(32.0), child: Text("Você ainda não cadastrou nenhum produto.", style: TextStyle(color: Colors.grey))));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      itemBuilder: (context, index) => _buildProductCard(products[index]),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        leading: CircleAvatar(backgroundColor: const Color(0xFF764ba2).withOpacity(0.1), child: const Icon(Icons.shopping_bag, color: Color(0xFF764ba2))),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          product.description ?? 'Sem descrição',
        ),
        trailing: Text(
          'R\$ ${product.price.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16),
        ),
      ),
    );
  }
} 