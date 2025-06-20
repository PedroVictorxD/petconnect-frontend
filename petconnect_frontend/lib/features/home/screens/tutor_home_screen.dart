import 'package:flutter/material.dart';
import 'package:petconnect_frontend/core/models/produto.dart';
import 'package:petconnect_frontend/core/models/servico.dart';
import 'package:petconnect_frontend/features/auth/auth_service.dart';
import 'package:petconnect_frontend/features/lojista/product_service.dart';
import 'package:petconnect_frontend/features/veterinario/service_service.dart';
import 'package:petconnect_frontend/shared/themes/app_theme.dart';

class TutorHomeScreen extends StatefulWidget {
  const TutorHomeScreen({Key? key}) : super(key: key);

  @override
  State<TutorHomeScreen> createState() => _TutorHomeScreenState();
}

class _TutorHomeScreenState extends State<TutorHomeScreen> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final ProductService _productService = ProductService();
  final ServiceService _serviceService = ServiceService();

  late Future<List<Produto>> _productsFuture;
  late Future<List<Servico>> _servicesFuture;

  String _search = '';
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _productsFuture = _productService.getProducts();
    _servicesFuture = _serviceService.getServices();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.pets, color: AppTheme.primaryColor, size: 28),
            const SizedBox(width: 12),
            const Text('Dashboard do Tutor'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _authService.logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
        elevation: 2,
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- CARDS FLUTUANTES ---
            FutureBuilder<List<dynamic>>(
              future: Future.wait([_productsFuture, _servicesFuture]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()));
                } else if (snapshot.hasError) {
                  return const SizedBox();
                }
                final produtos = snapshot.data![0] as List<Produto>;
                final servicos = snapshot.data![1] as List<Servico>;
                return FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isMobile = constraints.maxWidth < 600;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            _DashboardCard(
                              color: AppTheme.primaryColor,
                              icon: Icons.shopping_bag,
                              label: 'Produtos disponíveis',
                              value: produtos.length,
                            ),
                            SizedBox(width: isMobile ? 0 : 24, height: isMobile ? 16 : 0),
                            _DashboardCard(
                              color: AppTheme.secondaryColor,
                              icon: Icons.medical_services,
                              label: 'Serviços disponíveis',
                              value: servicos.length,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            // --- BUSCA E LISTAGEM ---
            TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar produtos ou serviços',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _search = value.trim().toLowerCase();
                });
              },
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Row(
                children: [
                  // Produtos
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Produtos disponíveis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 8),
                        Expanded(
                          child: FutureBuilder<List<Produto>>(
                            future: _productsFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(child: Text('Erro ao carregar produtos: \\${snapshot.error}'));
                              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return const Center(child: Text('Nenhum produto encontrado.'));
                              }
                              final filtered = snapshot.data!.where((p) =>
                                p.nome.toLowerCase().contains(_search) ||
                                p.description.toLowerCase().contains(_search)
                              ).toList();
                              if (filtered.isEmpty) {
                                return const Center(child: Text('Nenhum produto corresponde à busca.'));
                              }
                              return ListView.builder(
                                itemCount: filtered.length,
                                itemBuilder: (context, i) {
                                  final produto = filtered[i];
                                  return Card(
                                    elevation: 6,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: AppTheme.primaryColor.withOpacity(0.15),
                                        child: Icon(Icons.shopping_bag, color: AppTheme.primaryColor),
                                      ),
                                      title: Text(produto.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      subtitle: Text(produto.description),
                                      trailing: Text('R\$ \\${produto.price.toStringAsFixed(2)}', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Serviços
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Serviços disponíveis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 8),
                        Expanded(
                          child: FutureBuilder<List<Servico>>(
                            future: _servicesFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(child: Text('Erro ao carregar serviços: \\${snapshot.error}'));
                              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return const Center(child: Text('Nenhum serviço encontrado.'));
                              }
                              final filtered = snapshot.data!.where((s) =>
                                s.nome.toLowerCase().contains(_search) ||
                                s.description.toLowerCase().contains(_search)
                              ).toList();
                              if (filtered.isEmpty) {
                                return const Center(child: Text('Nenhum serviço corresponde à busca.'));
                              }
                              return ListView.builder(
                                itemCount: filtered.length,
                                itemBuilder: (context, i) {
                                  final servico = filtered[i];
                                  return Card(
                                    elevation: 6,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: AppTheme.secondaryColor.withOpacity(0.15),
                                        child: Icon(Icons.medical_services, color: AppTheme.secondaryColor),
                                      ),
                                      title: Text(servico.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      subtitle: Text(servico.description),
                                      trailing: Text('R\$ \\${servico.price.toStringAsFixed(2)}', style: TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.bold)),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final int value;
  const _DashboardCard({required this.color, required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, right: 16),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.09),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.18),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color,
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 18),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text('$value', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 