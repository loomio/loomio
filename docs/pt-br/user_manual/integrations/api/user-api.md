---
title: API do usuário
source_revision: c6076258c3438c0dd6dc8fbf1fc0b0df47c0aeb5
source_file: docs/en/user_manual/integrations/api/user-api.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: a43c8b800d13fd33
  authentication-change: 06b5c2cd9d9e72a0
  response-size-and-related-records: 1ffc59ad606a87e7
  endpoint-summary: 52c480c59d3669e3
  groups: 0473f1f7fb78f074
  list-groups: 2b783ec54f27b2ce
  get-a-group: dffef659cb92745e
  webhooks: f65fa289f8c1b808
  list-webhooks: a8b52c1a9bfdb16c
  create-a-webhook: 007312bcc204853a
  update-a-webhook: 124b07d2c401e319
  test-a-webhook-destination: 8fc3ac4ad10de6f6
  delete-a-webhook: 34eda1e07d65db80
  event-types: 73bfe87c8b790af3
  http-delivery: a32c763b6f816e65
  payload-formats: ca728b0ef542305c
  search: bb5a1cfc7a6179aa
  params: 7eebe4e259830976
  participation-report: a1798112a78390fe
  params-2: 464322ffc1ac56e5
  example: 63bed6e82107f992
  create-discussion: ad202a0bdbfa7c2e
  params-3: 529f10e32be74c5c
  example-2: f25daafbba33718c
  show-discussion: b61aea6bf3d55e16
  example-3: e095e8e34cd562a0
  list-discussions: f209b8feb7c795a6
  params-4: 3ec197245f595be6
  example-4: 37d59c03fee8a15b
  list-threads: 34edc6c34552e136
  params-5: a5f41285afccdc8b
  example-5: 81c145ad5f6eb232
  read-thread: 0de1409aaa00b9ac
  example-6: 7c7553e1a3e94070
  edit-discussion: 1ab04653354b8036
  params-6: 4d3f5862a5f948b4
  example-7: d2a61a34af9e99c3
  soft-delete-discussion: fdb0d4db8470524c
  example-8: 423894a70b5ce489
  create-comment: bf95ee58b610f2fd
  params-7: 7af2127e1f721b66
  example-9: 4e7d49ac39938c12
  edit-comment: 49e722ec6bca25a1
  params-8: b2be783e4398d866
  example-10: bf626a7f693182c3
  soft-delete-comment: afb51bf4074aeab7
  example-11: e39b758ad0d7aa62
  create-poll: b2a11ae34ce22151
  params-9: 3e592c12f9cbb757
  example-12: f5d6029049637276
  show-poll: 2e7a14ac23eeffa6
  example-13: 1a5acf0b8a6f62f2
  list-polls: 606f27566d6d5f98
  params-10: 1b1a6f003f91eb9a
  example-14: 710a82f6b2203f48
  edit-poll: 42b85770aebd8ef2
  params-11: 52d278a2f38d6a9f
  example-15: 8f7d523fc36f5da7
  soft-delete-poll: 0f1b24e1263dcfbe
  example-16: ec71cfcd4a0b98ab
  list-memberships: 82712683aa3a424a
  params-12: d2fc821e97d53145
  example-17: 266443e0eb35078c
  manage-memberships: 3c821029101515ad
  params-13: 249b307203206387
  example-18: ffd950cd7ab5aaec
generated:
  introduction: 4c4a0b8e5b5435b4
  authentication-change: 74ca4d37ec506383
  response-size-and-related-records: 025d6a81ce148d35
  endpoint-summary: 748eddf28cc29c84
  groups: '0778b0182dde2603'
  list-groups: 7a0805ab1d4ef799
  get-a-group: 414459e7cdd9a431
  webhooks: e38ab983943851ed
  list-webhooks: bf4b7ddc153ca21c
  create-a-webhook: 0d38d46e975b9f85
  update-a-webhook: 06aafb817d52a88b
  test-a-webhook-destination: 174be6e412c48b41
  delete-a-webhook: 455dc1ea7e558c87
  event-types: 6020709e52bb8837
  http-delivery: 037c731e37c8ea10
  payload-formats: 04e7e6af2c9956b6
  search: 87ba55be2afbf4ab
  params: 4bb6c41c7c4e708a
  participation-report: 7c3569e86fd71616
  params-2: b56c6cdff81edbb1
  example: c6b796e636eaedd5
  create-discussion: 999eda8ad032288c
  params-3: bef08720b6e874ef
  example-2: a91b97e9c6856427
  show-discussion: b5440bcea424fb86
  example-3: c1bb4a084fb56a59
  list-discussions: 52a739890047d43e
  params-4: d14ce258f32b23fe
  example-4: 86c31825c210cd71
  list-threads: dec841af44696593
  params-5: 7fc47d5558afb203
  example-5: 03fa4195098dbb12
  read-thread: 86a6c3a7258fc5a0
  example-6: 4f19e6dfcfba126e
  edit-discussion: 68c1ed19a03c50e2
  params-6: b99bbf234e223e89
  example-7: b3cbea7afe0f8d1b
  soft-delete-discussion: eb2e4288e9d93def
  example-8: ef6233e30ff79950
  create-comment: 00d5b41d4459885d
  params-7: 2dd6dc084636b7ad
  example-9: 88e52636b290826b
  edit-comment: f426677f627854b2
  params-8: d73d38ec6349580b
  example-10: cf7b2699b3a249d9
  soft-delete-comment: f73bec54941b5de9
  example-11: ef9178ca5d82d87e
  create-poll: b34697eab8430c24
  params-9: 2cd0b988792151d7
  example-12: 62c765fc9d73ab6c
  show-poll: a9a2a08cd0508e9e
  example-13: d63c44af5cda4d9b
  list-polls: 94e38fcf1a33d258
  params-10: b90a3a22edbd9c72
  example-14: 6b8f2caddb4d1b9b
  edit-poll: fd6ab49cbe1d19f1
  params-11: 03e69e4b6c81332b
  example-15: 23d947830ff3be47
  soft-delete-poll: 46283d67095270ed
  example-16: 1916a12dd3857760
  list-memberships: 90d91bcfc653e8bd
  params-12: d9053838f3d1a80f
  example-17: 42ee1f7e11fb590c
  manage-memberships: 945a6ff35cac7fd0
  params-13: a436598cb25482d9
  example-18: 6134c9125b633cef
