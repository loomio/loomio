---
title: API del servidor
source_revision: 2d360988a87765e6a1345dd06155bc988154178e
source_file: docs/help/en/user_manual/integrations/api/server-api.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-23'
sections:
  introduction: 8b28f9c34e3f7575
  authentication: cbabcc874f053455
  user-object: 7e9e8ff3e48a4055
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
  provisioning: 590e1f295602247d
generated:
  introduction: 1a264007f5af5b1c
  authentication: a565887f03230c99
  user-object: b019a967473c8e83
  list-users: 75361385532784b7
  example: 39c3508f1a79310f
  show-user: 6e1c14170eb6a758
  examples: bdde7958671dc288
  update-user: 41f228cd42c4ef42
  params: 42660e2e26cd2f89
  examples-2: 16c19c727e5e0e73
  deactivate-user: b0b9d7fa60abed82
  examples-3: 51cdad0f7f5bcb95
  reactivate-user: 8eea66563f5c35b2
  examples-4: 27ebb086d4b5298b
  redact-user: 59dac8710ce7719e
  examples-5: 90dacd80913a0a19
  delete-user: 5c749fd38df63325
  examples-6: 304108503603f9f1
  sso-profile-sync-settings: e5c4912041cc426f
  provisioning: d9efc17d5f364c86
title_source: 370e81eb20eece44
title_generated: 52f1803799fb221f
---

<!-- translation-section: introduction -->

# Documentación de la API del servidor de Loomio

<!-- seo-description: Usa la API del servidor de Loomio para crear cuentas de usuario, descubrir grupos y gestionar membresías en una instalación de Loomio autoalojada. -->

`/api/b3` sirve para operaciones a nivel del servidor. Usa `/api/b2` para acciones orientadas al usuario realizadas mediante una cuenta de usuario de Loomio.

Usa una única clave de servidor para crear y gestionar cuentas, descubrir grupos en toda la instalación y gestionar las membresías y los roles de esos grupos. No se requiere una cuenta de bot, una clave de API de usuario ni pertenecer a los grupos. Las claves de API de usuario siguen respetando los permisos del usuario en los grupos.

<!-- translation-section: authentication -->

## Autenticación

Establece `B3_API_KEY` como una clave secreta de más de 16 caracteres.

Envía la clave como un token de portador:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
```

Envía las credenciales únicamente en la cabecera `Authorization`. Las claves de API en cadenas de consulta o cuerpos de solicitud se rechazan.

<!-- translation-section: provisioning -->

## Crear cuentas y gestionar membresías

| Método | Endpoint | Finalidad |
| --- | --- | --- |
| `POST` | `/api/b3/users` | Crear una cuenta |
| `GET` | `/api/b3/groups` | Descubrir grupos en toda la instalación |
| `GET` | `/api/b3/memberships` | Listar las membresías de un grupo |
| `POST` | `/api/b3/memberships` | Invitar a miembros o sincronizar una lista completa de membresías |
| `PATCH` | `/api/b3/memberships/:id` | Cambiar los roles de admin del grupo y delegado |
| `DELETE` | `/api/b3/memberships/:id` | Revocar una membresía |

Los endpoints existentes para actualizar, desactivar, reactivar, anonimizar y eliminar cuentas se describen más abajo.

### Crear una cuenta

`POST /api/b3/users`

Envía un objeto `user` con el campo obligatorio `email`. Se eliminan los espacios al principio y al final de las direcciones de correo electrónico y se convierten a minúsculas. Los campos opcionales son `name`, `username` e `is_admin`. Aquí, `is_admin` indica un administrador de la instancia; los roles de admin del grupo se gestionan en las membresías. Omite `username` para generar uno automáticamente. Se rechazan los campos desconocidos.

```bash
curl https://loomio.example.org/api/b3/users \
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

La respuesta es HTTP `201` con un objeto `user`. Los campos no válidos o un correo electrónico o nombre de usuario que ya esté en uso devuelven HTTP `422`. Crear una cuenta no envía una invitación, no inicia la sesión de la persona ni marca el correo electrónico como verificado. Invita a esa persona a un grupo mediante el endpoint de membresías para enviar una invitación a través del flujo habitual de notificaciones.

### Descubrir grupos

`GET /api/b3/groups`

Lista todos los grupos que no se hayan eliminado, incluidos los grupos privados y los grupos con suscripciones vencidas. Los resultados se ordenan por ID ascendente. Usa `limit` (valor predeterminado y máximo: `50`) y `offset` (valor predeterminado: `0`) para recorrerlos por páginas.

```bash
curl 'https://loomio.example.org/api/b3/groups?limit=50&offset=0' \
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

### Listar membresías

`GET /api/b3/memberships?group_id=123`

`group_id` es obligatorio. Los resultados incluyen las membresías aceptadas y las invitaciones pendientes, ordenadas por ID de membresía ascendente. Se excluyen las membresías revocadas. Usa `limit` (valor predeterminado y máximo: `50`) y `offset` (valor predeterminado: `0`) para la paginación.

```bash
curl 'https://loomio.example.org/api/b3/memberships?group_id=123&limit=50&offset=0' \
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

`admin` y `delegate` son roles del grupo. `accepted_at` es la marca de tiempo de aceptación, o `null` mientras la invitación está pendiente. Este endpoint no expone tokens de invitación, credenciales de inicio de sesión ni votos.

### Invitar o sincronizar miembros

`POST /api/b3/memberships`

