import 'package:flutter/material.dart';
import '../../auth/auth_service.dart';
import '../../veterinario/service_service.dart';

class VeterinarioHomeScreen extends StatefulWidget {
  @override
  _VeterinarioHomeScreenState createState() => _VeterinarioHomeScreenState();
}

class _VeterinarioHomeScreenState extends State<VeterinarioHomeScreen> {
  List<Map<String, dynamic>> servicos = [];
  bool isLoading = true;
  String? errorMsg;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchServicos();
  }

  Future<void> _loadUserData() async {
    final user = await AuthService().getUserData();
    setState(() {
      userData = user;
    });
  }

  Future<void> _fetchServicos() async {
    setState(() {
      isLoading = true;
      errorMsg = null;
    });
    try {
      final data = await ServiceService().fetchServicos();
      setState(() {
        servicos = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMsg = e.toString();
        isLoading = false;
      });
    }
  }

  void _showServiceDialog({Map<String, dynamic>? servico}) {
    final nomeController = TextEditingController(text: servico?['nome'] ?? servico?['name'] ?? '');
    final descController = TextEditingController(text: servico?['descricao'] ?? servico?['description'] ?? '');
    final valorController = TextEditingController(text: servico?['valor']?.toString() ?? servico?['price']?.toString() ?? '');
    bool isLoading = false;
    String? errorMsg;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(servico == null ? 'Cadastrar Serviço' : 'Editar Serviço'),
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
                      final novoServico = {
                        'nome': nomeController.text,
                        'descricao': descController.text,
                        'valor': double.tryParse(valorController.text) ?? 0.0,
                      };
                      try {
                        if (servico == null) {
                          await ServiceService().cadastrarServico(novoServico);
                        } else {
                          await ServiceService().editarServico(servico['id'], novoServico);
                        }
                        Navigator.pop(context);
                        _fetchServicos();
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
    final servico = servicos[index];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remover Serviço'),
        content: Text('Tem certeza que deseja remover este serviço?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ServiceService().removerServico(servico['id']);
                _fetchServicos();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro ao remover serviço: $e')),
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Veterinário'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.teal.shade50,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.teal,
                  child: Icon(Icons.pets, color: Colors.white, size: 30),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bem-vindo, ${userData?['name'] ?? 'Veterinário'}!',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text('Gerencie seus serviços veterinários'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : errorMsg != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Erro: $errorMsg', style: TextStyle(color: Colors.red)),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _fetchServicos,
                              child: Text('Tentar Novamente'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchServicos,
                        child: ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: servicos.length,
                          itemBuilder: (context, index) {
                            final servico = servicos[index];
                            return Card(
                              margin: EdgeInsets.only(bottom: 16),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.teal,
                                  child: Icon(Icons.medical_services, color: Colors.white),
                                ),
                                title: Text(servico['nome'] ?? servico['name'] ?? 'Serviço'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(servico['descricao'] ?? servico['description'] ?? ''),
                                    Text(
                                      'R\$ ${(servico['valor'] ?? servico['price'] ?? 0.0).toStringAsFixed(2)}',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                                    ),
                                  ],
                                ),
                                trailing: PopupMenuButton(
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: ListTile(
                                        leading: Icon(Icons.edit),
                                        title: Text('Editar'),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: ListTile(
                                        leading: Icon(Icons.delete, color: Colors.red),
                                        title: Text('Remover', style: TextStyle(color: Colors.red)),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ],
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _showServiceDialog(servico: servico);
                                    } else if (value == 'delete') {
                                      _confirmRemove(index);
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showServiceDialog(),
        child: Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
  }
} 