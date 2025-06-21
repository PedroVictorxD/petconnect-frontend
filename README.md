# PetConnect Frontend

Frontend Flutter Web para o sistema PetConnect, uma plataforma completa para gestão de pets, produtos e serviços veterinários.

## 🚀 Funcionalidades

### Autenticação e Usuários
- **Login/Registro**: Sistema completo de autenticação
- **Tipos de Usuário**: 
  - **Tutor**: Gerencia seus pets e visualiza produtos/serviços
  - **Lojista**: Cadastra e gerencia produtos
  - **Veterinário**: Cadastra e gerencia serviços veterinários
  - **Administrador**: Visualiza estatísticas e dados do sistema

### Gestão de Pets (Tutores)
- ✅ Cadastro de pets com informações completas
- ✅ Visualização em cards organizados
- ✅ Dados: nome, tipo, peso, idade, raça, nível de atividade, observações

### Gestão de Produtos (Lojistas)
- ✅ Cadastro de produtos com preços e descrições
- ✅ Visualização em cards com informações do lojista
- ✅ Dados: nome, descrição, preço, unidade de medida, localização

### Gestão de Serviços (Veterinários)
- ✅ Cadastro de serviços veterinários
- ✅ Visualização em cards com informações do veterinário
- ✅ Dados: nome, descrição, preço, horário de funcionamento, CRMV

### Dashboard Administrativo
- ✅ Estatísticas em tempo real
- ✅ Visualização de todos os pets, produtos e serviços
- ✅ Controle total do sistema

## 🛠️ Tecnologias Utilizadas

- **Flutter Web**: Framework principal
- **Provider**: Gerenciamento de estado
- **HTTP**: Comunicação com API REST
- **JSON Serialization**: Serialização de dados
- **Material Design**: Interface moderna e responsiva

## 📦 Estrutura do Projeto

```
lib/
├── main.dart                 # Ponto de entrada da aplicação
├── models/                   # Modelos de dados
│   ├── user.dart
│   ├── pet.dart
│   ├── product.dart
│   └── vet_service.dart
├── providers/                # Gerenciamento de estado
│   ├── auth_provider.dart
│   └── data_provider.dart
├── services/                 # Serviços de API
│   └── api_service.dart
└── features/                 # Funcionalidades organizadas
    ├── landing/
    │   └── landing_page.dart
    ├── auth/
    │   ├── login_screen.dart
    │   └── register_screen.dart
    ├── tutor/
    │   └── tutor_home_screen.dart
    ├── lojista/
    │   └── lojista_home_screen.dart
    ├── veterinario/
    │   └── vet_home_screen.dart
    └── admin/
        └── admin_home_screen.dart
```

## 🚀 Como Executar

### Pré-requisitos
- Flutter SDK (versão 3.8.0 ou superior)
- Dart SDK
- Backend PetConnect rodando na porta 8080

### Instalação

1. **Clone o repositório**
```bash
git clone <repository-url>
cd petconnect-frontend
```

2. **Instale as dependências**
```bash
flutter pub get
```

3. **Gere os arquivos de serialização JSON**
```bash
flutter packages pub run build_runner build
```

4. **Execute o projeto**
```bash
flutter run -d web-server --web-port 3000
```

5. **Acesse no navegador**
```
http://localhost:3000
```

## 🔧 Configuração

### Backend
Certifique-se de que o backend está rodando em `http://localhost:8080`. O frontend está configurado para se comunicar com esta URL por padrão.

### Variáveis de Ambiente
O projeto usa configurações padrão para desenvolvimento local. Para produção, ajuste a URL da API no arquivo `lib/services/api_service.dart`.

## 📱 Interface do Usuário

### Landing Page
- Design moderno com gradiente
- Botões de login e registro
- Apresentação das funcionalidades

### Login/Registro
- Formulários responsivos
- Validação de campos
- Feedback visual de erros

### Dashboards
- **Tutor**: Cards de pets, produtos e serviços
- **Lojista**: Gestão de produtos
- **Veterinário**: Gestão de serviços
- **Admin**: Estatísticas e visão geral

## 🔌 Integração com Backend

### Endpoints Utilizados
- `POST /api/auth/login` - Autenticação
- `POST /tutores` - Criação de tutores
- `POST /veterinarios` - Criação de veterinários
- `POST /lojistas` - Criação de lojistas
- `POST /admins` - Criação de administradores
- `GET /api/pets` - Listagem de pets
- `POST /api/pets` - Criação de pets
- `GET /api/products` - Listagem de produtos
- `POST /api/products` - Criação de produtos
- `GET /api/services` - Listagem de serviços
- `POST /api/services` - Criação de serviços

### Modelos de Dados
Todos os modelos são serializáveis e compatíveis com a API do backend.

## 🎨 Design System

### Cores Principais
- **Primária**: `#667eea` (Azul)
- **Secundária**: `#764ba2` (Roxo)
- **Gradiente**: Linear gradient entre as cores principais

### Componentes
- Cards com elevação e bordas arredondadas
- Botões com design consistente
- Campos de formulário padronizados
- Ícones Material Design

## 📊 Estado da Aplicação

### AuthProvider
- Gerenciamento de autenticação
- Estado do usuário logado
- Funções de login/logout

### DataProvider
- Dados de pets, produtos e serviços
- Funções de CRUD
- Estado de loading e erros

## 🔒 Segurança

- Validação de formulários no frontend
- Tratamento de erros de API
- Feedback visual para o usuário
- Logout automático

## 🚀 Deploy

### Build para Produção
```bash
flutter build web
```

### Servir Arquivos Estáticos
Os arquivos gerados em `build/web/` podem ser servidos por qualquer servidor web estático.

## 📝 Logs e Debug

O projeto inclui logs detalhados para debug:
- Logs de requisições HTTP
- Logs de erros de autenticação
- Logs de operações CRUD

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature
3. Commit suas mudanças
4. Push para a branch
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT.

## 🆘 Suporte

Para suporte, entre em contato através dos canais oficiais do projeto.

---

**PetConnect** - Conectando pets, tutores e profissionais! 🐾 