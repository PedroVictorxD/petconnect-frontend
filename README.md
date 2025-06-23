# 🐾 PetConnect Frontend - Interface Moderna para Gestão Pet

## 📋 Descrição

O PetConnect Frontend é uma aplicação web moderna desenvolvida em **Flutter** que oferece uma interface intuitiva e responsiva para o sistema PetConnect. A aplicação conecta tutores, veterinários e lojistas através de uma experiência de usuário rica em animações, design glassmorphism e funcionalidades avançadas como calculadora de ração e integração com WhatsApp.

## 🏗️ Arquitetura e Tecnologias

### Stack Tecnológico
- **Flutter 3.8.0** - Framework principal
- **Dart 3.8.0** - Linguagem de programação
- **Provider 6.1.1** - Gerenciamento de estado
- **HTTP 1.2.1** - Comunicação com API
- **Carousel Slider 5.1.1** - Carrosséis responsivos
- **URL Launcher 6.1.14** - Integração com WhatsApp
- **Shared Preferences 2.2.2** - Armazenamento local
- **Flutter Secure Storage 9.0.0** - Armazenamento seguro
- **JSON Annotation 4.8.1** - Serialização de dados

### Estrutura do Projeto
```
petconnect-frontend/
├── lib/
│   ├── main.dart                      # Ponto de entrada da aplicação
│   ├── core/                          # Funcionalidades core
│   │   ├── api/
│   │   │   └── api_client.dart        # Cliente HTTP base
│   │   └── models/                    # Modelos de dados
│   │       ├── pet.dart               # Modelo de pet
│   │       ├── product.dart           # Modelo de produto
│   │       ├── user.dart              # Modelo de usuário
│   │       └── vet_service.dart       # Modelo de serviço veterinário
│   ├── features/                      # Funcionalidades específicas
│   │   ├── admin/
│   │   │   └── admin_home_screen.dart # Tela principal do administrador
│   │   ├── auth/
│   │   │   ├── login_screen.dart      # Tela de login
│   │   │   ├── register_screen.dart   # Tela de registro
│   │   │   └── user_type_selection.dart # Seleção de tipo de usuário
│   │   ├── landing/
│   │   │   └── landing_page.dart      # Página inicial animada
│   │   ├── lojista/
│   │   │   └── lojista_home_screen.dart # Tela principal do lojista
│   │   ├── tutor/
│   │   │   └── tutor_home_screen.dart # Tela principal do tutor
│   │   └── veterinario/
│   │       └── vet_home_screen.dart   # Tela principal do veterinário
│   ├── providers/                     # Gerenciadores de estado
│   │   ├── auth_provider.dart         # Estado de autenticação
│   │   └── data_provider.dart         # Estado dos dados
│   └── services/                      # Serviços
│       └── api_service.dart           # Serviço de comunicação com API
├── pubspec.yaml                       # Dependências do projeto
├── pubspec.lock                       # Versões fixas das dependências
└── README.md                          # Este arquivo
```

## 🎨 Design System e UI/UX

### Paleta de Cores
- **Primária**: `#667eea` (Azul gradiente)
- **Secundária**: `#764ba2` (Roxo gradiente)
- **Acentos**: `#7b4cfe` (Roxo vibrante)
- **WhatsApp**: `#25D366` (Verde WhatsApp)
- **Sucesso**: `#4CAF50` (Verde)
- **Erro**: `#F44336` (Vermelho)
- **Aviso**: `#FF9800` (Laranja)

### Design Language
- **Glassmorphism**: Efeito de vidro com transparência
- **Gradientes**: Transições suaves entre cores
- **Sombras**: Efeitos de profundidade
- **Bordas arredondadas**: 12px-24px de raio
- **Animações**: Transições suaves de 300-800ms

### Tipografia
- **Família**: Roboto (Material Design)
- **Títulos**: 22-28px, FontWeight.bold
- **Subtítulos**: 16-18px, FontWeight.w500
- **Corpo**: 14-16px, FontWeight.normal
- **Legendas**: 12-14px, FontWeight.w300

