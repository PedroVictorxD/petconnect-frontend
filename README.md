# PetConnect Frontend

## 📋 Descrição

O PetConnect Frontend é uma aplicação web desenvolvida em Flutter que fornece uma interface moderna e intuitiva para o sistema PetConnect. Permite que tutores, veterinários, lojistas e administradores gerenciem seus respectivos recursos de forma eficiente e amigável.

## 🏗️ Arquitetura

### Tecnologias Utilizadas
- **Flutter 3.8.0**
- **Dart 3.8.0**
- **Provider** (Gerenciamento de Estado)
- **HTTP** (Comunicação com API)
- **Shared Preferences** (Armazenamento Local)
- **JSON Serialization** (Serialização de Dados)

### Estrutura do Projeto
```
lib/
├── main.dart                      # Ponto de entrada da aplicação
├── core/                          # Funcionalidades core
│   ├── api/
│   │   └── api_client.dart        # Cliente HTTP base
│   └── models/                    # Modelos de dados
│       ├── pet.dart
│       ├── product.dart
│       ├── user.dart
│       └── vet_service.dart
├── features/                      # Funcionalidades específicas
│   ├── admin/
│   │   └── admin_home_screen.dart # Tela principal do admin
│   ├── auth/
│   │   ├── login_screen.dart      # Tela de login
│   │   ├── register_screen.dart   # Tela de registro
│   │   └── user_type_selection.dart # Seleção de tipo de usuário
│   ├── landing/
│   │   └── landing_page.dart      # Página inicial
│   ├── lojista/
│   │   └── lojista_home_screen.dart # Tela principal do lojista
│   ├── tutor/
│   │   └── tutor_home_screen.dart # Tela principal do tutor
│   └── veterinario/
│       └── vet_home_screen.dart   # Tela principal do veterinário
├── providers/                     # Gerenciadores de estado
│   ├── auth_provider.dart         # Estado de autenticação
│   └── data_provider.dart         # Estado dos dados
└── services/                      # Serviços
    └── api_service.dart           # Serviço de comunicação com API
```

## 🎨 Interface do Usuário

### Design System
- **Tema:** Material Design 3
- **Cores principais:**
  - Primária: `#667eea` (Azul)
  - Secundária: `#764ba2` (Roxo)
  - Fundo: Gradiente linear
- **Tipografia:** Roboto
- **Ícones:** Material Icons

### Responsividade
- **Mobile-first** design
- **Adaptável** para diferentes tamanhos de tela
- **Orientação** portrait e landscape

## 🔐 Sistema de Autenticação

### Fluxo de Autenticação
1. **Registro:** Usuário escolhe tipo e preenche dados
2. **Login:** Email e senha para autenticação
3. **Token JWT:** Armazenado localmente
4. **Autorização:** Headers automáticos nas requisições

### Tipos de Usuário
- **Tutor:** Gerencia pets
- **Veterinário:** Oferece serviços
- **Lojista:** Vende produtos
- **Admin:** Acesso total

## 📱 Telas e Funcionalidades

### Landing Page
- **Apresentação** do sistema
- **Call-to-action** para registro/login
- **Informações** sobre funcionalidades

### Autenticação
#### Login Screen
- **Campos:** Email e senha
- **Validação** em tempo real
- **Feedback** visual de erros
- **Lembrar** credenciais

#### Register Screen
- **Seleção** de tipo de usuário
- **Campos dinâmicos** baseados no tipo
- **Validação** completa
- **Upload** de foto (futuro)

### Telas Principais por Tipo

#### Tutor Home Screen
- **Dashboard** com estatísticas
- **Lista** de pets
- **CRUD** completo de pets
- **Busca** e filtros
- **Perfil** do usuário

#### Veterinário Home Screen
- **Dashboard** com estatísticas
- **Lista** de serviços
- **CRUD** completo de serviços
- **Agenda** (futuro)
- **Perfil** profissional

#### Lojista Home Screen
- **Dashboard** com estatísticas
- **Lista** de produtos
- **CRUD** completo de produtos
- **Estoque** (futuro)
- **Perfil** da loja

