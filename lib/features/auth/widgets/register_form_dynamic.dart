import 'package:flutter/material.dart';
import '../../../core/utils/validators.dart';
import '../auth_service.dart';

class RegisterFormDynamic extends StatefulWidget {
  @override
  _RegisterFormDynamicState createState() => _RegisterFormDynamicState();
}

class _RegisterFormDynamicState extends State<RegisterFormDynamic> {
  final _formKey = GlobalKey<FormState>();
  String? _profile;
  String? _nome;
  String? _email;
  String? _senha;
  String? _confirmSenha;
  String? _cnpj;
  String? _localizacao;
  String? _contato;
  String? _tipoLoja;
  String? _crmv;
  String? _horarios;
  String? _responsavel;
  // Perguntas de segurança
  String? _q1;
  String? _a1;
  String? _q2;
  String? _a2;
  String? _q3;
  String? _a3;
  bool _isLoading = false;
  String? _message;

  final List<String> _profiles = ['ADMIN', 'TUTOR', 'VETERINARIO', 'LOJISTA'];
  final List<String> _tiposLoja = ['Virtual', 'Local'];

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() { _isLoading = true; _message = null; });
    // Montar o payload conforme o perfil
    final Map<String, dynamic> payload = {
      'userType': _profile,
      'fullName': _nome,
      'email': _email,
      'password': _senha,
      'username': _email,
    };
    if (_profile == 'LOJISTA') {
      payload.addAll({
        'cnpj': _cnpj,
        'location': _localizacao,
        'contactNumber': _contato,
        'storeType': _tipoLoja,
        'securityQuestion1': _q1,
        'securityAnswer1': _a1,
        'securityQuestion2': _q2,
        'securityAnswer2': _a2,
        'securityQuestion3': _q3,
        'securityAnswer3': _a3,
      });
    } else if (_profile == 'TUTOR') {
      payload.addAll({
        'cnpj': _cnpj,
        'location': _localizacao,
        'contactNumber': _contato,
        'guardian': _responsavel,
      });
    } else if (_profile == 'VETERINARIO') {
      payload.addAll({
        'crmv': _crmv,
        'location': _localizacao,
        'contactNumber': _contato,
        'businessHours': _horarios,
      });
    }
    final result = await AuthService().register(
      _nome ?? '',
      _email ?? '',
      _senha ?? '',
      _profile ?? '',
    );
    setState(() { _isLoading = false; _message = result.message; });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _profile,
                decoration: InputDecoration(labelText: 'Perfil'),
                items: _profiles.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (v) => setState(() => _profile = v),
                validator: (v) => v == null ? 'Selecione o perfil' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Nome completo'),
                validator: (v) => v == null || v.isEmpty ? 'Informe o nome' : null,
                onSaved: (v) => _nome = v,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                validator: validateEmail,
                onSaved: (v) => _email = v,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Senha'),
                obscureText: true,
                validator: validatePassword,
                onSaved: (v) => _senha = v,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Confirmar Senha'),
                obscureText: true,
                validator: (v) => v != _senha ? 'As senhas não coincidem' : null,
                onSaved: (v) => _confirmSenha = v,
              ),
              if (_profile == 'LOJISTA' || _profile == 'TUTOR')
                TextFormField(
                  decoration: InputDecoration(labelText: 'CNPJ'),
                  onSaved: (v) => _cnpj = v,
                ),
              if (_profile == 'LOJISTA' || _profile == 'TUTOR' || _profile == 'VETERINARIO')
                TextFormField(
                  decoration: InputDecoration(labelText: 'Localização'),
                  onSaved: (v) => _localizacao = v,
                ),
              if (_profile == 'LOJISTA' || _profile == 'TUTOR' || _profile == 'VETERINARIO')
                TextFormField(
                  decoration: InputDecoration(labelText: 'Número para contato'),
                  onSaved: (v) => _contato = v,
                ),
              if (_profile == 'LOJISTA')
                DropdownButtonFormField<String>(
                  value: _tipoLoja,
                  decoration: InputDecoration(labelText: 'Tipo de loja'),
                  items: _tiposLoja.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setState(() => _tipoLoja = v),
                  validator: (v) => v == null ? 'Selecione o tipo de loja' : null,
                ),
              if (_profile == 'LOJISTA') ...[
                TextFormField(
                  decoration: InputDecoration(labelText: 'Pergunta de segurança 1'),
                  onSaved: (v) => _q1 = v,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Resposta 1'),
                  onSaved: (v) => _a1 = v,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Pergunta de segurança 2'),
                  onSaved: (v) => _q2 = v,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Resposta 2'),
                  onSaved: (v) => _a2 = v,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Pergunta de segurança 3'),
                  onSaved: (v) => _q3 = v,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Resposta 3'),
                  onSaved: (v) => _a3 = v,
                ),
              ],
              if (_profile == 'TUTOR')
                TextFormField(
                  decoration: InputDecoration(labelText: 'Responsável'),
                  onSaved: (v) => _responsavel = v,
                ),
              if (_profile == 'VETERINARIO')
                TextFormField(
                  decoration: InputDecoration(labelText: 'CRMV'),
                  onSaved: (v) => _crmv = v,
                ),
              if (_profile == 'VETERINARIO')
                TextFormField(
                  decoration: InputDecoration(labelText: 'Horários de funcionamento'),
                  onSaved: (v) => _horarios = v,
                ),
              SizedBox(height: 16),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submit,
                      child: Text('Cadastrar'),
                    ),
              if (_message != null) ...[
                SizedBox(height: 16),
                Text(_message!, style: TextStyle(color: _message!.contains('sucesso') ? Colors.green : Colors.red)),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 