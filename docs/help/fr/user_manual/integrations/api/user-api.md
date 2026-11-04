---
title: API utilisateur
source_revision: 81fbad246f674a34694bb2ebfc8416dd04e46ee6
source_file: docs/help/en/user_manual/integrations/api/user-api.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-28'
sections:
  introduction: 68d638b236cac8c3
  response-size-and-related-records: 6f8cf57b45766ad1
  endpoint-summary: faaeafa590fb56e0
  groups: 0473f1f7fb78f074
  list-groups: 9aef26f9b926766b
  get-a-group: 05fd7cc3b212e7e1
  webhooks: f65fa289f8c1b808
  list-webhooks: fa6555a40e1c4929
  create-a-webhook: 82f92d8c0291ebba
  update-a-webhook: 7e838aa6eba73663
  test-a-webhook-destination: bceeb98f6e8c0000
  delete-a-webhook: 36bb783e464646d0
  event-types: 73bfe87c8b790af3
  http-delivery: a32c763b6f816e65
  payload-formats: ca728b0ef542305c
  search: 9f562d745e3eb6b2
  params: 9fa99390aca5fcce
  participation-report: 2d11a398e2293ea4
  params-2: 464322ffc1ac56e5
  example: 7cab9083deb72c59
  create-discussion: 560273365cd6c232
  params-3: 657d582c89333097
  example-2: 71b3da6ca440fc97
  show-discussion: e4c59f833a2e0f0e
  example-3: 2371364611978a4d
  list-discussions: 70edb4a95bf5cafd
  params-4: dcebc294fbb9d837
  example-4: 62b76a3e8ccd9d3f
  list-threads: 46509be0004f5b26
  params-5: 79b1cefac558effc
  example-5: 785a417a6afa1b29
  read-thread: d7b366d09189eeaf
  example-6: 13abd928820aa15e
  edit-discussion: 9bee023a69bdff84
  params-6: b819796d34354623
  example-7: a98e95cf6bec9f7d
  soft-delete-discussion: 97396a318d1c74a2
  example-8: e92d4004513fc701
  create-comment: a3c290a9028f0f28
  params-7: 5ad8ede0919c5f47
  example-9: a13b59af4b411c26
  edit-comment: fd9b7963e483d2a1
  params-8: 288331c60f3c9b28
  example-10: 48c0def4c835d801
  soft-delete-comment: be989b770bd2025a
  example-11: e9019f5c028e3632
  create-poll: f339b99e95def65f
  params-9: 1c63b4ef4047f3c3
  example-12: 58ea197b72a8bd0f
  show-poll: 40b4370bcac536e5
  example-13: 6e74d6164d61fd19
  list-polls: e52282b2b9fe775b
  params-10: e68e8cf62b21488d
  example-14: cda8994926bc7002
  edit-poll: b2c8cd57e7dea231
  params-11: 70b594511872194a
  example-15: fda29e1741869e22
  soft-delete-poll: 740d74b8f48adfd8
  example-16: aa8016ff2c0dcd5d
  list-memberships: 769573d5f0f4a077
  params-12: decaff0790566fb0
  example-17: 213d79e474d7ab1d
  manage-memberships: c492589da7e249c8
  params-13: 771b5338a4ba3d0b
  example-18: bacb90328233ce5b
  pagination: 4171ca78df07d4fe
  comments: ccd37303241bac95
  discussions: 16ffe7a7b6202d3e
  memberships: e7cf8846c3179720
  polls: 821dcd89b5460804
  threads: 19bc02fc1c26317b
  request-bodies: 0ec99fc25454f511
  poll-many-options: 54f4ab737df476d9
  poll-detailed-options: 1df1348a129c3991
  edit-poll-detailed-options: 2be9b78ff51be3ec
generated:
  introduction: 6cf983eb92a13d33
  response-size-and-related-records: 3c8e2ae824999ff0
  endpoint-summary: 957fed49d1364b4f
  groups: 4165b194b092ad2b
  list-groups: 0aeb6132b09ca9f4
  get-a-group: 8c1f1a9e2f6d63e9
  webhooks: d8459e73f1df3bbc
  list-webhooks: ff765ba8e65a2dd8
  create-a-webhook: f6ddf167169489a1
  update-a-webhook: e9f4692fc3555e64
  test-a-webhook-destination: a076a7ab66fe5e4b
  delete-a-webhook: a9793decdfbb54bd
  event-types: 2f2f0949618e9ebd
  http-delivery: 3a93e64b014635ab
  payload-formats: b6d306b26130b03d
  search: 7cfbba362cd554f7
  params: acef076bfdfca77d
  participation-report: 06acf70f3deb6812
  params-2: df18756e7c57d73e
  example: 9aa1994501e3f206
  create-discussion: b43d917b1df17d82
  params-3: 901bceb0905c3ef7
  example-2: 15e969a1c6880b95
  show-discussion: de278b26550d6815
  example-3: 9b1db52f57728f04
  list-discussions: 2a5a5b1a57f3b2c9
  params-4: fbcde8eaaf0e172b
  example-4: 84b30990894e5696
  list-threads: 60a6792ba2ef5446
  params-5: c6c8d6d0412eaa63
  example-5: 345ae7c5038231e5
  read-thread: 5316c32cb13fa514
  example-6: d9e0717c59eb2b56
  edit-discussion: 28620eeafd9b7bd3
  params-6: 69224e29cccc12bb
  example-7: 943e31d285c08bf7
  soft-delete-discussion: 1fa0c2d2a2328a9d
  example-8: 3ac50bf30bc7cde8
  create-comment: f810c35c59edde04
  params-7: 2991b1a4ba2e8bad
  example-9: 14870ae331b57a99
  edit-comment: 370de416eb1d3dd6
  params-8: ae1bd8074c80e226
  example-10: 7fe88f3188275d4f
  soft-delete-comment: b59cf221768769d3
  example-11: b8cd74b3c1426efe
  create-poll: 5ea21ad0b19c63d3
  params-9: 9d822d2a09cb1625
  example-12: c90466eece69a890
  show-poll: 5557b95059b58037
  example-13: a14fc34d58896501
  list-polls: 2ee6cbc0ad22d7e0
  params-10: 622d70d2d10f46ce
  example-14: 5a4e98817fc44a24
  edit-poll: b9a04dabb3564196
  params-11: 82fe57c80bf7551b
  example-15: 18e7bf0c44536e3c
  soft-delete-poll: 35e7bda778c7ddfd
  example-16: 8596d2cacbf60d1a
  list-memberships: 570e27559eeb6e1f
  params-12: 5fa3261a88ab052a
  example-17: 7bb380d824d276f8
  manage-memberships: 16e8fcade37c1205
  params-13: 5123db4fb41a6c9d
  example-18: d88abebcb5377bdd
  pagination: eb3c1e5997c4f5da
  comments: 11cb22d13cc54616
  discussions: 16ffe7a7b6202d3e
  memberships: d1d3c44761fb4480
  polls: 6e024ce43b74fd59
  threads: 519ee5dec8a27ec0
  request-bodies: 3508f2503ae0ac3c
  poll-many-options: 45a1e7e2caffab2d
  poll-detailed-options: 7a14c95abd6eda83
  edit-poll-detailed-options: 3d3d63386727ce0e