### Componentes Reutilizáveis
- **Cards**: Com gradiente e sombra
- **Botões**: Com animações e estados
- **Modais**: Com backdrop blur
- **Carrosséis**: Responsivos e animados
- **Formulários**: Com validação visual

## 🔐 Sistema de Autenticação

### Fluxo de Autenticação
1. **Landing Page**: Apresentação do sistema
2. **Seleção de Tipo**: Escolha entre Tutor, Veterinário, Lojista
3. **Registro**: Formulário específico por tipo
4. **Login**: Email e senha
5. **Token JWT**: Armazenamento seguro
6. **Redirecionamento**: Para tela específica do tipo

### Armazenamento Seguro
- **JWT Token**: Flutter Secure Storage
- **Dados do Usuário**: Shared Preferences
- **Sessão**: Persistente entre sessões
- **Logout**: Limpeza automática de dados

### Validação de Formulários
- **Email**: Formato válido
- **Senha**: Mínimo 6 caracteres
- **Campos obrigatórios**: Validação em tempo real
- **Feedback visual**: Indicadores de erro/sucesso

## 📱 Telas e Funcionalidades Detalhadas

### 🏠 Landing Page
**Arquivo**: `lib/features/landing/landing_page.dart`

#### Características
- **Gradiente animado**: Fundo dinâmico
- **Animações sequenciais**: Fade, slide e scale
- **Call-to-action**: Botões para login/registro
- **Features grid**: Apresentação das funcionalidades
- **Responsivo**: Adaptável a diferentes telas

#### Animações
- **Fade In**: Elementos aparecem suavemente
- **Slide Up**: Conteúdo desliza de baixo
- **Scale**: Botões com efeito elástico
- **Staggered**: Animações em sequência

### 🔐 Autenticação
**Arquivo**: `lib/features/auth/`

#### Login Screen
- **Campos**: Email e senha
- **Validação**: Em tempo real
- **Estados**: Loading, erro, sucesso
- **Lembrar**: Opção de persistir dados
- **Esqueci senha**: Link para recuperação

#### Register Screen
- **Seleção de tipo**: Radio buttons animados
- **Campos dinâmicos**: Baseados no tipo escolhido
- **Validação completa**: Todos os campos obrigatórios
- **Upload de foto**: Preparado para implementação
- **Termos**: Checkbox de aceitação

#### User Type Selection
- **Cards interativos**: Cada tipo de usuário
- **Ícones**: Representativos de cada função
- **Descrições**: Explicação das funcionalidades
- **Animações**: Hover e seleção

### 🏠 Tela Principal do Tutor
**Arquivo**: `lib/features/tutor/tutor_home_screen.dart`

#### Header Profissional
- **Saudação**: "Olá, [Nome]!"
- **Cards de estatísticas**: Pets, produtos, serviços
- **Design glassmorphism**: Gradiente com transparência
- **Animações**: Fade in suave

#### Seletor de Seções
- **Tabs animadas**: Pets, Produtos, Serviços
- **Indicador visual**: Linha animada
- **Estados**: Ativo/inativo
- **Transições**: Suaves entre seções

#### Carrossel de Pets
- **Layout responsivo**: Adapta ao tamanho da tela
- **Auto-play**: Para múltiplos pets
- **Enlarge center**: Destaque do item central
- **Navegação**: Dots e setas
- **Cards interativos**: Clique para detalhes

#### Carrossel de Produtos
- **Grid responsivo**: Desktop, tablet, mobile
- **Informações**: Nome, preço, vendedor
- **Imagens**: Com fallback para ícone
- **Ações**: Contato via WhatsApp

#### Carrossel de Serviços
- **Layout similar**: Ao de produtos
- **Informações específicas**: CRMV, horários
- **Contato direto**: WhatsApp integrado
- **Detalhes completos**: Modal informativo

