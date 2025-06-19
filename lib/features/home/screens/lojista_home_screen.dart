import 'package:flutter/material.dart';
import '../../auth/auth_service.dart';
import '../../lojista/product_service.dart';

class LojistaHomeScreen extends StatefulWidget {
  @override
  State<LojistaHomeScreen> createState() => _LojistaHomeScreenState();
}

class _LojistaHomeScreenState extends State<LojistaHomeScreen> {
  List<Map<String, dynamic>> produtos = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProdutos();
  }

  Future<void> _fetchProdutos() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      produtos = await ProductService().fetchProdutos();
    } catch (e) {
      _error = e.toString();
    }
    setState(() { _isLoading = false; });
  }

  void _showProductDialog({Map<String, dynamic>? produto, int? index}) {
    final nomeController = TextEditingController(text: produto?['nome'] ?? produto?['name'] ?? '');
    final descController = TextEditingController(text: produto?['descricao'] ?? produto?['description'] ?? '');
    final valorController = TextEditingController(text: produto?['valor']?.toString() ?? produto?['price']?.toString() ?? '');
    final unidadeController = TextEditingController(text: produto?['unidade'] ?? produto?['unitOfMeasure'] ?? '');
    bool isLoading = false;
    String? errorMsg;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(produto == null ? 'Cadastrar Produto' : 'Editar Produto'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomeController,
                  decoration: InputDecoration(labelText: 'Nome'),
                ),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(labelText: 'Descrição'),
                ),
                TextField(
                  controller: valorController,
                  decoration: InputDecoration(labelText: 'Valor'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: unidadeController,
                  decoration: InputDecoration(labelText: 'Unidade de medida'),
                ),
                if (errorMsg != null) ...[
                  SizedBox(height: 8),
                  Text(errorMsg!, style: TextStyle(color: Colors.red)),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      setStateDialog(() { isLoading = true; errorMsg = null; });
                      final novoProduto = {
                        'nome': nomeController.text,
                        'descricao': descController.text,
                        'valor': double.tryParse(valorController.text) ?? 0.0,
                        'foto': null,
                        'unidade': unidadeController.text,
                      };
                      try {
                        if (produto == null) {
                          await ProductService().cadastrarProduto(novoProduto);
                        } else {
                          await ProductService().editarProduto(produto['id'], novoProduto);
                        }
                        Navigator.pop(context);
                        _fetchProdutos();
                      } catch (e) {
                        setStateDialog(() { errorMsg = e.toString(); isLoading = false; });
                      }
                    },
              child: isLoading ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRemove(int index) {
    final produto = produtos[index];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remover Produto'),
        content: Text('Tem certeza que deseja remover este produto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ProductService().removerProduto(produto['id']);
                _fetchProdutos();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro ao remover produto: $e')),
                );
              }
            },
            child: Text('Remover'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text('Lojista - Produtos'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            tooltip: 'Sair',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bem-vindo, ${user?['fullName'] ?? ''}', style: TextStyle(fontSize: 20)),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Produtos cadastrados', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ElevatedButton.icon(
                  onPressed: () => _showProductDialog(),
                  icon: Icon(Icons.add),
                  label: Text('Cadastrar Produto'),
                ),
              ],
            ),
            SizedBox(height: 12),
            if (_isLoading)
              Expanded(child: Center(child: CircularProgressIndicator())),
            if (_error != null)
              Expanded(child: Center(child: Text(_error!, style: TextStyle(color: Colors.red)))),
            if (!_isLoading && _error == null)
              Expanded(
                child: ListView.separated(
                  itemCount: produtos.length,
                  separatorBuilder: (_, __) => Divider(),
                  itemBuilder: (context, i) {
                    final p = produtos[i];
                    return ListTile(
                      leading: p['foto'] == null ? Icon(Icons.shopping_bag) : Image.network(p['foto']),
                      title: Text(p['nome'] ?? p['name'] ?? ''),
                      subtitle: Text('${p['descricao'] ?? p['description'] ?? ''}\nValor: R\$ ${p['valor'] ?? p['price'] ?? ''} | Unidade: ${p['unidade'] ?? p['unitOfMeasure'] ?? ''}'),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _showProductDialog(produto: p, index: i),
                            tooltip: 'Editar',
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _confirmRemove(i),
                            tooltip: 'Remover',
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
} 