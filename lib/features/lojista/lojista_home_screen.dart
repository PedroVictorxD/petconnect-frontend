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
  final _imageUrlController = TextEditingController();

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
    _imageUrlController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _measurementUnitController.clear();
    _imageUrlController.clear();
  }

  void _showAddProductDialog() {
    _clearForm();
    showDialog(
      context: context,
      builder: (context) => _buildFormDialog(
        title: 'Adicionar Novo Produto',
        onSave: _addProduct,
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
      imageUrl: _imageUrlController.text,
      ownerId: authProvider.currentUser?.id,
      ownerName: authProvider.currentUser?.name,
      ownerLocation: authProvider.currentUser?.location,
      ownerPhone: authProvider.currentUser?.phone,
    );

    final success = await dataProvider.createProduct(product);
    
    if (mounted) {
      Navigator.pop(context);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Produto adicionado com sucesso!'), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(dataProvider.error ?? 'Erro ao adicionar produto'), backgroundColor: Colors.red));
      }
    }
  }

  void _showEditProductDialog(Product product) {
    _clearForm();
    _nameController.text = product.name;
    _descriptionController.text = product.description ?? '';
    _priceController.text = product.price.toString().replaceAll('.', ',');
    _measurementUnitController.text = product.measurementUnit ?? '';
    _imageUrlController.text = product.imageUrl ?? '';

    showDialog(
      context: context,
      builder: (context) => _buildFormDialog(
        title: 'Editar Produto',
        onSave: () => _updateProduct(product),
      ),
    );
  }

  Future<void> _updateProduct(Product product) async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    final updatedProduct = Product(
      id: product.id,
      name: _nameController.text,
      description: _descriptionController.text,
      price: double.parse(_priceController.text.replaceAll(',', '.')),
      measurementUnit: _measurementUnitController.text,
      imageUrl: _imageUrlController.text,
      ownerId: authProvider.currentUser?.id,
      ownerName: authProvider.currentUser?.name,
      ownerLocation: authProvider.currentUser?.location,
      ownerPhone: authProvider.currentUser?.phone,
    );

    final success = await dataProvider.updateProduct(updatedProduct);

    if (mounted) {
      Navigator.pop(context);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Produto atualizado com sucesso!'), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(dataProvider.error ?? 'Erro ao atualizar produto'), backgroundColor: Colors.red));
      }
    }
  }

  void _handleDeleteProduct(int productId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem certeza de que deseja excluir este produto? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteProduct(productId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduct(int productId) async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final success = await dataProvider.deleteProduct(productId);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Produto excluído com sucesso!'), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(dataProvider.error ?? 'Erro ao excluir produto'), backgroundColor: Colors.red));
      }
    }
  }

  Widget _buildFormDialog({required String title, required VoidCallback onSave}) {
    return AlertDialog(
      title: Text(title),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nome do Produto'), validator: (v) => v!.isEmpty ? 'Obrigatório' : null),
                TextFormField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Descrição'), maxLines: 2),
                TextFormField(controller: _priceController, decoration: const InputDecoration(labelText: 'Preço (R\$)', prefixIcon: Icon(Icons.attach_money)), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Obrigatório' : null),
                TextFormField(controller: _measurementUnitController, decoration: const InputDecoration(labelText: 'Unidade de Medida (kg, un, etc.)')),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(labelText: 'URL da Imagem do Produto'),
                  keyboardType: TextInputType.url,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(onPressed: onSave, child: const Text('Salvar')),
      ],
    );
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
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(authProvider),
                        const SizedBox(height: 24),
                        const Text("Meus Produtos", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                         const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                _buildProductGrid(myProducts),
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

  Widget _buildProductGrid(List<Product> products) {
    if (products.isEmpty) {
      return const SliverToBoxAdapter(
          child: Center(
              child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text("Você ainda não cadastrou nenhum produto.",
                      style: TextStyle(color: Colors.grey)))));
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 400.0,
          mainAxisSpacing: 16.0,
          crossAxisSpacing: 16.0,
          childAspectRatio: 2.8,
        ),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) => _buildProductCard(products[index]),
          childCount: products.length,
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      elevation: 4,
      shadowColor: Colors.grey.withOpacity(0.2),
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(15)),
              child: (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                ? Image.network(
                    product.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildProductPlaceholderIcon(),
                  )
                : _buildProductPlaceholderIcon(),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(product.description ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(height: 8),
                  Text('R\$ ${product.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
                ],
              ),
            ),
          ),
          Column(
            children: [
              IconButton(icon: const Icon(Icons.edit, color: Colors.blueGrey), onPressed: () => _showEditProductDialog(product)),
              IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent), onPressed: () => _handleDeleteProduct(product.id!)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildProductPlaceholderIcon() {
    return Container(
      color: Colors.grey.shade200,
      child: Icon(Icons.shopping_bag_outlined, size: 50, color: Colors.grey.shade400),
    );
  }
} 