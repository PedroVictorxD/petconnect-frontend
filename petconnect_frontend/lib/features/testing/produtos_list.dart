import 'package:flutter/material.dart';

class ProdutosList extends StatelessWidget {
  final List produtos;
  const ProdutosList({required this.produtos});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: produtos.length,
      itemBuilder: (context, index) {
        final product = produtos[index];
        return Card(
          child: ListTile(
            leading: product['photoUrl'] != null
                ? Image.network(product['photoUrl'])
                : Icon(Icons.shopping_bag),
            title: Text(product['nome'] ?? ''),
            subtitle: Text(product['description'] ?? ''),
            trailing: Text('R\$ ${product['price']?.toStringAsFixed(2) ?? ''}'),
          ),
        );
      },
    );
  }
} 