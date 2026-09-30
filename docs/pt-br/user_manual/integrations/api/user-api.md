---
title: API do usuário
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/integrations/api/user-api.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-30'
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
  introduction: ecc3aa09f5d22ed1
  authentication-change: ff58cf965716b7fd
  response-size-and-related-records: 8b35de3ad726fd46
  endpoint-summary: 8bb5309cdc55cd59
  groups: '0778b0182dde2603'
  list-groups: c2c7b3531e09ef5b
  get-a-group: 63acddef8178bfec
  webhooks: 9ffb578cd110ec00
  list-webhooks: 8b414f20aa723728
  create-a-webhook: 424e43ed58d0083f
  update-a-webhook: d5c23efb75b8125e
  test-a-webhook-destination: ca3bde551d1a05b7
  delete-a-webhook: fea1c8ad102146a7
  event-types: 4a2925e896b6e9b7
  http-delivery: 529524654cc8d93d
  payload-formats: 28a9e23fdf3f2795
  search: 979485039cd32651
  params: 43e43a5ef84cb1d8
  participation-report: c31a5b3479d713f0
  params-2: b1ed776c4ee330b4
  example: 4d23a7b65e5ecbbd
  create-discussion: cc860ce2a66575f4
  params-3: '078b2d5a65573c77'
  example-2: a91b97e9c6856427
  show-discussion: 3685abca04e2b9dd
  example-3: c1bb4a084fb56a59
  list-discussions: 3c8790ab24476cca
  params-4: 837710448c4c10b0
  example-4: 86c31825c210cd71
  list-threads: 71cf2096e77f7552
  params-5: 7fc47d5558afb203
  example-5: 03fa4195098dbb12
  read-thread: dc4e40dbdfcfc880
  example-6: 0e2a164e114b2fec
  edit-discussion: b2422d273b4f9e03
  params-6: ec015e50bb107e86
  example-7: b3cbea7afe0f8d1b
  soft-delete-discussion: 2e8d43db29866732
  example-8: ef6233e30ff79950
  create-comment: 7fdf27b96d0df3f1
  params-7: c628dd658cc2d872
  example-9: 88e52636b290826b
  edit-comment: dea59c5a423ba61f
  params-8: d71aaadd84892187
  example-10: cf7b2699b3a249d9
  soft-delete-comment: 0e1ad09acc8b5043
  example-11: ef9178ca5d82d87e
  create-poll: b34697eab8430c24
  params-9: 31ab38b1d769d74a
  example-12: 62c765fc9d73ab6c
  show-poll: e498ad87faff9e25
  example-13: d63c44af5cda4d9b
  list-polls: ac82f8d84c697bc8
  params-10: 3ded9fb66fa1a4e4
  example-14: 6b8f2caddb4d1b9b
  edit-poll: 507362e5f76970cd
  params-11: e2663692bbb47218
  example-15: 23d947830ff3be47
  soft-delete-poll: 00f617d95a46607f
  example-16: 1916a12dd3857760
  list-memberships: a4002c21446a4f69
  params-12: e278f906808d1260
  example-17: 42ee1f7e11fb590c
  manage-memberships: d0c20f286f24e581
  params-13: 07d335d55503dba1
  example-18: 48b62c3eb3ef0ff5
title_source: c23fb6526b722360
title_generated: 7133c3ebccc01f8b
---

<!-- translation-section: introduction -->

# Documentação da API do usuário do Loomio

<!-- seo-description: Use a API do usuário do Loomio para criar e gerenciar discussões, comentários, enquetes, tópicos e participações em grupos a partir de outros softwares. -->

`/api/b2` é a API voltada a usuários para integrações com o Loomio. Ela usa a chave de API de uma conta de usuário, e todas as ações são realizadas em nome desse usuário.

As operações em grupos seguem as participações e permissões de grupo do usuário da chave de API. Ser administrador da instância não amplia o acesso da chave de API a grupos ou conteúdos. Para administrar a instância, use a API do servidor.

Use a chave de API da conta do Loomio que realizará as ações. Uma conta exclusiva para o bot é útil quando a integração não deve ser convidada para enquetes nem receber notificações.

Após entrar no Loomio, você encontra sua chave de API e os IDs dos grupos na [página de acesso à API](/profile/api_access).

