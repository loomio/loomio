---
title: API du serveur
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
  introduction: d342b93ffbf7bd9c
  authentication: a5723ee0092b6c7d
  user-object: 90f4faab979ee743
  list-users: 520de4776ee59488
  example: d846f9ad81a21076
  show-user: b71c4abd1e2d9af0
  examples: f35b3640390e4704
  update-user: 56f62f7bb09daf3b
  params: 441b416646e2ab6f
  examples-2: 93764b35184d8245
  deactivate-user: b691433ca25a4b2d
  examples-3: 8873bd3b3bab3243
  reactivate-user: 05fa751f5c32340b
  examples-4: 7ebbcda2c88b36dd
  redact-user: 072d699449872bd6
  examples-5: dfbafabd939b0979
  delete-user: 1e285d16ef2e6795
  examples-6: e1dd1081d8446715
  sso-profile-sync-settings: 121a65c62fc28de4
  provisioning: 185124072ab75728
title_source: 370e81eb20eece44
title_generated: 8705cb84226ab509
---

<!-- translation-section: introduction -->

# Documentation de l’API du serveur Loomio

<!-- seo-description: Utilisez l’API du serveur Loomio pour créer des comptes utilisateurs, découvrir les groupes et gérer les adhésions sur une installation Loomio auto-hébergée. -->

`/api/server0` est destiné aux opérations au niveau du serveur. Utilisez `/api/user0` pour les actions effectuées avec un compte utilisateur Loomio.

Utilisez une seule clé de serveur pour créer et gérer les comptes, découvrir les groupes de l’installation et gérer leurs adhésions et leurs rôles. Aucun compte de robot, aucune clé API utilisateur ni aucune adhésion aux groupes n’est nécessaire. Les clés API utilisateur restent soumises aux autorisations de groupe de l’utilisateur.

<!-- translation-section: authentication -->

## Authentification

La clé correspond au paramètre `SERVER_API_KEY` dans l’environnement du serveur. `create_env.sh` en génère une pour les nouvelles installations.

