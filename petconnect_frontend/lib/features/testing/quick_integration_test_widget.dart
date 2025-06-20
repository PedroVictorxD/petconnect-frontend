import 'package:flutter/material.dart';
import 'package:petconnect_frontend/features/auth/auth_service.dart';
import 'package:petconnect_frontend/features/lojista/product_service.dart';
import 'package:petconnect_frontend/features/veterinario/service_service.dart';
import 'package:petconnect_frontend/features/admin/user_service.dart';
import 'package:petconnect_frontend/core/models/produto.dart';
import 'package:petconnect_frontend/core/models/servico.dart';

class QuickIntegrationTestWidget extends StatefulWidget {
  const QuickIntegrationTestWidget({Key? key}) : super(key: key);

  @override
  State<QuickIntegrationTestWidget> createState() => _QuickIntegrationTestWidgetState();
}

class _QuickIntegrationTestWidgetState extends State<QuickIntegrationTestWidget> {
  final AuthService _authService = AuthService();
  final ProductService _productService = ProductService();
  final ServiceService _serviceService = ServiceService();
  final UserService _userService = UserService();

  String _result = '';

  void _setResult(String msg) {
    setState(() => _result = msg);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Testes Rápidos de Integração')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: _testRegister,
                child: const Text('1. Cadastro de Usuário'),
              ),
              ElevatedButton(
                onPressed: _testLogin,
                child: const Text('2. Login'),
              ),
              ElevatedButton(
                onPressed: _testCadastrarVeterinarioDominio,
                child: const Text('3. Cadastro Veterinário de Domínio'),
              ),
              ElevatedButton(
                onPressed: _testCadastrarLojistaDominio,
                child: const Text('4. Cadastro Lojista de Domínio'),
              ),
              ElevatedButton(
                onPressed: _testAddProduct,
                child: const Text('5. Adicionar Produto'),
              ),
              ElevatedButton(
                onPressed: _testListProducts,
                child: const Text('6. Listar Produtos'),
              ),
              ElevatedButton(
                onPressed: _testAddService,
                child: const Text('7. Adicionar Serviço'),
              ),
              ElevatedButton(
                onPressed: _testListServices,
                child: const Text('8. Listar Serviços'),
              ),
              ElevatedButton(
                onPressed: _testDashboardAdmin,
                child: const Text('9. Dashboard Admin'),
              ),
              ElevatedButton(
                onPressed: _testDashboardTutor,
                child: const Text('10. Dashboard Tutor'),
              ),
              ElevatedButton(
                onPressed: _testDashboardVeterinario,
                child: const Text('11. Dashboard Veterinário'),
              ),
              const SizedBox(height: 24),
              Text(_result, style: const TextStyle(fontSize: 14, color: Colors.blue)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _testRegister() async {
    try {
      final msg = await _authService.register({
        'email': 'teste${DateTime.now().millisecondsSinceEpoch}@email.com',
        'password': 'Senha@123',
        'fullName': 'Usuário Teste',
        'userType': 'TUTOR',
      });
      _setResult('Cadastro realizado: $msg');
    } catch (e) {
      _setResult('Erro no cadastro: $e');
    }
  }

  Future<void> _testLogin() async {
    try {
      final user = await _authService.login('usuario@email.com', 'Senha@123');
      _setResult('Login realizado: ${user.fullName} (${user.userType})');
    } catch (e) {
      _setResult('Erro no login: $e');
    }
  }

  Future<void> _testCadastrarVeterinarioDominio() async {
    try {
      await _serviceService.cadastrarVeterinarioDominio({
        'userId': '<UUID_DO_USUARIO_VETERINARIO>',
        'nome': 'Veterinário Teste',
        'crmv': '12345',
        'localizacao': 'Rua das Flores, 100',
        'numeroContato': '11999999999',
        'horariosFuncionamento': '08:00-18:00',
      });
      _setResult('Veterinário de domínio cadastrado!');
    } catch (e) {
      _setResult('Erro ao cadastrar veterinário de domínio: $e');
    }
  }

  Future<void> _testCadastrarLojistaDominio() async {
    try {
      await _productService.cadastrarLojistaDominio({
        'userId': '<UUID_DO_USUARIO_LOJISTA>',
        'nome': 'Lojista Teste',
        'cnpj': '12345678000199',
        'localizacao': 'Rua das Lojas, 200',
        'numeroContato': '11988888888',
        'tipoLoja': 'VIRTUAL',
      });
      _setResult('Lojista de domínio cadastrado!');
    } catch (e) {
      _setResult('Erro ao cadastrar lojista de domínio: $e');
    }
  }

  Future<void> _testAddProduct() async {
    try {
      final produto = Produto(
        id: '',
        lojistaId: '<UUID_DO_LOJISTA>',
        nome: 'Ração Premium',
        description: 'Ração de alta qualidade para cães',
        price: 89.90,
        unitOfMeasure: 'kg',
      );
      final prod = await _productService.addProduct(produto);
      _setResult('Produto adicionado: ${prod.nome}');
    } catch (e) {
      _setResult('Erro ao adicionar produto: $e');
    }
  }

  Future<void> _testListProducts() async {
    try {
      final produtos = await _productService.getProducts();
      _setResult('Produtos encontrados: ${produtos.length}');
    } catch (e) {
      _setResult('Erro ao listar produtos: $e');
    }
  }

  Future<void> _testAddService() async {
    try {
      final servico = Servico(
        id: '',
        veterinarioId: '<UUID_DO_VETERINARIO>',
        nome: 'Consulta Clínica',
        description: 'Consulta geral para pets',
        price: 120.00,
      );
      final serv = await _serviceService.addService(servico);
      _setResult('Serviço adicionado: ${serv.nome}');
    } catch (e) {
      _setResult('Erro ao adicionar serviço: $e');
    }
  }

  Future<void> _testListServices() async {
    try {
      final servicos = await _serviceService.getServices();
      _setResult('Serviços encontrados: ${servicos.length}');
    } catch (e) {
      _setResult('Erro ao listar serviços: $e');
    }
  }

  Future<void> _testDashboardAdmin() async {
    try {
      final dash = await _userService.getAdminDashboard();
      _setResult('Dashboard admin: ${dash.toString()}');
    } catch (e) {
      _setResult('Erro ao buscar dashboard admin: $e');
    }
  }

  Future<void> _testDashboardTutor() async {
    try {
      final dash = await _authService.getTutorDashboard();
      _setResult('Dashboard tutor: ${dash.toString()}');
    } catch (e) {
      _setResult('Erro ao buscar dashboard tutor: $e');
    }
  }

  Future<void> _testDashboardVeterinario() async {
    try {
      final dash = await _serviceService.getVeterinarioDashboard('<UUID_DO_VETERINARIO>');
      _setResult('Dashboard veterinário: ${dash.toString()}');
    } catch (e) {
      _setResult('Erro ao buscar dashboard veterinário: $e');
    }
  }
} 