Envie a chave de API no cabeçalho `Authorization: Bearer`. Chaves de API em parâmetros de consulta são rejeitadas porque proxies e registros de acesso podem armazenar URLs.

<!-- translation-section: authentication-change -->

### Alteração na autenticação

Antes, a chave de API era aceita no parâmetro de URL `api_key`. As solicitações com `?api_key=YOUR_API_KEY` não funcionam mais. Use o cabeçalho HTTP `Authorization`:

```text
Authorization: Bearer YOUR_API_KEY
```

Os exemplos usam `YOUR_API_KEY`, o ID de grupo `123` e `https://www.loomio.com/`. Substitua esses valores pela sua chave de API, pelo ID do grupo e pela URL da sua instalação do Loomio.

<!-- translation-section: response-size-and-related-records -->

## Tamanho das respostas e registros relacionados

As respostas da API do usuário têm um formato composto: os registros principais vêm acompanhados de registros relacionados, como tópicos, grupos, usuários, enquetes e reações. Assim, um cliente pode preencher seu armazenamento local de registros com uma única solicitação, embora a resposta possa conter mais dados do que uma integração simples precisa.

Passe `compact=1` para omitir registros relacionados volumosos de tópicos, grupos, grupos superiores, participações, reações, etiquetas e traduções. Os registros principais e os registros relacionados necessários para interpretar seu conteúdo continuam presentes.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads/123/items?compact=1'
```

Para controlar as exclusões diretamente, passe `exclude_types` com tipos de registro no singular separados por espaços. Por exemplo, `exclude_types=group reaction` omite grupos e reações relacionados. Valores comuns são `topic`, `group`, `parent`, `membership`, `reaction`, `tag`, `translation`, `user`, `discussion`, `poll`, `poll_option`, `stance`, `stance_choice`, `outcome` e `topic_item`. As exclusões afetam os registros relacionados, não o recurso principal solicitado ao endpoint.

As respostas de coleções incluem `meta.total` quando é possível determinar o tamanho exato da coleção. O total é calculado antes da aplicação de `limit` e `offset`. Endpoints como o de busca, que retornam intencionalmente um conjunto limitado de resultados, omitem `meta.total` em vez de retornar `null`.

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
| `GET` | `/api/b2/discussions` | Listar discussões de um grupo |
| `PATCH` | `/api/b2/discussions/:id` | Editar uma discussão |
| `DELETE` | `/api/b2/discussions/:id` | Excluir uma discussão sem remover seu registro |
| `GET` | `/api/b2/threads` | Listar tópicos visíveis de discussões e enquetes independentes |
| `GET` | `/api/b2/threads/:topic_id` | Obter um tópico |
| `GET` | `/api/b2/threads/:topic_id/items` | Obter os itens de um tópico em ordem |
| `GET` | `/api/b2/threads/:topic_id/markdown` | Obter um tópico completo em Markdown |
| `POST` | `/api/b2/comments` | Criar um comentário ou uma resposta |
| `PATCH` | `/api/b2/comments/:id` | Editar um comentário |
| `DELETE` | `/api/b2/comments/:id` | Excluir um comentário sem remover seu registro |
| `POST` | `/api/b2/polls` | Criar uma enquete |
| `GET` | `/api/b2/polls/:id` | Obter uma enquete |
| `GET` | `/api/b2/polls` | Listar enquetes de um grupo |
| `PATCH` | `/api/b2/polls/:id` | Editar uma enquete |
| `DELETE` | `/api/b2/polls/:id` | Excluir uma enquete sem remover seu registro |
| `GET` | `/api/b2/memberships` | Listar as participações em um grupo |
| `POST` | `/api/b2/memberships` | Adicionar membros e, opcionalmente, remover os ausentes da lista |
| `GET` | `/api/b2/chatbots` | Listar as integrações de bate-papo e os webhooks de um grupo |
| `POST` | `/api/b2/chatbots` | Criar uma integração de bate-papo ou um webhook |
| `PATCH` | `/api/b2/chatbots/:id` | Atualizar uma integração de bate-papo ou um webhook |
| `DELETE` | `/api/b2/chatbots/:id` | Excluir uma integração de bate-papo ou um webhook |
| `POST` | `/api/b2/chatbots/check` | Enviar um teste de conexão do webhook |

<!-- translation-section: groups -->

## Grupos

<!-- translation-section: list-groups -->

### Listar grupos

Retorna os grupos dos quais o usuário da chave de API é membro ativo.

`GET /api/b2/groups`

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups
```

