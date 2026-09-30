---
title: API du serveur
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/integrations/api/server-api.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-30'
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
  introduction: 3c92aa325e306378
  authentication: 83723b1dd56c6b27
  user-object: f33df5d507457730
  list-users: 6b62bd5ff67ab5e9
  example: ed0ef4e6f3dfd24c
  show-user: 93f90b0a12e6e8c1
  examples: edc9f7d0db53279d
  update-user: f630e0b4abbb7949
  params: 441b416646e2ab6f
  examples-2: 3799cf2821a36b1e
  deactivate-user: a13cf100e6222995
  examples-3: aad792bbd473617f
  reactivate-user: 4e8242b4825a9927
  examples-4: e45acac3f44612a3
  redact-user: de131f0ab511c4c2
  examples-5: f953c0a2acecbfd0
  delete-user: 365534b7fbf613ea
  examples-6: 71e798a49595750a
  sso-profile-sync-settings: fa6882b8888f76b1
title_source: 370e81eb20eece44
title_generated: 8705cb84226ab509
---

<!-- translation-section: introduction -->

# Documentation de l’API du serveur Loomio

<!-- seo-description: Utilisez l’API du serveur Loomio pour gérer les comptes utilisateurs d’une installation Loomio auto-hébergée. -->

`/api/b3` sert aux opérations au niveau du serveur. Utilisez `/api/b2` pour les actions effectuées avec un compte utilisateur Loomio.

<!-- translation-section: authentication -->

## Authentification

Définissez `B3_API_KEY` avec une valeur secrète de plus de 16 caractères.

Envoyez la clé comme jeton Bearer :

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
```

Envoyez les identifiants uniquement dans l’en-tête `Authorization`. Les clés API placées dans la chaîne de requête ou le corps de la requête sont refusées.

<!-- translation-section: user-object -->

## Objet utilisateur

Les réponses concernant un utilisateur ont cette structure :

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

Renvoie :

```json
{
  "users": []
}
```

<!-- translation-section: show-user -->

## Afficher un utilisateur

Recherchez un utilisateur par son identifiant utilisateur Loomio ou son identité externe.

`GET /api/b3/users/:id`

`GET /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples -->

### Exemples

Par identifiant utilisateur Loomio :

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123
```

Par identité externe :

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123
```

Renvoie :

```json
{
  "user": {}
}
```

<!-- translation-section: update-user -->

## Mettre à jour un utilisateur

Mettez à jour les champs du profil d’un utilisateur recherché par son identifiant utilisateur Loomio ou son identité externe.

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

Par identifiant utilisateur Loomio :

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/b3/users/123
```

Par identité externe :

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/b3/users/identity/oauth/external-123
```

Renvoie l’utilisateur mis à jour :

```json
{
  "user": {}
}
```

<!-- translation-section: deactivate-user -->

## Désactiver un utilisateur

Désactivez un compte utilisateur recherché par son identifiant utilisateur Loomio ou son identité externe.

`POST /api/b3/users/:id/deactivate`

`POST /api/b3/users/identity/:identity_type/:uid/deactivate`

<!-- translation-section: examples-3 -->

### Exemples

Par identifiant utilisateur Loomio :

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/deactivate
```

Par identité externe :

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/deactivate
```

Renvoie :

```json
{
  "success": true,
  "user": {}
}
```

<!-- translation-section: reactivate-user -->

## Réactiver un utilisateur

Réactivez un compte utilisateur désactivé recherché par son identifiant utilisateur Loomio ou son identité externe.

`POST /api/b3/users/:id/reactivate`

`POST /api/b3/users/identity/:identity_type/:uid/reactivate`

<!-- translation-section: examples-4 -->

### Exemples

Par identifiant utilisateur Loomio :

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/reactivate
```

Par identité externe :

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/reactivate
```

Renvoie :

```json
{
  "success": true,
  "user": {}
}
```

<!-- translation-section: redact-user -->

## Effacer les données personnelles d’un utilisateur

L’effacement des données personnelles conserve les commentaires et les autres contenus créés par l’utilisateur dans ses groupes. Il supprime les informations personnelles connues, notamment le nom, la biographie, la photo de profil, l’adresse e-mail, les identifiants de connexion, les identités et les sessions actives.

C’est la méthode recommandée pour retirer un utilisateur de Loomio.

`POST /api/b3/users/:id/redact`

`POST /api/b3/users/identity/:identity_type/:uid/redact`

<!-- translation-section: examples-5 -->

### Exemples

Par identifiant utilisateur Loomio :

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/redact
```

Par identité externe :

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/redact
```

Renvoie :

```json
{
  "success": true
}
```

<!-- translation-section: delete-user -->

## Supprimer un utilisateur

La suppression efface le compte utilisateur et les données créées par cette personne. Ses commentaires sont retirés des fils de discussion et ses votes des sondages. Les groupes, discussions, sondages et autres données qu’elle a créés peuvent aussi être supprimés par les associations de la base de données.

Cette opération entraîne de nombreuses suppressions. Il est fortement recommandé d’anonymiser le compte à la place.

`DELETE /api/b3/users/:id`

`DELETE /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples-6 -->

### Exemples

Par identifiant utilisateur Loomio :

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123
```

Par identité externe :

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123
```

Renvoie :

```json
{
  "success": true
}
```

<!-- translation-section: sso-profile-sync-settings -->

## Paramètres de synchronisation du profil par SSO

Utilisez ces paramètres lorsqu’un autre système gère les champs du profil Loomio.

```env
LOOMIO_DISABLE_EDIT_USER_PROFILE=1
# LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1
```

`LOOMIO_DISABLE_EDIT_USER_PROFILE=1` empêche les utilisateurs de modifier eux-mêmes ces champs :

| Champ | Remarques |
| --- | --- |
| `name` | Géré par la synchronisation externe |
| `username` | Géré par la synchronisation externe |
| `email` | Géré par la synchronisation externe |
| `avatar_kind` / `uploaded_avatar` | Géré par la synchronisation externe |

Les utilisateurs peuvent toujours modifier les champs propres à Loomio, comme `short_bio` et `location`.

`LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1` met à jour `name` et `email` à partir des données de connexion SSO. Laissez ce paramètre en commentaire ou ne le définissez pas si seul un script de synchronisation externe doit effectuer ces mises à jour.

`LOOMIO_SSO_FORCE_USER_ATTRS` fonctionne toujours sur les installations existantes. Ce paramètre empêche les utilisateurs de modifier leur profil et met à jour `name` et `email` lors de la connexion SSO.
