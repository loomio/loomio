---
title: API do servidor
source_revision: 81fbad246f674a34694bb2ebfc8416dd04e46ee6
source_file: docs/help/en/user_manual/integrations/api/server-api.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-28'
sections:
  introduction: 33c4ce1c59342826
  authentication: a215188bb0ae2b38
  user-object: 7e9e8ff3e48a4055
  list-users: 16e557db2983e597
  example: 5a370a67d3dc961f
  show-user: ef061aab9e142a98
  examples: 5b98557c8af42e29
  update-user: fc52abc60aa4eb6e
  params: 368f797e2a2b5c3d
  examples-2: b6bc03ca1e104210
  deactivate-user: 19c9b37ded7cad07
  examples-3: 706a02fb50225d20
  reactivate-user: 03bccb45ded4f11c
  examples-4: 5c9cf19d21267502
  redact-user: 9560a30820cb43cc
  examples-5: df81d06971fb0391
  delete-user: 1aad5e4da586e0ed
  examples-6: 23542029b0bc8237
  sso-profile-sync-settings: 416144004d040e4f
  provisioning: de7ad238bf914455
generated:
  introduction: 7b1d8ac0ee4f3919
  authentication: 0d9ee4359aeee6d3
  user-object: 8424c11a963abb51
  list-users: 89c4922a2baf6e5e
  example: 6eac2c753aadb930
  show-user: 6ec51ddc6698183b
  examples: b39cf6693e1e4175
  update-user: 253d1843586b4e6e
  params: 83d3c28bb7de427e
  examples-2: 93211ed64064c8ee
  deactivate-user: 21ff40333079f5d3
  examples-3: 7c23673b4a046f5e
  reactivate-user: 55ebff1f71c343d3
  examples-4: ec615dd794e5bba0
  redact-user: ff316bf074793a55
  examples-5: c753ad035de72f1e
  delete-user: f7fe080a32467931
  examples-6: 36f1af7f5cf1bb9f
  sso-profile-sync-settings: 3793ea7f5de05436
  provisioning: a952dfc94c494202
title_source: 370e81eb20eece44
title_generated: 8f49c340fcf3bf2d
---

<!-- translation-section: introduction -->

# Documentação da API do servidor Loomio

<!-- seo-description: Use a API do servidor Loomio para provisionar contas de usuário, localizar grupos e gerenciar vínculos de membros em uma instalação auto-hospedada do Loomio. -->

`/api/server0` serve para operações no nível do servidor. Use `/api/user0` para ações voltadas ao usuário, realizadas com uma conta de usuário do Loomio.

Use uma única chave de servidor para criar e gerenciar contas, localizar grupos em toda a instalação e gerenciar seus vínculos de membros e funções. Não é necessário ter uma conta de bot, uma chave de API de usuário ou ser membro dos grupos. As chaves de API de usuário continuam seguindo as permissões do usuário nos grupos.

<!-- translation-section: authentication -->

## Autenticação

A chave é definida pela configuração `SERVER_API_KEY` no ambiente do servidor. O script `create_env.sh` gera uma chave para novas instalações.

Envie a chave como um token bearer:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users
```

Envie as credenciais somente no cabeçalho `Authorization`. Chaves de API em strings de consulta ou no corpo das requisições são rejeitadas.

<!-- translation-section: provisioning -->

## Provisionar contas e vínculos de membros

| Método | Endpoint | Finalidade |
| --- | --- | --- |
| `POST` | `/api/server0/users` | Criar uma conta |
| `GET` | `/api/server0/groups` | Localizar grupos em toda a instalação |
| `GET` | `/api/server0/memberships` | Listar vínculos de membros em um grupo |
| `POST` | `/api/server0/memberships` | Convidar membros ou sincronizar uma lista completa de membros |
| `PATCH` | `/api/server0/memberships/:id` | Alterar funções de administrador e delegado do grupo |
| `DELETE` | `/api/server0/memberships/:id` | Revogar um vínculo de membro |

Os endpoints existentes para atualização, desativação, reativação, anonimização e exclusão de contas estão descritos abaixo.

### Criar uma conta

`POST /api/server0/users`

Envie um objeto `user` com o campo obrigatório `email`. Os espaços em branco no início e no fim dos endereços de e-mail são removidos, e os endereços são convertidos para letras minúsculas. Os campos opcionais são `name`, `username` e `is_admin`. Aqui, `is_admin` indica um administrador da instância; as funções de administrador de grupo são gerenciadas nos vínculos de membros. Omita `username` para gerar um nome de usuário automaticamente. Campos desconhecidos são rejeitados.

```bash
curl https://loomio.example.org/api/server0/users \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  --json '{
    "user": {
      "email": "ada@example.org",
      "name": "Ada Lovelace",
      "username": "ada",
      "is_admin": false
    }
  }'