A resposta contém todos os registros correspondentes em um array `groups` sem paginação. Ela inclui grupos superiores e subgrupos, mesmo quando a assinatura de um grupo não está ativa. Consulte o campo `enabled` se a integração deve operar apenas em grupos ativos.

Os principais campos de grupo são:

| Campo | Descrição |
| --- | --- |
| `id` | ID numérico do grupo usado por outros endpoints da API do usuário |
| `key` | Chave curta e estável usada nas URLs do Loomio |
| `handle` | Identificador legível do grupo |
| `name` | Nome do grupo |
| `full_name` | Nome do grupo com o contexto do grupo superior |
| `parent_id` | ID numérico do grupo superior de um subgrupo; caso contrário, `null` |
| `enabled` | Indica se o grupo e sua assinatura estão ativos |
| `memberships_count` | Número de participações ativas e pendentes |
| `accepted_memberships_count` | Número de participações aceitas |
| `pending_memberships_count` | Número de convites pendentes |
| `admin_memberships_count` | Número de administradores do grupo |
| `delegates_count` | Número de delegados |
| `discussions_count` | Número de discussões diretamente no grupo |
| `polls_count` | Número de enquetes diretamente no grupo |
| `subgroups_count` | Número de subgrupos |

A resposta pode incluir outras configurações do grupo, registros relacionados do grupo superior e as participações do usuário da API. Os clientes devem ignorar os campos que não usam.

<!-- translation-section: get-a-group -->

### Obter um grupo

Retorna um grupo visível para o usuário da chave de API.

`GET /api/b2/groups/:id_or_key_or_handle`

O identificador pode ser o ID numérico, a chave ou o identificador legível do grupo.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/123
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/example-group
```

A resposta contém o grupo no array `groups` e usa os mesmos campos do endpoint de listagem. Uma solicitação para um grupo ao qual o usuário da chave de API não tem acesso retorna um erro de permissão.

<!-- translation-section: webhooks -->

## Webhooks

A API do usuário funciona por solicitação: uma integração chama o Loomio quando precisa ler ou alterar dados. Um webhook de grupo permite o envio no sentido inverso. O Loomio envia os eventos selecionados do grupo ao seu endpoint conforme acontecem, dispensando consultas periódicas à API REST para detectar mudanças.

Os webhooks são configurados por grupo e exigem permissão de administrador do grupo. Você pode gerenciá-los pela interface do Loomio:

1. Abra o grupo.
2. Abra o menu do grupo e selecione **Integrações de bate-papo**.
3. Adicione a integração correspondente ao formato de dados aceito pelo seu endpoint. Para um endpoint de uso geral, use o formato Mattermost/Markdown.
4. Insira um nome e a URL de destino.
5. Selecione os eventos que o Loomio deve enviar automaticamente.
6. Salve a integração e use **Conexão de teste** para enviar uma mensagem de teste.

Use um destino HTTPS com uma URL difícil de adivinhar. O Loomio exige que o destino corresponda a um endereço público e bloqueia solicitações a endereços de redes locais ou privadas.

Agentes e outras integrações também podem gerenciar webhooks pelos endpoints de chatbot autenticados com Bearer descritos abaixo. O recurso se chama `chatbots` por compatibilidade com as integrações de bate-papo do Loomio, mas também representa webhooks de saída em geral.

<!-- translation-section: list-webhooks -->

### Listar webhooks

Retorna as integrações de bate-papo configuradas para um grupo. O usuário da chave de API precisa ser administrador desse grupo. A resposta inclui URLs de destino e, portanto, não deve ser exposta a membros comuns do grupo.

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
| `webhook_kind` | Formato dos dados enviados: `markdown`, `slack`, `discord`, `microsoft` ou `webex` |
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

O usuário da chave de API precisa ser administrador de `group_id`. A URL de destino é validada como pública antes de ser salva.

<!-- translation-section: update-a-webhook -->

### Atualizar um webhook

`PATCH /api/b2/chatbots/:id`

Envie os campos que você deseja alterar. Alterar `group_id` não transfere o webhook para outro grupo.

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"name":"Planning events","event_kinds":["new_discussion","outcome_created"]}' \
  https://www.loomio.com/api/b2/chatbots/456
```

