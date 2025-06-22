import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../models/vet_service.dart';

class VetHomeScreen extends StatefulWidget {
  const VetHomeScreen({super.key});

  @override
  State<VetHomeScreen> createState() => _VetHomeScreenState();
}

class _VetHomeScreenState extends State<VetHomeScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _operatingHoursController = TextEditingController();

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
      dataProvider.loadVetServices();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _operatingHoursController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _operatingHoursController.clear();
  }

  void _showAddServiceDialog() {
    _clearForm();
    showDialog(
      context: context,
      builder: (context) => _buildFormDialog(
        title: 'Adicionar Novo Serviço',
        onSave: _addService,
      ),
    );
  }

  Future<void> _addService() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    final service = VetService(
      name: _nameController.text,
      description: _descriptionController.text,
      price: double.parse(_priceController.text.replaceAll(',', '.')),
      operatingHours: _operatingHoursController.text,
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Serviço adicionado com sucesso!'), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(dataProvider.error ?? 'Erro ao adicionar serviço'), backgroundColor: Colors.red));
      }
    }
  }

  void _showEditServiceDialog(VetService service) {
    _clearForm();
    _nameController.text = service.name;
    _descriptionController.text = service.description ?? '';
    _priceController.text = service.price.toString().replaceAll('.', ',');
    _operatingHoursController.text = service.operatingHours ?? '';

    showDialog(
      context: context,
      builder: (context) => _buildFormDialog(
        title: 'Editar Serviço',
        onSave: () => _updateService(service),
      ),
    );
  }

  Future<void> _updateService(VetService service) async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    final updatedService = VetService(
      id: service.id,
      name: _nameController.text,
      description: _descriptionController.text,
      price: double.parse(_priceController.text.replaceAll(',', '.')),
      operatingHours: _operatingHoursController.text,
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Serviço atualizado com sucesso!'), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(dataProvider.error ?? 'Erro ao atualizar serviço'), backgroundColor: Colors.red));
      }
    }
  }

  void _handleDeleteService(int serviceId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem certeza de que deseja excluir este serviço? Esta ação não pode ser desfeita.'),
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Serviço excluído com sucesso!'), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(dataProvider.error ?? 'Erro ao excluir serviço'), backgroundColor: Colors.red));
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
                TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nome do Serviço'), validator: (v) => v!.isEmpty ? 'Obrigatório' : null),
                TextFormField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Descrição'), maxLines: 2),
                TextFormField(controller: _priceController, decoration: const InputDecoration(labelText: 'Preço (R\$)', prefixIcon: Icon(Icons.attach_money)), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Obrigatório' : null),
                TextFormField(controller: _operatingHoursController, decoration: const InputDecoration(labelText: 'Horário de Atendimento')),
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
        title: const Text('Painel do Veterinário', style: TextStyle(fontWeight: FontWeight.bold)),
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
          if (dataProvider.isLoading && dataProvider.vetServices.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final myServices = dataProvider.vetServices.where((s) => s.ownerId == authProvider.currentUser?.id).toList();

          return FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(authProvider),
                        const SizedBox(height: 24),
                        const Text("Meus Serviços", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                _buildServiceGrid(myServices),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddServiceDialog,
        label: const Text('Adicionar Serviço'),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFF667eea),
      ),
    );
  }

  Widget _buildHeader(AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.medical_services_rounded,
              color: Color(0xFF667eea),
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Olá, Dr. ${authProvider.currentUser?.name ?? 'Veterinário'}!',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                if (authProvider.currentUser?.crmv != null)
                  Text(
                    'CRMV: ${authProvider.currentUser?.crmv}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceGrid(List<VetService> services) {
    if (services.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Text(
              "Você ainda não cadastrou nenhum serviço.",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
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
          (BuildContext context, int index) => _buildServiceCard(services[index]),
          childCount: services.length,
        ),
      ),
    );
  }

  Widget _buildServiceCard(VetService service) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF764ba2).withOpacity(0.1),
              child: const Icon(Icons.local_hospital_rounded, color: Color(0xFF764ba2)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    service.description ?? 'Sem descrição',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Text(
                    'R\$ ${service.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 15),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditServiceDialog(service);
                } else if (value == 'delete') {
                  _handleDeleteService(service.id!);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(value: 'edit', child: ListTile(leading: Icon(Icons.edit), title: Text('Editar'))),
                const PopupMenuItem<String>(value: 'delete', child: ListTile(leading: Icon(Icons.delete), title: Text('Excluir'))),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 