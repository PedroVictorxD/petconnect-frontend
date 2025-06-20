import 'package:flutter/material.dart';
import 'package:petconnect_frontend/core/models/produto.dart';
import 'package:petconnect_frontend/features/auth/auth_service.dart';
import 'package:petconnect_frontend/features/lojista/product_service.dart';

class LojistaHomeScreen extends StatefulWidget {
  const LojistaHomeScreen({Key? key}) : super(key: key);

  @override
  State<LojistaHomeScreen> createState() => _LojistaHomeScreenState();
}

class _LojistaHomeScreenState extends State<LojistaHomeScreen> {
  final ProductService _productService = ProductService();
  final AuthService _authService = AuthService();
  late Future<List<Produto>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _productService.getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard do Lojista'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () {
              _authService.logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Produto>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar produtos: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum produto encontrado.'));
          }

          final products = snapshot.data!;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Nome')),
                DataColumn(label: Text('Descrição')),
                DataColumn(label: Text('Preço')),
                DataColumn(label: Text('Unidade')),
              ],
              rows: products.map((product) {
                return DataRow(cells: [
                  DataCell(Text(product.nome)),
                  DataCell(Text(product.description)),
                  DataCell(Text('R\$ ${product.price.toStringAsFixed(2)}')),
                  DataCell(Text(product.unitOfMeasure)),
                ]);
              }).toList(),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Lógica para adicionar novo produto virá aqui
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Adicionar novo produto (em breve)')),
          );
        },
        tooltip: 'Adicionar Produto',
        child: const Icon(Icons.add),
      ),
    );
  }
} 