Envoyez la clé sous forme de jeton Bearer :

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users
```

Envoyez les informations d’authentification uniquement dans l’en-tête `Authorization`. Les clés API présentes dans les chaînes de requête ou les corps de requête sont rejetées.

<!-- translation-section: provisioning -->

## Créer des comptes et gérer les adhésions

| Méthode | Point de terminaison | Fonction |
| --- | --- | --- |
| `POST` | `/api/server0/users` | Créer un compte |
| `GET` | `/api/server0/groups` | Découvrir les groupes de l’installation |
| `GET` | `/api/server0/memberships` | Lister les adhésions à un groupe |
| `POST` | `/api/server0/memberships` | Inviter des membres ou synchroniser une liste complète de membres |
| `PATCH` | `/api/server0/memberships/:id` | Modifier les rôles d’administrateur et de délégué du groupe |
| `DELETE` | `/api/server0/memberships/:id` | Révoquer une adhésion |

Les points de terminaison existants pour la mise à jour, la désactivation, la réactivation, l’anonymisation et la suppression des comptes sont décrits ci-dessous.

### Créer un compte

`POST /api/server0/users`

Envoyez un objet `user` avec le champ obligatoire `email`. Les espaces en début et en fin d’adresse e-mail sont supprimés et les adresses sont converties en minuscules. Les champs facultatifs sont `name`, `username` et `is_admin`. Ici, `is_admin` désigne un administrateur de l’instance ; les rôles d’administrateur de groupe sont gérés au niveau des adhésions. Omettez `username` pour en générer un automatiquement. Les champs inconnus sont rejetés.

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

La réponse contient le code HTTP `201` et un objet `user`. Des champs invalides ou une adresse e-mail ou un nom d’utilisateur déjà utilisé entraînent une réponse HTTP `422`. La création d’un compte n’envoie pas d’invitation, ne connecte pas la personne et ne marque pas son adresse e-mail comme vérifiée. Invitez cette personne à un groupe via le point de terminaison des adhésions pour envoyer une invitation selon le processus habituel de notification.

### Découvrir les groupes

`GET /api/server0/groups`

Listez tous les groupes qui n’ont pas été supprimés, y compris les groupes privés et ceux dont l’abonnement a expiré. Les résultats sont classés par identifiant croissant. Utilisez `limit` (valeur par défaut et maximale : `50`) et `offset` (valeur par défaut : `0`) pour les parcourir par pages.

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

### Lister les adhésions

`GET /api/server0/memberships?group_id=123`

`group_id` est obligatoire. Les résultats comprennent les adhésions acceptées et les invitations en attente, classées par identifiant d’adhésion croissant. Les adhésions révoquées sont exclues. Utilisez `limit` (valeur par défaut et maximale : `50`) et `offset` (valeur par défaut : `0`) pour la pagination.

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

`admin` et `delegate` sont des rôles au sein du groupe. `accepted_at` est l’horodatage de l’acceptation, ou `null` tant qu’une invitation est en attente. Ce point de terminaison ne divulgue ni les jetons d’invitation, ni les identifiants de connexion, ni les votes.

### Inviter ou synchroniser des membres

`POST /api/server0/memberships`

Envoyez un champ `group_id` et un tableau `emails`, tous deux obligatoires. Par défaut, cette opération ajoute les personnes de la liste qui n’ont pas déjà une adhésion active et conserve tous les autres membres. Les espaces en début et en fin d’adresse e-mail sont supprimés, les adresses sont converties en minuscules et les doublons sont éliminés. Les nouvelles adresses entraînent la création de comptes et d’invitations en attente. Les membres existants dont l’adresse e-mail est vérifiée et qui appartiennent à un autre groupe actif de la même organisation sont acceptés automatiquement, conformément au processus d’invitation de l’API utilisateur.

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

Pour synchroniser une liste complète de membres, définissez explicitement `remove_absent` sur `true`. Toute personne absente de la liste est retirée de ce groupe et de ses sous-groupes. Un tableau vide avec `remove_absent: true` retire tout le monde, y compris les administrateurs du groupe. Omettez `remove_absent` ou définissez-le sur `false` si vous souhaitez uniquement ajouter des personnes. Les anciennes valeurs `1` et `0` sont également acceptées.

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

Répéter la même requête ne crée pas d’adhésions en double et ne renvoie pas les invitations. Inviter de nouveau un membre dont l’adhésion a été révoquée rétablit son accès au groupe sans rétablir un éventuel rôle d’administrateur antérieur. Les nouvelles invitations et les changements de rôle suivent le processus habituel de notification, sans qu’aucun utilisateur soit enregistré comme auteur de l’action.

Les listes d’adresses e-mail manquantes ou mal formées et les valeurs booléennes invalides entraînent une réponse HTTP `400`. La présence d’un compte désactivé dans la liste entraîne une réponse HTTP `422` ; réactivez-le explicitement avant de l’ajouter. Des données de compte invalides, les limites d’abonnement ou d’autres erreurs annulent l’ensemble de la synchronisation, y compris les nouveaux comptes et les révocations d’adhésion. Les ajouts nécessitent un groupe actif et restent soumis au nombre maximal de membres autorisé par l’abonnement.

### Mettre à jour les rôles d’une adhésion

`PATCH /api/server0/memberships/:id`

Envoyez un objet `membership` contenant l’un des champs booléens `admin` et `delegate`, ou les deux. Les rôles omis restent inchangés. Les champs inconnus sont rejetés ; ce point de terminaison ne permet pas de transférer une adhésion, d’accepter une invitation ni de modifier la pondération des votes.

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

Renvoie un objet `membership` avec les mêmes champs qu’une adhésion figurant dans la liste. L’attribution d’un rôle crée la notification habituelle pour ce rôle ; renvoyer un rôle inchangé ne déclenche pas de nouvelle notification. Les changements de rôle nécessitent un groupe actif. Les adhésions révoquées entraînent une réponse HTTP `404`.

### Révoquer une adhésion

`DELETE /api/server0/memberships/:id`

```bash
curl https://loomio.example.org/api/server0/memberships/456 \
  -X DELETE \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY'
```

Renvoie `{"success": true}`. La révocation retire l’accès au groupe et à ses sous-groupes, y compris l’accès aux sujets et les droits de vote dans les sondages actifs. Elle ne supprime pas le compte, ne modifie pas les autres groupes et ne retire pas l’accès accordé directement aux fils. Répéter une révocation réussit. Vous pouvez révoquer des adhésions dans les groupes dont l’abonnement a expiré ; les groupes supprimés entraînent une réponse HTTP `404`.

<!-- translation-section: user-object -->

## Objet utilisateur

Les réponses contenant des utilisateurs suivent cette structure :

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

## Lister les utilisateurs

Listez tous les comptes utilisateurs de l’installation Loomio.

`GET /api/server0/users`

<!-- translation-section: example -->

### Exemple

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users
```

Renvoie :

```json
{
  "users": []
}
```

<!-- translation-section: show-user -->

## Afficher un utilisateur

Recherchez un utilisateur à partir de son identifiant utilisateur Loomio ou de son identité externe.

`GET /api/server0/users/:id`

`GET /api/server0/users/identity/:identity_type/:uid`

<!-- translation-section: examples -->

### Exemples

Par identifiant utilisateur Loomio :

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123
```

Par identité externe :

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123
```

Renvoie :

```json
{
  "user": {}
}
```

<!-- translation-section: update-user -->