```

A resposta é HTTP `201` com um objeto `user`. Campos inválidos ou um e-mail ou nome de usuário já em uso retornam HTTP `422`. Criar uma conta não envia um convite, não inicia uma sessão para a pessoa nem marca seu e-mail como verificado. Convide a pessoa para um grupo usando o endpoint de vínculos de membros para enviar um convite pelo fluxo normal de notificações.

### Localizar grupos

`GET /api/server0/groups`

Liste todos os grupos que não foram excluídos, incluindo grupos privados e grupos com assinaturas expiradas. Os resultados são ordenados por ID em ordem crescente. Use `limit` (padrão e máximo de `50`) e `offset` (padrão de `0`) para percorrer as páginas de resultados.

```bash
curl 'https://loomio.example.org/api/server0/groups?limit=50&offset=0' \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY'
```

```json
{
  "groups": [
    {
      "id": 123,
      "key": "examplegroup",
      "name": "Planning group",
      "handle": "planning",
      "parent_id": null,
      "group_privacy": "secret"
    }
  ],
  "meta": {
    "total": 1
  }
}
```

### Listar vínculos de membros

`GET /api/server0/memberships?group_id=123`

`group_id` é obrigatório. Os resultados incluem vínculos de membros aceitos e convites pendentes, ordenados pelo ID do vínculo em ordem crescente. Vínculos revogados são excluídos dos resultados. Use `limit` (padrão e máximo de `50`) e `offset` (padrão de `0`) para paginação.

```bash
curl 'https://loomio.example.org/api/server0/memberships?group_id=123&limit=50&offset=0' \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY'
```

```json
{
  "memberships": [
    {
      "id": 456,
      "group_id": 123,
      "user_id": 789,
      "user_email": "ada@example.org",
      "user_name": "Ada Lovelace",
      "admin": false,
      "delegate": false,
      "accepted_at": null,
      "pending": true
    }
  ],
  "meta": {
    "total": 1
  }
}
```

`admin` e `delegate` são funções do grupo. `accepted_at` é a data e hora da aceitação, ou `null` enquanto um convite estiver pendente. Este endpoint não expõe tokens de convite, credenciais de acesso ou votos.

### Convidar ou sincronizar membros

`POST /api/server0/memberships`

Envie os campos obrigatórios `group_id` e `emails`, sendo este último um array. Por padrão, isso adiciona as pessoas listadas que ainda não têm um vínculo ativo, mantendo todos os demais membros. Os espaços em branco no início e no fim dos endereços de e-mail são removidos, os endereços são convertidos para letras minúsculas e as duplicatas são eliminadas. Novos endereços criam contas e convites pendentes. Membros verificados de outro grupo ativo da mesma organização são aceitos automaticamente, seguindo o fluxo de convites da API de usuário.

```bash
curl https://loomio.example.org/api/server0/memberships \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  --json '{
    "group_id": 123,
    "emails": [
      "ada@example.org",
      "alex@example.org"
    ]
  }'
```

Para sincronizar uma lista completa de membros, defina explicitamente `remove_absent` como `true`. Qualquer pessoa que não esteja na lista será removida desse grupo e de seus subgrupos. Um array vazio com `remove_absent: true` remove todos, incluindo os administradores do grupo. Omita `remove_absent` ou defina-o como `false` quando quiser apenas adicionar pessoas. Os valores legados `1` e `0` também são aceitos.

```bash
curl https://loomio.example.org/api/server0/memberships \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  --json '{
    "group_id": 123,
    "emails": [
      "ada@example.org"
    ],
    "remove_absent": true
  }'