title_source: c23fb6526b722360
title_generated: d78d191c914e4614
---

<!-- translation-section: introduction -->

# Documentation de l’API utilisateur de Loomio

<!-- seo-description: Utilisez l’API utilisateur de Loomio pour créer et gérer des discussions, des commentaires, des sondages, des fils et des adhésions aux groupes depuis d’autres logiciels. -->

`/api/user0` est l’API destinée aux utilisateurs pour les intégrations avec Loomio. Elle utilise la clé API d’un compte utilisateur, et chaque action est effectuée au nom de cet utilisateur.

Les opérations sur les groupes utilisent les adhésions et les permissions dans les groupes de l’utilisateur associé à la clé API. Le statut d’administrateur de l’instance n’étend pas l’accès d’une clé API aux groupes ou au contenu ; utilisez l’API serveur pour l’administration de l’instance.

Utilisez la clé API du compte utilisateur Loomio qui effectuera les actions. Un compte de bot dédié est utile lorsqu’une intégration ne doit pas être invitée aux sondages ni recevoir de notifications.

Les utilisateurs connectés peuvent trouver leur clé API et les identifiants de leurs groupes sur la [page d’accès à l’API](/profile/api_access).

Envoyez la clé API dans un en-tête `Authorization: Bearer`. Les clés API dans les chaînes de requête sont rejetées, car les URL peuvent être enregistrées par les serveurs mandataires et dans les journaux d’accès.

```text
Authorization: Bearer YOUR_API_KEY
```

Les exemples utilisent `YOUR_API_KEY`, l’identifiant de groupe `123` et `https://www.loomio.com/`. Remplacez ces valeurs par votre clé API, l’identifiant de votre groupe et l’URL de votre installation Loomio.

<!-- translation-section: request-bodies -->

### Envoyer des corps de requête

Envoyez du JSON avec `Content-Type: application/json`. Les exemples cURL utilisent `--json`, qui définit automatiquement cet en-tête. Les points de terminaison de création et de modification des discussions, commentaires et sondages acceptent soit un objet à plat, soit un objet imbriqué sous le nom de la ressource, comme `{"poll": {...}}`.

Envoyez les tableaux sous forme de tableaux JSON, comme `"options": ["foo", "bar"]`. Si vous utilisez plutôt l’encodage de formulaire, les noms des champs doivent comporter des crochets pour les tableaux, comme `options[]=foo&options[]=bar` ; répéter `options=foo&options=bar` ne conserve que la dernière valeur.

Vérifiez le statut HTTP et le corps de la réponse après chaque requête. Un échec de validation renvoie `422` avec un objet `errors` ; la création réussie d’un sondage renvoie le sondage dans `polls` et ses options dans `poll_options`.

<!-- translation-section: endpoint-summary -->

## Récapitulatif des points de terminaison

