// validators.dart

String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Digite um e-mail';
  }
  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+ ');
  if (!emailRegex.hasMatch(value)) {
    return 'E-mail inválido';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.length < 6) {
    return 'A senha deve ter pelo menos 6 caracteres';
  }
  return null;
} 