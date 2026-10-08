---
title: API utilisateur
source_revision: c27ee3b193231816878f1c074ff9fc2a086a88c0
source_file: docs/en/user_manual/integrations/api/user-api.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-02'
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
  introduction: 71f4e2d7560ec95b
  authentication-change: 8d922962860bd762
  response-size-and-related-records: 3363173ccc43c630
  endpoint-summary: c8d63bce4a9a93ee
  groups: 4165b194b092ad2b
  list-groups: 8677592f6d6824f8
  get-a-group: 4c3920bd569c10de
  webhooks: d8459e73f1df3bbc
  list-webhooks: fe069bfb9ffd9cc6
  create-a-webhook: d274037b54052569
  update-a-webhook: 653dfd711e2d08bd
  test-a-webhook-destination: 33cc00272474b153
  delete-a-webhook: cc410ec7e479bd82
  event-types: 2f2f0949618e9ebd
  http-delivery: 3a93e64b014635ab
  payload-formats: b6d306b26130b03d
  search: b909fab691af30dd
  params: cdd8308bc848b8a6
  participation-report: a264913e39329d74
  params-2: df18756e7c57d73e
  example: 41b5546ee4429156
  create-discussion: 65ef84285d199931
  params-3: f7d37710486139d1
  example-2: ecd98262d99eaa28
  show-discussion: a7c9c1ff8b523a8e
  example-3: 1f83bba422863d21
  list-discussions: e5248d676f1c696d
  params-4: a21f46a834a64740
  example-4: 0f1e2f84de098ac0
  list-threads: df092d250057e892
  params-5: 7523600b8c96c948
  example-5: 3952a5cb559cd41b
  read-thread: ec6ceb8c9ee57208
  example-6: 6dc179a2d4fb4556
  edit-discussion: a6c77dcf6de15d3d
  params-6: c890fba612580018
  example-7: a826f6bbf20159a6
  soft-delete-discussion: f9b37eda7f553e44
  example-8: 0cecbcafe18fb257
  create-comment: 42802715a95bf9cb
  params-7: 7f4880d6da08d60a
  example-9: 446421db5b0760e0
  edit-comment: 73a49dcc47596f7e
  params-8: 39517eea3508e8e1
  example-10: 348cc7961ff197ec
  soft-delete-comment: 79f1f4441dd3c339
  example-11: b4ddc75f1980baff
  create-poll: e8d5f8ca647f4084
  params-9: a16e7f86cc5e2e5c
  example-12: 811c57dc075ab60b
  show-poll: 302f77efe4d68ed0
  example-13: 3ee18bed4f933b4e
  list-polls: c852c8f7c5a94acb
  params-10: d4ee353dedb06d2f
  example-14: 07e9009cea856b59
  edit-poll: 5501d674d8f98e6c
  params-11: 00e623251e0d3f13
  example-15: 31b07e0f3939cfb0
  soft-delete-poll: 773d40fc44511a06
  example-16: 0d18fc8991ec502b
  list-memberships: 58380f7b71efbe4c
  params-12: 15b68e051fef2f39
  example-17: c61306a42e275f3e
  manage-memberships: 4c4bb0675be4800e
  params-13: 9e30f2a032f0774f
  example-18: 5b0fe531e32f3041
title_source: c23fb6526b722360
title_generated: d78d191c914e4614
---

<!-- translation-section: introduction -->

# Documentation de l’API utilisateur de Loomio

<!-- seo-description: Utilisez l’API utilisateur de Loomio pour créer et gérer des discussions, des commentaires, des sondages, des fils et des adhésions aux groupes depuis d’autres logiciels. -->

`/api/b2` est l’API destinée aux utilisateurs pour les intégrations avec Loomio. Elle utilise la clé API d’un compte utilisateur, et chaque action est effectuée au nom de cet utilisateur.

Les opérations sur les groupes utilisent les adhésions et les permissions dans les groupes de l’utilisateur associé à la clé API. Le statut d’administrateur de l’instance n’étend pas l’accès d’une clé API aux groupes ou au contenu ; utilisez l’API serveur pour l’administration de l’instance.

Utilisez la clé API du compte utilisateur Loomio qui effectuera les actions. Un compte de bot dédié est utile lorsqu’une intégration ne doit pas être invitée aux sondages ni recevoir de notifications.

Les utilisateurs connectés peuvent trouver leur clé API et les identifiants de leurs groupes sur la [page d’accès à l’API](/profile/api_access).

Envoyez la clé API dans un en-tête `Authorization: Bearer`. Les clés API dans les chaînes de requête sont rejetées, car les URL peuvent être enregistrées par les serveurs mandataires et dans les journaux d’accès.

<!-- translation-section: authentication-change -->

### Changement d’authentification

La clé API était auparavant acceptée comme paramètre d’URL `api_key`. Les requêtes utilisant `?api_key=YOUR_API_KEY` ne fonctionnent plus. Utilisez désormais l’en-tête HTTP `Authorization` :