title_source: c23fb6526b722360
title_generated: 7133c3ebccc01f8b
needs_review:
  params: use "conclusão" instead of "resultado" for "outcome"
---

<!-- translation-section: introduction -->

# Documentação da API do usuário do Loomio

<!-- seo-description: Use a API do usuário do Loomio para criar e gerenciar discussões, comentários, enquetes, conversas e vínculos de membros com grupos a partir de outros softwares. -->

`/api/b2` é a API voltada ao usuário para integrações com o Loomio. Ela usa a chave de API de uma conta de usuário, e todas as ações são realizadas em nome desse usuário.

As operações em grupos usam os vínculos de membro e as permissões de grupo do usuário da chave de API. Ser administrador da instância não amplia o acesso de uma chave de API a grupos ou conteúdo; use a API do servidor para administrar a instância.

Use a chave de API da conta de usuário do Loomio que realizará as ações. Uma conta dedicada de bot é útil quando uma integração não deve receber convites para enquetes nem notificações.

Usuários conectados podem encontrar sua chave de API e os IDs dos grupos na [página de acesso à API](/profile/api_access).

Envie a chave de API em um cabeçalho `Authorization: Bearer`. Chaves de API em parâmetros de consulta são rejeitadas porque as URLs podem ser registradas por proxies e logs de acesso.

<!-- translation-section: authentication-change -->

### Mudança na autenticação

Antes, a chave de API era aceita como um parâmetro de URL `api_key`. Requisições que usam `?api_key=YOUR_API_KEY` não funcionam mais. Use o cabeçalho HTTP `Authorization`:

```text
Authorization: Bearer YOUR_API_KEY
```

Os exemplos usam `YOUR_API_KEY`, o ID de grupo `123` e `https://www.loomio.com/`. Substitua esses valores pela sua chave de API, pelo ID do seu grupo e pela URL da sua instalação do Loomio.

<!-- translation-section: response-size-and-related-records -->

## Tamanho da resposta e registros relacionados

As respostas da API do usuário usam um formato composto: os registros principais são acompanhados de registros relacionados, como conversas, grupos, usuários, enquetes e reações. Isso permite que um cliente preencha um armazenamento local de registros com uma única requisição, mas pode incluir mais dados do que uma integração simples precisa.

