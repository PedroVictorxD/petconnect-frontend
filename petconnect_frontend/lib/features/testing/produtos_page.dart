import 'package:flutter/material.dart';
import 'api_service.dart';
import 'produtos_list.dart';

class ProdutosPage extends StatelessWidget {
  final String token;
  const ProdutosPage({required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Produtos')),
      body: FutureBuilder<List<dynamic>>(
        future: ApiService().getProdutos(token),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: \\${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhum produto encontrado.'));
          } else {
            return ProdutosList(produtos: snapshot.data!);
          }
        },
      ),
    );
  }
} 