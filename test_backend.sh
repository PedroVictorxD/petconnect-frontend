#!/bin/bash

BASE_URL="http://localhost:8080"
echo "=== PETCONNECT BACKEND TEST ==="
echo "Base URL: $BASE_URL"
echo ""

# Teste 1: Verificar se o servidor está rodando
echo "1. Testando se o servidor está rodando..."
response=$(curl -s -w "%{http_code}" "$BASE_URL/")
http_code="${response: -3}"
if [ "$http_code" = "200" ] || [ "$http_code" = "404" ] || [ "$http_code" = "403" ] || [ "$http_code" = "500" ]; then
    echo "✓ Servidor está rodando (Status: $http_code)"
else
    echo "✗ Servidor não está respondendo"
    exit 1
fi

# Teste 2: Registrar usuário admin
echo ""
echo "2. Testando registro de admin..."
admin_data='{
  "name": "Admin Teste",
  "email": "admin@teste.com",
  "password": "123456",
  "phone": "11999999999",
  "location": "São Paulo, SP",
  "userType": "ADMIN",
  "securityQuestion": "Qual é o nome do seu primeiro pet?",
  "securityAnswer": "Rex"
}'
response=$(curl -s -w "%{http_code}" -X POST -H "Content-Type: application/json" -d "$admin_data" "$BASE_URL/auth/register")
http_code="${response: -3}"
if [ "$http_code" = "201" ] || [ "$http_code" = "200" ]; then
    echo "✓ Registro de admin bem-sucedido"
else
    echo "✗ Registro de admin falhou (Status: $http_code)"
fi

# Teste 3: Login admin
echo ""
echo "3. Testando login de admin..."
login_data='{"email":"admin@teste.com","password":"123456"}'
response=$(curl -s -w "%{http_code}" -X POST -H "Content-Type: application/json" -d "$login_data" "$BASE_URL/auth/login")
http_code="${response: -3}"
body="${response%???}"
if [ "$http_code" = "200" ]; then
    token=$(echo "$body" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
    if [ -n "$token" ]; then
        echo "✓ Login de admin bem-sucedido"
        echo "Token: ${token:0:20}..."
        JWT_TOKEN=$token
    else
        echo "✗ Token não encontrado na resposta"
    fi
else
    echo "✗ Login de admin falhou (Status: $http_code)"
fi

# Teste 4: Endpoints de admin
echo ""
echo "4. Testando endpoints de admin..."
if [ -n "$JWT_TOKEN" ]; then
    response=$(curl -s -w "%{http_code}" -H "Authorization: Bearer $JWT_TOKEN" "$BASE_URL/admin/users")
    http_code="${response: -3}"
    if [ "$http_code" = "200" ]; then
        echo "✓ Listar usuários (admin) - OK"
    else
        echo "✗ Listar usuários (admin) falhou (Status: $http_code)"
    fi
    
    response=$(curl -s -w "%{http_code}" -H "Authorization: Bearer $JWT_TOKEN" "$BASE_URL/admin/pets")
    http_code="${response: -3}"
    if [ "$http_code" = "200" ]; then
        echo "✓ Listar pets (admin) - OK"
    else
        echo "✗ Listar pets (admin) falhou (Status: $http_code)"
    fi
    
    response=$(curl -s -w "%{http_code}" -H "Authorization: Bearer $JWT_TOKEN" "$BASE_URL/admin/stats")
    http_code="${response: -3}"
    if [ "$http_code" = "200" ]; then
        echo "✓ Estatísticas (admin) - OK"
    else
        echo "✗ Estatísticas (admin) falhou (Status: $http_code)"
    fi
else
    echo "✗ Token não disponível para testes de admin"
fi

# Teste 5: Endpoints públicos
echo ""
echo "5. Testando endpoints públicos..."
response=$(curl -s -w "%{http_code}" "$BASE_URL/products")
http_code="${response: -3}"
if [ "$http_code" = "200" ]; then
    echo "✓ Listar produtos (público) - OK"
else
    echo "✗ Listar produtos (público) falhou (Status: $http_code)"
fi

response=$(curl -s -w "%{http_code}" "$BASE_URL/vet-services")
http_code="${response: -3}"
if [ "$http_code" = "200" ]; then
    echo "✓ Listar serviços (público) - OK"
else
    echo "✗ Listar serviços (público) falhou (Status: $http_code)"
fi

response=$(curl -s -w "%{http_code}" "$BASE_URL/food")
http_code="${response: -3}"
if [ "$http_code" = "200" ]; then
    echo "✓ Listar alimentos (público) - OK"
else
    echo "✗ Listar alimentos (público) falhou (Status: $http_code)"
fi

# Teste 6: Recuperação de senha
echo ""
echo "6. Testando recuperação de senha..."
forgot_data='{"email":"admin@teste.com"}'
response=$(curl -s -w "%{http_code}" -X POST -H "Content-Type: application/json" -d "$forgot_data" "$BASE_URL/auth/forgot-password")
http_code="${response: -3}"
if [ "$http_code" = "200" ]; then
    echo "✓ Recuperação de senha - OK"
else
    echo "✗ Recuperação de senha falhou (Status: $http_code)"
fi

echo ""
echo "=== TESTE CONCLUÍDO ==="
echo "Para ver logs detalhados, verifique o console do backend"