Passe `compact=1` para omitir registros relacionados volumosos de conversas, grupos, grupos principais, vínculos de membros, reações, tags e traduções. Os registros principais e os registros relacionados necessários para interpretar seu conteúdo permanecem na resposta.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads/123/items?compact=1'
```

Para controlar diretamente as exclusões, passe `exclude_types` com os tipos de registro no singular, separados por espaços. Por exemplo, `exclude_types=group reaction` omite grupos e reações relacionados. Os valores comuns são `topic`, `group`, `parent`, `membership`, `reaction`, `tag`, `translation`, `user`, `discussion`, `poll`, `poll_option`, `stance`, `stance_choice`, `outcome` e `topic_item`. As exclusões se aplicam aos registros relacionados, não ao recurso principal solicitado pelo endpoint.

As respostas de coleções incluem `meta.total` quando um tamanho exato da coleção é definido. O total é calculado antes da aplicação de `limit` e `offset`. Endpoints como o de busca, que retornam intencionalmente um conjunto limitado de resultados, omitem `meta.total` em vez de retornar `null`.

<!-- translation-section: endpoint-summary -->

## Resumo dos endpoints

| Método | Endpoint | Finalidade |
| --- | --- | --- |
| `GET` | `/api/b2/groups` | Listar os grupos do usuário da chave de API |
| `GET` | `/api/b2/groups/:id_or_key_or_handle` | Obter um grupo visível |
| `GET` | `/api/b2/reports` | Gerar um relatório de participação |
| `GET` | `/api/b2/search` | Buscar discussões, comentários, enquetes, votos e conclusões visíveis |
| `POST` | `/api/b2/discussions` | Criar uma discussão |
| `GET` | `/api/b2/discussions/:id` | Obter uma discussão |
| `GET` | `/api/b2/discussions` | Listar discussões em um grupo |
| `PATCH` | `/api/b2/discussions/:id` | Editar uma discussão |
| `DELETE` | `/api/b2/discussions/:id` | Excluir uma discussão sem apagar seu registro |
| `GET` | `/api/b2/threads` | Listar conversas visíveis de discussão e de enquete independente |
| `GET` | `/api/b2/threads/:topic_id` | Obter uma conversa |
| `GET` | `/api/b2/threads/:topic_id/items` | Obter os itens ordenados de uma conversa |
| `GET` | `/api/b2/threads/:topic_id/markdown` | Obter uma conversa completa em Markdown |
| `POST` | `/api/b2/comments` | Criar um comentário ou uma resposta |
| `PATCH` | `/api/b2/comments/:id` | Editar um comentário |
| `DELETE` | `/api/b2/comments/:id` | Excluir um comentário sem apagar seu registro |
| `POST` | `/api/b2/polls` | Criar uma enquete |
| `GET` | `/api/b2/polls/:id` | Obter uma enquete |
| `GET` | `/api/b2/polls` | Listar enquetes em um grupo |
| `PATCH` | `/api/b2/polls/:id` | Editar uma enquete |
| `DELETE` | `/api/b2/polls/:id` | Excluir uma enquete sem apagar seu registro |
| `GET` | `/api/b2/memberships` | Listar os vínculos de membros de um grupo |
| `POST` | `/api/b2/memberships` | Adicionar membros e, opcionalmente, remover membros ausentes da lista |
| `GET` | `/api/b2/chatbots` | Listar as integrações de bate-papo e os webhooks de um grupo |
| `POST` | `/api/b2/chatbots` | Criar uma integração de bate-papo ou um webhook |
| `PATCH` | `/api/b2/chatbots/:id` | Atualizar uma integração de bate-papo ou um webhook |
| `DELETE` | `/api/b2/chatbots/:id` | Excluir uma integração de bate-papo ou um webhook |
| `POST` | `/api/b2/chatbots/check` | Enviar um teste de conexão de webhook |

<!-- translation-section: groups -->

## Grupos

<!-- translation-section: list-groups -->

### Listar grupos

Retorna os grupos nos quais o usuário da chave de API tem um vínculo de membro ativo.

`GET /api/b2/groups`

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups
```

A resposta contém todos os registros correspondentes em um array `groups` sem paginação. Inclui grupos principais e subgrupos, inclusive grupos cuja assinatura não está ativa no momento. Verifique o campo `enabled` quando uma integração deve operar apenas em grupos habilitados.

Os principais campos de grupo incluem:

| Campo | Descrição |
| --- | --- |
| `id` | ID numérico do grupo usado por outros endpoints da API do usuário |
| `key` | Chave curta e estável usada nas URLs do Loomio |
| `handle` | Identificador legível do grupo |
| `name` | Nome do grupo |
| `full_name` | Nome do grupo incluindo o contexto do grupo principal |
| `parent_id` | ID numérico do grupo principal de um subgrupo; caso contrário, `null` |
| `enabled` | Indica se o grupo e sua assinatura estão ativos |
| `memberships_count` | Número de vínculos de membros ativos e pendentes |
| `accepted_memberships_count` | Número de vínculos de membros aceitos |
| `pending_memberships_count` | Número de convites pendentes |
| `admin_memberships_count` | Número de administradores do grupo |
| `delegates_count` | Número de delegados |
| `discussions_count` | Número de discussões diretamente no grupo |
| `polls_count` | Número de enquetes diretamente no grupo |
| `subgroups_count` | Número de subgrupos |

A resposta pode incluir configurações adicionais do grupo, registros relacionados do grupo principal e os vínculos de membro do usuário da API. Os clientes devem ignorar os campos que não usam.

<!-- translation-section: get-a-group -->

### Obter um grupo

Retorna um grupo visível ao usuário da chave de API.

`GET /api/b2/groups/:id_or_key_or_handle`