| Méthode | Point de terminaison | Fonction |
| --- | --- | --- |
| `POST` | `/api/user0/comments` | Créer un commentaire ou une réponse |
| `PATCH` | `/api/user0/comments/:id` | Modifier un commentaire |
| `DELETE` | `/api/user0/comments/:id` | Effectuer une suppression logique d’un commentaire |
| `POST` | `/api/user0/discussions` | Créer une discussion |
| `GET` | `/api/user0/discussions/:id` | Obtenir une discussion |
| `GET` | `/api/user0/discussions` | Lister les discussions d’un groupe |
| `PATCH` | `/api/user0/discussions/:id` | Modifier une discussion |
| `DELETE` | `/api/user0/discussions/:id` | Effectuer une suppression logique d’une discussion |
| `GET` | `/api/user0/groups` | Lister les groupes de l’utilisateur associé à la clé API |
| `GET` | `/api/user0/groups/:id_or_key_or_handle` | Obtenir un groupe visible |
| `GET` | `/api/user0/memberships` | Lister les adhésions à un groupe |
| `POST` | `/api/user0/memberships` | Ajouter des membres et, si nécessaire, retirer les membres absents de la liste |
| `GET` | `/api/user0/reports` | Générer un rapport de participation |
| `POST` | `/api/user0/polls` | Créer un sondage |
| `GET` | `/api/user0/polls/:id` | Obtenir un sondage |
| `GET` | `/api/user0/polls` | Lister les sondages d’un groupe |
| `PATCH` | `/api/user0/polls/:id` | Modifier un sondage |
| `DELETE` | `/api/user0/polls/:id` | Effectuer une suppression logique d’un sondage |
| `GET` | `/api/user0/search` | Rechercher les discussions, commentaires, sondages, votes et conclusions visibles |
| `GET` | `/api/user0/threads` | Lister les fils de discussion et les fils de sondage autonomes visibles |
| `GET` | `/api/user0/threads/:topic_id` | Obtenir un fil |
| `GET` | `/api/user0/threads/:topic_id/items` | Obtenir les éléments d’un fil dans l’ordre |
| `GET` | `/api/user0/threads/:topic_id/markdown` | Obtenir un fil complet au format Markdown |
| `GET` | `/api/user0/chatbots` | Lister les intégrations de chat et les webhooks d’un groupe |
| `POST` | `/api/user0/chatbots` | Créer une intégration de chat ou un webhook |
| `PATCH` | `/api/user0/chatbots/:id` | Mettre à jour une intégration de chat ou un webhook |
| `DELETE` | `/api/user0/chatbots/:id` | Supprimer une intégration de chat ou un webhook |
| `POST` | `/api/user0/chatbots/check` | Envoyer un test de connexion au webhook |

<!-- translation-section: pagination -->

## Pagination

Les discussions, groupes, adhésions, sondages, fils, éléments de fil et webhooks acceptent `limit` (valeur par défaut : `50`) et `offset` (valeur par défaut : `0`). Les groupes, éléments de fil et webhooks plafonnent `limit` à `500`.

Augmentez `offset` du nombre d’enregistrements principaux renvoyés pour récupérer la page suivante. `meta.total` correspond au nombre total d’enregistrements correspondants ; les enregistrements associés ne sont pas comptabilisés dans la taille de la page.

Les rapports de participation renvoient l’intégralité des données demandées, et la recherche renvoie jusqu’à 20 résultats. Aucun des deux ne prend en charge la pagination.

Les discussions, sondages et adhésions acceptent également les anciens alias `per` pour `limit` et `from` pour `offset`. Utilisez `limit` et `offset` pour les nouvelles intégrations.

<!-- translation-section: response-size-and-related-records -->

## Enregistrements associés

Les réponses de l’API utilisateur utilisent un format composé : les enregistrements principaux sont accompagnés d’enregistrements associés, tels que des sujets, des groupes, des utilisateurs, des sondages et des réactions. Cela permet à un client d’alimenter un stockage local d’enregistrements à partir d’une seule requête, mais peut inclure plus de données qu’une intégration simple n’en a besoin.

Passez `compact=1` pour omettre les données volumineuses des sujets, groupes, groupes parents, adhésions, réactions, tags et traductions associés. Les enregistrements principaux et les enregistrements associés nécessaires à l’interprétation de leur contenu restent présents.

```bash
curl 'https://www.loomio.com/api/user0/threads/123/items?compact=1' \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

Pour un contrôle précis, passez `exclude_types` avec des types d’enregistrements au singulier séparés par des espaces. Par exemple, `exclude_types=group reaction` omet les groupes et les réactions associés. Les valeurs courantes sont `topic`, `group`, `parent`, `membership`, `reaction`, `tag`, `translation`, `user`, `discussion`, `poll`, `poll_option`, `stance`, `stance_choice`, `outcome` et `topic_item`. Les exclusions s’appliquent aux enregistrements associés, pas à la ressource principale demandée au point de terminaison.

Les réponses contenant une collection incluent `meta.total` lorsqu’une taille exacte de la collection est définie. Le total est calculé avant l’application de `limit` et `offset`. Les points de terminaison, comme la recherche, qui renvoient volontairement un ensemble limité de résultats omettent `meta.total` plutôt que de renvoyer `null`.

<!-- translation-section: comments -->

## Commentaires

<!-- translation-section: create-comment -->

### Créer un commentaire

Créez un commentaire dans une discussion en tant qu’utilisateur associé à la clé API.

`POST /api/user0/comments`

<!-- translation-section: params-7 -->

#### Paramètres

| Nom | Description |
| --- | --- |
| `discussion_id` | Entier, obligatoire. Identifiant de la discussion à commenter |
| `body` | Corps du commentaire, obligatoire sauf si une pièce jointe est fournie |
| `body_format` | `md` ou `html`, facultatif, valeur par défaut : `md` |

<!-- translation-section: example-9 -->

#### Exemple

```bash
curl https://www.loomio.com/api/user0/comments \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "discussion_id": 123,
    "body": "example comment",
    "body_format": "md"
  }'
```

<!-- translation-section: edit-comment -->

### Modifier un commentaire

Modifiez un commentaire en tant qu’utilisateur associé à la clé API. Les mêmes permissions que dans Loomio s’appliquent : l’utilisateur doit être autorisé à modifier ce commentaire.

`PATCH /api/user0/comments/:id`

<!-- translation-section: params-8 -->

#### Paramètres

| Nom | Description |
| --- | --- |
| `body` | Corps du commentaire mis à jour |
| `body_format` | `md` ou `html`, facultatif, valeur par défaut : `md` |

<!-- translation-section: example-10 -->

#### Exemple

```bash
curl https://www.loomio.com/api/user0/comments/123 \
  -X PATCH \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "body": "updated comment",
    "body_format": "md"
  }'
