import 'package:flutter/material.dart';
import 'package:petconnect_frontend/core/models/produto.dart';
import 'package:petconnect_frontend/features/auth/auth_service.dart';
import 'package:petconnect_frontend/features/lojista/product_service.dart';
import 'package:petconnect_frontend/shared/themes/app_theme.dart';

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
        title: Row(
          children: [
            Icon(Icons.store, color: AppTheme.primaryColor, size: 28),
            const SizedBox(width: 12),
            const Text('Dashboard do Lojista'),
          ],
        ),
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
        elevation: 2,
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
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

            final products = snapshot.data!;

            return Center(
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 32,
                      headingRowColor: MaterialStateProperty.all(AppTheme.primaryColor.withOpacity(0.08)),
                      columns: const [
                        DataColumn(label: Text('Nome', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Descrição', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Preço', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Unidade', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Ações', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: products.map((product) {
                        return DataRow(cells: [
                          DataCell(Text(product.nome)),
                          DataCell(Text(product.description)),
                          DataCell(Text('R\$ \\${product.price.toStringAsFixed(2)}')),
                          DataCell(Text(product.unitOfMeasure)),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                color: AppTheme.infoColor,
                                tooltip: 'Editar',
                                onPressed: () async {
                                  final result = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => _ProductFormDialog(
                                      productService: _productService,
                                      produto: product,
                                    ),
                                  );
                                  if (result == true) {
                                    setState(() {
                                      _productsFuture = _productService.getProducts();
                                    });
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                color: AppTheme.errorColor,
                                tooltip: 'Remover',
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      title: const Text('Remover Produto'),
                                      content: Text('Tem certeza que deseja remover o produto "${product.nome}"?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(false),
                                          child: const Text('Cancelar'),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppTheme.errorColor,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                          onPressed: () => Navigator.of(context).pop(true),
                                          child: const Text('Remover'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    try {
                                      await _productService.deleteProduct(product.id);
                                      setState(() {
                                        _productsFuture = _productService.getProducts();
                                      });
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Produto removido com sucesso!'), backgroundColor: Colors.green),
                                        );
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Erro ao remover produto: \\${e.toString()}'), backgroundColor: AppTheme.errorColor),
                                        );
                                      }
                                    }
                                  }
                                },
                              ),
                            ],
                          )),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showDialog<bool>(
            context: context,
            builder: (context) => _ProductFormDialog(productService: _productService),
          );
          if (result == true) {
            setState(() {
              _productsFuture = _productService.getProducts();
            });
          }
        },
        tooltip: 'Adicionar Produto',
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ProductFormDialog extends StatefulWidget {
  final ProductService productService;
  final Produto? produto;
  const _ProductFormDialog({required this.productService, this.produto});

  @override
  State<_ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<_ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descController = TextEditingController();
  final _precoController = TextEditingController();
  final _unidadeController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.produto != null) {
      _nomeController.text = widget.produto!.nome;
      _descController.text = widget.produto!.description;
      _precoController.text = widget.produto!.price.toString();
      _unidadeController.text = widget.produto!.unitOfMeasure;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descController.dispose();
    _precoController.dispose();
    _unidadeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() { _isLoading = true; });
      try {
        final produto = Produto(
          id: widget.produto?.id ?? '',
          lojistaId: '',
          nome: _nomeController.text,
          description: _descController.text,
          price: double.parse(_precoController.text.replaceAll(',', '.')),
          unitOfMeasure: _unidadeController.text,
        );
        if (widget.produto == null) {
          await widget.productService.addProduct(produto);
        } else {
          await widget.productService.updateProduct(produto.id, produto);
        }
        if (mounted) Navigator.of(context).pop(true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar produto: \\${e.toString()}'), backgroundColor: AppTheme.errorColor),
        );
      } finally {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(widget.produto == null ? 'Cadastrar Produto' : 'Editar Produto'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome', border: OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Descrição', border: OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _precoController,
                decoration: const InputDecoration(labelText: 'Preço', border: OutlineInputBorder()),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Campo obrigatório';
                  final value = double.tryParse(v.replaceAll(',', '.'));
                  if (value == null || value <= 0) return 'Informe um valor válido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _unidadeController,
                decoration: const InputDecoration(labelText: 'Unidade', border: OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: _isLoading ? null : _submit,
          child: _isLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Salvar'),
        ),
      ],
    );
  }
} 