O identificador pode ser o ID numérico, a chave ou o identificador legível do grupo.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/123
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/example-group
```

A resposta contém o grupo no array `groups` e usa os mesmos campos do endpoint de listagem. Uma requisição para um grupo ao qual o usuário da chave de API não tem acesso retorna um erro de permissão.

<!-- translation-section: webhooks -->

## Webhooks

A API do usuário funciona por requisições: uma integração chama o Loomio quando precisa ler ou alterar dados. Um webhook de grupo permite o envio no sentido inverso. O Loomio envia os eventos selecionados do grupo ao seu endpoint assim que acontecem, para que a integração não precise consultar periodicamente a API REST em busca de alterações.

Os webhooks são configurados por grupo e exigem permissão de administrador do grupo. Você pode gerenciá-los pela interface do Loomio:

1. Abra o grupo.
2. Abra o menu do grupo e selecione **Integrações de bate-papo**.
3. Adicione a integração correspondente ao formato de payload que seu endpoint aceita. Para um endpoint de uso geral, use o formato Mattermost/Markdown.
4. Informe um nome e a URL de destino.
5. Selecione os eventos que o Loomio deve enviar automaticamente.
6. Salve a integração e use **Conexão de teste** para enviar uma mensagem de teste.

Use um destino HTTPS com uma URL que não possa ser adivinhada. O Loomio exige que o destino seja resolvido para um endereço público e bloqueia requisições para endereços de rede locais ou privados.

Agentes e outras integrações também podem gerenciar webhooks pelos endpoints de chatbot com autenticação Bearer descritos abaixo. O recurso se chama `chatbots` por compatibilidade com as integrações de bate-papo do Loomio, mas também representa webhooks de saída de uso geral.

<!-- translation-section: list-webhooks -->

### Listar webhooks

Retorna as integrações de bate-papo configuradas para um grupo. O usuário da chave de API deve ser administrador desse grupo. A resposta inclui URLs de destino, por isso não deve ser exposta aos membros comuns do grupo.

`GET /api/b2/chatbots?group_id=123`

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/chatbots?group_id=123'
```

A resposta contém um array `chatbots` com estes campos:

| Campo | Descrição |
| --- | --- |
| `id` | ID da integração usado para atualizações e exclusão |
| `group_id` | Grupo que recebe os eventos |
| `name` | Nome administrativo da integração |
| `kind` | `webhook` para um webhook de saída ou `matrix` para uma integração com o Matrix |
| `webhook_kind` | Formato do payload: `markdown`, `slack`, `discord`, `microsoft` ou `webex` |
| `server` | URL de destino |
| `event_kinds` | Eventos enviados automaticamente |
| `notification_only` | Indica se as mensagens contêm apenas o título da notificação |

<!-- translation-section: create-a-webhook -->

### Criar um webhook

`POST /api/b2/chatbots`

```bash
curl -X POST \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{
    "group_id": 123,
    "name": "Planning system",
    "kind": "webhook",
    "webhook_kind": "markdown",
    "server": "https://hooks.example.org/loomio/unguessable-token",
    "event_kinds": ["new_discussion", "new_comment", "poll_created", "outcome_created"],
    "notification_only": false
  }' \
  https://www.loomio.com/api/b2/chatbots
```

O usuário da chave de API deve ser administrador de `group_id`. O destino é validado como uma URL pública antes de ser salvo.

<!-- translation-section: update-a-webhook -->

### Atualizar um webhook

`PATCH /api/b2/chatbots/:id`

Envie os campos que devem mudar. O webhook não pode ser transferido para outro grupo por meio da alteração de `group_id`.

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"name":"Planning events","event_kinds":["new_discussion","outcome_created"]}' \
  https://www.loomio.com/api/b2/chatbots/456
```

<!-- translation-section: test-a-webhook-destination -->

### Testar um destino de webhook

Envie uma mensagem de teste compatível com Markdown para um destino antes ou depois de salvar sua configuração.

`POST /api/b2/chatbots/check`

```bash
curl -X POST \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"group_id":123,"server":"https://hooks.example.org/loomio/unguessable-token"}' \
  https://www.loomio.com/api/b2/chatbots/check
```

<!-- translation-section: delete-a-webhook -->

### Excluir um webhook

`DELETE /api/b2/chatbots/:id`

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/chatbots/456
```

Excluir a configuração interrompe os envios futuros. Isso não exclui nenhum conteúdo do grupo no Loomio.

<!-- translation-section: event-types -->

### Tipos de evento

Um webhook pode se inscrever nestes tipos de evento:

| Evento | Quando é enviado |
| --- | --- |
| `new_discussion` | Uma discussão é iniciada |
| `discussion_edited` | Uma discussão é editada |
| `new_comment` | Um comentário é criado |
| `poll_created` | Uma enquete é iniciada |
| `poll_edited` | Uma enquete é editada |
| `poll_closing_soon` | Uma enquete está se aproximando do horário de encerramento |
| `poll_expired` | Uma enquete chega ao horário de encerramento |
| `poll_closed_by_user` | Uma pessoa encerra uma enquete manualmente |
| `poll_reopened` | Uma enquete é reaberta |
| `outcome_created` | Uma conclusão é publicada |
| `outcome_updated` | Uma conclusão é atualizada |
| `outcome_review_due` | Chega a data de revisão de uma conclusão |
| `stance_created` | Um voto é registrado |
| `stance_updated` | Um voto é alterado |

O webhook pertence a um grupo e recebe os eventos desse grupo nos quais está inscrito. As pessoas também podem selecionar explicitamente a integração ao compartilhar conteúdo ou enviar algumas notificações, mesmo quando o evento automático correspondente não está selecionado.

<!-- translation-section: http-delivery -->

### Envio por HTTP

O Loomio envia uma requisição HTTP `POST` assíncrona para a URL configurada com este cabeçalho:

```text
Content-Type: application/json; charset=utf-8
```

O tempo limite da requisição é de cinco segundos. Uma resposta `2xx`, incluindo `204 No Content`, é considerada bem-sucedida. Os serviços que recebem webhooks devem responder prontamente, processar tarefas mais demoradas de forma assíncrona e aceitar envios duplicados ou fora de ordem.