```text
Authorization: Bearer YOUR_API_KEY
```

Les exemples utilisent `YOUR_API_KEY`, l’identifiant de groupe `123` et `https://www.loomio.com/`. Remplacez ces valeurs par votre clé API, l’identifiant de votre groupe et l’URL de votre installation Loomio.

<!-- translation-section: response-size-and-related-records -->

## Taille des réponses et enregistrements associés

Les réponses de l’API utilisateur utilisent un format composé : les enregistrements principaux sont accompagnés d’enregistrements associés, tels que des sujets, des groupes, des utilisateurs, des sondages et des réactions. Cela permet à un client d’alimenter un stockage local d’enregistrements à partir d’une seule requête, mais peut inclure plus de données qu’une intégration simple n’en a besoin.

Passez `compact=1` pour omettre les données volumineuses des sujets, groupes, groupes parents, adhésions, réactions, tags et traductions associés. Les enregistrements principaux et les enregistrements associés nécessaires à l’interprétation de leur contenu restent présents.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads/123/items?compact=1'
```

Pour un contrôle précis, passez `exclude_types` avec des types d’enregistrements au singulier séparés par des espaces. Par exemple, `exclude_types=group reaction` omet les groupes et les réactions associés. Les valeurs courantes sont `topic`, `group`, `parent`, `membership`, `reaction`, `tag`, `translation`, `user`, `discussion`, `poll`, `poll_option`, `stance`, `stance_choice`, `outcome` et `topic_item`. Les exclusions s’appliquent aux enregistrements associés, pas à la ressource principale demandée au point de terminaison.

Les réponses contenant une collection incluent `meta.total` lorsqu’une taille exacte de la collection est définie. Le total est calculé avant l’application de `limit` et `offset`. Les points de terminaison, comme la recherche, qui renvoient volontairement un ensemble limité de résultats omettent `meta.total` plutôt que de renvoyer `null`.

<!-- translation-section: endpoint-summary -->

## Récapitulatif des points de terminaison

| Méthode | Point de terminaison | Fonction |
| --- | --- | --- |
| `GET` | `/api/b2/groups` | Lister les groupes de l’utilisateur associé à la clé API |
| `GET` | `/api/b2/groups/:id_or_key_or_handle` | Obtenir un groupe visible |
| `GET` | `/api/b2/reports` | Générer un rapport de participation |
| `GET` | `/api/b2/search` | Rechercher les discussions, commentaires, sondages, votes et conclusions visibles |
| `POST` | `/api/b2/discussions` | Créer une discussion |
| `GET` | `/api/b2/discussions/:id` | Obtenir une discussion |
| `GET` | `/api/b2/discussions` | Lister les discussions d’un groupe |
| `PATCH` | `/api/b2/discussions/:id` | Modifier une discussion |
| `DELETE` | `/api/b2/discussions/:id` | Effectuer une suppression logique d’une discussion |
| `GET` | `/api/b2/threads` | Lister les fils de discussion et les fils de sondage autonomes visibles |
| `GET` | `/api/b2/threads/:topic_id` | Obtenir un fil |
| `GET` | `/api/b2/threads/:topic_id/items` | Obtenir les éléments d’un fil dans l’ordre |
| `GET` | `/api/b2/threads/:topic_id/markdown` | Obtenir un fil complet au format Markdown |
| `POST` | `/api/b2/comments` | Créer un commentaire ou une réponse |
| `PATCH` | `/api/b2/comments/:id` | Modifier un commentaire |
| `DELETE` | `/api/b2/comments/:id` | Effectuer une suppression logique d’un commentaire |
| `POST` | `/api/b2/polls` | Créer un sondage |
| `GET` | `/api/b2/polls/:id` | Obtenir un sondage |
| `GET` | `/api/b2/polls` | Lister les sondages d’un groupe |
| `PATCH` | `/api/b2/polls/:id` | Modifier un sondage |
| `DELETE` | `/api/b2/polls/:id` | Effectuer une suppression logique d’un sondage |
| `GET` | `/api/b2/memberships` | Lister les adhésions à un groupe |
| `POST` | `/api/b2/memberships` | Ajouter des membres et, si nécessaire, retirer les membres absents de la liste |
| `GET` | `/api/b2/chatbots` | Lister les intégrations de chat et les webhooks d’un groupe |
| `POST` | `/api/b2/chatbots` | Créer une intégration de chat ou un webhook |
| `PATCH` | `/api/b2/chatbots/:id` | Mettre à jour une intégration de chat ou un webhook |
| `DELETE` | `/api/b2/chatbots/:id` | Supprimer une intégration de chat ou un webhook |
| `POST` | `/api/b2/chatbots/check` | Envoyer un test de connexion au webhook |

<!-- translation-section: groups -->

## Groupes

<!-- translation-section: list-groups -->

### Lister les groupes

Renvoie les groupes dans lesquels l’utilisateur associé à la clé API a une adhésion active.

`GET /api/b2/groups`

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups
```

