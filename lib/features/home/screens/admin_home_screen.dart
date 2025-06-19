import 'package:flutter/material.dart';
import '../../auth/auth_service.dart';
import '../../admin/user_service.dart';

class AdminHomeScreen extends StatefulWidget {
  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;
  String? errorMsg;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchUsers();
  }

  Future<void> _loadUserData() async {
    final user = await AuthService().getUserData();
    setState(() {
      userData = user;
    });
  }

  Future<void> _fetchUsers() async {
    setState(() {
      isLoading = true;
      errorMsg = null;
    });
    try {
      final data = await UserService().fetchUsers();
      setState(() {
        users = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMsg = e.toString();
        isLoading = false;
      });
    }
  }

  void _showUserDialog({Map<String, dynamic>? user}) {
    final nameController = TextEditingController(text: user?['fullName'] ?? user?['name'] ?? '');
    final emailController = TextEditingController(text: user?['email'] ?? '');
    final passwordController = TextEditingController();
    String selectedUserType = user?['userType'] ?? 'TUTOR';
    bool isLoading = false;
    String? errorMsg;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(user == null ? 'Criar Usuário' : 'Editar Usuário'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Nome Completo'),
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                if (user == null) TextField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: 'Senha'),
                  obscureText: true,
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedUserType,
                  decoration: InputDecoration(labelText: 'Tipo de Usuário'),
                  items: ['ADMIN', 'TUTOR', 'VETERINARIO', 'LOJISTA'].map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) {
                    setStateDialog(() {
                      selectedUserType = value!;
                    });
                  },
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
                      final novoUser = {
                        'fullName': nameController.text,
                        'email': emailController.text,
                        'userType': selectedUserType,
                      };
                      if (user == null) {
                        novoUser['password'] = passwordController.text;
                      }
                      try {
                        if (user == null) {
                          await UserService().createUser(novoUser);
                        } else {
                          await UserService().updateUser(user['id'], novoUser);
                        }
                        Navigator.pop(context);
                        _fetchUsers();
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

  void _confirmDelete(int index) {
    final user = users[index];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Deletar Usuário'),
        content: Text('Tem certeza que deseja deletar este usuário?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await UserService().deleteUser(user['id']);
                _fetchUsers();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro ao deletar usuário: $e')),
                );
              }
            },
            child: Text('Deletar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Admin'),
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
                  child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 30),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bem-vindo, ${userData?['fullName'] ?? userData?['name'] ?? 'Administrador'}!',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text('Gerencie usuários do sistema'),
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
                              onPressed: _fetchUsers,
                              child: Text('Tentar Novamente'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchUsers,
                        child: ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            return Card(
                              margin: EdgeInsets.only(bottom: 16),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.teal,
                                  child: Icon(Icons.person, color: Colors.white),
                                ),
                                title: Text(user['fullName'] ?? user['name'] ?? 'Usuário'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(user['email'] ?? ''),
                                    Text(
                                      user['userType'] ?? '',
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
                                        title: Text('Deletar', style: TextStyle(color: Colors.red)),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ],
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _showUserDialog(user: user);
                                    } else if (value == 'delete') {
                                      _confirmDelete(index);
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
        onPressed: () => _showUserDialog(),
        child: Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
  }
} 