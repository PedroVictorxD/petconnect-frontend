#!/bin/bash

echo "🧪 Testando Persistência de Sessão - PetConnect"
echo "================================================"

BASE_URL="http://localhost:8080"
FRONTEND_URL="http://localhost:3000"

echo ""
echo "1. Testando login..."
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "tutor@teste.com",
    "password": "admin123"
  }')

echo "Resposta do login: $LOGIN_RESPONSE"

# Extrair token da resposta
TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
    echo "❌ Falha ao obter token"
    exit 1
fi

echo "✅ Token obtido: ${TOKEN:0:20}..."

echo ""
echo "2. Testando validação de token..."
VALIDATION_RESPONSE=$(curl -s -X GET "$BASE_URL/api/auth/validate" \
  -H "Authorization: Bearer $TOKEN")

echo "Resposta da validação: $VALIDATION_RESPONSE"

echo ""
echo "3. Testando acesso a endpoint protegido..."
PROTECTED_RESPONSE=$(curl -s -X GET "$BASE_URL/api/pets" \
  -H "Authorization: Bearer $TOKEN")

if [[ $PROTECTED_RESPONSE == *"id"* ]]; then
    echo "✅ Acesso a endpoint protegido funcionando"
else
    echo "❌ Falha no acesso a endpoint protegido"
fi

echo ""
echo "4. Testando token inválido..."
INVALID_RESPONSE=$(curl -s -X GET "$BASE_URL/api/auth/validate" \
  -H "Authorization: Bearer invalid_token")

echo "Resposta com token inválido: $INVALID_RESPONSE"

echo ""
echo "🎯 Teste de Persistência Concluído!"
echo ""
echo "📋 Instruções para testar no navegador:"
echo "1. Acesse: $FRONTEND_URL"
echo "2. Faça login com: tutor@teste.com / admin123"
echo "3. Atualize a página (F5)"
echo "4. Verifique se permanece logado"
echo ""
echo "🔍 Logs para verificar:"
echo "- Abra o DevTools (F12)"
echo "- Vá na aba Console"
echo "- Procure por mensagens do AuthProvider" 