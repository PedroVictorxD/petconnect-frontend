import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';

import '../../models/pet.dart';
import '../../models/vet_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';

class VetHomeScreen extends StatefulWidget {
  const VetHomeScreen({super.key});

  @override
  State<VetHomeScreen> createState() => _VetHomeScreenState();
}

class _VetHomeScreenState extends State<VetHomeScreen> with TickerProviderStateMixin {
  // Formulário de Serviço
  final _serviceFormKey = GlobalKey<FormState>();
  final _serviceNameController = TextEditingController();
  final _serviceDescriptionController = TextEditingController();
  final _servicePriceController = TextEditingController();
  final _serviceImageUrlController = TextEditingController();
  final _serviceOperatingHoursController = TextEditingController();

  // UI
  String _selectedSection = 'services';

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
      dataProvider.loadVetServices();
      dataProvider.loadPets();
    });
  }

  @override
  void dispose() {
    _serviceNameController.dispose();
    _serviceDescriptionController.dispose();
    _servicePriceController.dispose();
    _serviceImageUrlController.dispose();
    _serviceOperatingHoursController.dispose();
    _pawAnimationController?.dispose();
    super.dispose();
  }

  void _clearForm() {
    _serviceFormKey.currentState?.reset();
    _serviceNameController.clear();
    _serviceDescriptionController.clear();
    _servicePriceController.clear();
    _serviceImageUrlController.clear();
    _serviceOperatingHoursController.clear();
  }

  // --- MÉTODOS DE CRUD DE SERVIÇO ---

  void _showAddServiceDialog() {
    _clearForm();
    _showAnimatedDialog(
        title: 'Adicionar Novo Serviço',
        onSave: _addService,
    );
  }

  Future<void> _addService() async {
    if (!_serviceFormKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    final service = VetService(
      name: _serviceNameController.text,
      description: _serviceDescriptionController.text,
      price: double.parse(_servicePriceController.text.replaceAll(',', '.')),
      imageUrl: _serviceImageUrlController.text,
      operatingHours: _serviceOperatingHoursController.text,
      ownerId: authProvider.currentUser?.id,
      ownerName: authProvider.currentUser?.name,
      ownerLocation: authProvider.currentUser?.location,
      ownerPhone: authProvider.currentUser?.phone,
      ownerCrmv: authProvider.currentUser?.crmv,
    );

    final success = await dataProvider.createVetService(service);
    
    if (mounted) {
      Navigator.pop(context);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Serviço adicionado com sucesso!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(dataProvider.error ?? 'Erro ao adicionar serviço'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showEditServiceDialog(VetService service) {
    _clearForm();
    _serviceNameController.text = service.name;
    _serviceDescriptionController.text = service.description ?? '';
    _servicePriceController.text = service.price.toString().replaceAll('.', ',');
    _serviceImageUrlController.text = service.imageUrl ?? '';
    _serviceOperatingHoursController.text = service.operatingHours ?? '';

    _showAnimatedDialog(
        title: 'Editar Serviço',
        onSave: () => _updateService(service),
    );
  }

  Future<void> _updateService(VetService service) async {
    if (!_serviceFormKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    final updatedService = VetService(
      id: service.id,
      name: _serviceNameController.text,
      description: _serviceDescriptionController.text,
      price: double.parse(_servicePriceController.text.replaceAll(',', '.')),
      imageUrl: _serviceImageUrlController.text,
      operatingHours: _serviceOperatingHoursController.text,
      ownerId: authProvider.currentUser?.id,
      ownerName: authProvider.currentUser?.name,
      ownerLocation: authProvider.currentUser?.location,
      ownerPhone: authProvider.currentUser?.phone,
      ownerCrmv: authProvider.currentUser?.crmv,
    );

    final success = await dataProvider.updateVetService(updatedService);

    if (mounted) {
      Navigator.pop(context);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Serviço atualizado com sucesso!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(dataProvider.error ?? 'Erro ao atualizar serviço'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _handleDeleteService(int serviceId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF33333D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirmar Exclusão', style: TextStyle(color: Colors.white)),
        content: const Text('Tem certeza de que deseja excluir este serviço? Esta ação não pode ser desfeita.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteService(serviceId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteService(int serviceId) async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final success = await dataProvider.deleteVetService(serviceId);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Serviço excluído com sucesso!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(dataProvider.error ?? 'Erro ao excluir serviço'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showAnimatedDialog({required String title, required Future<void> Function() onSave}) {
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
            child: _buildFormDialog(title: title, onSave: onSave),
          ),
        );
      },
    );
  }

  Widget _buildFormDialog({required String title, required Future<void> Function() onSave}) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(title.startsWith('Adicionar') ? Icons.add_box_rounded : Icons.edit_rounded, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(color: Colors.white)),
        ],
      ),
      backgroundColor: const Color(0xFF6A5ACD).withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withOpacity(0.3)),
      ),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _serviceFormKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextFormField(
                  controller: _serviceNameController,
                  labelText: 'Nome do Serviço',
                  icon: Icons.medical_services,
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: _serviceDescriptionController,
                  labelText: 'Descrição do Serviço',
                  icon: Icons.description,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: _servicePriceController,
                  labelText: 'Preço (R\$)',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: _serviceImageUrlController,
                  labelText: 'URL da Imagem do Serviço',
                  icon: Icons.image,
                  keyboardType: TextInputType.url,
                  isOptional: true,
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: _serviceOperatingHoursController,
                  labelText: 'Horário de Funcionamento',
                  icon: Icons.access_time,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          onPressed: onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF9370DB),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('Salvar'),
        ),
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    int? maxLines = 1,
    TextInputType? keyboardType = TextInputType.text,
    bool isOptional = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
        filled: true,
        fillColor: Colors.black.withOpacity(0.15),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: const Color(0xFF9370DB), width: 2),
        ),
      ),
      validator: (v) {
        if (!isOptional && (v == null || v.isEmpty)) {
          return 'Campo obrigatório';
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
        title: const Text("Painel do Veterinário", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          if (dataProvider.isLoading && dataProvider.vetServices.isEmpty) {
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
                Icons.local_hospital_rounded,
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
                    'Olá, Dr(a). ${authProvider.currentUser?.name ?? 'Veterinário'}!',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                  const SizedBox(height: 4),
                  Text(
                    'CRMV: ${authProvider.currentUser?.crmv ?? 'Não informado'}',
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
    final servicesCount = dataProvider.vetServices.length;
    final totalPetsCount = dataProvider.pets.length;

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            icon: Icons.medical_services,
            label: 'Serviços',
            value: servicesCount.toString(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            icon: Icons.pets,
            label: 'Pets',
            value: totalPetsCount.toString(),
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
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: _buildSelectorButton(
              icon: Icons.medical_services_outlined,
              label: 'Serviços',
              isSelected: _selectedSection == 'services',
              onTap: () => setState(() => _selectedSection = 'services'),
            ),
          ),
          Expanded(
            child: _buildSelectorButton(
              icon: Icons.pets_outlined,
              label: 'Pets',
              isSelected: _selectedSection == 'pets',
              onTap: () => setState(() => _selectedSection = 'pets'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF667eea) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
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

  Widget _buildSectionContent(DataProvider dataProvider) {
    if (_selectedSection == 'services') {
      final services = dataProvider.vetServices;
      if (services.isEmpty) {
        return _buildEmptyState(
          'Nenhum Serviço Cadastrado',
          'Adicione um novo serviço no botão +',
          Icons.medical_services_rounded,
        );
      }
      return SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 400.0,
          mainAxisSpacing: 16.0,
          crossAxisSpacing: 16.0,
          childAspectRatio: 0.9,
        ),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            return _buildServiceCard(services[index]);
          },
          childCount: services.length,
        ),
      );
    } else if (_selectedSection == 'pets') {
      final pets = dataProvider.pets;
      if (pets.isEmpty) {
        return _buildEmptyState(
          'Nenhum Pet Encontrado',
          'Os tutores ainda não cadastraram seus pets.',
          Icons.pets,
        );
      }
      return SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 350.0,
          mainAxisSpacing: 16.0,
          crossAxisSpacing: 16.0,
          childAspectRatio: 1.0,
        ),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            return _buildPetCard(pets[index]);
          },
          childCount: pets.length,
      ),
    );
  }
    // Fallback
    return const SliverToBoxAdapter(child: SizedBox.shrink());
  }

  // --- WIDGETS DE CONSTRUÇÃO DE CARDS ---

  Widget _buildServiceCard(VetService service) {
    return Card(
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
              child: (service.imageUrl != null && service.imageUrl!.isNotEmpty)
                  ? Image.network(
                      service.imageUrl!,
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
                            Icon(Icons.medical_services, color: Colors.white70, size: 40),
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
                      service.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  Text(
                    service.description ?? 'Sem descrição',
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                  Text(
                          'R\$ ${service.price.toStringAsFixed(2).replaceAll('.', ',')}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.white70, size: 20),
                              onPressed: () => _showEditServiceDialog(service),
                              tooltip: 'Editar Serviço',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                              onPressed: () => _handleDeleteService(service.id!),
                              tooltip: 'Excluir Serviço',
                            ),
                          ],
                        )
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
    if (_selectedSection == 'services') {
      return Positioned(
        bottom: 16,
        right: 16,
        child: FloatingActionButton(
          heroTag: 'addServiceBtn',
          onPressed: _showAddServiceDialog,
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

  // --- ANIMAÇÃO DE PATINHAS ---
  // (O restante do código permanece o mesmo)
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
      // Movimento vertical
      final currentY = paw.position.dy - (animationValue * 100 * paw.speed);
      
      if (currentY < -50) {
        // Reinicia a posição no topo quando sai da tela por baixo
        // Esta lógica de atualização de estado não deve estar no paint.
        // A animação deve ser controlada no AnimationController.
        // Por simplicidade, vamos deixar o controller fazer o loop.
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