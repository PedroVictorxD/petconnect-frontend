# PetConect Backend

Backend do sistema PetConect, desenvolvido em Spring Boot (Java 21) com Maven, persistência em PostgreSQL e endpoints RESTful para múltiplos tipos de usuários.

## Visão Geral
- **Framework:** Spring Boot 3.3.0
- **Java:** 21
- **Banco:** PostgreSQL
- **Porta padrão:** 8081
- **Entidades principais:** Admin, Veterinario, Tutor, Lojista

## Requisitos
- Java 21+
- Maven 3.8+
- PostgreSQL rodando e banco `petconectdb` criado

## Configuração
1. **Clone o repositório e acesse a pasta do backend:**
   ```bash
   cd backend
   ```
2. **Configure o banco em `src/main/resources/application.properties`:**
   ```properties
   spring.datasource.url=jdbc:postgresql://localhost:5432/petconectdb
   spring.datasource.username=postgres
   spring.datasource.password=postgres
   spring.jpa.hibernate.ddl-auto=update
   server.port=8081
   ```
3. **Crie o banco se necessário:**
   ```bash
   psql -U postgres -c "CREATE DATABASE petconectdb;"
   ```

## Execução
```bash
mvn spring-boot:run
```
Acesse a API em: [http://localhost:8081](http://localhost:8081)

## Entidades e Endpoints

### Admin
- **POST /admins** — Cria admin
- **GET /admins** — Lista admins
- **GET /admins/{id}** — Busca admin por id
- **PUT /admins/{id}** — Atualiza admin
- **DELETE /admins/{id}** — Remove admin

#### Exemplo de criação
```bash
curl -X POST http://localhost:8081/admins -H "Content-Type: application/json" -d '{"name":"Admin Test","email":"admin@test.com","password":"123456","phone":"11999999999","location":"SP"}'
```

### Veterinario
- **POST /veterinarios** — Cria veterinário
- **GET /veterinarios** — Lista veterinários
- **GET /veterinarios/{id}** — Busca veterinário por id
- **PUT /veterinarios/{id}** — Atualiza veterinário
- **DELETE /veterinarios/{id}** — Remove veterinário

#### Exemplo de criação
```bash
curl -X POST http://localhost:8081/veterinarios -H "Content-Type: application/json" -d '{"name":"Veterinario Test","email":"vet@test.com","password":"123456","phone":"11988888888","location":"RJ","crmv":"CRMV12345"}'
```

### Tutor
- **POST /tutores** — Cria tutor
- **GET /tutores** — Lista tutores
- **GET /tutores/{id}** — Busca tutor por id
- **PUT /tutores/{id}** — Atualiza tutor
- **DELETE /tutores/{id}** — Remove tutor

#### Exemplo de criação
```bash
curl -X POST http://localhost:8081/tutores -H "Content-Type: application/json" -d '{"name":"Tutor Test","email":"tutor@test.com","password":"123456","phone":"11977777777","location":"MG"}'
```

### Lojista
- **POST /lojistas** — Cria lojista
- **GET /lojistas** — Lista lojistas
- **GET /lojistas/{id}** — Busca lojista por id
- **PUT /lojistas/{id}** — Atualiza lojista
- **DELETE /lojistas/{id}** — Remove lojista

#### Exemplo de criação
```bash
curl -X POST http://localhost:8081/lojistas -H "Content-Type: application/json" -d '{"name":"Lojista Test","email":"lojista@test.com","password":"123456","phone":"11966666666","location":"BA","cnpj":"12345678000199","responsibleName":"Responsável Teste","storeType":"VIRTUAL","operatingHours":"08:00-18:00"}'
```

## Testes Rápidos
- **Listar todos:**
  - `curl http://localhost:8081/admins`
  - `curl http://localhost:8081/veterinarios`
  - `curl http://localhost:8081/tutores`
  - `curl http://localhost:8081/lojistas`
- **Buscar por ID:**
  - `curl http://localhost:8081/admins/5`
  - `curl http://localhost:8081/veterinarios/6`
  - `curl http://localhost:8081/tutores/7`
  - `curl http://localhost:8081/lojistas/8`
- **Atualizar:**
  - `curl -X PUT http://localhost:8081/admins/5 -H "Content-Type: application/json" -d '{"name":"Novo Admin", ...}'`
- **Remover:**
  - `curl -X DELETE http://localhost:8081/admins/5 -i`

## Observações
- O backend está pronto para integração com o frontend Flutter.
- Para adicionar autenticação, roles ou relacionamentos, basta pedir! 