<!-- translation-section: test-a-webhook-destination -->

### Testar o destino de um webhook

Envie uma mensagem de teste compatível com Markdown para o destino antes ou depois de salvar a configuração.

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

Excluir a configuração interrompe os envios futuros. O conteúdo do grupo no Loomio não é excluído.

<!-- translation-section: event-types -->

### Tipos de evento

Um webhook pode receber estes tipos de evento:

| Evento | Quando é enviado |
| --- | --- |
| `new_discussion` | Uma discussão é iniciada |
| `discussion_edited` | Uma discussão é editada |
| `new_comment` | Um comentário é criado |
| `poll_created` | Uma enquete é iniciada |
| `poll_edited` | Uma enquete é editada |
| `poll_closing_soon` | O prazo de encerramento de uma enquete está próximo |
| `poll_expired` | Uma enquete chega ao prazo de encerramento |
| `poll_closed_by_user` | Uma pessoa encerra uma enquete manualmente |
| `poll_reopened` | Uma enquete é reaberta |
| `outcome_created` | Uma conclusão é publicada |
| `outcome_updated` | Uma conclusão é atualizada |
| `outcome_review_due` | Chega o prazo para revisar uma conclusão |
| `stance_created` | Um voto é registrado |
| `stance_updated` | Um voto é alterado |

O webhook pertence a um grupo e recebe os eventos selecionados desse grupo. As pessoas também podem selecionar a integração ao compartilhar conteúdo ou enviar algumas notificações, mesmo que o evento automático correspondente não tenha sido selecionado.

<!-- translation-section: http-delivery -->

### Envio por HTTP

O Loomio envia uma requisição HTTP `POST` assíncrona para a URL configurada com este cabeçalho:

```text
Content-Type: application/json; charset=utf-8
```

O tempo limite da requisição é de cinco segundos. Uma resposta `2xx`, incluindo `204 No Content`, é considerada bem-sucedida. O serviço que recebe o webhook deve responder rapidamente, processar tarefas demoradas de forma assíncrona e aceitar envios duplicados ou fora de ordem.

Atualmente, o Loomio não adiciona assinatura ao webhook, cabeçalho com segredo compartilhado, ID de evento nem ID de envio. Trate a URL de destino completa como uma credencial, não a divulgue publicamente e inclua um token difícil de adivinhar na URL quando o serviço receptor permitir. Se você precisar de um esquema de eventos estável e legível por máquina ou de envios assinados, use o webhook como aviso de mudança e consulte os registros atuais pela API do usuário autenticada.

<!-- translation-section: payload-formats -->

### Formatos dos dados enviados

Os dados enviados pelos webhooks são mensagens para exibição em serviços de bate-papo. Eles não contêm registros completos do Loomio. Os links na mensagem identificam o conteúdo afetado. Se uma integração precisar dos dados atuais em formato estruturado, ela pode consultá-los pela API do usuário.

| Formato da integração | Principais campos JSON |
| --- | --- |
| Mattermost/Markdown | `text`, `icon_url`, `username` |
| Slack | `text` |
| Discord | `content`, limitado a aproximadamente 1.900 caracteres |
| Microsoft Teams | `@type`, `@context`, `themeColor`, `text`, `sections` |
| Webex | `markdown` |

Por exemplo, o formato geral Markdown envia dados com esta estrutura:

```json
{
  "text": "Ada started a discussion: [Quarterly planning](https://example.loomio.org/d/example)",
  "icon_url": "https://example.loomio.org/path/to/group-logo.png",
  "username": "Loomio"
}
```

O texto exato da mensagem depende do evento, do idioma do grupo, da configuração de notificações resumidas e da versão do Loomio. Use os campos de nível superior documentados para o formato selecionado, sem depender da redação das frases.

<!-- translation-section: search -->

## Pesquisa

