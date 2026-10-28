---
title: API del servidor
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
  introduction: '0156193d339e8fe7'
  authentication: 0b30c414db3dd474
  user-object: b019a967473c8e83
  list-users: 69759d1905328994
  example: 858b50a631eebcf1
  show-user: 9dea2a1824073bec
  examples: e0e35f976ffeb5f7
  update-user: 1067292c60ffcb63
  params: 42660e2e26cd2f89
  examples-2: f2097cb96918a07e
  deactivate-user: aa9e57455595dbb4
  examples-3: '0451974d46271905'
  reactivate-user: 8826c20daf954d39
  examples-4: ac3957867ca09209
  redact-user: e3c5fa54cc7b37c2
  examples-5: 818c819964919486
  delete-user: 71f0c98d64af9e5e
  examples-6: 4f8a8bcbe7458f84
  sso-profile-sync-settings: e5c4912041cc426f
  provisioning: ff4f67c3fa838106
title_source: 370e81eb20eece44
title_generated: 52f1803799fb221f
---

<!-- translation-section: introduction -->

# Documentación de la API del servidor de Loomio

<!-- seo-description: Usa la API del servidor de Loomio para crear cuentas de usuario, descubrir grupos y gestionar membresías en una instalación de Loomio autoalojada. -->

`/api/server0` sirve para operaciones a nivel del servidor. Usa `/api/user0` para acciones orientadas al usuario realizadas mediante una cuenta de usuario de Loomio.

Usa una única clave de servidor para crear y gestionar cuentas, descubrir grupos en toda la instalación y gestionar las membresías y los roles de esos grupos. No se requiere una cuenta de bot, una clave de API de usuario ni pertenecer a los grupos. Las claves de API de usuario siguen respetando los permisos del usuario en los grupos.

<!-- translation-section: authentication -->

## Autenticación

La clave se define mediante el ajuste `SERVER_API_KEY` en el entorno del servidor. `create_env.sh` genera una para las nuevas instalaciones.