La réponse contient tous les enregistrements correspondants dans un tableau `groups` non paginé. Elle inclut les groupes parents et les sous-groupes, y compris les groupes dont l’abonnement n’est pas actuellement actif. Vérifiez le champ `enabled` lorsqu’une intégration doit fonctionner uniquement avec les groupes activés.

Les principaux champs des groupes sont les suivants :

| Champ | Description |
| --- | --- |
| `id` | Identifiant numérique du groupe utilisé par les autres points de terminaison de l’API utilisateur |
| `key` | Clé courte et stable utilisée dans les URL de Loomio |
| `handle` | Identifiant du groupe lisible par une personne |
| `name` | Nom du groupe |
| `full_name` | Nom du groupe incluant le contexte de son groupe parent |
| `parent_id` | Identifiant numérique du groupe parent pour un sous-groupe, sinon `null` |
| `enabled` | Indique si le groupe et son abonnement sont actifs |
| `memberships_count` | Nombre d’adhésions actives et en attente |
| `accepted_memberships_count` | Nombre d’adhésions acceptées |
| `pending_memberships_count` | Nombre d’invitations en attente |
| `admin_memberships_count` | Nombre d’administrateurs du groupe |
| `discussions_count` | Nombre de discussions directement dans le groupe |
| `polls_count` | Nombre de sondages directement dans le groupe |
| `subgroups_count` | Nombre de sous-groupes |

La réponse peut inclure des paramètres supplémentaires du groupe, des enregistrements de groupes parents associés et les adhésions de l’utilisateur de l’API. Les clients doivent ignorer les champs qu’ils n’utilisent pas.

<!-- translation-section: get-a-group -->

### Obtenir un groupe

Renvoie un groupe visible par l’utilisateur associé à la clé API.

`GET /api/b2/groups/:id_or_key_or_handle`

L’identifiant peut être l’identifiant numérique, la clé ou l’identifiant lisible du groupe.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/123
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/example-group
```

La réponse contient le groupe dans le tableau `groups` et utilise les mêmes champs que le point de terminaison de liste. Une requête visant un groupe auquel l’utilisateur associé à la clé API ne peut pas accéder renvoie une erreur de permission.

<!-- translation-section: webhooks -->

## Webhooks

L’API utilisateur fonctionne par requêtes : une intégration appelle Loomio lorsqu’elle souhaite lire ou modifier des données. Un webhook de groupe permet l’envoi dans l’autre sens. Loomio envoie les événements du groupe sélectionnés à votre point de terminaison au moment où ils se produisent ; une intégration n’a donc pas besoin d’interroger régulièrement l’API REST pour détecter les changements.

Les webhooks sont configurés par groupe et nécessitent la permission d’administrateur du groupe. Vous pouvez les gérer dans l’interface de Loomio :

1. Ouvrez le groupe.
2. Ouvrez le menu du groupe et sélectionnez **Intégrations de chat**.
3. Ajoutez l’intégration correspondant au format de données accepté par votre point de terminaison. Pour un point de terminaison à usage général, utilisez le format Mattermost/Markdown.
4. Saisissez un nom et l’URL de destination.
5. Sélectionnez les événements que Loomio doit envoyer automatiquement.
6. Enregistrez l’intégration et utilisez **Tester la connexion** pour envoyer un message de test.

Utilisez une destination HTTPS avec une URL impossible à deviner. Loomio exige que la destination se résolve en une adresse publique et bloque les requêtes vers des adresses de réseau locales ou privées.

Les agents et les autres intégrations peuvent aussi gérer les webhooks via les points de terminaison des chatbots décrits ci-dessous, avec une authentification Bearer. La ressource porte le nom `chatbots` pour assurer la compatibilité avec les intégrations de chat de Loomio, mais elle représente également les webhooks sortants à usage général.

<!-- translation-section: list-webhooks -->

### Lister les webhooks

Renvoie les intégrations de chat configurées pour un groupe. L’utilisateur associé à la clé API doit être administrateur de ce groupe. La réponse inclut les URL de destination et ne doit donc pas être accessible aux membres ordinaires du groupe.

`GET /api/b2/chatbots?group_id=123`

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/chatbots?group_id=123'
```

La réponse contient un tableau `chatbots` avec les champs suivants :

| Champ | Description |
| --- | --- |
| `id` | Identifiant de l’intégration utilisé pour les mises à jour et la suppression |
| `group_id` | Groupe recevant les événements |
| `name` | Nom de l’intégration utilisé pour son administration |
| `kind` | `webhook` pour un webhook sortant ou `matrix` pour une intégration Matrix |
| `webhook_kind` | Format des données envoyées : `markdown`, `slack`, `discord`, `microsoft` ou `webex` |
| `server` | URL de destination |
| `event_kinds` | Événements envoyés automatiquement |
| `notification_only` | Indique si les messages contiennent uniquement le titre de la notification |

