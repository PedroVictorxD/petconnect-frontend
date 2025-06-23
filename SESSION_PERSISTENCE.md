# 🔐 Persistência de Sessão - PetConnect

## 📋 Problema Resolvido

**Problema**: Ao atualizar a página (F5), o usuário era deslogado automaticamente, perdendo a sessão.

**Solução**: Implementação de persistência de sessão usando `SharedPreferences` e validação de token JWT.

## 🏗️ Arquitetura da Solução

### 1. **AuthProvider** (`lib/providers/auth_provider.dart`)
- **Persistência Local**: Usa `SharedPreferences` para salvar dados da sessão
- **Validação de Token**: Verifica se o token JWT ainda é válido com o backend
- **Restauração Automática**: Carrega dados salvos na inicialização

### 2. **AuthWrapper** (`lib/main.dart`)
- **Verificação Inicial**: Executa na inicialização do app
- **Redirecionamento Inteligente**: Direciona para a tela correta baseado no tipo de usuário
- **Loading State**: Mostra indicador de carregamento durante verificação

### 3. **Backend Validation** (`/api/auth/validate`)
- **Endpoint de Validação**: Verifica se o token JWT é válido
- **Resposta Padronizada**: Retorna status 200 para token válido, 401 para inválido

## 🔧 Como Funciona

### Fluxo de Login
```
1. Usuário faz login
2. Backend retorna token JWT + dados do usuário
3. AuthProvider salva dados no SharedPreferences
4. Usuário é redirecionado para sua tela
```

### Fluxo de Refresh/Reinicialização
```
1. App inicia
2. AuthWrapper verifica se há dados salvos
3. Se houver, valida token com backend
4. Se válido, redireciona para tela apropriada
5. Se inválido, limpa dados e vai para landing
```

## 📁 Arquivos Modificados

### Frontend
- `lib/main.dart` - Adicionado AuthWrapper
- `lib/providers/auth_provider.dart` - Melhorado com logs e validação
- `lib/services/api_service.dart` - Método validateToken já existia

### Backend
- `AuthController.java` - Endpoint `/api/auth/validate` já existia

## 🧪 Como Testar

### 1. Teste Manual
```bash
# 1. Inicie o backend
cd petconnect-backend-only/backend
./mvnw spring-boot:run

# 2. Inicie o frontend
cd petconnect-frontend
flutter run -d chrome --web-port=3000

# 3. Acesse http://localhost:3000
# 4. Faça login com: tutor@teste.com / admin123
# 5. Atualize a página (F5)
# 6. Verifique se permanece logado
```

### 2. Teste Automatizado
```bash
# Execute o script de teste
./test_session_persistence.sh
```

### 3. Verificar Logs
```bash
# No navegador, abra DevTools (F12)
# Vá na aba Console
# Procure por mensagens do AuthProvider:
# - "Carregando dados da sessão..."
# - "Sessão restaurada com sucesso"
# - "Validando token com backend..."
```

## 🔍 Debug e Troubleshooting

### Logs Importantes
- `AuthProvider: Carregando dados da sessão...`
- `AuthProvider: Dados encontrados - User: true, Token: true, Type: TUTOR`
- `AuthProvider: Sessão restaurada com sucesso`
- `AuthProvider: Validando token com backend...`
- `AuthProvider: Token válido`

### Problemas Comuns

#### 1. Usuário sempre vai para landing
**Causa**: Token expirado ou dados corrompidos
**Solução**: Verificar logs do AuthProvider

#### 2. Loop infinito de loading
**Causa**: Erro na validação do token
**Solução**: Verificar se o backend está rodando

#### 3. Dados não são salvos
**Causa**: Erro no SharedPreferences
**Solução**: Verificar permissões do navegador

## 🚀 Melhorias Futuras

1. **Refresh Token**: Implementar refresh automático de tokens
2. **Expiração**: Adicionar aviso de expiração próxima
3. **Logout Remoto**: Implementar logout em todas as abas
4. **Criptografia**: Criptografar dados salvos localmente

## 📊 Dados Salvos Localmente

```json
{
  "currentUser": "{\"id\":1,\"name\":\"João Silva\",\"email\":\"tutor@teste.com\",...}",
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "userType": "TUTOR"
}
```

## 🔒 Segurança

- **Token JWT**: Validação com backend a cada inicialização
- **Limpeza Automática**: Dados corrompidos são removidos
- **Timeout**: Tokens expirados são invalidados automaticamente
- **Logout**: Limpa todos os dados locais

---

**Status**: ✅ Implementado e Testado
**Versão**: 1.0.0
**Data**: 2024-06-22 