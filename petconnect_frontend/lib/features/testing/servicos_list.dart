import 'package:flutter/material.dart';

class ServicosList extends StatelessWidget {
  final List servicos;
  const ServicosList({required this.servicos});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: servicos.length,
      itemBuilder: (context, index) {
        final servico = servicos[index];
        return Card(
          child: ListTile(
            leading: Icon(Icons.medical_services),
            title: Text(servico['nome'] ?? ''),
            subtitle: Text(servico['description'] ?? ''),
            trailing: Text('R\$ ${servico['price']?.toStringAsFixed(2) ?? ''}'),
          ),
        );
      },
    );
  }
} 