## Mettre à jour un utilisateur

Mettez à jour les champs du profil d’un utilisateur trouvé à partir de son identifiant utilisateur Loomio ou de son identité externe.

`PATCH /api/server0/users/:id`

`PATCH /api/server0/users/identity/:identity_type/:uid`

<!-- translation-section: params -->

### Paramètres

| Champ | Description |
| --- | --- |
| `name` | Nom affiché |
| `username` | Nom d’utilisateur Loomio |
| `email` | Adresse e-mail |

<!-- translation-section: examples-2 -->

### Exemples

Par identifiant utilisateur Loomio :

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/server0/users/123
```

Par identité externe :

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/server0/users/identity/oauth/external-123
```

Renvoie l’utilisateur mis à jour :

```json
{
  "user": {}
}
```

<!-- translation-section: deactivate-user -->

## Désactiver un utilisateur

Désactivez un compte utilisateur trouvé à partir de son identifiant utilisateur Loomio ou de son identité externe.

`POST /api/server0/users/:id/deactivate`

`POST /api/server0/users/identity/:identity_type/:uid/deactivate`

<!-- translation-section: examples-3 -->

### Exemples

Par identifiant utilisateur Loomio :

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123/deactivate
```

Par identité externe :

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123/deactivate
```

Renvoie :

```json
{
  "success": true,
  "user": {}
}
```

<!-- translation-section: reactivate-user -->

## Réactiver un utilisateur

Réactivez un compte utilisateur désactivé en le recherchant par son identifiant utilisateur Loomio ou son identité externe.

`POST /api/server0/users/:id/reactivate`

`POST /api/server0/users/identity/:identity_type/:uid/reactivate`

<!-- translation-section: examples-4 -->

### Exemples

Par identifiant utilisateur Loomio :

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123/reactivate
```

Par identité externe :

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123/reactivate
```

Renvoie :

```json
{
  "success": true,
  "user": {}
}
```

<!-- translation-section: redact-user -->

## Effacer les données personnelles d’un utilisateur

L’effacement des données personnelles conserve les commentaires de l’utilisateur et les autres contenus qu’il a créés au sein de ses groupes, mais supprime les informations connues permettant de l’identifier, telles que son nom, sa biographie, sa photo de profil, son adresse e-mail, ses identifiants de connexion, ses identités et ses sessions actives.

C’est la méthode recommandée pour retirer un utilisateur de Loomio.

`POST /api/server0/users/:id/redact`

`POST /api/server0/users/identity/:identity_type/:uid/redact`

<!-- translation-section: examples-5 -->

### Exemples

Par identifiant utilisateur Loomio :

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123/redact
```

Par identité externe :

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123/redact
```

Renvoie :

```json
{
  "success": true
}
```

<!-- translation-section: delete-user -->

## Supprimer un utilisateur

La suppression retire l’utilisateur et les enregistrements qu’il a créés. Les commentaires sont supprimés des fils, les votes sont supprimés des sondages, et les groupes, discussions, sondages et autres enregistrements créés par l’utilisateur peuvent également être supprimés par le biais des associations de la base de données.

Cette opération est très destructive. L’effacement des données personnelles est fortement recommandé à la place.

`DELETE /api/server0/users/:id`

`DELETE /api/server0/users/identity/:identity_type/:uid`

<!-- translation-section: examples-6 -->

### Exemples

Par identifiant utilisateur Loomio :

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123
```

Par identité externe :

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123
```

Renvoie :

```json
{
  "success": true
}
```

<!-- translation-section: sso-profile-sync-settings -->

## Paramètres de synchronisation du profil SSO

Utilisez ces paramètres lorsqu’un autre système gère les champs du profil Loomio.

```env
LOOMIO_DISABLE_EDIT_USER_PROFILE=1
# LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1
```

`LOOMIO_DISABLE_EDIT_USER_PROFILE=1` empêche les utilisateurs de modifier eux-mêmes ces champs :

| Champ | Notes |
| --- | --- |
| `name` | Géré par une synchronisation externe |
| `username` | Géré par une synchronisation externe |
| `email` | Géré par une synchronisation externe |
| `avatar_kind` / `uploaded_avatar` | Gérés par une synchronisation externe |

Les utilisateurs peuvent toujours modifier les champs propres à Loomio, tels que `short_bio` et `location`.

`LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1` met à jour `name` et `email` à partir des données de connexion SSO. Laissez ce paramètre en commentaire ou non défini lorsqu’un script de synchronisation externe doit être la seule source de ces mises à jour.

`LOOMIO_SSO_FORCE_USER_ATTRS` fonctionne toujours pour les installations existantes. Ce paramètre empêche les utilisateurs de modifier ces champs et met à jour `name` et `email` lors de la connexion SSO.
