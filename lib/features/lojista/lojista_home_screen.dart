import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';
import 'package:flutter/rendering.dart';

import '../../models/pet.dart';
import '../../models/product.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../core/widgets/custom_alert_dialog.dart';

class LojistaHomeScreen extends StatefulWidget {
  const LojistaHomeScreen({super.key});

  @override
  State<LojistaHomeScreen> createState() => _LojistaHomeScreenState();
}

class _LojistaHomeScreenState extends State<LojistaHomeScreen> with TickerProviderStateMixin {
  // Formulário de Produto
  final _productFormKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _productDescriptionController = TextEditingController();
  final _productPriceController = TextEditingController();
  final _productImageUrlController = TextEditingController();
  final _productCategoryController = TextEditingController();

  // UI
  String _selectedSection = 'products';

  // Animação do Fundo
  AnimationController? _pawAnimationController;
  final List<_Paw> _paws = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadData();
  }

  void _initializeAnimations() {
    _pawAnimationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
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
          speed: _random.nextDouble() * 2 + 1,
        ));
      }
    });
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      dataProvider.loadProducts();
      dataProvider.loadPets();
    });
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _productDescriptionController.dispose();
    _productPriceController.dispose();
    _productImageUrlController.dispose();
    _productCategoryController.dispose();
    _pawAnimationController?.dispose();
    super.dispose();
  }

  void _clearForm() {
    _productFormKey.currentState?.reset();
    _productNameController.clear();
    _productDescriptionController.clear();
    _productPriceController.clear();
    _productImageUrlController.clear();
    _productCategoryController.clear();
  }

  // --- MÉTODOS DE CRUD DE PRODUTO ---

  void _showAddProductDialog() {
    _clearForm();
    _showAnimatedDialog(
        title: 'Adicionar Novo Produto',
        onSave: _addProduct,
    );
  }

  Future<void> _addProduct() async {
    if (!_productFormKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    final product = Product(
      name: _productNameController.text,
      description: _productDescriptionController.text,
      price: double.parse(_productPriceController.text.replaceAll(',', '.')),
      imageUrl: _productImageUrlController.text,
      category: _productCategoryController.text,
      ownerId: authProvider.currentUser?.id,
      ownerName: authProvider.currentUser?.name,
      ownerLocation: authProvider.currentUser?.location,
      ownerPhone: authProvider.currentUser?.phone,
    );

    final success = await dataProvider.createProduct(product);
    
    if (mounted) {
      Navigator.pop(context);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produto adicionado com sucesso!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(dataProvider.error ?? 'Erro ao adicionar produto'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showEditProductDialog(Product product) {
    _clearForm();
    _productNameController.text = product.name;
    _productDescriptionController.text = product.description ?? '';
    _productPriceController.text = product.price.toString().replaceAll('.', ',');
    _productImageUrlController.text = product.imageUrl ?? '';
    _productCategoryController.text = product.category ?? '';

    _showAnimatedDialog(
        title: 'Editar Produto',
        onSave: () => _updateProduct(product),
    );
  }

  Future<void> _updateProduct(Product product) async {
    if (!_productFormKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    final updatedProduct = Product(
      id: product.id,
      name: _productNameController.text,
      description: _productDescriptionController.text,
      price: double.parse(_productPriceController.text.replaceAll(',', '.')),
      imageUrl: _productImageUrlController.text,
      category: _productCategoryController.text,
      ownerId: authProvider.currentUser?.id,
      ownerName: authProvider.currentUser?.name,
      ownerLocation: authProvider.currentUser?.location,
      ownerPhone: authProvider.currentUser?.phone,
    );

    final success = await dataProvider.updateProduct(updatedProduct);

    if (mounted) {
      Navigator.pop(context);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produto atualizado com sucesso!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(dataProvider.error ?? 'Erro ao atualizar produto'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produto excluído com sucesso!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(dataProvider.error ?? 'Erro ao excluir produto'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showAnimatedDialog({required String title, required Future<void> Function() onSave}) {
    showDialog(
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            title: Text(title, style: const TextStyle(color: Colors.white)),
            backgroundColor: const Color(0xFF3a3a5c).withOpacity(0.9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            content: _buildProductForm(),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
              ),
              ElevatedButton(
                onPressed: () async {
                  await onSave();
                },
                child: const Text('Salvar'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductForm() {
    return Form(
      key: _productFormKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
            _buildTextFormField(
              controller: _productNameController,
              labelText: 'Nome do Produto',
              icon: Icons.label,
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _productDescriptionController,
              labelText: 'Descrição',
              icon: Icons.description,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _productPriceController,
              labelText: 'Preço',
              icon: Icons.attach_money,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _productImageUrlController,
              labelText: 'URL da Imagem',
              icon: Icons.image,
              isOptional: true,
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _productCategoryController,
              labelText: 'Categoria',
              icon: Icons.category,
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool isOptional = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.deepPurpleAccent),
        ),
      ),
      validator: (value) {
        if (!isOptional && (value == null || value.isEmpty)) {
          return 'Este campo é obrigatório';
        }
        return null;
      },
    );
  }

  // --- WIDGETS DE CONSTRUÇÃO DA UI ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF667eea),
        elevation: 0,
        title: const Text("Painel do Lojista", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
            tooltip: 'Sair',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Fundo animado
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
                  Color(0xFFf093fb),
                ],
                stops: [0.0, 0.6, 1.0],
              ),
            ),
            child: AnimatedBuilder(
              animation: _pawAnimationController!,
              builder: (context, child) {
                return CustomPaint(
                  painter: _PawPrintPainter(_paws, _pawAnimationController!.value),
                );
            },
          ),
      ),
          
          // Conteúdo principal
          SafeArea(
            child: Consumer2<AuthProvider, DataProvider>(
        builder: (context, authProvider, dataProvider, child) {
          if (dataProvider.isLoading && dataProvider.products.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                return CustomScrollView(
              slivers: [
                    // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                        child: _buildHeader(authProvider, dataProvider),
                      ),
                    ),

                    // Seletor de seções
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: _buildSectionSelector(),
                      ),
                    ),

                    // Conteúdo das seções
                    SliverPadding(
                      padding: const EdgeInsets.all(16.0),
                      sliver: _buildSectionContent(dataProvider),
                    ),

                    // Espaço para botões flutuantes
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 100),
                    ),
              ],
          );
        },
      ),
          ),

          // Botões flutuantes
          _buildFloatingActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader(AuthProvider authProvider, DataProvider dataProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
      ),
              child: const Icon(
                Icons.store,
                color: Colors.white,
                size: 30,
              ),
            ),
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
                  const SizedBox(height: 4),
                  Text(
                    'Sua loja de produtos para pets',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildDashboardMetrics(dataProvider),
      ],
    );
  }

  Widget _buildDashboardMetrics(DataProvider dataProvider) {
    final productsCount = dataProvider.products.length;
    final petsCount = dataProvider.pets.length;

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            icon: Icons.shopping_bag,
            label: 'Produtos',
            value: productsCount.toString(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            icon: Icons.pets,
            label: 'Pets na Plataforma',
            value: petsCount.toString(),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({required IconData icon, required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 8),
                Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: Colors.white.withOpacity(0.9)),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          _buildSectionButton('products', 'Meus Produtos', Icons.shopping_bag),
          _buildSectionButton('pets', 'Pets na Plataforma', Icons.pets),
        ],
      ),
    );
  }

  Widget _buildSectionButton(String section, String label, IconData icon) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedSection = section;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: _selectedSection == section ? const Color(0xFF667eea) : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
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
      ),
    );
  }

  Widget _buildSectionContent(DataProvider dataProvider) {
    switch (_selectedSection) {
      case 'products':
        return _buildProductGrid(dataProvider.products);
      case 'pets':
        return _buildPetGrid(dataProvider.pets);
      default:
        return _buildProductGrid(dataProvider.products);
    }
  }

  Widget _buildProductGrid(List<Product> products) {
    if (products.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(top: 100),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.shopping_bag, size: 60, color: Colors.white30),
                SizedBox(height: 16),
                Text('Nenhum produto cadastrado.', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ),
      );
    }

    return SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 0.9,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildProductCard(products[index]),
        childCount: products.length,
      ),
    );
  }

  Widget _buildPetGrid(List<Pet> pets) {
    if (pets.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(top: 100),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.pets, size: 60, color: Colors.white30),
                SizedBox(height: 16),
                Text('Nenhum pet encontrado na plataforma.', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ),
      );
    }

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 0.9,
        ),
        delegate: SliverChildBuilderDelegate(
        (context, index) => _buildPetCard(pets[index]),
        childCount: pets.length,
      ),
    );
  }

  Widget _buildEmptyState(String title, String message, IconData icon) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.white.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS DE CONSTRUÇÃO DE CARDS ---

  Widget _buildProductCard(Product product) {
    return Card(
      elevation: 4,
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
              child: (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                ? ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
                    child: Image.network(
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
                                Icon(Icons.shopping_bag, size: 60, color: Colors.white30),
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
                  )
                : Container(
                    color: Colors.black.withOpacity(0.2),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_bag, size: 60, color: Colors.white30),
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
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.description ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  'R\$ ${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
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
                  icon: const Icon(Icons.edit, color: Colors.white70),
                  onPressed: () => _showEditProductDialog(product),
                  tooltip: 'Editar',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => _handleDeleteProduct(product.id!),
                  tooltip: 'Excluir',
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPetCard(Pet pet) {
    return GestureDetector(
      onTap: () => _showPetDetailsDialog(pet),
      child: Card(
        elevation: 4,
        color: Colors.white.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: (pet.photoUrl != null && pet.photoUrl!.isNotEmpty)
                    ? Image.network(
                        pet.photoUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator(color: Colors.white));
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(child: Icon(Icons.broken_image, color: Colors.white70, size: 40));
                        },
                      )
                    : Container(
                        color: Colors.black.withOpacity(0.2),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.pets, color: Colors.white70, size: 40),
                              SizedBox(height: 8),
                              Text('Sem Imagem', style: TextStyle(color: Colors.white70)),
                            ],
                          ),
                        ),
            ),
          ),
          Expanded(
                flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                      Text(
                        pet.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  const SizedBox(height: 4),
                      Text(
                        pet.breed ?? 'Sem raça',
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                           Text(
                            'Tutor: ${pet.ownerName ?? 'Não informado'}',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.amber.shade200),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      if (pet.ownerPhone != null && pet.ownerPhone!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                pet.ownerPhone!,
                                style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.message,
                                color: Colors.green,
                                size: 16,
                              ),
                              onPressed: () => _launchWhatsApp(pet.ownerPhone!),
                              tooltip: 'Contatar tutor',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ],
                ],
              ),
            ),
          ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    if (_selectedSection == 'products') {
      return Positioned(
        bottom: 16,
        right: 16,
        child: FloatingActionButton(
          heroTag: 'addProductBtn',
          onPressed: _showAddProductDialog,
          backgroundColor: const Color(0xFF667eea),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  void _showPetDetailsDialog(Pet pet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C34).withOpacity(0.95),
         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(pet.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (pet.photoUrl != null && pet.photoUrl!.isNotEmpty)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(pet.photoUrl!, height: 150, fit: BoxFit.cover),
                  ),
                ),
              const SizedBox(height: 16),
              _buildDetailRow(Icons.pets, 'Raça', pet.breed ?? 'Não informada'),
              _buildDetailRow(Icons.cake, 'Idade', '${pet.age} anos'),
              _buildDetailRow(Icons.scale, 'Peso', '${pet.weight} kg'),
              _buildDetailRow(Icons.person, 'Tutor', pet.ownerName ?? 'Não informado'),
              _buildDetailRow(Icons.phone, 'Contato', pet.ownerPhone ?? 'Não informado'),
              if(pet.notes != null && pet.notes!.isNotEmpty)
                 _buildDetailRow(Icons.notes, 'Notas', pet.notes!),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Fechar', style: TextStyle(color: Colors.white70)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          if (pet.ownerPhone != null && pet.ownerPhone!.isNotEmpty)
            ElevatedButton.icon(
              icon: const Icon(Icons.chat, size: 18),
              label: const Text('Contatar Tutor'),
              onPressed: () => _launchWhatsApp(pet.ownerPhone!),
               style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.7), size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                 const SizedBox(height: 2),
                 Text(value, style: const TextStyle(color: Colors.white, fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchWhatsApp(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final whatsappUrl = "https://wa.me/55$cleanPhone";
    
    try {
      await launchUrl(Uri.parse(whatsappUrl), mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível abrir o WhatsApp: $e')),
        );
      }
    }
  }
}

// --- Classes de Animação e Pintura ---

class _Paw {
  Offset position;
  final double scale;
  final double opacity;
  final double speed;

  _Paw({
    required this.position,
    required this.scale,
    required this.opacity,
    required this.speed,
  });
}

class _PawPrintPainter extends CustomPainter {
  final List<_Paw> paws;
  final double animationValue;

  _PawPrintPainter(this.paws, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    if (paws.isEmpty) return;

    for (final paw in paws) {
      final currentY = paw.position.dy - (animationValue * 100 * paw.speed);
      
      if (currentY < -50) {
        // A animação deve ser controlada no AnimationController.
      }

      paint.color = Colors.white.withOpacity(paw.opacity);

      // Desenho da patinha
      final pawSize = 20.0 * paw.scale;
      final center = Offset(paw.position.dx, currentY);

      // Palma
      final mainPad = RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: pawSize, height: pawSize * 0.9),
        Radius.circular(pawSize * 0.3),
      );
      canvas.drawRRect(mainPad, paint);

      // Dedos
      final toeSize = pawSize * 0.25;
      final toeY = center.dy - (pawSize * 0.6);
      canvas.drawCircle(Offset(center.dx - pawSize * 0.4, toeY), toeSize, paint);
      canvas.drawCircle(Offset(center.dx + pawSize * 0.4, toeY), toeSize, paint);
      canvas.drawCircle(Offset(center.dx - pawSize * 0.15, toeY - toeSize * 0.5), toeSize, paint);
      canvas.drawCircle(Offset(center.dx + pawSize * 0.15, toeY - toeSize * 0.5), toeSize, paint);
  }
  }

  @override
  bool shouldRepaint(covariant _PawPrintPainter oldDelegate) => true;
} 