```

```json
{
  "added_emails": [],
  "removed_emails": [
    "alex@example.org"
  ]
}
```

Repetir a mesma requisição não cria vínculos de membros duplicados nem reenvia convites. Convidar novamente um membro cujo vínculo foi revogado restaura seu acesso ao grupo sem restaurar uma função anterior de administrador. Novos convites e alterações de função usam o fluxo normal de notificações, sem registrar um usuário como responsável pela ação.

Listas de e-mail ausentes ou malformadas e valores booleanos inválidos retornam HTTP `400`. Uma conta desativada incluída na lista retorna HTTP `422`; reative-a explicitamente antes de adicioná-la. Dados de conta inválidos, limites da assinatura ou outras falhas desfazem toda a sincronização, incluindo novas contas e remoções de vínculos de membros. As adições exigem um grupo ativo e continuam sujeitas aos limites de membros da assinatura.

### Atualizar funções de um membro

`PATCH /api/server0/memberships/:id`

Envie um objeto `membership` contendo um ou ambos os campos booleanos `admin` e `delegate`. As funções omitidas permanecem inalteradas. Campos desconhecidos são rejeitados; o endpoint não pode transferir um vínculo de membro, aceitar um convite ou alterar pesos de voto.

```bash
curl https://loomio.example.org/api/server0/memberships/456 \
  -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  --json '{
    "membership": {
      "admin": true,
      "delegate": false
    }
  }'
```

Retorna um objeto `membership` com os mesmos campos de um vínculo de membro listado. A concessão de uma função cria a notificação habitual dessa função; repetir uma função inalterada não envia outra notificação. Alterações de função exigem um grupo ativo. Vínculos de membros revogados retornam HTTP `404`.

### Remover um vínculo de membro

`DELETE /api/server0/memberships/:id`

```bash
curl https://loomio.example.org/api/server0/memberships/456 \
  -X DELETE \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY'
```

Retorna `{"success": true}`. A remoção revoga o acesso ao grupo e a seus subgrupos, incluindo o acesso a tópicos e o direito de votar em enquetes ativas. Ela não exclui a conta, não altera grupos sem relação com esse vínculo nem remove o acesso direto a conversas. Repetir uma remoção também retorna sucesso. Você pode remover vínculos de membros de grupos com assinaturas expiradas; grupos excluídos retornam HTTP `404`.

<!-- translation-section: user-object -->

## Objeto de usuário

As respostas de usuário usam esta estrutura:

```json
{
  "id": 123,
  "name": "Ada Lovelace",
  "username": "ada",
  "email": "ada@example.org",
  "is_admin": false,
  "active": true,
  "deactivated_at": null,
  "identities": [
    {
      "id": 456,
      "identity_type": "oauth",
      "uid": "external-123",
      "email": "ada@example.org",
      "name": "Ada Lovelace"
    }
  ]
}
```

<!-- translation-section: list-users -->

## Listar usuários

Liste todas as contas de usuário da instalação do Loomio.

`GET /api/server0/users`

<!-- translation-section: example -->

### Exemplo

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users
```

Retorna:

```json
{
  "users": []
}
```

<!-- translation-section: show-user -->

## Exibir usuário

Encontre um usuário pelo seu ID de usuário do Loomio ou pela sua identidade externa.

`GET /api/server0/users/:id`

`GET /api/server0/users/identity/:identity_type/:uid`

<!-- translation-section: examples -->

### Exemplos

Pelo ID de usuário do Loomio:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123
```

Pela identidade externa:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123
```

Retorna:

```json
{
  "user": {}
}
```

<!-- translation-section: update-user -->

## Atualizar usuário

Atualize os campos do perfil de um usuário encontrado pelo seu ID de usuário do Loomio ou pela sua identidade externa.

`PATCH /api/server0/users/:id`

`PATCH /api/server0/users/identity/:identity_type/:uid`

<!-- translation-section: params -->

### Parâmetros