Atualmente, o Loomio não adiciona uma assinatura ao webhook, um cabeçalho com segredo compartilhado, um ID de evento ou um ID de envio. Trate a URL de destino completa como uma credencial, não a exponha publicamente e inclua na URL um token que não possa ser adivinhado quando o serviço receptor permitir. Se você precisar de um esquema de eventos estável e legível por máquina ou de envios assinados, use o webhook como uma notificação de alteração e obtenha os registros atuais pela API do usuário autenticada.

<!-- translation-section: payload-formats -->

### Formatos de payload

Os payloads dos webhooks são mensagens formatadas para exibição em serviços de bate-papo. Eles não são registros completos e serializados do Loomio. Os links na mensagem identificam o conteúdo afetado no Loomio; uma integração pode consultar a API do usuário quando precisar do estado atual em formato estruturado.

| Formato de integração | Principais campos JSON |
| --- | --- |
| Mattermost/Markdown | `text`, `icon_url`, `username` |
| Slack | `text` |
| Discord | `content`, limitado a aproximadamente 1.900 caracteres |
| Microsoft Teams | `@type`, `@context`, `themeColor`, `text`, `sections` |
| Webex | `markdown` |

Por exemplo, o formato Markdown geral envia um corpo com esta estrutura:

```json
{
  "text": "Ada started a discussion: [Quarterly planning](https://example.loomio.org/d/example)",
  "icon_url": "https://example.loomio.org/path/to/group-logo.png",
  "username": "Loomio"
}
```

O texto exato da mensagem depende do evento, do idioma do grupo, da configuração de envio apenas da notificação e da versão do Loomio. Os serviços receptores devem usar os campos de nível superior documentados para o formato selecionado, em vez de analisar a redação das frases.

<!-- translation-section: search -->

## Busca

Busque discussões, comentários, enquetes, votos e conclusões visíveis para o usuário da chave de API. Os resultados incluem conteúdo público mesmo quando o usuário não é membro do grupo ao qual o conteúdo pertence; o conteúdo privado continua sujeito às regras normais de visibilidade da conversa.

`GET /api/b2/search`

<!-- translation-section: params -->

### Parâmetros

| Nome | Descrição |
| --- | --- |
| `query` | Texto de busca. São aceitas correspondências exatas e aproximadas |
| `group_id` | Restrinja os resultados a um grupo visível |
| `org_id` | Restrinja os resultados a um grupo principal visível e seus subgrupos visíveis. Use `0` para discussões diretas |
| `type` | Restrinja os resultados a um tipo: `Discussion`, `Comment`, `Poll`, `Stance` ou `Outcome` (conclusão) |
| `types` | Lista de tipos de resultados separados por vírgulas |
| `tag` | Restrinja os resultados a tópicos com esta tag |
| `author_id` | Restrinja os resultados ao conteúdo de um autor. Sem `query`, retorna a atividade recente visível desse autor |
| `order` | Defina como `authored_at_desc` para ordenar o conteúdo correspondente pela data e hora de criação |

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/search?query=quarterly+planning&type=Discussion'
```

A resposta contém um array `search_results`. Cada resultado identifica o registro correspondente e seu contexto visível com campos que incluem `searchable_type`, `searchable_id`, `highlight`, `group_id`, `group_name`, `discussion_key`, `poll_key`, `author_id`, `author_name`, `authored_at` e `tags`. Os campos que não se aplicam a um resultado são `null`.

<!-- translation-section: participation-report -->

## Relatório de participação

Retorna os mesmos dados agregados de participação usados pelo Relatório de participação do Loomio.

`GET /api/b2/reports`

<!-- translation-section: params-2 -->

### Parâmetros

| Nome | Descrição |
| --- | --- |
| `section` | Seção do relatório: `base`, `users` ou `countries`. Use `users` para a atividade por pessoa |
| `group_scope` | `custom` ou `my`. O valor legado `all` é tratado como `my` porque as chaves da API do usuário nunca recebem acesso a toda a instância |
| `group_ids` | IDs de grupos separados por vírgulas quando `group_scope=custom`. IDs de grupos dos quais o usuário da API não é membro são ignorados |
| `start_month` | Primeiro mês a incluir, no formato `YYYY-MM`; o padrão é 12 meses atrás |
| `end_month` | Último mês a incluir, no formato `YYYY-MM`; o padrão é o mês atual |
| `interval` | Intervalo para a seção `base`: `day`, `week`, `month` ou `year` |
| `member_type` | Defina como `delegate` com `section=users` para retornar apenas os delegados atuais |

Uma pessoa é delegada quando tem um vínculo ativo como membro delegado em qualquer grupo selecionado. Suas contagens são agregadas em todos os grupos selecionados. As linhas dos delegados são retornadas mesmo quando todas as contagens de atividade são zero. As contagens abrangem conversas, comentários, enquetes, votos, conclusões e reações; elas não são taxas de participação na votação. As linhas dos usuários também incluem cédulas de votação identificadas emitidas, utilizadas e não utilizadas. As enquetes anônimas são excluídas de todas as contagens de votação por pessoa. `all_votes_cast` é verdadeiro somente quando pelo menos uma cédula foi emitida e todas as cédulas emitidas foram utilizadas.

A API aplica as mesmas regras de visibilidade dos grupos que o relatório disponível no aplicativo. Uma chave da API do usuário não pode expor dados de relatório de grupos aos quais esse usuário não tem acesso.

<!-- translation-section: example -->

### Exemplo

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/reports?section=users&group_scope=custom&group_ids=123&member_type=delegate&start_month=2026-01&end_month=2026-09'
```