Envía los campos obligatorios `group_id` y `emails`, este último como un array. De forma predeterminada, se añaden las personas de la lista que aún no tengan una membresía activa, sin cambiar las demás membresías. Se eliminan los espacios al principio y al final de las direcciones de correo electrónico, se convierten a minúsculas y se eliminan los duplicados. Las direcciones nuevas crean cuentas e invitaciones pendientes. Los miembros verificados que ya pertenezcan a otro grupo activo de la misma organización se aceptan automáticamente, siguiendo el flujo de invitaciones de la API de usuario.

```bash
curl https://loomio.example.org/api/b3/memberships \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  --json '{
    "group_id": 123,
    "emails": [
      "ada@example.org",
      "alex@example.org"
    ]
  }'
```

Para sincronizar una lista completa de membresías, establece explícitamente `remove_absent` en `true`. Se elimina de ese grupo y de sus subgrupos a cualquier persona que no figure en la lista. Un array vacío con `remove_absent: true` elimina a todos, incluidos los admins del grupo. Omite `remove_absent` o establécelo en `false` cuando solo quieras añadir personas. También se aceptan los valores antiguos `1` y `0`.

```bash
curl https://loomio.example.org/api/b3/memberships \
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

Repetir la misma solicitud no crea membresías duplicadas ni repite las invitaciones. Volver a invitar a un miembro con una membresía revocada restablece el acceso al grupo sin restablecer un rol anterior de admin. Las nuevas invitaciones y los cambios de rol usan el flujo habitual de notificaciones, sin registrar a ningún usuario como autor de la acción.

Las listas de correo electrónico ausentes o con un formato incorrecto y los valores booleanos no válidos devuelven HTTP `400`. Si la lista incluye una cuenta desactivada, se devuelve HTTP `422`; reactívala explícitamente antes de añadirla. Los datos de cuenta no válidos, los límites de la suscripción u otros fallos revierten toda la sincronización, incluidas las cuentas nuevas y las eliminaciones de membresías. Para añadir personas, el grupo debe estar activo y se siguen aplicando los límites de miembros de la suscripción.

### Actualizar los roles de una membresía

`PATCH /api/b3/memberships/:id`

Envía un objeto `membership` que contenga uno o ambos campos booleanos `admin` y `delegate`. Los roles omitidos no cambian. Se rechazan los campos desconocidos; el endpoint no permite transferir una membresía, aceptar una invitación ni cambiar el peso de los votos.

```bash
curl https://loomio.example.org/api/b3/memberships/456 \
  -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  --json '{
    "membership": {
      "admin": true,
      "delegate": false
    }
  }'
```

Devuelve un objeto `membership` con los mismos campos que una membresía de la lista. Conceder un rol crea la notificación de rol habitual; repetir un rol sin cambios no vuelve a enviar una notificación. Los cambios de rol requieren un grupo activo. Las membresías revocadas devuelven HTTP `404`.

### Eliminar una membresía

`DELETE /api/b3/memberships/:id`

```bash
curl https://loomio.example.org/api/b3/memberships/456 \
  -X DELETE \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY'
```

Devuelve `{"success": true}`. La eliminación revoca el acceso al grupo y a sus subgrupos, incluidos el acceso a los temas y el derecho a votar en encuestas activas. No elimina la cuenta, no modifica grupos ajenos a esa membresía ni elimina el acceso directo a hilos. Repetir una eliminación también tiene éxito. Puedes eliminar membresías de grupos con suscripciones vencidas; los grupos eliminados devuelven HTTP `404`.

<!-- translation-section: user-object -->

## Objeto de usuario

Las respuestas de usuario tienen esta estructura:

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

## Mostrar un usuario

Busca un usuario por el ID de usuario de Loomio o la identidad externa.

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

Actualiza los campos del perfil de un usuario localizado por el ID de usuario de Loomio o la identidad externa.

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

Desactiva una cuenta de usuario localizada por el ID de usuario de Loomio o la identidad externa.

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

Reactiva una cuenta de usuario desactivada localizada mediante el ID de usuario de Loomio o una identidad externa.

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

La eliminación de datos personales conserva los comentarios del usuario y otros contenidos que haya generado en los grupos a los que pertenece, pero elimina la información conocida que permite identificarlo, como el nombre, la biografía, la foto de perfil, la dirección de correo electrónico, las credenciales de acceso, las identidades y las sesiones activas.

Esta es la forma recomendada de eliminar un usuario de Loomio.

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

## Eliminar un usuario

La eliminación borra el usuario y los registros que haya creado. Los comentarios se eliminan de los hilos y los votos se eliminan de las encuestas. Los grupos, las discusiones, las encuestas y otros registros creados por el usuario también pueden eliminarse mediante las asociaciones de la base de datos.

Esta operación es muy destructiva. Se recomienda encarecidamente eliminar los datos personales en su lugar.

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

## Ajustes de sincronización del perfil mediante SSO

Usa estos ajustes cuando otro sistema gestione los campos del perfil de Loomio.

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
| `avatar_kind` / `uploaded_avatar` | Gestionados mediante sincronización externa |

Los usuarios pueden seguir editando campos locales de Loomio, como `short_bio` y `location`.

`LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1` actualiza `name` y `email` a partir de los datos de inicio de sesión mediante SSO. Déjalo comentado o sin definir cuando un script de sincronización externa deba ser la única fuente de esas actualizaciones.

`LOOMIO_SSO_FORCE_USER_ATTRS` sigue funcionando en las instalaciones existentes. Impide que los usuarios editen esos campos y actualiza `name` y `email` al iniciar sesión mediante SSO.