| Campo | Descrição |
| --- | --- |
| `name` | Nome de exibição |
| `username` | Nome de usuário do Loomio |
| `email` | Endereço de e-mail |

<!-- translation-section: examples-2 -->

### Exemplos

Pelo ID de usuário do Loomio:

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/server0/users/123
```

Pela identidade externa:

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/server0/users/identity/oauth/external-123
```

Retorna o usuário atualizado:

```json
{
  "user": {}
}
```

<!-- translation-section: deactivate-user -->

## Desativar usuário

Desative uma conta de usuário encontrada pelo seu ID de usuário do Loomio ou pela sua identidade externa.

`POST /api/server0/users/:id/deactivate`

`POST /api/server0/users/identity/:identity_type/:uid/deactivate`

<!-- translation-section: examples-3 -->

### Exemplos

Pelo ID de usuário do Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123/deactivate
```

Pela identidade externa:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123/deactivate
```

Retorna:

```json
{
  "success": true,
  "user": {}
}
```

<!-- translation-section: reactivate-user -->

## Reativar usuário

Reative uma conta de usuário desativada localizada pelo ID de usuário do Loomio ou pela identidade externa.

`POST /api/server0/users/:id/reactivate`

`POST /api/server0/users/identity/:identity_type/:uid/reactivate`

<!-- translation-section: examples-4 -->

### Exemplos

Pelo ID de usuário do Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123/reactivate
```

Pela identidade externa:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123/reactivate
```

Retorna:

```json
{
  "success": true,
  "user": {}
}
```

<!-- translation-section: redact-user -->

## Remover dados pessoais do usuário

A remoção de dados pessoais mantém os comentários do usuário e outros conteúdos criados por ele em seus grupos, mas remove informações conhecidas que permitem identificá-lo, como nome, biografia, foto de perfil, endereço de e-mail, credenciais de acesso, identidades e sessões ativas.

Esta é a forma recomendada de remover um usuário do Loomio.

`POST /api/server0/users/:id/redact`

`POST /api/server0/users/identity/:identity_type/:uid/redact`

<!-- translation-section: examples-5 -->

### Exemplos

Pelo ID de usuário do Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123/redact
```

Pela identidade externa:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123/redact
```

Retorna:

```json
{
  "success": true
}
```

<!-- translation-section: delete-user -->

## Excluir usuário

A exclusão remove o usuário e os registros que ele criou. Os comentários são removidos das conversas, os votos são removidos das enquetes, e grupos, discussões, enquetes e outros registros criados pelo usuário também podem ser excluídos por meio de associações no banco de dados.

Esta operação é muito destrutiva. É altamente recomendável optar pela remoção de dados pessoais.

`DELETE /api/server0/users/:id`

`DELETE /api/server0/users/identity/:identity_type/:uid`

<!-- translation-section: examples-6 -->

### Exemplos

Pelo ID de usuário do Loomio:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123
```

Pela identidade externa:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123
```

Retorna:

```json
{
  "success": true
}
```

<!-- translation-section: sso-profile-sync-settings -->

## Configurações de sincronização de perfil via SSO

Use estas configurações quando outro sistema gerenciar os campos de perfil do Loomio.

```env
LOOMIO_DISABLE_EDIT_USER_PROFILE=1
# LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1
```

`LOOMIO_DISABLE_EDIT_USER_PROFILE=1` impede que os próprios usuários editem estes campos:

| Campo | Observações |
| --- | --- |
| `name` | Gerenciado por sincronização externa |
| `username` | Gerenciado por sincronização externa |
| `email` | Gerenciado por sincronização externa |
| `avatar_kind` / `uploaded_avatar` | Gerenciado por sincronização externa |

Os usuários ainda podem editar campos locais do Loomio, como `short_bio` e `location`.

`LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1` atualiza `name` e `email` com os dados de login via SSO. Deixe essa variável comentada ou sem definir quando um script de sincronização externa deve ser a única fonte dessas atualizações.

`LOOMIO_SSO_FORCE_USER_ATTRS` continua funcionando em instalações existentes. Essa variável impede as edições pelos usuários e atualiza `name` e `email` no login via SSO.
