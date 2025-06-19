import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(PetConnectApp());
}

class PetConnectApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pet Connect',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LandingPage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/forgot-password': (context) => ForgotPasswordPage(),
        '/admin': (context) => AdminHomePage(),
        '/tutor': (context) => TutorHomePage(),
        '/veterinario': (context) => VeterinarioHomePage(),
        '/lojista': (context) => LojistaHomePage(),
      },
    );
  }
}

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pet Connect')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Bem-vindo ao Pet Connect!', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: Text('Entrar'),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: Text('Cadastre-se'),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _message;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });
    final url = Uri.parse('http://localhost:8080/api/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "username": _emailController.text,
        "password": _passwordController.text
      }),
    );
    setState(() {
      _isLoading = false;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userType = data['data']?['user']?['userType'];
        if (userType == 'ADMIN') {
          Navigator.pushReplacementNamed(context, '/admin');
        } else if (userType == 'TUTOR') {
          Navigator.pushReplacementNamed(context, '/tutor');
        } else if (userType == 'VETERINARIO') {
          Navigator.pushReplacementNamed(context, '/veterinario');
        } else if (userType == 'LOJISTA') {
          Navigator.pushReplacementNamed(context, '/lojista');
        } else {
          _message = "Tipo de usuário desconhecido.";
        }
      } else {
        _message = "Erro ao logar: ${response.body}";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Senha'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      child: Text('Entrar'),
                    ),
              if (_message != null) ...[
                SizedBox(height: 20),
                Text(_message!, style: TextStyle(color: Colors.red)),
              ],
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                child: Text('Esqueci minha senha'),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: Text('Cadastre-se'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _message;
  final List<String> _userTypes = ['TUTOR', 'VETERINARIO', 'LOJISTA'];
  String? _selectedUserType;

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });
    final url = Uri.parse('http://localhost:8080/api/auth/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "username": _emailController.text,
        "email": _emailController.text,
        "password": _passwordController.text,
        "fullName": _fullNameController.text,
        "userType": _selectedUserType
      }),
    );
    setState(() {
      _isLoading = false;
      if (response.statusCode == 201 || response.statusCode == 200) {
        _message = "Cadastro realizado com sucesso!";
      } else {
        _message = "Erro ao cadastrar: ${response.body}";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastro')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _fullNameController,
                  decoration: InputDecoration(labelText: 'Nome completo'),
                  validator: (value) => value == null || value.isEmpty ? 'Informe o nome completo' : null,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) => value == null || value.isEmpty ? 'Informe o email' : null,
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Senha'),
                  obscureText: true,
                  validator: (value) => value == null || value.isEmpty ? 'Informe a senha' : null,
                ),
                DropdownButtonFormField<String>(
                  value: _selectedUserType,
                  decoration: InputDecoration(labelText: 'Tipo de usuário'),
                  items: _userTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedUserType = value;
                    });
                  },
                  validator: (value) => value == null ? 'Selecione o tipo de usuário' : null,
                ),
                SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _register();
                          }
                        },
                        child: Text('Cadastrar'),
                      ),
                if (_message != null) ...[
                  SizedBox(height: 20),
                  Text(_message!, style: TextStyle(color: _message!.contains('sucesso') ? Colors.green : Colors.red)),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ForgotPasswordPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Recuperar Senha')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Email'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                child: Text('Enviar link de recuperação'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin - Dashboard')),
      body: Center(child: Text('Bem-vindo, Administrador!')),
    );
  }
}

class TutorHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tutor - Dashboard')),
      body: Center(child: Text('Bem-vindo, Tutor!')),
    );
  }
}

class VeterinarioHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Veterinário - Dashboard')),
      body: Center(child: Text('Bem-vindo, Veterinário!')),
    );
  }
}

class LojistaHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lojista - Dashboard')),
      body: Center(child: Text('Bem-vindo, Lojista!')),
    );
  }
}