#### Admin Home Screen
- **Dashboard** com estatísticas gerais
- **Gerenciamento** de usuários
- **Relatórios** do sistema
- **Configurações** globais

## 🔧 Configuração

### pubspec.yaml
```yaml
name: petconnect_frontend
environment:
  sdk: '^3.8.0'

dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.1
  provider: ^6.1.1
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0
  json_annotation: ^4.8.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  json_serializable: ^6.7.1
  build_runner: ^2.4.7
```

### Configuração da API
```dart
// lib/services/api_service.dart
static const String baseUrl = 'http://localhost:8080';
```

## 🚀 Instalação e Execução

### Pré-requisitos
- **Flutter SDK** 3.8.0+
- **Dart SDK** 3.8.0+
- **Git**
- **Backend** rodando na porta 8080

### Passos de Instalação

1. **Clone o repositório**
```bash
git clone <repository-url>
cd petconnect-frontend
```

2. **Instale as dependências**
```bash
flutter pub get
```

3. **Gere os arquivos de serialização**
```bash
flutter packages pub run build_runner build
```

4. **Execute a aplicação**
```bash
# Para web
flutter run -d web-server --web-port 3000

# Para mobile
flutter run

# Para desktop
flutter run -d windows  # ou macos, linux
```

### Verificação da Instalação
```bash
# Verificar se tudo está configurado
flutter doctor

# Executar testes
flutter test

# Análise de código
flutter analyze
```

## 📊 Gerenciamento de Estado

### Provider Pattern
- **AuthProvider:** Estado de autenticação
- **DataProvider:** Estado dos dados da aplicação

### Estrutura do Estado
```dart
class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  String? _token;
  bool _isLoading;
  String? _error;
  
  // Getters e métodos
}
```

## 🔌 Comunicação com API

### ApiService
- **Cliente HTTP** centralizado
- **Interceptors** para tokens
- **Tratamento** de erros
- **Cache** local (futuro)

### Endpoints Utilizados
```dart
// Autenticação
POST /api/auth/login
POST /api/auth/register-tutor
POST /api/auth/register-lojista
POST /api/auth/register-veterinario

// Pets
GET /api/pets
POST /api/pets
PUT /api/pets/{id}
DELETE /api/pets/{id}

// Produtos
GET /api/products
POST /api/products
PUT /api/products/{id}
DELETE /api/products/{id}

// Serviços
GET /api/services
POST /api/services
PUT /api/services/{id}
DELETE /api/services/{id}
```

## 📱 Modelos de Dados

### User Model
```dart
@JsonSerializable()
class User {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String? phone;
  final String? location;
  final String? dtype;
  final String? crmv;
  final String? cnpj;
  final String? responsibleName;
  final String? storeType;
  final String? operatingHours;
  
  // Getters para tipo de usuário
  bool get isVeterinario => dtype == 'Veterinario';
  bool get isLojista => dtype == 'Lojista';
  bool get isTutor => dtype == 'Tutor';
  bool get isAdmin => dtype == 'Admin';
}
```

### Pet Model
```dart
@JsonSerializable()
class Pet {
  final int? id;
  final String name;
  final String type;
  final String? breed;
  final int? age;
  final double? weight;
  final String? activityLevel;
  final String? notes;
  final String? photoUrl;
  final User? tutor;
}
```

## 🎯 Funcionalidades Principais

### CRUD de Pets (Tutor)
- **Criar** novo pet
- **Visualizar** lista de pets
- **Editar** informações
- **Excluir** pet
- **Upload** de foto (futuro)

### CRUD de Produtos (Lojista)
- **Criar** novo produto
- **Visualizar** catálogo
- **Editar** informações
- **Excluir** produto
- **Upload** de imagem (futuro)

### CRUD de Serviços (Veterinário)
- **Criar** novo serviço
- **Visualizar** serviços oferecidos
- **Editar** informações
- **Excluir** serviço
- **Agenda** (futuro)