```

<!-- translation-section: soft-delete-comment -->

### Supprimer un commentaire de manière logique

Supprimez un commentaire de manière logique en tant qu’utilisateur associé à la clé API. Cette opération retire le commentaire et masque son corps tout en conservant son enregistrement.

`DELETE /api/user0/comments/:id`

<!-- translation-section: example-11 -->

#### Exemple

```bash
curl https://www.loomio.com/api/user0/comments/123 \
  -X DELETE \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

<!-- translation-section: discussions -->

## Discussions

<!-- translation-section: create-discussion -->

### Créer une discussion

Créez une discussion au nom de l’utilisateur associé à la clé API.

`POST /api/user0/discussions`

<!-- translation-section: params-3 -->

#### Paramètres

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

#### Exemple

```bash
curl https://www.loomio.com/api/user0/discussions \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "group_id": 123,
    "title": "example thread",
    "recipient_emails": [
      "person@example.com"
    ]
  }'
```

<!-- translation-section: show-discussion -->

### Afficher une discussion

Récupérez une discussion à l’aide de son identifiant, un entier, ou de sa clé, une chaîne de caractères.

`GET /api/user0/discussions/:id`

<!-- translation-section: example-3 -->

#### Exemple

```bash
curl https://www.loomio.com/api/user0/discussions/abc123 \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

<!-- translation-section: list-discussions -->

### Lister les discussions

Listez les discussions d’un groupe visibles par l’utilisateur associé à la clé API. Pour un groupe visible publiquement, une personne qui n’en est pas membre peut lister ses discussions publiques ; les discussions privées restent réservées aux utilisateurs qui peuvent les lire dans Loomio.

`GET /api/user0/discussions`

<!-- translation-section: params-4 -->

#### Paramètres

| Nom | Description |
| --- | --- |
| `group_id` | Entier, obligatoire. Identifiant du groupe dont les discussions seront listées |
| `status` | Chaîne de caractères, facultative, valeur par défaut `open`. Valeurs : `open`, `closed`, `all` |
| `limit` | Entier, facultatif, valeur par défaut 50. Taille de la page |
| `offset` | Entier, facultatif, valeur par défaut 0. Décalage pour la pagination |

Compatibilité avec les anciennes versions : `per` et `from` sont acceptés comme alias de `limit` et `offset` et continueront à fonctionner.

<!-- translation-section: example-4 -->

#### Exemple

```bash
curl 'https://www.loomio.com/api/user0/discussions?group_id=123' \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

<!-- translation-section: edit-discussion -->

### Modifier une discussion

Modifiez une discussion au nom de l’utilisateur associé à la clé API. Les mêmes permissions que dans Loomio s’appliquent : l’utilisateur doit être autorisé à modifier cette discussion.

`PATCH /api/user0/discussions/:id`

<!-- translation-section: params-6 -->

#### Paramètres

| Nom | Description |
| --- | --- |
| `title` | Titre mis à jour |
| `description` | Contexte mis à jour |
| `description_format` | `md` ou `html`, facultatif, valeur par défaut `md` |
| `recipient_audience` | `group` ou null. Si la valeur est `group`, tout le groupe sera informé de la modification |
| `recipient_user_ids` | Tableau d’identifiants d’utilisateurs à informer ou à inviter dans le fil |
| `recipient_emails` | Tableau d’adresses e-mail des personnes à inviter dans le fil |
| `recipient_message` | Message à inclure dans l’invitation par e-mail |

<!-- translation-section: example-7 -->

#### Exemple

```bash
curl https://www.loomio.com/api/user0/discussions/123 \
  -X PATCH \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "title": "updated thread title",
    "description": "updated context",
    "description_format": "md"
  }'
```

<!-- translation-section: soft-delete-discussion -->

### Supprimer une discussion de manière logique

Supprimez une discussion de manière logique en tant qu’utilisateur associé à la clé API. Cette opération retire la discussion tout en conservant son enregistrement.

`DELETE /api/user0/discussions/:id`

<!-- translation-section: example-8 -->

#### Exemple

```bash
curl https://www.loomio.com/api/user0/discussions/123 \
  -X DELETE \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

<!-- translation-section: groups -->

## Groupes

<!-- translation-section: list-groups -->

<!-- translation-correction: {"before":"ministrateurs du groupe |\n| `delegates_count` | Nombre de délégués |\n| `discussions_count` | Nombre de ","after":"ministrateurs du groupe |\n| `discussions_count` | Nombre de "} -->

### Lister les groupes

Renvoie les groupes dans lesquels l’utilisateur associé à la clé API a une adhésion active.

`GET /api/user0/groups`

| Nom | Description |
| --- | --- |
| `limit` | Entier, facultatif, valeur par défaut 50, maximum 500. Taille de la page |
| `offset` | Entier, facultatif, valeur par défaut 0. Décalage pour la pagination |

```bash
curl 'https://www.loomio.com/api/user0/groups?limit=50&offset=0' \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

La réponse contient une page de `groups` triée par identifiant de groupe croissant, avec le nombre total de groupes correspondants dans `meta.total`. Elle inclut les groupes parents et les sous-groupes, y compris les groupes dont l’abonnement n’est pas actuellement actif. Vérifiez le champ `enabled` lorsqu’une intégration doit fonctionner uniquement avec les groupes activés.

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

`GET /api/user0/groups/:id_or_key_or_handle`

L’identifiant peut être l’identifiant numérique, la clé ou l’identifiant lisible du groupe.

