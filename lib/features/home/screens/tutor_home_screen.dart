import 'package:flutter/material.dart';
import '../../auth/auth_service.dart';

class TutorHomeScreen extends StatefulWidget {
  @override
  State<TutorHomeScreen> createState() => _TutorHomeScreenState();
}

class _TutorHomeScreenState extends State<TutorHomeScreen> {
  final List<Map<String, dynamic>> produtos = [
    {
      'nome': 'Ração Premium',
      'lojista': 'PetShop Central',
      'endereco': 'Rua das Flores, 123',
      'valor': 89.90,
      'contato': '(11) 99999-0000',
      'foto': null,
    },
    {
      'nome': 'Brinquedo para Gato',
      'lojista': 'PetStore Online',
      'endereco': 'Av. Brasil, 456',
      'valor': 29.90,
      'contato': '(11) 98888-1111',
      'foto': null,
    },
  ];
  final List<Map<String, dynamic>> servicos = [
    {
      'nome': 'Consulta Veterinária',
      'veterinario': 'Dr. João',
      'endereco': 'Rua Saúde, 789',
      'valor': 120.00,
      'contato': '(11) 97777-2222',
      'foto': null,
    },
    {
      'nome': 'Vacinação',
      'veterinario': 'Dra. Ana',
      'endereco': 'Av. Pet, 321',
      'valor': 80.00,
      'contato': '(11) 96666-3333',
      'foto': null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text('Tutor - Dashboard'),
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
        child: ListView(
          children: [
            Text('Bem-vindo, ${user?['fullName'] ?? ''}', style: TextStyle(fontSize: 20)),
            SizedBox(height: 16),
            Text('Produtos de Lojistas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 8),
            SizedBox(
              height: 180,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: produtos.length,
                separatorBuilder: (_, __) => SizedBox(width: 16),
                itemBuilder: (context, i) {
                  final p = produtos[i];
                  return Card(
                    child: Container(
                      width: 220,
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: p['foto'] == null
                                ? Icon(Icons.pets, size: 48)
                                : Image.network(p['foto'], fit: BoxFit.cover),
                          ),
                          Text(p['nome'], style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Lojista: ${p['lojista']}'),
                          Text('Endereço: ${p['endereco']}'),
                          Text('Valor: R\$ ${p['valor']}'),
                          Text('Contato: ${p['contato']}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 24),
            Text('Serviços de Veterinários', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 8),
            SizedBox(
              height: 180,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: servicos.length,
                separatorBuilder: (_, __) => SizedBox(width: 16),
                itemBuilder: (context, i) {
                  final s = servicos[i];
                  return Card(
                    child: Container(
                      width: 220,
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: s['foto'] == null
                                ? Icon(Icons.medical_services, size: 48)
                                : Image.network(s['foto'], fit: BoxFit.cover),
                          ),
                          Text(s['nome'], style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Veterinário: ${s['veterinario']}'),
                          Text('Endereço: ${s['endereco']}'),
                          Text('Valor: R\$ ${s['valor']}'),
                          Text('Contato: ${s['contato']}'),
                        ],
                      ),
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