### Gerenciamento de Usuários (Admin)
- **Visualizar** todos os usuários
- **Editar** informações
- **Excluir** usuários
- **Estatísticas** do sistema

## 🔒 Segurança

### Armazenamento Seguro
- **Shared Preferences** para dados não sensíveis
- **Flutter Secure Storage** para tokens (futuro)
- **Criptografia** local (futuro)

### Validação de Dados
- **Validação** em tempo real
- **Sanitização** de inputs
- **Feedback** visual de erros

### Autenticação
- **JWT** tokens
- **Expiração** automática
- **Refresh** tokens (futuro)

## 📱 Responsividade e UX

### Design Responsivo
- **Breakpoints** definidos
- **Layout** adaptativo
- **Navegação** intuitiva

### Experiência do Usuário
- **Loading** states
- **Error** handling
- **Success** feedback
- **Animations** suaves

### Acessibilidade
- **Semantic** labels
- **Screen** readers
- **Keyboard** navigation
- **High** contrast (futuro)

## 🧪 Testes

### Testes Unitários
```bash
flutter test test/unit/
```

### Testes de Widget
```bash
flutter test test/widget/
```

### Testes de Integração
```bash
flutter test test/integration/
```

## 📦 Build e Deploy

### Build para Web
```bash
flutter build web
```

### Build para Mobile
```bash
# Android
flutter build apk
flutter build appbundle

# iOS
flutter build ios
```

### Deploy
- **Web:** Servidor web estático
- **Mobile:** Google Play / App Store
- **Desktop:** Distribuição direta

## 🐛 Troubleshooting

### Problemas Comuns

1. **Erro de dependências**
   ```bash
   flutter clean
   flutter pub get
   ```

2. **Erro de compilação**
   ```bash
   flutter analyze
   flutter packages pub run build_runner build
   ```

3. **Erro de conexão com API**
   - Verifique se o backend está rodando
   - Confirme URL no `api_service.dart`
   - Verifique CORS no backend

4. **Erro de CORS**
   - Configure CORS no backend
   - Use proxy no desenvolvimento

### Logs de Debug
```bash
flutter run --verbose
```

## 📝 Changelog

### v1.0.0 (2025-06-21)
- ✅ Interface completa para todos os tipos de usuário
- ✅ Sistema de autenticação integrado
- ✅ CRUD completo para pets, produtos e serviços
- ✅ Design responsivo e moderno
- ✅ Gerenciamento de estado com Provider
- ✅ Comunicação com API REST
- ✅ Documentação completa

## 🔮 Roadmap

### Próximas Funcionalidades
- [ ] Upload de imagens
- [ ] Chat entre usuários
- [ ] Sistema de agendamento
- [ ] Notificações push
- [ ] Modo offline
- [ ] PWA (Progressive Web App)
- [ ] Tema escuro
- [ ] Internacionalização

### Melhorias Técnicas
- [ ] Testes automatizados
- [ ] CI/CD pipeline
- [ ] Performance optimization
- [ ] Code splitting
- [ ] Lazy loading

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature
3. Commit suas mudanças
4. Push para a branch
5. Abra um Pull Request

### Padrões de Código
- **Dart:** Effective Dart guidelines
- **Flutter:** Material Design guidelines
- **Commits:** Conventional Commits
- **Documentação:** DartDoc

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

## 📞 Suporte

Para suporte e dúvidas:
- **Email:** suporte@petconnect.com
- **Issues:** GitHub Issues
- **Documentação:** Este README

## 🎨 Screenshots

### Landing Page
![Landing Page](screenshots/landing.png)

### Login Screen
![Login Screen](screenshots/login.png)

### Tutor Dashboard
![Tutor Dashboard](screenshots/tutor-dashboard.png)

### Veterinário Dashboard
![Veterinário Dashboard](screenshots/vet-dashboard.png)

### Lojista Dashboard
![Lojista Dashboard](screenshots/lojista-dashboard.png)

### Admin Dashboard
![Admin Dashboard](screenshots/admin-dashboard.png)

---

**Desenvolvido com ❤️ pela equipe PetConnect** 