<!-- translation-section: create-a-webhook -->

### Créer un webhook

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

L’utilisateur associé à la clé API doit être administrateur du groupe désigné par `group_id`. Avant son enregistrement, la destination est vérifiée pour confirmer qu’il s’agit d’une URL publique.

<!-- translation-section: update-a-webhook -->

### Mettre à jour un webhook

`PATCH /api/b2/chatbots/:id`

Envoyez les champs à modifier. Le webhook ne peut pas être transféré à un autre groupe en modifiant `group_id`.

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"name":"Planning events","event_kinds":["new_discussion","outcome_created"]}' \
  https://www.loomio.com/api/b2/chatbots/456
```

<!-- translation-section: test-a-webhook-destination -->

### Tester la destination d’un webhook

Envoyez un message de test compatible avec Markdown à une destination avant ou après l’enregistrement de sa configuration.

`POST /api/b2/chatbots/check`

```bash
curl -X POST \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"group_id":123,"server":"https://hooks.example.org/loomio/unguessable-token"}' \
  https://www.loomio.com/api/b2/chatbots/check
```

<!-- translation-section: delete-a-webhook -->

### Supprimer un webhook

`DELETE /api/b2/chatbots/:id`

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/chatbots/456
```

La suppression de la configuration arrête les envois futurs. Elle ne supprime aucun contenu du groupe Loomio.

<!-- translation-section: event-types -->

### Types d’événements

Un webhook peut s’abonner aux types d’événements suivants :

| Événement | Moment de l’envoi |
| --- | --- |
| `new_discussion` | Une discussion est lancée |
| `discussion_edited` | Une discussion est modifiée |
| `new_comment` | Un commentaire est créé |
| `poll_created` | Un sondage est lancé |
| `poll_edited` | Un sondage est modifié |
| `poll_closing_soon` | Un sondage approche de son heure de clôture |
| `poll_expired` | Un sondage atteint son heure de clôture |
| `poll_closed_by_user` | Une personne clôture un sondage manuellement |
| `poll_reopened` | Un sondage est rouvert |
| `outcome_created` | Une conclusion est publiée |
| `outcome_updated` | Une conclusion est mise à jour |
| `outcome_review_due` | La date de réexamen d’une conclusion est atteinte |
| `stance_created` | Un vote est exprimé |
| `stance_updated` | Un vote est modifié |

Le webhook appartient à un seul groupe et reçoit les événements de ce groupe auxquels il est abonné. Les personnes peuvent aussi sélectionner explicitement l’intégration lors du partage ou de l’envoi de certaines notifications, même si l’événement automatique correspondant n’est pas sélectionné.

<!-- translation-section: http-delivery -->

### Envoi HTTP

Loomio envoie une requête HTTP `POST` asynchrone à l’URL configurée avec cet en-tête :

```text
Content-Type: application/json; charset=utf-8
```

Le délai d’expiration de la requête est de cinq secondes. Une réponse `2xx`, y compris `204 No Content`, est considérée comme un succès. Les services qui reçoivent les webhooks doivent répondre rapidement, effectuer les traitements plus longs de manière asynchrone et accepter les envois en double ou dans le désordre.

Loomio n’ajoute actuellement ni signature de webhook, ni en-tête contenant un secret partagé, ni identifiant d’événement ou d’envoi. Traitez l’URL de destination complète comme un identifiant d’accès, ne l’exposez pas publiquement et incluez un jeton impossible à deviner dans l’URL lorsque le service destinataire le permet. Si vous avez besoin d’un schéma d’événements stable et lisible par machine ou d’un envoi signé, utilisez le webhook comme notification de changement et récupérez les enregistrements actuels via l’API utilisateur authentifiée.

<!-- translation-section: payload-formats -->

### Formats des données envoyées

Les données envoyées par les webhooks sont des messages destinés à être affichés dans des services de chat. Ce ne sont pas des enregistrements Loomio sérialisés complets. Les liens dans le message identifient le contenu Loomio concerné ; une intégration peut ensuite utiliser l’API utilisateur lorsqu’elle a besoin de l’état actuel sous une forme structurée.

| Format d’intégration | Principaux champs JSON |
| --- | --- |
| Mattermost/Markdown | `text`, `icon_url`, `username` |
| Slack | `text` |
| Discord | `content`, limité à environ 1 900 caractères |
| Microsoft Teams | `@type`, `@context`, `themeColor`, `text`, `sections` |
| Webex | `markdown` |

Par exemple, le format Markdown général envoie un corps de requête de cette forme :

```json
{
  "text": "Ada started a discussion: [Quarterly planning](https://example.loomio.org/d/example)",
  "icon_url": "https://example.loomio.org/path/to/group-logo.png",
  "username": "Loomio"
}
```

Le texte exact du message dépend de l’événement, de la langue du groupe, du paramètre limitant le message au titre de la notification et de la version de Loomio. Les services destinataires doivent s’appuyer sur les champs de premier niveau documentés du format sélectionné plutôt que d’analyser la formulation des phrases.