```bash
curl https://www.loomio.com/api/user0/groups/123 \
  -H 'Authorization: Bearer YOUR_API_KEY'

curl https://www.loomio.com/api/user0/groups/example-group \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

La réponse contient le groupe dans le tableau `groups` et utilise les mêmes champs que le point de terminaison de liste. Une requête visant un groupe auquel l’utilisateur associé à la clé API ne peut pas accéder renvoie une erreur de permission.

<!-- translation-section: memberships -->

## Adhésions

<!-- translation-section: list-memberships -->

### Lister les adhésions

Listez les adhésions visibles par l’utilisateur associé à la clé API. Les membres du groupe peuvent consulter les noms, les identifiants, les titres et les rôles des membres. Les adresses e-mail sont incluses uniquement pour le compte de l’utilisateur associé à la clé API ou lorsque cet utilisateur est administrateur du groupe.

`GET /api/user0/memberships`

<!-- translation-section: params-12 -->

#### Paramètres

| Nom | Description |
| --- | --- |
| `group_id` | Entier, obligatoire. Identifiant du groupe dont les adhésions seront listées |
| `limit` | Entier, facultatif, valeur par défaut 50. Taille de la page |
| `offset` | Entier, facultatif, valeur par défaut 0. Décalage pour la pagination |

Compatibilité avec les anciennes versions : `per` et `from` sont acceptés comme alias de `limit` et `offset` et continueront de fonctionner.

La réponse contient une page de `memberships` et les `users` associés. `meta.total` est le nombre total d’adhésions visibles dans le groupe avant pagination.

<!-- translation-section: example-17 -->

#### Exemple

```bash
curl 'https://www.loomio.com/api/user0/memberships?group_id=123&limit=50&offset=0' \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

<!-- translation-section: manage-memberships -->

### Gérer les adhésions

Envoyez une liste d’adresses e-mail. Toutes les nouvelles adresses e-mail recevront une invitation à rejoindre le groupe. Contrairement à la consultation de la liste des adhésions, cette opération nécessite les droits d’administration du groupe.

`POST /api/user0/memberships`

<!-- translation-section: params-13 -->

#### Paramètres

| Nom | Description |
| --- | --- |
| `group_id` | Entier, obligatoire. Identifiant du groupe dont les adhésions seront gérées |
| `emails` | Tableau de chaînes de caractères, obligatoire. Adresses e-mail des personnes à inviter dans le groupe |
| `remove_absent` | Booléen. Si la valeur est true, retire du groupe toute personne dont l’adresse e-mail ne figure pas dans la liste |

<!-- translation-section: example-18 -->

#### Exemple

```bash
curl https://www.loomio.com/api/user0/memberships \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "group_id": 123,
    "emails": [
      "person@example.com"
    ]
  }'
```

Si vous transmettez `remove_absent=1`, tous les membres du groupe qui ne figurent pas dans la liste seront retirés du groupe. Faites attention, vous pourriez retirer tous les membres de votre groupe.

```bash
curl https://www.loomio.com/api/user0/memberships \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "group_id": 123,
    "emails": [
      "person@example.com"
    ],
    "remove_absent": 1
  }'
```

Cette opération renvoie un objet contenant `{added_emails: ["person@added.com"], removed_emails: ["person@removed.com"]}`.

<!-- translation-section: participation-report -->

## Rapport de participation

Renvoie les mêmes données de participation agrégées que celles utilisées par le rapport de participation de Loomio.

`GET /api/user0/reports`

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
curl 'https://www.loomio.com/api/user0/reports?section=users&group_scope=custom&group_ids=123&member_type=delegate&start_month=2026-01&end_month=2026-09' \
  -H 'Authorization: Bearer YOUR_API_KEY'
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

<!-- translation-section: polls -->

## Sondages

<!-- translation-section: create-poll -->

### Créer un sondage

Créez un sondage en tant qu’utilisateur associé à la clé API.

`POST /api/user0/polls`

<!-- translation-section: params-9 -->

#### Paramètres