Envía la clave como un token de portador:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users
```

Envía las credenciales únicamente en la cabecera `Authorization`. Las claves de API en cadenas de consulta o cuerpos de solicitud se rechazan.

<!-- translation-section: provisioning -->

## Crear cuentas y gestionar membresías

| Método | Endpoint | Finalidad |
| --- | --- | --- |
| `POST` | `/api/server0/users` | Crear una cuenta |
| `GET` | `/api/server0/groups` | Descubrir grupos en toda la instalación |
| `GET` | `/api/server0/memberships` | Listar las membresías de un grupo |
| `POST` | `/api/server0/memberships` | Invitar a miembros o sincronizar una lista completa de membresías |
| `PATCH` | `/api/server0/memberships/:id` | Cambiar los roles de admin del grupo y delegado |
| `DELETE` | `/api/server0/memberships/:id` | Revocar una membresía |

Los endpoints existentes para actualizar, desactivar, reactivar, anonimizar y eliminar cuentas se describen más abajo.

### Crear una cuenta

`POST /api/server0/users`

Envía un objeto `user` con el campo obligatorio `email`. Se eliminan los espacios al principio y al final de las direcciones de correo electrónico y se convierten a minúsculas. Los campos opcionales son `name`, `username` e `is_admin`. Aquí, `is_admin` indica un administrador de la instancia; los roles de admin del grupo se gestionan en las membresías. Omite `username` para generar uno automáticamente. Se rechazan los campos desconocidos.

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

La respuesta es HTTP `201` con un objeto `user`. Los campos no válidos o un correo electrónico o nombre de usuario que ya esté en uso devuelven HTTP `422`. Crear una cuenta no envía una invitación, no inicia la sesión de la persona ni marca el correo electrónico como verificado. Invita a esa persona a un grupo mediante el endpoint de membresías para enviar una invitación a través del flujo habitual de notificaciones.

### Descubrir grupos

`GET /api/server0/groups`

Lista todos los grupos que no se hayan eliminado, incluidos los grupos privados y los grupos con suscripciones vencidas. Los resultados se ordenan por ID ascendente. Usa `limit` (valor predeterminado y máximo: `50`) y `offset` (valor predeterminado: `0`) para recorrerlos por páginas.

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

### Listar membresías

`GET /api/server0/memberships?group_id=123`

`group_id` es obligatorio. Los resultados incluyen las membresías aceptadas y las invitaciones pendientes, ordenadas por ID de membresía ascendente. Se excluyen las membresías revocadas. Usa `limit` (valor predeterminado y máximo: `50`) y `offset` (valor predeterminado: `0`) para la paginación.

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

`admin` y `delegate` son roles del grupo. `accepted_at` es la marca de tiempo de aceptación, o `null` mientras la invitación está pendiente. Este endpoint no expone tokens de invitación, credenciales de inicio de sesión ni votos.

### Invitar o sincronizar miembros

`POST /api/server0/memberships`

Envía los campos obligatorios `group_id` y `emails`, este último como un array. De forma predeterminada, se añaden las personas de la lista que aún no tengan una membresía activa, sin cambiar las demás membresías. Se eliminan los espacios al principio y al final de las direcciones de correo electrónico, se convierten a minúsculas y se eliminan los duplicados. Las direcciones nuevas crean cuentas e invitaciones pendientes. Los miembros verificados que ya pertenezcan a otro grupo activo de la misma organización se aceptan automáticamente, siguiendo el flujo de invitaciones de la API de usuario.

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

Para sincronizar una lista completa de membresías, establece explícitamente `remove_absent` en `true`. Se elimina de ese grupo y de sus subgrupos a cualquier persona que no figure en la lista. Un array vacío con `remove_absent: true` elimina a todos, incluidos los admins del grupo. Omite `remove_absent` o establécelo en `false` cuando solo quieras añadir personas. También se aceptan los valores antiguos `1` y `0`.

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

Repetir la misma solicitud no crea membresías duplicadas ni repite las invitaciones. Volver a invitar a un miembro con una membresía revocada restablece el acceso al grupo sin restablecer un rol anterior de admin. Las nuevas invitaciones y los cambios de rol usan el flujo habitual de notificaciones, sin registrar a ningún usuario como autor de la acción.

Las listas de correo electrónico ausentes o con un formato incorrecto y los valores booleanos no válidos devuelven HTTP `400`. Si la lista incluye una cuenta desactivada, se devuelve HTTP `422`; reactívala explícitamente antes de añadirla. Los datos de cuenta no válidos, los límites de la suscripción u otros fallos revierten toda la sincronización, incluidas las cuentas nuevas y las eliminaciones de membresías. Para añadir personas, el grupo debe estar activo y se siguen aplicando los límites de miembros de la suscripción.

### Actualizar los roles de una membresía

`PATCH /api/server0/memberships/:id`

Envía un objeto `membership` que contenga uno o ambos campos booleanos `admin` y `delegate`. Los roles omitidos no cambian. Se rechazan los campos desconocidos; el endpoint no permite transferir una membresía, aceptar una invitación ni cambiar el peso de los votos.

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

Devuelve un objeto `membership` con los mismos campos que una membresía de la lista. Conceder un rol crea la notificación de rol habitual; repetir un rol sin cambios no vuelve a enviar una notificación. Los cambios de rol requieren un grupo activo. Las membresías revocadas devuelven HTTP `404`.

### Eliminar una membresía

`DELETE /api/server0/memberships/:id`

```bash
curl https://loomio.example.org/api/server0/memberships/456 \
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

`GET /api/server0/users`

<!-- translation-section: example -->

### Ejemplo

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users
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

`GET /api/server0/users/:id`

`GET /api/server0/users/identity/:identity_type/:uid`

<!-- translation-section: examples -->

### Ejemplos

Por ID de usuario de Loomio:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123
```

Por identidad externa:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123
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

`PATCH /api/server0/users/:id`

`PATCH /api/server0/users/identity/:identity_type/:uid`

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
  https://www.loomio.com/api/server0/users/123
```

Por identidad externa:

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/server0/users/identity/oauth/external-123
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

`POST /api/server0/users/:id/deactivate`

`POST /api/server0/users/identity/:identity_type/:uid/deactivate`

<!-- translation-section: examples-3 -->

### Ejemplos

Por ID de usuario de Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123/deactivate
```

Por identidad externa:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123/deactivate
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

`POST /api/server0/users/:id/reactivate`

`POST /api/server0/users/identity/:identity_type/:uid/reactivate`

<!-- translation-section: examples-4 -->

### Ejemplos

Por ID de usuario de Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123/reactivate
```

Por identidad externa:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123/reactivate
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

`POST /api/server0/users/:id/redact`

`POST /api/server0/users/identity/:identity_type/:uid/redact`

<!-- translation-section: examples-5 -->

### Ejemplos

Por ID de usuario de Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123/redact
```

Por identidad externa:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123/redact
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

`DELETE /api/server0/users/:id`

`DELETE /api/server0/users/identity/:identity_type/:uid`

<!-- translation-section: examples-6 -->

### Ejemplos

Por ID de usuario de Loomio:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123
```

Por identidad externa:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123
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