<!-- translation-section: search -->

## Recherche

Recherchez les discussions, commentaires, sondages, votes et conclusions visibles par l’utilisateur associé à la clé API. Les résultats incluent le contenu public même si l’utilisateur n’est pas membre du groupe concerné ; le contenu privé reste soumis aux règles habituelles de visibilité des fils.

`GET /api/b2/search`

<!-- translation-section: params -->

### Paramètres

| Nom | Description |
| --- | --- |
| `query` | Texte à rechercher. Les correspondances exactes et approximatives sont prises en charge |
| `group_id` | Limite les résultats à un groupe visible |
| `org_id` | Limite les résultats à un groupe parent visible et à ses sous-groupes visibles. Utilisez `0` pour les discussions directes |
| `type` | Limite les résultats à un type : `Discussion`, `Comment`, `Poll`, `Stance` ou `Outcome` |
| `types` | Liste des types de résultats séparés par des virgules |
| `tag` | Limite les résultats aux fils portant ce tag |
| `author_id` | Limite les résultats au contenu d’un auteur. Sans `query`, renvoie l’activité récente visible de cet auteur |
| `order` | Définissez la valeur sur `authored_at_desc` pour trier le contenu correspondant par date de création |

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/search?query=quarterly+planning&type=Discussion'
```

La réponse contient un tableau `search_results`. Chaque résultat identifie l’enregistrement correspondant et son contexte visible avec des champs comprenant `searchable_type`, `searchable_id`, `highlight`, `group_id`, `group_name`, `discussion_key`, `poll_key`, `author_id`, `author_name`, `authored_at` et `tags`. Les champs qui ne s’appliquent pas à un résultat ont la valeur `null`.

<!-- translation-section: participation-report -->

## Rapport de participation

Renvoie les mêmes données de participation agrégées que celles utilisées par le rapport de participation de Loomio.

`GET /api/b2/reports`

<!-- translation-section: params-2 -->

### Paramètres

| Nom | Description |
| --- | --- |
| `section` | Section du rapport : `base`, `users` ou `countries`. Utilisez `users` pour l’activité par personne |
| `group_scope` | `custom` ou `my`. L’ancienne valeur `all` est traitée comme `my`, car les clés de l’API utilisateur ne donnent jamais accès à l’ensemble de l’instance |
| `group_ids` | Identifiants de groupes séparés par des virgules lorsque `group_scope=custom`. Les identifiants de groupes dont l’utilisateur de l’API n’est pas membre sont ignorés |
| `start_month` | Premier mois à inclure au format `YYYY-MM` ; par défaut, le mois d’il y a 12 mois |
| `end_month` | Dernier mois à inclure au format `YYYY-MM` ; par défaut, le mois en cours |
| `interval` | Intervalle pour la section `base` : `day`, `week`, `month` ou `year` |
| `member_type` | Définissez la valeur sur `delegate` avec `section=users` pour ne renvoyer que les délégués actuels |

Une personne est déléguée lorsqu’elle dispose d’une adhésion active avec le rôle de délégué dans au moins un groupe sélectionné. Ses décomptes sont agrégés sur l’ensemble des groupes sélectionnés. Les lignes des délégués sont renvoyées même lorsque tous les décomptes d’activité sont nuls. Les décomptes couvrent les fils, commentaires, sondages, votes, conclusions et réactions ; ce ne sont pas des taux de participation aux votes. Les lignes des utilisateurs incluent aussi les bulletins de vote nominatifs attribués, déposés et non déposés. Les sondages anonymes sont exclus de tous les décomptes de vote par personne. `all_votes_cast` vaut true uniquement lorsqu’au moins un bulletin a été attribué et que tous les bulletins attribués ont été déposés.

L’API applique les mêmes règles de visibilité des groupes que le rapport dans l’application. Une clé de l’API utilisateur ne peut pas exposer les données de rapport de groupes auxquels cet utilisateur n’a pas accès.

<!-- translation-section: example -->

### Exemple

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/reports?section=users&group_scope=custom&group_ids=123&member_type=delegate&start_month=2026-01&end_month=2026-09'
```

Le tableau `users` contient des lignes d’activité complètes :

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

## Créer une discussion

Créez une discussion au nom de l’utilisateur associé à la clé API.

`POST /api/b2/discussions`

<!-- translation-section: params-3 -->

### Paramètres

| Nom | Description |
| --- | --- |
| `group_id` | Groupe dans lequel le fil sera créé |
| `title` | Titre du fil, obligatoire |
| `description` | Contexte du fil, facultatif |
| `description_format` | `md` ou `html`, facultatif, `md` par défaut |
| `recipient_audience` | `group` ou null. Si la valeur est `group`, tout le groupe sera informé du nouveau fil |
| `recipient_user_ids` | Tableau d’identifiants d’utilisateurs à informer ou à inviter dans le fil |
| `recipient_emails` | Tableau d’adresses e-mail des personnes à inviter dans le fil |
| `recipient_message` | Message à inclure dans l’invitation par e-mail |