| Nom | Description |
| --- | --- |
| `group_id` | Entier, facultatif, null par défaut. Identifiant du groupe du sondage. Si `discussion_id` est fourni, `group_id` est ignoré |
| `discussion_id` | Entier, facultatif, null par défaut. Identifiant du fil de discussion auquel ajouter ce sondage |
| `title` | Chaîne de caractères, obligatoire. Titre du sondage |
| `poll_type` | Chaîne de caractères, obligatoire. Valeurs : `proposal`, `poll`, `count`, `score`, `ranked_choice`, `meeting`, `dot_vote` |
| `details` | Chaîne de caractères, facultative. Texte du sondage |
| `details_format` | Chaîne de caractères, facultative, `md` par défaut. Valeurs : `md` ou `html` |
| `options` | Noms simples des options sous forme de tableau de chaînes de caractères. Pour `proposal`, utilisez `agree`, `disagree`, `abstain` ou `block` pour obtenir les libellés, icônes, significations et questions standard. Pour `meeting`, fournissez des chaînes de caractères représentant des dates ou des dates et heures au format ISO 8601. Pour les autres types de sondage, fournissez les noms des options. Pour des options détaillées, utilisez plutôt `poll_options_attributes` |
| `poll_options_attributes` | Alternative à `options` : un tableau d’objets décrivant les options avec leurs noms, significations, questions, icônes et ordre. Consultez [Créer un sondage avec des options détaillées](#create-a-poll-with-detailed-options) |
| `reason_prompt` | Chaîne de caractères, facultative. Question commune demandant la raison du vote, utilisée par les types de sondage sans question propre à chaque option, comme `poll`, `score` et `ranked_choice` |
| `stance_reason_required` | Chaîne de caractères, `optional` par défaut. Valeurs : `disabled`, `optional`, `required`, `required_for_disagree_or_block`, `required_for_block`. Les deux dernières s’appliquent aux icônes `disagree` et `block`. Les sondages anonymes désactivent les raisons du vote |
| `closing_at` | Chaîne de caractères au format ISO 8601 ou null, null par défaut. Exemple : `2026-09-01T12:00:00Z`. Si la valeur est null, le vote est désactivé et le sondage est considéré comme en cours de préparation |
| `specified_voters_only` | Booléen, facultatif, false par défaut. Si la valeur est true, seules les personnes désignées peuvent voter. Si la valeur est false, toutes les personnes du groupe seront invitées à voter |
| `hide_results` | Chaîne de caractères, facultative, `off` par défaut. Valeurs : `off`, `until_vote`, `until_closed` |
| `shuffle_options` | Booléen, false par défaut. Affiche les options aux électeurs dans un ordre aléatoire |
| `anonymous` | Booléen, facultatif, false par défaut. Masque l’identité des électeurs |
| `recipient_audience` | `group` ou null, facultatif, null par défaut. Si la valeur est `group`, tout le groupe recevra une notification |
| `notify_on_closing_soon` | Chaîne de caractères, facultative, `nobody` par défaut. Valeurs : `nobody`, `author`, `voters_uncast`, `voters` |
| `recipient_user_ids` | Tableau d’identifiants d’utilisateurs à notifier ou à inviter |
| `recipient_emails` | Tableau d’adresses e-mail des personnes à inviter à voter |
| `recipient_message` | Message à inclure dans l’invitation par e-mail |
| `notify_recipients` | Booléen, false par défaut. Si la valeur est false, les personnes sont ajoutées sans envoi de notifications. Si la valeur est true, toutes les personnes invitées par cette requête recevront une notification par e-mail |

<!-- translation-section: example-12 -->

#### Exemple

```bash
curl https://www.loomio.com/api/user0/polls \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "group_id": 123,
    "title": "example poll",
    "poll_type": "proposal",
    "options": [
      "agree",
      "disagree"
    ],
    "closing_at": "2026-09-01T12:00:00Z",
    "recipient_emails": [
      "person@example.com"
    ]
  }'
```

<!-- translation-section: poll-many-options -->

#### Créer un brouillon de sondage avec de nombreuses options

Envoyez tous les noms des options dans le tableau `options`. Si vous omettez `closing_at`, le sondage est créé en cours de préparation et le vote est désactivé ; le sondage reste visible aux personnes qui peuvent lire son fil. Ajoutez une valeur future pour `closing_at` lorsque vous souhaitez ouvrir le vote.

Ajoutez tous les noms de vos options au tableau :

```bash
curl https://www.loomio.com/api/user0/polls \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "group_id": 123,
    "title": "Meeting venue",
    "poll_type": "poll",
    "options": [
      "Town hall",
      "Library",
      "Community centre"
    ]
  }'
```

<!-- translation-section: poll-detailed-options -->

#### Créer un sondage avec des options détaillées

Utilisez `options` pour une liste de noms, ou `poll_options_attributes` lorsque chaque option nécessite une signification, une question demandant la raison du vote ou une icône. Choisissez un seul format par requête. Les deux formats fonctionnent dans un corps JSON plat ou à l’intérieur d’un objet `poll`.

Chaque objet de `poll_options_attributes` accepte les champs suivants :

| Champ | Description |
| --- | --- |
| `name` | Chaîne de caractères, obligatoire pour une nouvelle option. Libellé affiché aux électeurs |
| `meaning` | Chaîne de caractères, facultative. Explique ce que signifie le choix de cette option |
| `prompt` | Chaîne de caractères, facultative. Question demandant la raison du vote, affichée lorsque cette option est sélectionnée dans un sondage de type `proposal`, `count` ou `check`. Pour les autres types de sondage, définissez `reason_prompt` sur le sondage |
| `icon` | Chaîne de caractères, facultative. Pour `proposal`, `count` et `check`, utilisez `agree`, `disagree`, `abstain` ou `block` |
| `priority` | Entier. Ordre des options, à partir de `0`. Fournissez une priorité distincte pour chaque option ; les options de réunion sont quant à elles classées par date |
| `test_operator` | Chaîne de caractères ou null, facultatif. Condition portant sur la part des votes : `gte` signifie au moins, `lte` signifie au plus. Définissez la valeur sur null pour désactiver cette condition |
| `test_percent` | Entier, facultatif. Pourcentage utilisé pour la condition portant sur la part des votes, de `0` à `100` |
| `test_against` | Chaîne de caractères, facultative. `score_percent` compare la part de l’option dans le total des notes ou des points attribués ; `voter_percent` compare ses électeurs à l’ensemble des électeurs autorisés à voter |
| `id` | Entier. À inclure lors de la modification d’une option existante ; à omettre pour une nouvelle option |
| `_destroy` | Booléen, facultatif. Définissez la valeur sur `true` avec l’`id` d’une option existante pour la supprimer |

Créez une proposition avec des libellés d’options et des questions personnalisés :

```bash
curl https://www.loomio.com/api/user0/polls \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "group_id": 123,
    "title": "Should we adopt this proposal?",
    "poll_type": "proposal",
    "stance_reason_required": "optional",
    "poll_options_attributes": [
      {
        "name": "Support",
        "meaning": "I support adopting this proposal",
        "prompt": "What do you support about it?",
        "icon": "agree",
        "priority": 0
      },
      {
        "name": "Oppose",
        "meaning": "I would prefer another approach",
        "prompt": "What would you change?",
        "icon": "disagree",
        "priority": 1
      }
    ]
  }'
```

Pour un sondage classique, utilisez le même format d’options détaillées avec un `reason_prompt` commun défini sur le sondage :

```bash
curl https://www.loomio.com/api/user0/polls \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "group_id": 123,
    "title": "Choose a venue",
    "poll_type": "poll",
    "reason_prompt": "Why do you prefer this venue?",
    "stance_reason_required": "optional",
    "poll_options_attributes": [
      {
        "name": "Town hall",
        "meaning": "Central, accessible venue",
        "priority": 0
      },
      {
        "name": "Library",
        "meaning": "Smaller room with no hire fee",
        "priority": 1
      }
    ]
  }'
```

Ces exemples omettent `closing_at` ; le vote reste donc désactivé jusqu’à ce qu’une date de clôture future soit définie.

<!-- translation-section: show-poll -->

### Afficher un sondage

Récupérez un sondage à l’aide de son identifiant, un entier, ou de sa clé, une chaîne de caractères.

`GET /api/user0/polls/:id`

<!-- translation-section: example-13 -->

#### Exemple

```bash
curl https://www.loomio.com/api/user0/polls/abc123 \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

<!-- translation-section: list-polls -->

### Lister les sondages

Listez les sondages d’un groupe visibles par l’utilisateur de la clé API. Pour un groupe visible publiquement, une personne qui n’en est pas membre peut lister ses sondages publics ; les sondages privés restent réservés aux utilisateurs qui peuvent les consulter dans Loomio. La réponse inclut la conclusion actuelle de chaque sondage visible. Vous pouvez donc utiliser `status=closed` pour lister les propositions ayant fait l’objet d’une décision.

`GET /api/user0/polls`

<!-- translation-section: params-10 -->

#### Paramètres

| Nom | Description |
| --- | --- |
| `group_id` | Entier, obligatoire. Identifiant du groupe dont vous souhaitez lister les sondages |
| `status` | Chaîne de caractères, facultative, `active` par défaut. Valeurs : `active`, `closed`, `all` |
| `limit` | Entier, facultatif, 50 par défaut. Taille de la page |
| `offset` | Entier, facultatif, 0 par défaut. Décalage pour la pagination |

Compatibilité avec les anciens paramètres : `per` et `from` sont acceptés comme alias de `limit` et `offset` et continueront à fonctionner.

<!-- translation-section: example-14 -->

#### Exemple

```bash
curl 'https://www.loomio.com/api/user0/polls?group_id=123' \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

<!-- translation-section: edit-poll -->

### Modifier un sondage

Modifiez un sondage en tant qu’utilisateur de la clé API. Les mêmes permissions que dans Loomio s’appliquent : l’utilisateur doit être autorisé à modifier ce sondage.

`PATCH /api/user0/polls/:id`

<!-- translation-section: params-11 -->

#### Paramètres

| Nom | Description |
| --- | --- |
| `title` | Titre mis à jour |
| `details` | Détails du sondage mis à jour |
| `details_format` | `md` ou `html`, facultatif, `md` par défaut |
| `options` | Noms des options mis à jour. La modification des options peut affecter les votes existants selon l’état du sondage |
| `poll_options_attributes` | Alternative à `options`. Modifiez les objets d’options détaillées par leur `id`, ajoutez des objets sans `id` ou supprimez une option avec son `id` et `_destroy: true`. Les options omises restent inchangées |
| `reason_prompt` | Question commune demandant la raison du vote mise à jour pour les types de sondage sans question propre à chaque option |
| `stance_reason_required` | Exigence relative à la raison du vote mise à jour ; les mêmes valeurs s’appliquent que lors de la création d’un sondage |
| `closing_at` | Chaîne de caractères au format ISO 8601 ou null |
| `recipient_audience` | `group` ou null. Si la valeur est `group`, tout le groupe recevra une notification |
| `recipient_user_ids` | Tableau d’identifiants d’utilisateurs à notifier ou à inviter |
| `recipient_emails` | Tableau d’adresses e-mail des personnes à inviter à voter |
| `recipient_message` | Message à inclure dans l’invitation par e-mail |

<!-- translation-section: example-15 -->

#### Exemple

```bash
curl https://www.loomio.com/api/user0/polls/123 \
  -X PATCH \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "title": "updated poll title",
    "details": "updated details",
    "details_format": "md"
  }'
```

<!-- translation-section: edit-poll-detailed-options -->

#### Modifier les options détaillées

Récupérez les identifiants des options dans le tableau `poll_options` d’une réponse de création ou de consultation. Envoyez uniquement les champs à modifier, avec l’`id` de chaque option existante :

```bash
curl https://www.loomio.com/api/user0/polls/123 \
  -X PATCH \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "poll_options_attributes": [
      {
        "id": 456,
        "meaning": "Updated explanation",
        "prompt": "What would improve this proposal?"
      },
      {
        "name": "Abstain",
        "meaning": "I leave the decision to others",
        "icon": "abstain",
        "priority": 2
      }
    ]
  }'
```

Les identifiants des options doivent appartenir au sondage en cours de modification. Vous devez avoir l’autorisation de modifier le sondage, et les sondages clôturés ne peuvent pas être modifiés. Les sondages anonymes figent également la configuration des options dès qu’un premier bulletin de vote est soumis.

<!-- translation-section: soft-delete-poll -->

### Supprimer un sondage sans effacer son enregistrement

Supprimez un sondage en tant qu’utilisateur de la clé API. Cette opération retire le sondage tout en conservant son enregistrement.

`DELETE /api/user0/polls/:id`

<!-- translation-section: example-16 -->

#### Exemple

```bash
curl https://www.loomio.com/api/user0/polls/123 \
  -X DELETE \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

<!-- translation-section: search -->

## Recherche

Recherchez les discussions, commentaires, sondages, votes et conclusions visibles par l’utilisateur associé à la clé API. Les résultats incluent le contenu public même si l’utilisateur n’est pas membre du groupe concerné ; le contenu privé reste soumis aux règles habituelles de visibilité des fils.

`GET /api/user0/search`

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
curl 'https://www.loomio.com/api/user0/search?query=quarterly+planning&type=Discussion' \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

La réponse contient un tableau `search_results`. Chaque résultat identifie l’enregistrement correspondant et son contexte visible avec des champs comprenant `searchable_type`, `searchable_id`, `highlight`, `group_id`, `group_name`, `discussion_key`, `poll_key`, `author_id`, `author_name`, `authored_at` et `tags`. Les champs qui ne s’appliquent pas à un résultat ont la valeur `null`.

<!-- translation-section: threads -->

## Fils

<!-- translation-section: list-threads -->

### Lister les fils

Listez les fils de discussion et les fils de sondage visibles par l’utilisateur de la clé API, classés par activité la plus récente. L’identifiant d’un fil est son `topic_id`.

`GET /api/user0/threads`

<!-- translation-section: params-5 -->

#### Paramètres

| Nom | Description |
| --- | --- |
| `limit` | Entier, facultatif, valeur par défaut 50. Taille de la page |
| `offset` | Entier, facultatif, valeur par défaut 0. Décalage pour la pagination |

<!-- translation-section: example-5 -->

#### Exemple

```bash
curl 'https://www.loomio.com/api/user0/threads?limit=50&offset=0' \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

<!-- translation-section: read-thread -->

### Lire un fil

Lisez un fil, son flux d’événements ordonné ou son document Markdown visible complet.

`GET /api/user0/threads/:topic_id`

`GET /api/user0/threads/:topic_id/items`

`GET /api/user0/threads/:topic_id/markdown`

Le point de terminaison `items` accepte les paramètres de pagination suivants :

| Nom | Description |
| --- | --- |
| `limit` | Entier, facultatif, valeur par défaut 50, maximum 500. Taille de la page |
| `offset` | Entier, facultatif, valeur par défaut 0. Décalage pour la pagination |

<!-- translation-section: example-6 -->

#### Exemple

```text
GET https://www.loomio.com/api/user0/threads/<topic_id>
GET https://www.loomio.com/api/user0/threads/<topic_id>/items?limit=50&offset=0
GET https://www.loomio.com/api/user0/threads/<topic_id>/markdown
```

Le point de terminaison `items` renvoie une page du flux d’événements dans l’ordre croissant de leur séquence, comprenant les commentaires, sondages, votes et conclusions visibles. `meta.total` indique le nombre total d’éléments du fil. Récupérez les pages suivantes pour lire l’intégralité du flux. Le point de terminaison `markdown` renvoie l’intégralité du contenu visible du fil dans un seul document Markdown. Les raisons des votes ne sont incluses que lorsqu’elles sont visibles par l’utilisateur de la clé API.

Tous les points de terminaison relatifs aux fils appliquent les mêmes permissions que l’interface Loomio. La clé API ne donne pas accès à un fil que l’utilisateur ne peut pas ouvrir normalement.

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

`GET /api/user0/chatbots?group_id=123`

| Nom | Description |
| --- | --- |
| `group_id` | Entier, obligatoire. Identifiant du groupe dont les webhooks seront listés |
| `limit` | Entier, facultatif, valeur par défaut 50, maximum 500. Taille de la page |
| `offset` | Entier, facultatif, valeur par défaut 0. Décalage pour la pagination |

```bash
curl 'https://www.loomio.com/api/user0/chatbots?group_id=123&limit=50&offset=0' \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

La réponse contient une page de `chatbots` classés par identifiant d’intégration croissant, avec le nombre total pour le groupe dans `meta.total`. Chaque intégration possède les champs suivants :

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

`POST /api/user0/chatbots`

```bash
curl https://www.loomio.com/api/user0/chatbots \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "group_id": 123,
    "name": "Planning system",
    "kind": "webhook",
    "webhook_kind": "markdown",
    "server": "https://hooks.example.org/loomio/unguessable-token",
    "event_kinds": [
      "new_discussion",
      "new_comment",
      "poll_created",
      "outcome_created"
    ],
    "notification_only": false
  }'