Pesquise discussões, comentários, enquetes, votos e conclusões visíveis para o usuário da chave de API. Os resultados incluem conteúdo público mesmo que o usuário não seja membro do grupo. O conteúdo privado continua sujeito às regras normais de visibilidade do tópico.

`GET /api/b2/search`

<!-- translation-section: params -->

### Parâmetros

| Nome | Descrição |
| --- | --- |
| `query` | Texto da pesquisa. Aceita correspondências exatas e aproximadas |
| `group_id` | Restringe os resultados a um grupo visível |
| `org_id` | Restringe os resultados a um grupo principal visível e seus subgrupos visíveis. Use `0` para discussões diretas |
| `type` | Restringe os resultados a um tipo: `Discussion`, `Comment`, `Poll`, `Stance` ou `Outcome` |
| `types` | Lista de tipos de resultado separados por vírgulas |
| `tag` | Restringe os resultados a tópicos com esta etiqueta |
| `author_id` | Restringe os resultados ao conteúdo de um autor. Sem `query`, retorna a atividade recente e visível desse autor |
| `order` | Defina como `authored_at_desc` para ordenar o conteúdo correspondente pela data de autoria |

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/search?query=quarterly+planning&type=Discussion'
```

A resposta contém um array `search_results`. Cada resultado identifica o registro encontrado e seu contexto visível por meio de campos como `searchable_type`, `searchable_id`, `highlight`, `group_id`, `group_name`, `discussion_key`, `poll_key`, `author_id`, `author_name`, `authored_at` e `tags`. Os campos que não se aplicam a um resultado têm valor `null`.

<!-- translation-section: participation-report -->

## Relatório de participação

Retorna os mesmos dados agregados de participação usados no relatório de participação do Loomio.

`GET /api/b2/reports`

<!-- translation-section: params-2 -->

### Parâmetros

| Nome | Descrição |
| --- | --- |
| `section` | Seção do relatório: `base`, `users` ou `countries`. Use `users` para consultar a atividade por pessoa |
| `group_scope` | `custom` ou `my`. O valor antigo `all` é tratado como `my`, pois chaves da API do usuário não dão acesso a toda a instância |
| `group_ids` | IDs de grupos separados por vírgulas quando `group_scope=custom`. IDs de grupos dos quais o usuário da API não é membro são ignorados |
| `start_month` | Primeiro mês incluído, no formato `YYYY-MM`. O padrão é 12 meses atrás |
| `end_month` | Último mês incluído, no formato `YYYY-MM`. O padrão é o mês atual |
| `interval` | Intervalo da seção `base`: `day`, `week`, `month` ou `year` |
| `member_type` | Defina como `delegate` com `section=users` para retornar apenas os delegados atuais |

Uma pessoa é delegada quando tem uma associação ativa como delegada em qualquer um dos grupos selecionados. Suas contagens são agregadas em todos os grupos selecionados. Delegados aparecem no relatório mesmo quando todas as contagens de atividade são zero. As contagens incluem tópicos, comentários, enquetes, votos, conclusões e reações; elas não representam taxas de participação nas votações. Os registros de usuários também incluem os convites para votar em enquetes identificadas: quantos foram emitidos, atendidos e não atendidos. Enquetes anônimas ficam fora de todas as contagens de votos por pessoa. `all_votes_cast` só é verdadeiro quando pelo menos um convite para votar foi emitido e todos os convites emitidos resultaram em voto.

A API aplica as mesmas regras de visibilidade de grupos usadas pelo relatório no Loomio. Uma chave da API do usuário não pode expor dados de grupos aos quais esse usuário não tem acesso.

<!-- translation-section: example -->

### Exemplo

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/reports?section=users&group_scope=custom&group_ids=123&member_type=delegate&start_month=2026-01&end_month=2026-09'
```

O array `users` contém registros completos de atividade:

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

Crie uma discussão usando a conta associada à chave de API.

`POST /api/b2/discussions`

<!-- translation-section: params-3 -->

### Parâmetros