<!-- translation-section: example-2 -->

### Exemple

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example thread", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/discussions
```

<!-- translation-section: show-discussion -->

## Afficher une discussion

Récupérez une discussion à l’aide de son identifiant, un entier, ou de sa clé, une chaîne de caractères.

`GET /api/b2/discussions/:id`

<!-- translation-section: example-3 -->

### Exemple

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/discussions/abc123
```

<!-- translation-section: list-discussions -->

## Lister les discussions

Listez les discussions d’un groupe visibles par l’utilisateur de la clé API. Pour un groupe visible publiquement, une personne qui n’en est pas membre peut lister ses discussions publiques ; les discussions privées restent réservées aux utilisateurs qui peuvent les lire dans Loomio.

`GET /api/b2/discussions`

<!-- translation-section: params-4 -->

### Paramètres

| Nom | Description |
| --- | --- |
| `group_id` | Entier, obligatoire. Identifiant du groupe dont les discussions seront listées |
| `status` | Chaîne de caractères, facultative, valeur par défaut `open`. Valeurs : `open`, `closed`, `all` |
| `limit` | Entier, facultatif, valeur par défaut 50. Taille de la page |
| `offset` | Entier, facultatif, valeur par défaut 0. Décalage pour la pagination |

Compatibilité avec les anciennes versions : `per` et `from` sont acceptés comme alias de `limit` et `offset` et continueront à fonctionner.

<!-- translation-section: example-4 -->

### Exemple

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/discussions?group_id=123'
```

<!-- translation-section: list-threads -->

## Lister les fils

Listez les fils de discussion et les fils de sondage visibles par l’utilisateur de la clé API, classés par activité la plus récente. L’identifiant d’un fil est son `topic_id`.

`GET /api/b2/threads`

<!-- translation-section: params-5 -->

### Paramètres

| Nom | Description |
| --- | --- |
| `limit` | Entier, facultatif, valeur par défaut 50. Taille de la page |
| `offset` | Entier, facultatif, valeur par défaut 0. Décalage pour la pagination |

<!-- translation-section: example-5 -->

### Exemple

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads?limit=50&offset=0'
```

<!-- translation-section: read-thread -->

## Lire un fil

Lisez un fil, son flux d’événements ordonné ou son document Markdown visible complet.

`GET /api/b2/threads/:topic_id`

`GET /api/b2/threads/:topic_id/items`

`GET /api/b2/threads/:topic_id/markdown`

<!-- translation-section: example-6 -->

### Exemple

```text
GET https://www.loomio.com/api/b2/threads/<topic_id>
GET https://www.loomio.com/api/b2/threads/<topic_id>/items
GET https://www.loomio.com/api/b2/threads/<topic_id>/markdown
```

Le point de terminaison `items` renvoie le flux d’événements ordonné, comprenant les commentaires, sondages, votes et conclusions visibles. Le point de terminaison `markdown` renvoie l’intégralité du contenu visible du fil dans un seul document Markdown. Les raisons des votes ne sont incluses que lorsqu’elles sont visibles par l’utilisateur de la clé API.

Tous les points de terminaison relatifs aux fils appliquent les mêmes permissions que l’interface Loomio. La clé API ne donne pas accès à un fil que l’utilisateur ne peut pas ouvrir normalement.

<!-- translation-section: edit-discussion -->

## Modifier une discussion

Modifiez une discussion en tant qu’utilisateur de la clé API. Les mêmes permissions que dans Loomio s’appliquent : l’utilisateur doit être autorisé à modifier cette discussion.

`PATCH /api/b2/discussions/:id`

<!-- translation-section: params-6 -->

### Paramètres

| Nom | Description |
| --- | --- |
| `title` | Titre mis à jour |
| `description` | Contexte mis à jour |
| `description_format` | `md` ou `html`, facultatif, valeur par défaut `md` |
| `recipient_audience` | `group` ou null. Si la valeur est `group`, tout le groupe sera informé de la modification |
| `recipient_user_ids` | Tableau d’identifiants des utilisateurs à informer ou à inviter au fil |
| `recipient_emails` | Tableau d’adresses e-mail des personnes à inviter au fil |
| `recipient_message` | Message à inclure dans l’invitation par e-mail |

<!-- translation-section: example-7 -->

### Exemple

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated thread title", "description":"updated context", "description_format":"md"}' https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: soft-delete-discussion -->

## Supprimer une discussion de manière logique

Supprimez une discussion de manière logique en tant qu’utilisateur associé à la clé API. Cette opération retire la discussion tout en conservant son enregistrement.

`DELETE /api/b2/discussions/:id`

<!-- translation-section: example-8 -->

### Exemple

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: create-comment -->

## Créer un commentaire

Créez un commentaire dans une discussion en tant qu’utilisateur associé à la clé API.