```

L’utilisateur associé à la clé API doit être administrateur du groupe désigné par `group_id`. Avant son enregistrement, la destination est vérifiée pour confirmer qu’il s’agit d’une URL publique.

<!-- translation-section: update-a-webhook -->

### Mettre à jour un webhook

`PATCH /api/user0/chatbots/:id`

Envoyez les champs à modifier. Le webhook ne peut pas être transféré à un autre groupe en modifiant `group_id`.

```bash
curl https://www.loomio.com/api/user0/chatbots/456 \
  -X PATCH \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "name": "Planning events",
    "event_kinds": [
      "new_discussion",
      "outcome_created"
    ]
  }'
```

<!-- translation-section: test-a-webhook-destination -->

### Tester la destination d’un webhook

Envoyez un message de test compatible avec Markdown à une destination avant ou après l’enregistrement de sa configuration.

`POST /api/user0/chatbots/check`

```bash
curl https://www.loomio.com/api/user0/chatbots/check \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  --json '{
    "group_id": 123,
    "server": "https://hooks.example.org/loomio/unguessable-token"
  }'
```

<!-- translation-section: delete-a-webhook -->

### Supprimer un webhook

`DELETE /api/user0/chatbots/:id`

```bash
curl https://www.loomio.com/api/user0/chatbots/456 \
  -X DELETE \
  -H 'Authorization: Bearer YOUR_API_KEY'
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