| Nome | Descrição |
| --- | --- |
| `group_id` | Grupo em que o tópico será criado |
| `title` | Título do tópico, obrigatório |
| `description` | Contexto do tópico, opcional |
| `description_format` | `md` ou `html`, opcional, padrão `md` |
| `recipient_audience` | `group` ou null. Se for `group`, todo o grupo será notificado sobre o novo tópico |
| `recipient_user_ids` | Lista de IDs de usuários para notificar ou convidar para o tópico |
| `recipient_emails` | Lista de endereços de e-mail de pessoas a convidar para o tópico |
| `recipient_message` | Mensagem a incluir no convite por e-mail |

<!-- translation-section: example-2 -->

### Exemplo

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example thread", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/discussions
```

<!-- translation-section: show-discussion -->

## Consultar discussão

Consulte uma discussão pelo ID numérico ou pela chave de texto.

`GET /api/b2/discussions/:id`

<!-- translation-section: example-3 -->

### Exemplo

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/discussions/abc123
```

<!-- translation-section: list-discussions -->

## Listar discussões

Liste as discussões de um grupo visíveis para o usuário da chave de API. Em um grupo público, quem não é membro pode listar as discussões públicas. As discussões privadas só ficam disponíveis para quem pode lê-las no Loomio.

`GET /api/b2/discussions`

<!-- translation-section: params-4 -->

### Parâmetros

| Nome | Descrição |
| --- | --- |
| `group_id` | Número inteiro, obrigatório. ID do grupo cujas discussões serão listadas |
| `status` | Texto, opcional, padrão `open`. Valores: `open`, `closed`, `all` |
| `limit` | Número inteiro, opcional, padrão 50. Tamanho da página |
| `offset` | Número inteiro, opcional, padrão 0. Deslocamento para paginação |

Compatibilidade: `per` e `from` são aceitos como alternativas a `limit` e `offset` e continuarão funcionando.

<!-- translation-section: example-4 -->

### Exemplo

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/discussions?group_id=123'
```

<!-- translation-section: list-threads -->

## Listar tópicos

Liste os tópicos de discussão e de enquete visíveis para o usuário da chave de API, ordenados pela atividade mais recente. O ID de um tópico é seu `topic_id`.

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

## Ler tópico

Leia um tópico, sua sequência ordenada de eventos ou o documento Markdown completo com o conteúdo visível.

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

O endpoint `items` retorna a sequência ordenada de eventos, incluindo comentários, enquetes, votos e conclusões visíveis. O endpoint `markdown` retorna todo o conteúdo visível do tópico em um único documento Markdown. As justificativas dos votos são incluídas somente quando estão visíveis para o usuário da chave de API.

Todos os endpoints de tópicos aplicam as mesmas permissões da interface do Loomio. A chave de API não dá acesso a um tópico que o usuário normalmente não pode abrir.

<!-- translation-section: edit-discussion -->

## Editar discussão

Edite uma discussão usando a conta associada à chave de API. Aplicam-se as mesmas permissões do Loomio: o usuário precisa ter permissão para editar a discussão.

`PATCH /api/b2/discussions/:id`

<!-- translation-section: params-6 -->

### Parâmetros

| Nome | Descrição |
| --- | --- |
| `title` | Título atualizado |
| `description` | Contexto atualizado |
| `description_format` | `md` ou `html`, opcional, padrão `md` |
| `recipient_audience` | `group` ou null. Se for `group`, todo o grupo será notificado sobre a edição |
| `recipient_user_ids` | Lista de IDs de usuários para notificar ou convidar para o tópico |
| `recipient_emails` | Lista de endereços de e-mail de pessoas a convidar para o tópico |
| `recipient_message` | Mensagem a incluir no convite por e-mail |

<!-- translation-section: example-7 -->

### Exemplo

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated thread title", "description":"updated context", "description_format":"md"}' https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: soft-delete-discussion -->

## Excluir discussão sem remoção definitiva

Exclua uma discussão sem removê-la definitivamente, usando a conta associada à chave de API. A discussão é descartada, mas seu registro permanece.

`DELETE /api/b2/discussions/:id`

<!-- translation-section: example-8 -->

### Exemplo

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: create-comment -->

## Criar comentário

Crie um comentário em uma discussão usando a conta associada à chave de API.

`POST /api/b2/comments`

<!-- translation-section: params-7 -->

### Parâmetros

| Nome | Descrição |
| --- | --- |
| `discussion_id` | Número inteiro, obrigatório. ID da discussão em que o comentário será criado |
| `body` | Texto do comentário, obrigatório, exceto quando um anexo é fornecido |
| `body_format` | `md` ou `html`, opcional, padrão `md` |

<!-- translation-section: example-9 -->

### Exemplo

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"discussion_id": 123, "body":"example comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments
```

