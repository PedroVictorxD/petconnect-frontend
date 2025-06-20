# Caso de Uso: Recuperar Senha

| Item             | Descrição                                                                 |
|------------------|--------------------------------------------------------------------------|
| Nome             | Recuperar Senha                                                          |
| Ator             | Admin, Lojista, Tutor, Veterinário                                       |
| Pré-condições    | Usuário cadastrado e com perguntas de segurança definidas                |
| Fluxo Principal  | 1. Usuário solicita recuperação<br>2. Informa email<br>3. Responde perguntas de segurança<br>4. Redefine senha |
| Fluxo Alternativo| 3a. Resposta incorreta: sistema exibe erro                               |
| Pós-condições    | Senha redefinida                                                         |
| Exceções         | Email não cadastrado, falha de conexão                                   | 