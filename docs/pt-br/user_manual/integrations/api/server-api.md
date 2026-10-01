---
title: API do servidor
source_revision: c6076258c3438c0dd6dc8fbf1fc0b0df47c0aeb5
source_file: docs/en/user_manual/integrations/api/server-api.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: a357cdc2bfc0223e
  authentication: cbabcc874f053455
  user-object: c3a00ec4e3d66b09
  list-users: c7d62eee05e7a6a4
  example: 2f817ab1533206e6
  show-user: 36fa596a6a5c2fd8
  examples: 522d17246020d82f
  update-user: 39d632ce15d489d3
  params: 368f797e2a2b5c3d
  examples-2: 3aab846e77253829
  deactivate-user: 132d435583a46920
  examples-3: d8c7c152ab2b0ace
  reactivate-user: 309592dead978456
  examples-4: 95251484d1fd7e1d
  redact-user: 47ea30122aa92fae
  examples-5: 9d3bb1c3a865f3e0
  delete-user: 2d5a1dbd23324e6f
  examples-6: 71ae30577730b261
  sso-profile-sync-settings: 416144004d040e4f
generated:
  introduction: c55282fe646961f7
  authentication: 0b44d4ca87f20a89
  user-object: 58abd8db3fc2b121
  list-users: 353ed62e440fa4e4
  example: 5b0c3624a9655049
  show-user: 6d379f87bde94ebb
  examples: 3ccd14dce68e492d
  update-user: bfd78c23f8ff2998
  params: 83d3c28bb7de427e
  examples-2: 743d46642dd856a8
  deactivate-user: d5c73aa81fa5df95
  examples-3: 53b08ff7209b3a73
  reactivate-user: 772201569e4073c2
  examples-4: 9584f3ea70427015
  redact-user: 60e15530c50c7639
  examples-5: 41719088740a2289
  delete-user: bb4aa76031935076
  examples-6: 39bf481970ac996d
  sso-profile-sync-settings: 5809ede17f6525ff
title_source: 370e81eb20eece44
title_generated: 8f49c340fcf3bf2d
---

<!-- translation-section: introduction -->

# Documentação da API do servidor Loomio

<!-- seo-description: Use a API do servidor Loomio para gerenciar contas de usuário em uma instalação do Loomio hospedada por você. -->

`/api/b3` serve para operações no nível do servidor. Use `/api/b2` para ações voltadas ao usuário, realizadas com uma conta de usuário do Loomio.

<!-- translation-section: authentication -->

## Autenticação

Defina `B3_API_KEY` como um segredo com mais de 16 caracteres.

Envie a chave como um token bearer:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
```

Envie as credenciais apenas no cabeçalho `Authorization`. Chaves de API em strings de consulta ou no corpo das requisições são rejeitadas.

<!-- translation-section: user-object -->

## Objeto de usuário

As respostas com dados de usuários usam esta estrutura:

```json
{
  "id": 123,
  "name": "Ada Lovelace",
  "username": "ada",
  "email": "ada@example.org",
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

Liste todas as contas de usuário na instalação do Loomio.

`GET /api/b3/users`

<!-- translation-section: example -->

### Exemplo

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
```

Retorna:

```json
{
  "users": []
}
```

<!-- translation-section: show-user -->

## Consultar usuário

Encontre um usuário pelo seu ID de usuário do Loomio ou pela sua identidade externa.

`GET /api/b3/users/:id`

`GET /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples -->

### Exemplos

Pelo ID de usuário do Loomio:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123
```

Pela identidade externa:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123
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

`PATCH /api/b3/users/:id`

`PATCH /api/b3/users/identity/:identity_type/:uid`

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
  https://www.loomio.com/api/b3/users/123
```

Pela identidade externa:

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/b3/users/identity/oauth/external-123
```

Retorna o usuário atualizado:

```json
{
  "user": {}
}
```

<!-- translation-section: deactivate-user -->

## Desativar usuário

Desative uma conta de usuário encontrada pelo ID de usuário do Loomio ou pela identidade externa.

`POST /api/b3/users/:id/deactivate`

`POST /api/b3/users/identity/:identity_type/:uid/deactivate`

<!-- translation-section: examples-3 -->

### Exemplos

Pelo ID de usuário do Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/deactivate
```

Pela identidade externa:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/deactivate
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

Reative uma conta de usuário desativada localizada pelo ID do usuário no Loomio ou pela identidade externa.

`POST /api/b3/users/:id/reactivate`

`POST /api/b3/users/identity/:identity_type/:uid/reactivate`

<!-- translation-section: examples-4 -->

### Exemplos

Pelo ID do usuário no Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/reactivate
```

Pela identidade externa:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/reactivate
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

A remoção de dados pessoais mantém os comentários e outros conteúdos criados pelo usuário em seus grupos, mas remove informações conhecidas que permitem identificá-lo, como nome, biografia, foto de perfil, endereço de e-mail, credenciais de acesso, identidades e sessões ativas.

Esta é a forma recomendada de remover um usuário do Loomio.

`POST /api/b3/users/:id/redact`

`POST /api/b3/users/identity/:identity_type/:uid/redact`

<!-- translation-section: examples-5 -->

### Exemplos

Pelo ID do usuário no Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/redact
```

Pela identidade externa:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/redact
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

Esta operação é muito destrutiva. É altamente recomendável remover os dados pessoais em vez de excluir o usuário.

`DELETE /api/b3/users/:id`

`DELETE /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples-6 -->

### Exemplos

Pelo ID do usuário no Loomio:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123
```

Pela identidade externa:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123
```

Retorna:

```json
{
  "success": true
}
```

<!-- translation-section: sso-profile-sync-settings -->

## Configurações de sincronização de perfil com SSO

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

`LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1` atualiza `name` e `email` com os dados de acesso via SSO. Deixe essa configuração comentada ou não definida quando um script de sincronização externa precisar ser a única fonte dessas atualizações.

`LOOMIO_SSO_FORCE_USER_ATTRS` continua funcionando nas instalações existentes. Essa configuração impede a edição pelos usuários e atualiza `name` e `email` quando eles acessam via SSO.
