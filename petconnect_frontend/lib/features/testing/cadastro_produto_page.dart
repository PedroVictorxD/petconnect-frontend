import 'package:flutter/material.dart';
import 'api_service.dart';
import 'produtos_list.dart';

class CadastroProdutoPage extends StatefulWidget {
  final String token;
  final String lojistaId;
  const CadastroProdutoPage({required this.token, required this.lojistaId});

  @override
  State<CadastroProdutoPage> createState() => _CadastroProdutoPageState();
}

class _CadastroProdutoPageState extends State<CadastroProdutoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _precoController = TextEditingController();
  final _unidadeController = TextEditingController();
  final _fotoUrlController = TextEditingController();
  bool _isLoading = false;
  String? _erro;
  List<dynamic> _produtos = [];

  @override
  void initState() {
    super.initState();
    _carregarProdutos();
  }

  Future<void> _carregarProdutos() async {
    setState(() { _isLoading = true; _erro = null; });
    try {
      final produtos = await ApiService().getProdutos(widget.token);
      setState(() { _produtos = produtos; });
    } catch (e) {
      setState(() { _erro = e.toString(); });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _cadastrarProduto() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _erro = null; });
    try {
      await ApiService().cadastrarProduto(
        token: widget.token,
        nome: _nomeController.text,
        descricao: _descricaoController.text,
        preco: double.parse(_precoController.text.replaceAll(',', '.')),
        unidade: _unidadeController.text,
        fotoUrl: _fotoUrlController.text,
        lojistaId: widget.lojistaId,
      );
      _nomeController.clear();
      _descricaoController.clear();
      _precoController.clear();
      _unidadeController.clear();
      _fotoUrlController.clear();
      await _carregarProdutos();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produto cadastrado com sucesso!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      setState(() { _erro = e.toString(); });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastro de Produto')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nomeController,
                      decoration: InputDecoration(labelText: 'Nome do produto'),
                      validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
                    ),
                    TextFormField(
                      controller: _descricaoController,
                      decoration: InputDecoration(labelText: 'Descrição'),
                      validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
                    ),
                    TextFormField(
                      controller: _precoController,
                      decoration: InputDecoration(labelText: 'Preço'),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Campo obrigatório';
                        final value = double.tryParse(v.replaceAll(',', '.'));
                        if (value == null || value <= 0) return 'Informe um valor válido';
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _unidadeController,
                      decoration: InputDecoration(labelText: 'Unidade de medida'),
                      validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
                    ),
                    TextFormField(
                      controller: _fotoUrlController,
                      decoration: InputDecoration(
                        labelText: 'URL da foto',
                        hintText: 'https://exemplo.com/imagem.jpg',
                        helperText: 'Insira o link direto da imagem do produto',
                        prefixIcon: Icon(Icons.image),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'A imagem do produto é obrigatória';
                        final uri = Uri.tryParse(v);
                        if (uri == null || !uri.isAbsolute || !(v.endsWith('.jpg') || v.endsWith('.png') || v.endsWith('.jpeg'))) {
                          return 'Insira uma URL válida de imagem (.jpg, .png)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _isLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _cadastrarProduto,
                            child: Text('Cadastrar Produto'),
                          ),
                    if (_erro != null) ...[
                      SizedBox(height: 8),
                      Text(_erro!, style: TextStyle(color: Colors.red)),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 400,
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ProdutosList(produtos: _produtos),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 