O array `users` contém linhas completas de atividade:

```json
{
  "users": [
    {
      "id": 456,
      "name": "Ada Lovelace",
      "country": "NZ",
      "delegate": true,
      "threads": 2,
      "comments": 8,
      "polls": 1,
      "votes": 5,
      "votes_cast": 5,
      "votes_issued": 6,
      "votes_missed": 1,
      "all_votes_cast": false,
      "outcomes": 1,
      "reactions": 4
    }
  ]
}
```

<!-- translation-section: create-discussion -->

## Criar discussão

Crie uma discussão como o usuário da chave de API.

`POST /api/b2/discussions`

<!-- translation-section: params-3 -->

### Parâmetros

| Nome | Descrição |
| --- | --- |
| `group_id` | Grupo em que a conversa será criada |
| `title` | Título da conversa, obrigatório |
| `description` | Contexto da conversa, opcional |
| `description_format` | `md` ou `html`, opcional, padrão `md` |
| `recipient_audience` | `group` ou null. Se for `group`, todo o grupo será notificado sobre a nova conversa |
| `recipient_user_ids` | Array de IDs de usuários a notificar ou convidar para a conversa |
| `recipient_emails` | Array de endereços de e-mail de pessoas a convidar para a conversa |
| `recipient_message` | Mensagem a incluir no convite por e-mail |

<!-- translation-section: example-2 -->

### Exemplo

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example thread", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/discussions
```

<!-- translation-section: show-discussion -->

## Exibir discussão

Obtenha uma discussão usando seu ID, um número inteiro, ou sua chave, uma string.

`GET /api/b2/discussions/:id`

<!-- translation-section: example-3 -->

### Exemplo

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/discussions/abc123
```

<!-- translation-section: list-discussions -->

## Listar discussões

Liste as discussões de um grupo visíveis ao usuário da chave de API. Em um grupo publicamente visível, uma pessoa que não é membro pode listar as discussões públicas; as discussões privadas permanecem restritas aos usuários que podem lê-las no Loomio.

`GET /api/b2/discussions`

<!-- translation-section: params-4 -->

### Parâmetros

| Nome | Descrição |
| --- | --- |
| `group_id` | Número inteiro, obrigatório. ID do grupo cujas discussões serão listadas |
| `status` | String, opcional, padrão `open`. Valores: `open`, `closed`, `all` |
| `limit` | Número inteiro, opcional, padrão 50. Tamanho da página |
| `offset` | Número inteiro, opcional, padrão 0. Deslocamento para paginação |

Compatibilidade com versões anteriores: `per` e `from` são aceitos como aliases de `limit` e `offset` e continuarão funcionando.

<!-- translation-section: example-4 -->

### Exemplo

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/discussions?group_id=123'
```

<!-- translation-section: list-threads -->

## Listar conversas

Liste as conversas de discussão e de enquete visíveis ao usuário da chave de API, ordenadas pela atividade mais recente. O ID de uma conversa é seu `topic_id`.

`GET /api/b2/threads`

<!-- translation-section: params-5 -->

### Parâmetros

| Nome | Descrição |
| --- | --- |
| `limit` | Número inteiro, opcional, padrão 50. Tamanho da página |
| `offset` | Número inteiro, opcional, padrão 0. Deslocamento para paginação |

<!-- translation-section: example-5 -->

### Exemplo

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads?limit=50&offset=0'
```

<!-- translation-section: read-thread -->

## Ler conversa

Leia uma conversa, seu fluxo ordenado de eventos ou seu documento Markdown completo com o conteúdo visível.

`GET /api/b2/threads/:topic_id`

`GET /api/b2/threads/:topic_id/items`

`GET /api/b2/threads/:topic_id/markdown`

<!-- translation-section: example-6 -->

### Exemplo

```text
GET https://www.loomio.com/api/b2/threads/<topic_id>
GET https://www.loomio.com/api/b2/threads/<topic_id>/items
GET https://www.loomio.com/api/b2/threads/<topic_id>/markdown
```

O endpoint `items` retorna o fluxo ordenado de eventos, incluindo comentários, enquetes, votos e conclusões visíveis. O endpoint `markdown` retorna todo o conteúdo visível da conversa em um único documento Markdown. Os motivos dos votos são incluídos apenas quando estão visíveis ao usuário da chave de API.

Todos os endpoints de conversas aplicam as mesmas permissões da interface do Loomio. A chave de API não concede acesso a uma conversa que o usuário normalmente não pode abrir.

<!-- translation-section: edit-discussion -->

## Editar discussão