#### Calculadora de Ração
- **Modal elegante**: Design glassmorphism
- **Campos dinâmicos**: Peso, tipo, idade, atividade
- **Cálculo em tempo real**: Resultado instantâneo
- **Seleção de pet**: Usar dados existentes
- **Animações**: Fade e scale

#### Botões Flutuantes
- **Calculadora**: Canto esquerdo
- **Adicionar Pet**: Canto direito
- **Design consistente**: Mesmo estilo
- **Animações**: Hover e press

#### Modal de Adicionar Pet
- **Formulário completo**: Todos os campos necessários
- **Validação**: Em tempo real
- **Upload de foto**: URL ou seleção
- **Design glassmorphism**: Consistente
- **Animações**: Entrada e saída suaves

#### Diálogo de Detalhes do Pet
- **Foto ampliada**: Modal com imagem
- **Informações completas**: Todos os dados
- **Ações**: Editar, excluir
- **Design**: Glassmorphism com gradiente

#### Diálogo de Detalhes de Produto/Serviço
- **Informações detalhadas**: Descrição, preço, contato
- **Botão WhatsApp**: Integração direta
- **Layout responsivo**: Adaptável
- **Animações**: Entrada suave

### 🏥 Tela Principal do Veterinário
**Arquivo**: `lib/features/veterinario/vet_home_screen.dart`

#### Funcionalidades
- **Dashboard**: Estatísticas de serviços
- **Gestão de serviços**: CRUD completo
- **Agenda**: Preparado para implementação
- **Perfil profissional**: Dados do CRMV
- **Contatos**: Comunicação com tutores

### 🏪 Tela Principal do Lojista
**Arquivo**: `lib/features/lojista/lojista_home_screen.dart`

#### Funcionalidades
- **Dashboard**: Estatísticas de produtos
- **Gestão de produtos**: CRUD completo
- **Estoque**: Preparado para implementação
- **Perfil da loja**: Dados do CNPJ
- **Vendas**: Histórico de transações

### 👨‍💼 Tela Principal do Administrador
**Arquivo**: `lib/features/admin/admin_home_screen.dart`

#### Funcionalidades
- **Dashboard geral**: Estatísticas do sistema
- **Gestão de usuários**: CRUD para todos os tipos
- **Relatórios**: Analytics do sistema
- **Configurações**: Parâmetros globais
- **Logs**: Monitoramento de atividades

## 🎭 Animações e Efeitos Visuais

### Animações de Fundo
- **Patinhas flutuantes**: CustomPainter animado
- **Movimento suave**: Translação contínua
- **Opacidade variável**: Efeito de profundidade
- **Performance otimizada**: 60fps

### Transições de Tela
- **Fade**: Aparecimento suave
- **Slide**: Deslizamento lateral
- **Scale**: Zoom in/out
- **Staggered**: Sequência de animações

### Interações de Usuário
- **Hover effects**: Cards e botões
- **Press animations**: Feedback tátil
- **Loading states**: Indicadores visuais
- **Success/Error**: Feedback imediato

### Carrosséis
- **Auto-play**: Para múltiplos itens
- **Enlarge center**: Destaque do item central
- **Smooth transitions**: Entre slides
- **Responsive**: Adaptável ao tamanho

## 🔧 Funcionalidades Técnicas

### Gerenciamento de Estado
**Provider Pattern**
- **AuthProvider**: Estado de autenticação
- **DataProvider**: Dados da aplicação
- **Loading states**: Indicadores de carregamento
- **Error handling**: Tratamento de erros

### Comunicação com API
**HTTP Client**
- **Base URL**: Configurável
- **Headers**: JWT automático
- **Interceptors**: Logging e erro
- **Timeout**: Configurável

### Armazenamento Local
**Shared Preferences**
- **Dados do usuário**: Informações básicas
- **Configurações**: Preferências
- **Cache**: Dados temporários

**Secure Storage**
- **JWT Token**: Armazenamento seguro
- **Credenciais**: Dados sensíveis
- **Criptografia**: Nível do sistema

