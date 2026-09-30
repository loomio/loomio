---
title: API del servidor
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
  introduction: 036da8d8524e2a34
  authentication: 8addc55beba492c4
  user-object: 13713701dd7b2cbe
  list-users: 75361385532784b7
  example: 39c3508f1a79310f
  show-user: '08c1df672536acd1'
  examples: bdde7958671dc288
  update-user: 135fd2c136c7d295
  params: 42660e2e26cd2f89
  examples-2: 16c19c727e5e0e73
  deactivate-user: 3871d29010a50243
  examples-3: 51cdad0f7f5bcb95
  reactivate-user: da1b7110121743d4
  examples-4: 27ebb086d4b5298b
  redact-user: 821d1a2e1e598c85
  examples-5: 90dacd80913a0a19
  delete-user: 1a7b4a1dde4b32c8
  examples-6: 304108503603f9f1
  sso-profile-sync-settings: 0baa0ff941f51290
title_source: 370e81eb20eece44
title_generated: 52f1803799fb221f
---

<!-- translation-section: introduction -->

# Documentación de la API del servidor de Loomio

<!-- seo-description: Usa la API del servidor de Loomio para gestionar cuentas de usuario en una instalación de Loomio alojada en tu propio servidor. -->

`/api/b3` sirve para operaciones del servidor. Usa `/api/b2` para las acciones que se realizan desde una cuenta de usuario de Loomio.

<!-- translation-section: authentication -->

## Autenticación

Configura `B3_API_KEY` con un valor secreto de más de 16 caracteres.

Envía la clave como token de portador:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
```

Envía las credenciales solo en la cabecera `Authorization`. Se rechazan las claves de API incluidas en la cadena de consulta o en el cuerpo de la solicitud.

<!-- translation-section: user-object -->

## Objeto de usuario

Las respuestas de usuario tienen esta estructura:

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

## Listar usuarios

Lista todas las cuentas de usuario de la instalación de Loomio.

`GET /api/b3/users`

<!-- translation-section: example -->

### Ejemplo

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
```

Devuelve:

```json
{
  "users": []
}
```

<!-- translation-section: show-user -->

## Consultar un usuario

Busca un usuario por su ID de usuario de Loomio o por su identidad externa.

`GET /api/b3/users/:id`

`GET /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples -->

### Ejemplos

Por ID de usuario de Loomio:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123
```

Por identidad externa:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123
```

Devuelve:

```json
{
  "user": {}
}
```

<!-- translation-section: update-user -->

## Actualizar un usuario

Actualiza los campos del perfil de un usuario identificado por su ID de usuario de Loomio o por su identidad externa.

`PATCH /api/b3/users/:id`

`PATCH /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: params -->

### Parámetros

| Campo | Descripción |
| --- | --- |
| `name` | Nombre visible |
| `username` | Nombre de usuario de Loomio |
| `email` | Dirección de correo electrónico |

<!-- translation-section: examples-2 -->

### Ejemplos

Por ID de usuario de Loomio:

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/b3/users/123
```

Por identidad externa:

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/b3/users/identity/oauth/external-123
```

Devuelve el usuario actualizado:

```json
{
  "user": {}
}
```

<!-- translation-section: deactivate-user -->

## Desactivar un usuario

Desactiva una cuenta de usuario identificada por su ID de usuario de Loomio o por su identidad externa.

`POST /api/b3/users/:id/deactivate`

`POST /api/b3/users/identity/:identity_type/:uid/deactivate`

<!-- translation-section: examples-3 -->

### Ejemplos

Por ID de usuario de Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/deactivate
```

Por identidad externa:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/deactivate
```

Devuelve:

```json
{
  "success": true,
  "user": {}
}
```

<!-- translation-section: reactivate-user -->

## Reactivar un usuario

Reactiva una cuenta de usuario desactivada identificada por su ID de usuario de Loomio o por su identidad externa.

`POST /api/b3/users/:id/reactivate`

`POST /api/b3/users/identity/:identity_type/:uid/reactivate`

<!-- translation-section: examples-4 -->

### Ejemplos

Por ID de usuario de Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/reactivate
```

Por identidad externa:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/reactivate
```

Devuelve:

```json
{
  "success": true,
  "user": {}
}
```

<!-- translation-section: redact-user -->

## Eliminar los datos personales de un usuario

Este proceso conserva los comentarios y otros contenidos creados por el usuario en sus grupos, pero elimina los datos personales conocidos que permiten identificarlo, como el nombre, la biografía, la foto de perfil, la dirección de correo electrónico, las credenciales de inicio de sesión, las identidades y las sesiones activas.

Este es el método recomendado para eliminar a un usuario de Loomio.

`POST /api/b3/users/:id/redact`

`POST /api/b3/users/identity/:identity_type/:uid/redact`

<!-- translation-section: examples-5 -->

### Ejemplos

Por ID de usuario de Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/redact
```

Por identidad externa:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/redact
```

Devuelve:

```json
{
  "success": true
}
```

<!-- translation-section: delete-user -->

## Eliminar usuario

La eliminación borra al usuario y los registros que creó. Sus comentarios se eliminan de los hilos y sus votos, de los sondeos. Las asociaciones de la base de datos también pueden eliminar los grupos, las discusiones, los sondeos y otros registros que creó.

Esta acción tiene efectos muy destructivos. Se recomienda encarecidamente anonimizar al usuario en su lugar.

`DELETE /api/b3/users/:id`

`DELETE /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples-6 -->

### Ejemplos

Por ID de usuario de Loomio:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123
```

Por identidad externa:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123
```

Devuelve:

```json
{
  "success": true
}
```

<!-- translation-section: sso-profile-sync-settings -->

## Configuración de la sincronización del perfil mediante SSO

Usa esta configuración cuando otro sistema gestione los campos del perfil de Loomio.

```env
LOOMIO_DISABLE_EDIT_USER_PROFILE=1
# LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1
```

`LOOMIO_DISABLE_EDIT_USER_PROFILE=1` impide que los usuarios editen estos campos por sí mismos:

| Campo | Notas |
| --- | --- |
| `name` | Gestionado mediante sincronización externa |
| `username` | Gestionado mediante sincronización externa |
| `email` | Gestionado mediante sincronización externa |
| `avatar_kind` / `uploaded_avatar` | Gestionado mediante sincronización externa |

Los usuarios todavía pueden editar campos propios de Loomio, como `short_bio` y `location`.

`LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1` actualiza `name` y `email` con los datos de inicio de sesión mediante SSO. Deja la línea comentada o la variable sin definir si solo un script de sincronización externa debe actualizar esos campos.

`LOOMIO_SSO_FORCE_USER_ATTRS` sigue funcionando en las instalaciones existentes. Impide que los usuarios editen el perfil y actualiza `name` y `email` al iniciar sesión mediante SSO.
