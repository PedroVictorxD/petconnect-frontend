import 'package:flutter/material.dart';
import 'package:petconnect_frontend/core/models/user.dart';
import 'package:petconnect_frontend/features/admin/user_service.dart';
import 'package:petconnect_frontend/features/auth/auth_service.dart';
import 'package:petconnect_frontend/shared/themes/app_theme.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
  late Future<List<User>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _userService.getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.admin_panel_settings, color: AppTheme.primaryColor, size: 28),
            const SizedBox(width: 12),
            const Text('Dashboard do Admin'),
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
        child: FutureBuilder<List<User>>(
          future: _usersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erro ao carregar usuários: \\${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Nenhum usuário encontrado.'));
            }

            final users = snapshot.data!;

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
                        DataColumn(label: Text('Nome Completo', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Tipo', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: users.map((user) {
                        return DataRow(cells: [
                          DataCell(Text(user.fullName)),
                          DataCell(Text(user.email)),
                          DataCell(Text(user.userType)),
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
    );
  }
} 