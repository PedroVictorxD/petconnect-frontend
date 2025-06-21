import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/models/user.dart';

class UserTypeSelectionScreen extends StatelessWidget {
  const UserTypeSelectionScreen({super.key});

  Future<void> _registerUser(BuildContext context, String type, Map<String, dynamic> args) async {
    final api = ApiClient();
    String endpoint;
    switch (type) {
      case 'tutor':
        endpoint = '/tutores';
        break;
      case 'lojista':
        endpoint = '/lojistas';
        break;
      case 'veterinario':
        endpoint = '/veterinarios';
        break;
      default:
        endpoint = '/tutores';
    }
    try {
      final resp = await api.post(endpoint, {
        'name': args['name'],
        'email': args['email'],
        'password': args['password'],
        'phone': args['phone'],
        'location': args['location'],
      });
      final user = User.fromJson(resp);
      if (type == 'tutor') {
        Navigator.pushReplacementNamed(context, '/tutor', arguments: user);
      } else if (type == 'lojista') {
        Navigator.pushReplacementNamed(context, '/lojista', arguments: user);
      } else if (type == 'veterinario') {
        Navigator.pushReplacementNamed(context, '/veterinario', arguments: user);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar usuário: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    return Scaffold(
      appBar: AppBar(title: const Text('Escolha o tipo de usuário')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Selecione seu perfil:', style: TextStyle(fontSize: 22)),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _UserTypeCard(
                    icon: Icons.pets,
                    label: 'Tutor',
                    color: Colors.teal,
                    onTap: () => _registerUser(context, 'tutor', args!),
                  ),
                  const SizedBox(width: 24),
                  _UserTypeCard(
                    icon: Icons.store,
                    label: 'Lojista',
                    color: Colors.orange,
                    onTap: () => _registerUser(context, 'lojista', args!),
                  ),
                  const SizedBox(width: 24),
                  _UserTypeCard(
                    icon: Icons.medical_services,
                    label: 'Veterinário',
                    color: Colors.blue,
                    onTap: () => _registerUser(context, 'veterinario', args!),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserTypeCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _UserTypeCard({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  State<_UserTypeCard> createState() => _UserTypeCardState();
}

class _UserTypeCardState extends State<_UserTypeCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _scaleAnim = Tween<double>(begin: 1, end: 1.1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: GestureDetector(
        onTap: widget.onTap,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Card(
            color: widget.color.withOpacity(0.15),
            elevation: 4,
            child: SizedBox(
              width: 120,
              height: 160,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(widget.icon, size: 48, color: widget.color),
                  const SizedBox(height: 16),
                  Text(widget.label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 