`POST /api/b2/comments`

<!-- translation-section: params-7 -->

### Paramètres

| Nom | Description |
| --- | --- |
| `discussion_id` | Entier, obligatoire. Identifiant de la discussion à commenter |
| `body` | Corps du commentaire, obligatoire sauf si une pièce jointe est fournie |
| `body_format` | `md` ou `html`, facultatif, valeur par défaut : `md` |

<!-- translation-section: example-9 -->

### Exemple

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"discussion_id": 123, "body":"example comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments
```

<!-- translation-section: edit-comment -->

## Modifier un commentaire

Modifiez un commentaire en tant qu’utilisateur associé à la clé API. Les mêmes permissions que dans Loomio s’appliquent : l’utilisateur doit être autorisé à modifier ce commentaire.

`PATCH /api/b2/comments/:id`

<!-- translation-section: params-8 -->

### Paramètres

| Nom | Description |
| --- | --- |
| `body` | Corps du commentaire mis à jour |
| `body_format` | `md` ou `html`, facultatif, valeur par défaut : `md` |

<!-- translation-section: example-10 -->

### Exemple

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"body":"updated comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments/123
```

<!-- translation-section: soft-delete-comment -->

## Supprimer un commentaire de manière logique

Supprimez un commentaire de manière logique en tant qu’utilisateur associé à la clé API. Cette opération retire le commentaire et masque son corps tout en conservant son enregistrement.

`DELETE /api/b2/comments/:id`

<!-- translation-section: example-11 -->

### Exemple

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/comments/123
```

<!-- translation-section: create-poll -->

## Créer un sondage

Créez un sondage en tant qu’utilisateur associé à la clé API.

`POST /api/b2/polls`

<!-- translation-section: params-9 -->

### Paramètres

| Nom | Description |
| --- | --- |
| `group_id` | Entier, facultatif, null par défaut. Identifiant du groupe du sondage. Si `discussion_id` est fourni, `group_id` est ignoré |
| `discussion_id` | Entier, facultatif, null par défaut. Identifiant du fil de discussion auquel ajouter ce sondage |
| `title` | Chaîne de caractères, obligatoire. Titre du sondage |
| `poll_type` | Chaîne de caractères, obligatoire. Valeurs : `proposal`, `poll`, `count`, `score`, `ranked_choice`, `meeting`, `dot_vote` |
| `details` | Chaîne de caractères, facultative. Texte du sondage |
| `details_format` | Chaîne de caractères, facultative, `md` par défaut. Valeurs : `md` ou `html` |
| `options` | Tableau de chaînes de caractères. Si `poll_type` vaut `proposal`, les valeurs valides sont `agree`, `disagree`, `abstain`, `block`. Si `poll_type` vaut `meeting`, fournissez des chaînes de caractères représentant des dates ou des dates et heures au format ISO 8601. Pour tous les autres types de sondage, toute chaîne de caractères est valide |
| `closing_at` | Chaîne de caractères au format ISO 8601 ou null, null par défaut. Exemple : `2026-09-01T12:00:00Z`. Si la valeur est null, le vote est désactivé et le sondage est considéré comme en cours de préparation |
| `specified_voters_only` | Booléen, facultatif, false par défaut. Si la valeur est true, seules les personnes désignées peuvent voter. Si la valeur est false, toutes les personnes du groupe seront invitées à voter |
| `hide_results` | Chaîne de caractères, facultative, `off` par défaut. Valeurs : `off`, `until_vote`, `until_closed` |
| `shuffle_options` | Booléen, false par défaut. Affiche les options aux électeurs dans un ordre aléatoire |
| `anonymous` | Booléen, facultatif, false par défaut. Masque l’identité des électeurs |
| `recipient_audience` | `group` ou null, facultatif, null par défaut. Si la valeur est `group`, tout le groupe recevra une notification |
| `notify_on_closing_soon` | Chaîne de caractères, facultative, `nobody` par défaut. Valeurs : `nobody`, `author`, `undecided_voters`, `voters` |
| `recipient_user_ids` | Tableau d’identifiants d’utilisateurs à notifier ou à inviter |
| `recipient_emails` | Tableau d’adresses e-mail des personnes à inviter à voter |
| `recipient_message` | Message à inclure dans l’invitation par e-mail |
| `notify_recipients` | Booléen, false par défaut. Si la valeur est false, les personnes sont ajoutées sans envoi de notifications. Si la valeur est true, toutes les personnes invitées par cette requête recevront une notification par e-mail |

<!-- translation-section: example-12 -->

### Exemple

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example poll", "poll_type": "proposal", "options": ["agree", "disagree"], "closing_at": "2026-09-01T12:00:00Z", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/polls
```

<!-- translation-section: show-poll -->

## Afficher un sondage

Récupérez un sondage à l’aide de son identifiant, un entier, ou de sa clé, une chaîne de caractères.

`GET /api/b2/polls/:id`