<!-- translation-section: edit-comment -->

## Editar comentário

Edite um comentário usando a conta associada à chave de API. Aplicam-se as mesmas permissões do Loomio: o usuário precisa ter permissão para editar o comentário.

`PATCH /api/b2/comments/:id`

<!-- translation-section: params-8 -->

### Parâmetros

| Nome | Descrição |
| --- | --- |
| `body` | Texto atualizado do comentário |
| `body_format` | `md` ou `html`, opcional, padrão `md` |

<!-- translation-section: example-10 -->

### Exemplo

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"body":"updated comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments/123
```

<!-- translation-section: soft-delete-comment -->

## Excluir comentário sem remoção definitiva

Exclua um comentário sem removê-lo definitivamente, usando a conta associada à chave de API. O comentário é descartado e seu texto fica oculto, mas o registro permanece.

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
| `discussion_id` | Inteiro, opcional, padrão null. ID da discussão à qual a enquete será adicionada |
| `title` | Texto, obrigatório. Título da enquete |
| `poll_type` | Texto, obrigatório. Valores: `proposal`, `poll`, `count`, `score`, `ranked_choice`, `meeting`, `dot_vote` |
| `details` | Texto, opcional. Conteúdo da enquete |
| `details_format` | Texto, opcional, padrão `md`. Valores: `md` ou `html` |
| `options` | Lista de textos. Se `poll_type` for `proposal`, os valores válidos são `agree`, `disagree`, `abstain`, `block`. Se `poll_type` for `meeting`, forneça datas ou datas e horas no formato ISO 8601. Para os demais tipos de enquete, qualquer texto é válido |
| `closing_at` | Texto no formato ISO 8601 ou null, padrão null. Exemplo: `2026-09-01T12:00:00Z`. Se for null, a votação ficará desativada e a enquete será considerada um trabalho em andamento |
| `specified_voters_only` | Booleano, opcional, padrão false. Se for true, apenas as pessoas indicadas poderão votar. Se for false, todas as pessoas do grupo serão convidadas a votar |
| `hide_results` | Texto, opcional, padrão `off`. Valores: `off`, `until_vote`, `until_closed` |
| `shuffle_options` | Booleano, padrão false. Mostra as opções aos votantes em ordem aleatória |
| `anonymous` | Booleano, opcional, padrão false. Oculta a identidade dos votantes |
| `recipient_audience` | `group` ou null, opcional, padrão null. Se for `group`, todo o grupo receberá uma notificação |
| `notify_on_closing_soon` | Texto, opcional, padrão `nobody`. Valores: `nobody`, `author`, `undecided_voters`, `voters` |
| `recipient_user_ids` | Lista de IDs de usuários que receberão uma notificação ou convite |
| `recipient_emails` | Lista de endereços de e-mail das pessoas a convidar para votar |
| `recipient_message` | Mensagem a incluir no convite por e-mail |
| `notify_recipients` | Booleano, padrão false. Se for false, adiciona pessoas sem enviar notificações. Se for true, todas as pessoas convidadas nesta solicitação receberão uma notificação por e-mail |

<!-- translation-section: example-12 -->

### Exemplo

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example poll", "poll_type": "proposal", "options": ["agree", "disagree"], "closing_at": "2026-09-01T12:00:00Z", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/polls
```

<!-- translation-section: show-poll -->

## Consultar enquete

Consulte uma enquete pelo ID numérico ou pela chave em texto.

`GET /api/b2/polls/:id`

<!-- translation-section: example-13 -->

