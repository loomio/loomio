---
title: API du serveur
source_revision: c27ee3b193231816878f1c074ff9fc2a086a88c0
source_file: docs/en/user_manual/integrations/api/server-api.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-02'
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
  introduction: 24e18419bff2fd2c
  authentication: a34b08c21c11b0e1
  user-object: bb20ba41f2e7b517
  list-users: 6b62bd5ff67ab5e9
  example: f56ff23f2d45c72c
  show-user: 2b94371c537bc586
  examples: 5edfc69a0fe8b304
  update-user: 46136578a89003db
  params: 441b416646e2ab6f
  examples-2: 2b79493022017a7e
  deactivate-user: 887b101ccb7e910d
  examples-3: '09c70dba1a9488e0'
  reactivate-user: 53713601c8bd494f
  examples-4: c52adc4707cf50fb
  redact-user: d4323cb84d684486
  examples-5: d2b60f63dd59bc4e
  delete-user: 4e1f8e3711377be5
  examples-6: 378dbc2e41fb1144
  sso-profile-sync-settings: 121a65c62fc28de4
title_source: 370e81eb20eece44
title_generated: 8705cb84226ab509
---

<!-- translation-section: introduction -->

# Documentation de l’API du serveur Loomio

<!-- seo-description: Utilisez l’API du serveur Loomio pour gérer les comptes utilisateurs sur une installation Loomio auto-hébergée. -->

`/api/b3` est destiné aux opérations au niveau du serveur. Utilisez `/api/b2` pour les actions effectuées avec un compte utilisateur Loomio.

<!-- translation-section: authentication -->

## Authentification

Définissez `B3_API_KEY` sur une valeur secrète de plus de 16 caractères.

Envoyez la clé sous forme de jeton Bearer :

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
```

Envoyez les informations d’authentification uniquement dans l’en-tête `Authorization`. Les clés API présentes dans les chaînes de requête ou les corps de requête sont rejetées.

<!-- translation-section: user-object -->

## Objet utilisateur

Les réponses contenant des utilisateurs suivent cette structure :

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

## Lister les utilisateurs

Listez tous les comptes utilisateurs de l’installation Loomio.

`GET /api/b3/users`

<!-- translation-section: example -->

### Exemple

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
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

`GET /api/b3/users/:id`

`GET /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples -->

### Exemples

Par identifiant utilisateur Loomio :

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123
```

Par identité externe :

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123
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

`PATCH /api/b3/users/:id`

`PATCH /api/b3/users/identity/:identity_type/:uid`

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
  https://www.loomio.com/api/b3/users/123
```

Par identité externe :

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/b3/users/identity/oauth/external-123
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

`POST /api/b3/users/:id/deactivate`

`POST /api/b3/users/identity/:identity_type/:uid/deactivate`

<!-- translation-section: examples-3 -->

### Exemples

Par identifiant utilisateur Loomio :

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/deactivate
```

Par identité externe :

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/deactivate
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

`POST /api/b3/users/:id/reactivate`

`POST /api/b3/users/identity/:identity_type/:uid/reactivate`

<!-- translation-section: examples-4 -->

### Exemples

Par identifiant utilisateur Loomio :

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/reactivate
```

Par identité externe :

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/reactivate
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

`POST /api/b3/users/:id/redact`

`POST /api/b3/users/identity/:identity_type/:uid/redact`

<!-- translation-section: examples-5 -->

### Exemples

Par identifiant utilisateur Loomio :

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/redact
```

Par identité externe :

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/redact
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

`DELETE /api/b3/users/:id`

`DELETE /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples-6 -->

### Exemples

Par identifiant utilisateur Loomio :

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123
```

Par identité externe :

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123
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