<!-- translation-section: example-13 -->

### Exemple

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/polls/abc123
```

<!-- translation-section: list-polls -->

## Lister les sondages

Listez les sondages d’un groupe visibles par l’utilisateur de la clé API. Pour un groupe visible publiquement, une personne qui n’en est pas membre peut lister ses sondages publics ; les sondages privés restent réservés aux utilisateurs qui peuvent les consulter dans Loomio. La réponse inclut la conclusion actuelle de chaque sondage visible. Vous pouvez donc utiliser `status=closed` pour lister les propositions ayant fait l’objet d’une décision.

`GET /api/b2/polls`

<!-- translation-section: params-10 -->

### Paramètres

| Nom | Description |
| --- | --- |
| `group_id` | Entier, obligatoire. Identifiant du groupe dont vous souhaitez lister les sondages |
| `status` | Chaîne de caractères, facultative, `active` par défaut. Valeurs : `active`, `closed`, `all` |
| `limit` | Entier, facultatif, 50 par défaut. Taille de la page |
| `offset` | Entier, facultatif, 0 par défaut. Décalage pour la pagination |

Compatibilité avec les anciens paramètres : `per` et `from` sont acceptés comme alias de `limit` et `offset` et continueront à fonctionner.

<!-- translation-section: example-14 -->

### Exemple

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/polls?group_id=123'
```

<!-- translation-section: edit-poll -->

## Modifier un sondage

Modifiez un sondage en tant qu’utilisateur de la clé API. Les mêmes permissions que dans Loomio s’appliquent : l’utilisateur doit être autorisé à modifier ce sondage.

`PATCH /api/b2/polls/:id`

<!-- translation-section: params-11 -->

### Paramètres

| Nom | Description |
| --- | --- |
| `title` | Titre mis à jour |
| `details` | Détails du sondage mis à jour |
| `details_format` | `md` ou `html`, facultatif, `md` par défaut |
| `options` | Noms des options mis à jour. La modification des options peut affecter les votes existants selon l’état du sondage |
| `closing_at` | Chaîne de caractères au format ISO 8601 ou null |
| `recipient_audience` | `group` ou null. Si la valeur est `group`, tout le groupe recevra une notification |
| `recipient_user_ids` | Tableau d’identifiants d’utilisateurs à notifier ou à inviter |
| `recipient_emails` | Tableau d’adresses e-mail des personnes à inviter à voter |
| `recipient_message` | Message à inclure dans l’invitation par e-mail |

<!-- translation-section: example-15 -->

### Exemple

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated poll title", "details":"updated details", "details_format":"md"}' https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: soft-delete-poll -->

## Supprimer un sondage sans effacer son enregistrement

Supprimez un sondage en tant qu’utilisateur de la clé API. Cette opération retire le sondage tout en conservant son enregistrement.

`DELETE /api/b2/polls/:id`

<!-- translation-section: example-16 -->

### Exemple

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: list-memberships -->

## Lister les adhésions

Liste les adhésions visibles par l’utilisateur de la clé API. Les membres du groupe peuvent consulter les noms, les identifiants, les titres et les rôles des membres. Les adresses e-mail sont incluses uniquement pour le compte de l’utilisateur de la clé API ou lorsque cet utilisateur est administrateur du groupe.

`GET /api/b2/memberships`

<!-- translation-section: params-12 -->

### Paramètres

| Nom | Description |
| --- | --- |
| `group_id` | Entier, obligatoire. Identifiant du groupe dont les adhésions seront listées |

<!-- translation-section: example-17 -->

### Exemple

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/memberships?group_id=123'
```

<!-- translation-section: manage-memberships -->

## Gérer les adhésions

Envoyez une liste d’adresses e-mail. Toutes les nouvelles adresses e-mail recevront une invitation à rejoindre le groupe. Contrairement à la consultation de la liste des adhésions, cette opération nécessite les droits d’administration du groupe.

`POST /api/b2/memberships`

<!-- translation-section: params-13 -->

### Paramètres

| Nom | Description |
| --- | --- |
| `group_id` | Entier, obligatoire. Identifiant du groupe dont les adhésions seront gérées |
| `emails` | Tableau de chaînes de caractères, obligatoire. Adresses e-mail des personnes à inviter dans le groupe |
| `remove_absent` | Booléen. Si la valeur est true, retire du groupe toute personne dont l’adresse e-mail ne figure pas dans la liste |

<!-- translation-section: example-18 -->

### Exemple

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"]}' https://www.loomio.com/api/b2/memberships
```

Si vous transmettez `remove_absent=1`, tous les membres du groupe qui ne figurent pas dans la liste seront retirés du groupe. Faites attention, vous pourriez retirer tous les membres de votre groupe.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"], "remove_absent": 1}' https://www.loomio.com/api/b2/memberships
```

Cette opération renvoie un objet contenant `{added_emails: ["person@added.com"], removed_emails: ["person@removed.com"]}`.
