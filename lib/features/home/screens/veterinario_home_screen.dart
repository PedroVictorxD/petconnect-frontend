import 'package:flutter/material.dart';
import 'package:petconnect_frontend/core/models/servico.dart';
import 'package:petconnect_frontend/features/auth/auth_service.dart';
import 'package:petconnect_frontend/features/veterinario/service_service.dart';
import 'package:petconnect_frontend/shared/themes/app_theme.dart';

class VeterinarioHomeScreen extends StatefulWidget {
  const VeterinarioHomeScreen({Key? key}) : super(key: key);

  @override
  State<VeterinarioHomeScreen> createState() => _VeterinarioHomeScreenState();
}

class _VeterinarioHomeScreenState extends State<VeterinarioHomeScreen> {
  final ServiceService _serviceService = ServiceService();
  final AuthService _authService = AuthService();
  late Future<List<Servico>> _servicesFuture;

  @override
  void initState() {
    super.initState();
    _servicesFuture = _serviceService.getServices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.medical_services, color: AppTheme.secondaryColor, size: 28),
            const SizedBox(width: 12),
            const Text('Dashboard do Veterinário'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
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
        child: FutureBuilder<List<Servico>>(
          future: _servicesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erro ao carregar serviços: \\${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Nenhum serviço encontrado.'));
            }

            final services = snapshot.data!;

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
                      headingRowColor: MaterialStateProperty.all(AppTheme.secondaryColor.withOpacity(0.08)),
                      columns: const [
                        DataColumn(label: Text('Nome', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Descrição', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Preço', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Ações', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: services.map((service) {
                        return DataRow(cells: [
                          DataCell(Text(service.nome)),
                          DataCell(Text(service.description)),
                          DataCell(Text('R\$ \\${service.price.toStringAsFixed(2)}')),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                color: AppTheme.infoColor,
                                tooltip: 'Editar',
                                onPressed: () async {
                                  final result = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => _ServiceFormDialog(
                                      serviceService: _serviceService,
                                      servico: service,
                                    ),
                                  );
                                  if (result == true) {
                                    setState(() {
                                      _servicesFuture = _serviceService.getServices();
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
                                      title: const Text('Remover Serviço'),
                                      content: Text('Tem certeza que deseja remover o serviço "${service.nome}"?'),
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
                                      await _serviceService.deleteService(service.id);
                                      setState(() {
                                        _servicesFuture = _serviceService.getServices();
                                      });
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Serviço removido com sucesso!'), backgroundColor: Colors.green),
                                        );
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Erro ao remover serviço: \\${e.toString()}'), backgroundColor: AppTheme.errorColor),
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
            builder: (context) => _ServiceFormDialog(serviceService: _serviceService),
          );
          if (result == true) {
            setState(() {
              _servicesFuture = _serviceService.getServices();
            });
          }
        },
        tooltip: 'Adicionar Serviço',
        backgroundColor: AppTheme.secondaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ServiceFormDialog extends StatefulWidget {
  final ServiceService serviceService;
  final Servico? servico;
  const _ServiceFormDialog({required this.serviceService, this.servico});

  @override
  State<_ServiceFormDialog> createState() => _ServiceFormDialogState();
}

class _ServiceFormDialogState extends State<_ServiceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descController = TextEditingController();
  final _precoController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.servico != null) {
      _nomeController.text = widget.servico!.nome;
      _descController.text = widget.servico!.description;
      _precoController.text = widget.servico!.price.toString();
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descController.dispose();
    _precoController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() { _isLoading = true; });
      try {
        final servico = Servico(
          id: widget.servico?.id ?? '',
          veterinarioId: '',
          nome: _nomeController.text,
          description: _descController.text,
          price: double.parse(_precoController.text.replaceAll(',', '.')),
        );
        if (widget.servico == null) {
          await widget.serviceService.addService(servico);
        } else {
          await widget.serviceService.updateService(servico.id, servico);
        }
        if (mounted) Navigator.of(context).pop(true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar serviço: \\${e.toString()}'), backgroundColor: AppTheme.errorColor),
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
      title: Text(widget.servico == null ? 'Cadastrar Serviço' : 'Editar Serviço'),
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
            backgroundColor: AppTheme.secondaryColor,
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