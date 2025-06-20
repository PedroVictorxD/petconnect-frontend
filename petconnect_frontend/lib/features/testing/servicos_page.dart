import 'package:flutter/material.dart';
import 'api_service.dart';
import 'servicos_list.dart';

class ServicosPage extends StatelessWidget {
  final String token;
  const ServicosPage({required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Serviços')),
      body: FutureBuilder<List<dynamic>>(
        future: ApiService().getServicos(token),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: \\${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhum serviço encontrado.'));
          } else {
            return ServicosList(servicos: snapshot.data!);
          }
        },
      ),
    );
  }
} 