Edite uma discussão como o usuário da chave de API. As mesmas permissões do Loomio se aplicam: o usuário deve ter permissão para editar essa discussão.

`PATCH /api/b2/discussions/:id`

<!-- translation-section: params-6 -->

### Parâmetros

| Nome | Descrição |
| --- | --- |
| `title` | Título atualizado |
| `description` | Contexto atualizado |
| `description_format` | `md` ou `html`, opcional, padrão `md` |
| `recipient_audience` | `group` ou null. Se for `group`, todo o grupo será notificado sobre a edição |
| `recipient_user_ids` | Array de IDs de usuários a notificar ou convidar para a conversa |
| `recipient_emails` | Array de endereços de e-mail de pessoas a convidar para a conversa |
| `recipient_message` | Mensagem a incluir no convite por e-mail |

<!-- translation-section: example-7 -->

### Exemplo

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated thread title", "description":"updated context", "description_format":"md"}' https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: soft-delete-discussion -->

## Excluir discussão logicamente

Exclua uma discussão logicamente como o usuário da chave de API. Isso descarta a discussão e mantém seu registro.

`DELETE /api/b2/discussions/:id`

<!-- translation-section: example-8 -->

### Exemplo

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: create-comment -->

## Criar comentário

Crie um comentário em uma discussão como o usuário da chave de API.

`POST /api/b2/comments`

<!-- translation-section: params-7 -->

### Parâmetros

| Nome | Descrição |
| --- | --- |
| `discussion_id` | Inteiro, obrigatório. ID da discussão na qual comentar |
| `body` | Corpo do comentário, obrigatório, exceto quando um anexo é fornecido |
| `body_format` | `md` ou `html`, opcional, padrão `md` |

<!-- translation-section: example-9 -->

### Exemplo

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"discussion_id": 123, "body":"example comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments
```

<!-- translation-section: edit-comment -->

## Editar comentário

Edite um comentário como o usuário da chave de API. As mesmas permissões do Loomio se aplicam: o usuário deve ter permissão para editar esse comentário.

`PATCH /api/b2/comments/:id`

<!-- translation-section: params-8 -->

### Parâmetros

| Nome | Descrição |
| --- | --- |
| `body` | Corpo atualizado do comentário |
| `body_format` | `md` ou `html`, opcional, padrão `md` |

<!-- translation-section: example-10 -->

### Exemplo

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"body":"updated comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments/123
```

<!-- translation-section: soft-delete-comment -->

## Excluir comentário logicamente

Exclua um comentário logicamente como o usuário da chave de API. Isso descarta o comentário, oculta seu corpo e mantém seu registro.

`DELETE /api/b2/comments/:id`

<!-- translation-section: example-11 -->

### Exemplo

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/comments/123
```

<!-- translation-section: create-poll -->

## Criar enquete

Crie uma enquete como o usuário da chave de API.

`POST /api/b2/polls`

<!-- translation-section: params-9 -->

### Parâmetros

| Nome | Descrição |
| --- | --- |
| `group_id` | Inteiro, opcional, padrão null. ID do grupo da enquete. Se `discussion_id` for informado, `group_id` será ignorado |
| `discussion_id` | Inteiro, opcional, padrão null. ID da conversa de discussão à qual adicionar esta enquete |
| `title` | String, obrigatória. Título da enquete |
| `poll_type` | String, obrigatória. Valores: `proposal`, `poll`, `count`, `score`, `ranked_choice`, `meeting`, `dot_vote` |
| `details` | String, opcional. Texto do corpo da enquete |
| `details_format` | String, opcional, padrão `md`. Valores: `md` ou `html` |
| `options` | Array de strings. Se `poll_type` for `proposal`, os valores válidos são `agree`, `disagree`, `abstain`, `block`. Se `poll_type` for `meeting`, forneça strings de data ou de data e hora no formato ISO 8601. Para todos os outros tipos de enquete, qualquer string é válida |
| `closing_at` | String no formato ISO 8601 ou null, padrão null. Exemplo: `2026-09-01T12:00:00Z`. Se for null, a votação será desativada e a enquete será considerada em elaboração |
| `specified_voters_only` | Booleano, opcional, padrão false. Se for true, apenas as pessoas especificadas poderão votar. Se for false, todas as pessoas do grupo serão convidadas a votar |
| `hide_results` | String, opcional, padrão `off`. Valores: `off`, `until_vote`, `until_closed` |
| `shuffle_options` | Booleano, padrão false. Exibe as opções aos eleitores em ordem aleatória |
| `anonymous` | Booleano, opcional, padrão false. Oculta a identidade dos eleitores |
| `recipient_audience` | `group` ou null, opcional, padrão null. Se for `group`, todo o grupo será notificado |
| `notify_on_closing_soon` | String, opcional, padrão `nobody`. Valores: `nobody`, `author`, `undecided_voters`, `voters` |
| `recipient_user_ids` | Array de IDs de usuários a notificar ou convidar |
| `recipient_emails` | Array de endereços de email de pessoas a convidar para votar |
| `recipient_message` | Mensagem a incluir no convite por email |
| `notify_recipients` | Booleano, padrão false. Se for false, adiciona pessoas sem enviar notificações. Se for true, todas as pessoas convidadas nesta requisição receberão uma notificação por email |

<!-- translation-section: example-12 -->

### Exemplo

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example poll", "poll_type": "proposal", "options": ["agree", "disagree"], "closing_at": "2026-09-01T12:00:00Z", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/polls
```

