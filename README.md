# 🐾 PetConnect Frontend - Interface Moderna para Gestão Pet

## 📋 Descrição

O PetConnect Frontend é uma aplicação web moderna desenvolvida em **Flutter** que oferece uma interface intuitiva e responsiva para o sistema PetConnect. A aplicação conecta tutores, veterinários e lojistas através de uma experiência de usuário rica em animações, design glassmorphism e funcionalidades avançadas como uma calculadora de ração inteligente e integração com WhatsApp.

## ✨ Principais Funcionalidades

- **Design Responsivo e Moderno**: Interface com *glassmorphism*, gradientes e animações suaves.
- **Múltiplos Perfis de Usuário**: Dashboards personalizados para Tutores, Veterinários, Lojistas e Administradores.
- **Gerenciamento Completo**: CRUD (Criar, Ler, Atualizar, Excluir) para pets, produtos e serviços.
- **Autenticação Segura**: Fluxo completo de registro e login com persistência de sessão via JWT.
- **Calculadora de Ração Avançada**:
    - Leva em conta **peso, tipo de animal, porte, nível de atividade, estágio de vida** (filhote, adulto, sênior) e se o pet é **castrado**.
    - Permite usar dados de pets já cadastrados para preenchimento automático.
    - Fornece recomendações detalhadas de quantidade diária e por refeição.
- **Integração com WhatsApp**: Contato direto com lojistas e veterinários.
- **Layout Consistente**: Interface padronizada para uma melhor experiência de usuário.

## 🏗️ Arquitetura e Tecnologias

### Stack Tecnológico
- **Flutter** - Framework principal para o desenvolvimento web.
- **Dart** - Linguagem de programação.
- **Provider** - Para um gerenciamento de estado simples e eficaz.
- **HTTP** - Para comunicação com a API REST do backend.
- **Carousel Slider** - Para exibição de pets, produtos e serviços.
- **URL Launcher** - Para integração com apps externos como o WhatsApp.
- **Flutter Secure Storage** - Para armazenamento seguro de tokens de autenticação.

### Estrutura do Projeto
A estrutura do projeto segue as melhores práticas de organização de código em Flutter, separando a lógica por funcionalidades (`features`), componentes de UI (`core/widgets`), modelos de dados (`core/models`) e gerenciadores de estado (`providers`).

```
petconnect-frontend/
├── lib/
│   ├── main.dart                      # Ponto de entrada da aplicação
│   ├── core/                          # Funcionalidades core
│   ├── features/                      # Funcionalidades específicas por tela/ator
│   ├── providers/                     # Gerenciadores de estado (Providers)
│   └── services/                      # Camada de serviço para API
├── pubspec.yaml                       # Dependências do projeto
└── README.md                          # Este arquivo
```

## 🚀 Como Executar

1.  **Pré-requisitos**:
    - [Flutter SDK](https://flutter.dev/docs/get-started/install) instalado.
    - Backend do PetConnect [configurado e em execução](#).

2.  **Instale as dependências**:
```bash
flutter pub get
```

3.  **Execute a aplicação em modo de desenvolvimento**:
```bash
    flutter run -d chrome
    ```

A aplicação estará disponível em `http://localhost:<porta>`.

## 🧑‍💻 Desenvolvido por

- **Jesse V.**
- **E-mail**: jessevvv63@gmail.com
- **GitHub**: [PedroVictorxD](https://github.com/PedroVictorxD)

---

Este README foi atualizado para refletir o estado atual do projeto, incluindo as últimas funcionalidades e melhorias implementadas. 