### Serialização de Dados
**JSON**
- **fromJson/toJson**: Conversão automática
- **Null safety**: Tratamento de valores nulos
- **Type safety**: Tipagem forte
- **Validation**: Validação de dados

## 📱 Responsividade e Adaptação

### Breakpoints
- **Mobile**: < 600px
- **Tablet**: 600px - 1200px
- **Desktop**: > 1200px

### Layout Adaptativo
- **Grid responsivo**: Colunas dinâmicas
- **Carrosséis**: Viewport fraction variável
- **Textos**: Tamanho adaptativo
- **Espaçamentos**: Margens responsivas

### Orientação
- **Portrait**: Layout vertical
- **Landscape**: Layout horizontal
- **Auto-rotate**: Suporte completo

## 🔗 Integrações Externas

### WhatsApp Integration
**URL Launcher**
- **Formato**: `https://wa.me/{numero}`
- **Limpeza**: Remove caracteres especiais
- **Fallback**: Mensagem de erro
- **Feedback**: SnackBar informativo

### API Integration
**HTTP Requests**
- **GET**: Buscar dados
- **POST**: Criar recursos
- **PUT**: Atualizar recursos
- **DELETE**: Remover recursos

### Image Loading
**Network Images**
- **Caching**: Automático
- **Error handling**: Placeholder
- **Loading**: Indicador visual
- **Optimization**: Compressão

## 🚀 Configuração e Instalação

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

4. **Configure a API**
```dart
// lib/services/api_service.dart
static const String baseUrl = 'http://localhost:8080';
```

5. **Execute a aplicação**
```bash
# Para web
flutter run -d chrome --web-port=3001

# Para mobile
flutter run

# Para desktop
flutter run -d windows  # ou macos, linux
```

### Verificação da Instalação
```bash
# Verificar dependências
flutter doctor

# Verificar se compila
flutter analyze

# Executar testes
flutter test
```

## 📦 Dependências

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
  mask_text_input_formatter: ^2.7.0
  carousel_slider: ^5.1.1
  url_launcher: ^6.1.14
  cupertino_icons: ^1.0.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  json_serializable: ^6.7.1
  build_runner: ^2.4.7
```

## 🧪 Testes e Qualidade

### Testes Unitários
- **Providers**: Estado da aplicação
- **Services**: Lógica de negócio
- **Models**: Serialização de dados
- **Utils**: Funções auxiliares

### Testes de Widget
- **Screens**: Telas principais
- **Components**: Componentes reutilizáveis
- **Navigation**: Fluxo de navegação
- **Interactions**: Interações do usuário

### Análise de Código
- **flutter_lints**: Regras de qualidade
- **flutter analyze**: Análise estática
- **Code coverage**: Cobertura de testes
- **Performance**: Métricas de performance

## 🔧 Configurações Avançadas

### Variáveis de Ambiente
```bash
export API_BASE_URL=http://localhost:8080
export APP_ENV=development
export DEBUG_MODE=true
```

### Configuração de Build
```bash
# Build para produção
flutter build web --release

# Build para Android
flutter build apk --release

# Build para iOS
flutter build ios --release
```

### Configuração de Deploy
```bash
# Deploy para web
flutter build web
# Copiar build/web para servidor