<!-- translation-section: show-poll -->

## Consultar enquete

Obtenha uma enquete usando seu ID, um inteiro, ou sua chave, uma string.

`GET /api/b2/polls/:id`

<!-- translation-section: example-13 -->

### Exemplo

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/polls/abc123
```

<!-- translation-section: list-polls -->

## Listar enquetes

Liste as enquetes de um grupo visíveis ao usuário da chave de API. Em um grupo com visibilidade pública, uma pessoa que não seja membro pode listar suas enquetes públicas; as enquetes privadas permanecem restritas aos usuários que podem lê-las no Loomio. A resposta inclui a conclusão atual de cada enquete visível, então você pode usar `status=closed` para listar propostas já decididas.

`GET /api/b2/polls`

<!-- translation-section: params-10 -->

### Parâmetros

| Nome | Descrição |
| --- | --- |
| `group_id` | Inteiro, obrigatório. ID do grupo cujas enquetes serão listadas |
| `status` | String, opcional, padrão `active`. Valores: `active`, `closed`, `all` |
| `limit` | Inteiro, opcional, padrão 50. Tamanho da página |
| `offset` | Inteiro, opcional, padrão 0. Deslocamento para paginação |

Compatibilidade com versões anteriores: `per` e `from` são aceitos como aliases de `limit` e `offset` e continuarão funcionando.

<!-- translation-section: example-14 -->

### Exemplo

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/polls?group_id=123'
```

<!-- translation-section: edit-poll -->

## Editar enquete

Edite uma enquete como o usuário da chave de API. Aplicam-se as mesmas permissões do Loomio: o usuário deve ter permissão para editar essa enquete.

`PATCH /api/b2/polls/:id`

<!-- translation-section: params-11 -->

### Parâmetros

| Nome | Descrição |
| --- | --- |
| `title` | Título atualizado |
| `details` | Detalhes atualizados da enquete |
| `details_format` | `md` ou `html`, opcional, padrão `md` |
| `options` | Nomes atualizados das opções. Alterar as opções pode afetar os votos existentes, dependendo do estado da enquete |
| `closing_at` | String no formato ISO 8601 ou null |
| `recipient_audience` | `group` ou null. Se for `group`, todo o grupo será notificado |
| `recipient_user_ids` | Array de IDs de usuários a notificar ou convidar |
| `recipient_emails` | Array de endereços de email de pessoas a convidar para votar |
| `recipient_message` | Mensagem a incluir no convite por email |

<!-- translation-section: example-15 -->

### Exemplo

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated poll title", "details":"updated details", "details_format":"md"}' https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: soft-delete-poll -->

## Excluir enquete logicamente

Exclua uma enquete logicamente como o usuário da chave de API. Isso descarta a enquete e mantém seu registro armazenado.

`DELETE /api/b2/polls/:id`

<!-- translation-section: example-16 -->

### Exemplo

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: list-memberships -->

## Listar vínculos de membros

Liste os vínculos de membros visíveis ao usuário da chave de API. Os membros do grupo podem consultar nomes, IDs, títulos e funções dos membros. Os endereços de e-mail são incluídos apenas para a própria conta do usuário da chave de API ou quando esse usuário é administrador do grupo.

`GET /api/b2/memberships`

<!-- translation-section: params-12 -->

### Parâmetros

| Nome | Descrição |
| --- | --- |
| `group_id` | Inteiro, obrigatório. ID do grupo cujos vínculos de membros serão listados |

<!-- translation-section: example-17 -->

### Exemplo

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/memberships?group_id=123'
```

<!-- translation-section: manage-memberships -->

## Gerenciar vínculos de membros

Envie uma lista de endereços de e-mail. Todos os novos endereços de e-mail receberão um convite para o grupo. Ao contrário da listagem de vínculos de membros, esta operação exige permissão de administrador do grupo.

`POST /api/b2/memberships`

<!-- translation-section: params-13 -->

### Parâmetros

| Nome | Descrição |
| --- | --- |
| `group_id` | Inteiro, obrigatório. ID do grupo cujos vínculos de membros serão gerenciados |
| `emails` | Array de strings, obrigatório. Endereços de e-mail das pessoas a convidar para o grupo |
| `remove_absent` | Booleano. Se verdadeiro, remove do grupo qualquer pessoa cujo e-mail não esteja na lista |

<!-- translation-section: example-18 -->

### Exemplo

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"]}' https://www.loomio.com/api/b2/memberships
```

Se você passar `remove_absent=1`, todos os membros do grupo que não estiverem na lista serão removidos do grupo. Tenha cuidado: você pode remover todas as pessoas do seu grupo.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"], "remove_absent": 1}' https://www.loomio.com/api/b2/memberships
```

Isso retorna um objeto com `{added_emails: ["person@added.com"], removed_emails: ["person@removed.com"]}`.