### Exemplo

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/polls/abc123
```

<!-- translation-section: list-polls -->

## Listar enquetes

Liste as enquetes de um grupo visíveis para o usuário da chave de API. Em um grupo público, quem não é membro pode listar as enquetes públicas. As enquetes privadas continuam acessíveis apenas a quem pode lê-las no Loomio. A resposta inclui a conclusão atual de cada enquete visível. Assim, você pode usar `status=closed` para listar propostas que já têm uma conclusão.

`GET /api/b2/polls`

<!-- translation-section: params-10 -->

### Parâmetros

| Nome | Descrição |
| --- | --- |
| `group_id` | Inteiro, obrigatório. ID do grupo cujas enquetes serão listadas |
| `status` | Texto, opcional, padrão `active`. Valores: `active`, `closed`, `all` |
| `limit` | Inteiro, opcional, padrão 50. Tamanho da página |
| `offset` | Inteiro, opcional, padrão 0. Deslocamento para paginação |

Compatibilidade: `per` e `from` são aceitos como alternativas a `limit` e `offset` e continuarão funcionando.

<!-- translation-section: example-14 -->

### Exemplo

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/polls?group_id=123'
```

<!-- translation-section: edit-poll -->

## Editar enquete

Edite uma enquete como o usuário da chave de API. Aplicam-se as mesmas permissões do Loomio: o usuário precisa ter permissão para editar a enquete.

`PATCH /api/b2/polls/:id`

<!-- translation-section: params-11 -->

### Parâmetros

| Nome | Descrição |
| --- | --- |
| `title` | Título atualizado |
| `details` | Detalhes atualizados da enquete |
| `details_format` | `md` ou `html`, opcional, padrão `md` |
| `options` | Nomes atualizados das opções. Alterar as opções pode afetar votos existentes, dependendo do estado da enquete |
| `closing_at` | Texto no formato ISO 8601 ou null |
| `recipient_audience` | `group` ou null. Se for `group`, todo o grupo receberá uma notificação |
| `recipient_user_ids` | Lista de IDs de usuários que receberão uma notificação ou convite |
| `recipient_emails` | Lista de endereços de e-mail das pessoas a convidar para votar |
| `recipient_message` | Mensagem a incluir no convite por e-mail |

<!-- translation-section: example-15 -->

### Exemplo

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated poll title", "details":"updated details", "details_format":"md"}' https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: soft-delete-poll -->

## Excluir enquete sem apagar o registro

Exclua uma enquete como o usuário da chave de API. A enquete será descartada, mas seu registro permanecerá armazenado.

`DELETE /api/b2/polls/:id`

<!-- translation-section: example-16 -->

### Exemplo

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: list-memberships -->

## Listar associações ao grupo

Liste as associações ao grupo visíveis para o usuário da chave de API. Membros do grupo podem consultar nomes, IDs, títulos e funções dos membros. Os endereços de e-mail são incluídos apenas para a própria conta do usuário da chave de API ou quando esse usuário é administrador do grupo.

`GET /api/b2/memberships`

<!-- translation-section: params-12 -->

### Parâmetros

| Nome | Descrição |
| --- | --- |
| `group_id` | Inteiro, obrigatório. ID do grupo cujas associações serão listadas |

<!-- translation-section: example-17 -->

### Exemplo

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/memberships?group_id=123'
```

<!-- translation-section: manage-memberships -->

## Gerenciar associações ao grupo

Envie uma lista de endereços de e-mail. Os endereços novos receberão um convite para o grupo. Ao contrário da consulta de associações, esta operação exige permissão de administrador do grupo.

`POST /api/b2/memberships`

<!-- translation-section: params-13 -->

### Parâmetros

| Nome | Descrição |
| --- | --- |
| `group_id` | Inteiro, obrigatório. ID do grupo cujas associações serão gerenciadas |
| `emails` | Lista de textos, obrigatória. Endereços de e-mail das pessoas a convidar para o grupo |
| `remove_absent` | Booleano. Se for true, remove do grupo todas as pessoas cujo e-mail não estiver na lista |

<!-- translation-section: example-18 -->

### Exemplo

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"]}' https://www.loomio.com/api/b2/memberships
```

Se você enviar `remove_absent=1`, os membros do grupo que não estiverem na lista serão removidos. Tenha cuidado: isso pode remover todas as pessoas do seu grupo.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"], "remove_absent": 1}' https://www.loomio.com/api/b2/memberships
```

A resposta é um objeto com `{added_emails: ["person@added.com"], removed_emails: ["person@removed.com"]}`.