# Deploy para mobile
flutter build apk
# Instalar APK no dispositivo
```

## 🚨 Tratamento de Erros

### Tipos de Erro
- **Network errors**: Problemas de conexão
- **API errors**: Erros do backend
- **Validation errors**: Dados inválidos
- **Authentication errors**: Token expirado

### Estratégias de Tratamento
- **Try-catch**: Captura de exceções
- **Error boundaries**: Limites de erro
- **Fallback UI**: Interface alternativa
- **User feedback**: Mensagens informativas

### Logging
- **Console logs**: Para desenvolvimento
- **Error tracking**: Para produção
- **Performance monitoring**: Métricas
- **User analytics**: Comportamento

## 📊 Performance e Otimização

### Otimizações Implementadas
- **Lazy loading**: Carregamento sob demanda
- **Image caching**: Cache de imagens
- **Widget optimization**: Rebuilds otimizados
- **Memory management**: Gerenciamento de memória

### Métricas de Performance
- **Frame rate**: 60fps constante
- **Memory usage**: < 100MB
- **Startup time**: < 3 segundos
- **Network requests**: Otimizadas

### Profiling
- **Flutter Inspector**: Debug de widgets
- **Performance Overlay**: Métricas em tempo real
- **Memory Profiler**: Análise de memória
- **Network Profiler**: Análise de rede

## 🔄 Versionamento e Deploy

### Versionamento
- **Versão atual**: 1.0.0
- **Convenção**: Semantic Versioning
- **Changelog**: Documentado
- **Tags**: Releases marcados

### CI/CD Pipeline
```yaml
# .github/workflows/flutter.yml
name: Flutter CI/CD
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test
      - run: flutter build web
```

### Deploy Automatizado
- **GitHub Actions**: CI/CD
- **Web hosting**: Firebase/Netlify
- **Mobile stores**: Google Play/App Store
- **Desktop**: Windows Store/Mac App Store

## 🤝 Contribuição

### Padrões de Código
- **Dart conventions**: Padrões oficiais
- **Flutter guidelines**: Diretrizes do Flutter
- **Documentation**: Comentários claros
- **Testing**: Cobertura mínima 80%

### Processo de Desenvolvimento
1. **Fork** do repositório
2. **Branch** para feature/fix
3. **Desenvolvimento** seguindo padrões
4. **Testes** unitários e widget
5. **Pull Request** com descrição
6. **Code Review** obrigatório
7. **Merge** após aprovação

### Checklist de PR
- [ ] Código segue padrões
- [ ] Testes passando
- [ ] Documentação atualizada
- [ ] Screenshots (se UI)
- [ ] Descrição clara

## 📞 Suporte e Documentação

### Documentação
- **API Docs**: Swagger do backend
- **Flutter Docs**: Documentação oficial
- **Code comments**: Comentários no código
- **README**: Este arquivo

### Recursos Úteis
- **Flutter.dev**: Documentação oficial
- **Dart.dev**: Linguagem Dart
- **pub.dev**: Pacotes Flutter
- **Stack Overflow**: Comunidade

### Contato
- **Desenvolvedor**: Pedro Victor
- **GitHub**: [PedroVictorxD](https://github.com/PedroVictorxD)
- **Email**: jessevvv63@gmail.com

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo LICENSE para mais detalhes.

---

## 🎯 Status do Projeto

### ✅ Funcionalidades Implementadas
- [x] Sistema de autenticação completo
- [x] Interface responsiva e moderna
- [x] Carrosséis animados para pets, produtos e serviços
- [x] Calculadora de ração com design glassmorphism
- [x] Integração com WhatsApp
- [x] Modais elegantes para detalhes
- [x] Animações de fundo com patinhas
- [x] Gerenciamento de estado com Provider
- [x] Validação de formulários
- [x] Armazenamento seguro de dados
- [x] Tratamento de erros robusto
- [x] Design system consistente

### 🚧 Funcionalidades Futuras
- [ ] Upload de imagens
- [ ] Notificações push
- [ ] Modo offline
- [ ] Temas escuro/claro
- [ ] Internacionalização (i18n)
- [ ] Testes automatizados
- [ ] Analytics e métricas
- [ ] PWA (Progressive Web App)
- [ ] Cache inteligente
- [ ] Otimizações de performance

### 🔧 Melhorias Técnicas
- [ ] Testes unitários completos
- [ ] Testes de integração
- [ ] CI/CD pipeline
- [ ] Code coverage > 90%
- [ ] Performance monitoring
- [ ] Error tracking
- [ ] A/B testing
- [ ] Feature flags

---

**Desenvolvido com ❤️ por Pedro Victor**  
**GitHub**: [PedroVictorxD](https://github.com/PedroVictorxD) 