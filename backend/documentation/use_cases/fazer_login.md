# Caso de Uso: Fazer Login

| Item             | Descrição                                                                 |
|------------------|--------------------------------------------------------------------------|
| Nome             | Fazer Login                                                              |
| Ator             | Admin, Lojista, Tutor, Veterinário                                       |
| Pré-condições    | Usuário já cadastrado                                                    |
| Fluxo Principal  | 1. Usuário informa email e senha<br>2. Sistema valida credenciais<br>3. Usuário acessa o sistema conforme perfil |
| Fluxo Alternativo| 2a. Credenciais inválidas: sistema exibe mensagem de erro                |
| Pós-condições    | Usuário autenticado e com sessão ativa                                   |
| Exceções         | Falha de conexão, conta bloqueada, etc                                   | 