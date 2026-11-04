---
title: API de usuario
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
  introduction: 518428194efe442f
  response-size-and-related-records: 13eb5ad3d4f8180e
  endpoint-summary: 8e8d44a62bbda6e7
  groups: '0778b0182dde2603'
  list-groups: 467f678cde32058b
  get-a-group: db4a774458fa28c4
  webhooks: cb286bac9df3da35
  list-webhooks: 63eda1067bbe680c
  create-a-webhook: '0038ca997c051deb'
  update-a-webhook: 7fdb6d8dde4fc1e8
  test-a-webhook-destination: '090b9cb37220fb64'
  delete-a-webhook: 33ca8d5e53ff7ee4
  event-types: acbe04f5fb86094c
  http-delivery: 12f6446dfc5e982f
  payload-formats: dbabcbb207e413b8
  search: '088edb105fe083c8'
  params: fcd75490b5d84aaf
  participation-report: ddda83b7bf088a99
  params-2: bf5e00e751a63738
  example: 4643a902de955aa4
  create-discussion: 25fcc1bbbee8d185
  params-3: ec9396c3ef70a93e
  example-2: 702a2054137fcc2e
  show-discussion: df9f1bbe14d76722
  example-3: 5d7d747ef7e14bab
  list-discussions: 2824f6a6ba0771b1
  params-4: da1d5fb3686fdd0d
  example-4: c2a015269930c6bc
  list-threads: 5f9d20fd4007c3d1
  params-5: '06846f9b3540dd90'
  example-5: 6874f8fe8947ada1
  read-thread: 436f19c7380ae4e2
  example-6: 3daaa1cf93ed68a4
  edit-discussion: 0c44990b3a948e24
  params-6: 076ba72836d49479
  example-7: 3eac8a96adb7f087
  soft-delete-discussion: 46bbb00162a39ea8
  example-8: 351c686ebca70d44
  create-comment: 5484f45c8de19b86
  params-7: 4f82ae2fc430e8dd
  example-9: e3a5994d6d2fc5b9
  edit-comment: 5ef157a7c7ade125
  params-8: e9135c94ba1e7165
  example-10: b1dd19e63dbeb83d
  soft-delete-comment: fe2eaa8f3264a1da
  example-11: 2bae0f9a23d176c5
  create-poll: f5f4b311625296eb
  params-9: 190f4563b339f7ee
  example-12: 4e93dc26627a6fd4
  show-poll: f853ba0eb1702b7c
  example-13: 15f9cb73460815ca
  list-polls: e25d3fd0de83bcc3
  params-10: f87fe79e309333f4
  example-14: 48fb25df253268d3
  edit-poll: 5c64b8aaa512f9d2
  params-11: 61876514e0586f34
  example-15: 27f27f9f42cd5116
  soft-delete-poll: c916f0b1cafcbf0b
  example-16: 03b41b26b585f21b
  list-memberships: 5a79acbf036666d4
  params-12: 4c5566d81d6293ed
  example-17: 633cb905d6ebfea2
  manage-memberships: dfc8bf38acb632d5
  params-13: 35bdd0b5136ad6eb
  example-18: cb5fc3b8755f722b
  pagination: b6690b645b004394
  comments: 2b7e71a5fa4ad037
  discussions: 3a3abec87d92732d
  memberships: 65a6a636af20437c
  polls: 7a7697d9ed7d7ebc
  threads: d445e2cafcaeba21
  request-bodies: 60c2fa5cf2f1f2d3
  poll-many-options: 4b30ac4a92d7c1b8
  poll-detailed-options: 8401aede7f014880
  edit-poll-detailed-options: '082cf04c5ae031db'
title_source: c23fb6526b722360
title_generated: 5bccf15677959a14
---

<!-- translation-section: introduction -->

# Documentación de la API de usuario de Loomio

<!-- seo-description: Usa la API de usuario de Loomio para crear y gestionar discusiones, comentarios, encuestas, hilos y membresías de grupos desde otro software. -->

`/api/user0` es la API orientada a usuarios para integraciones con Loomio. Utiliza la clave de API de una cuenta de usuario y cada acción se realiza como ese usuario.

Las operaciones de grupo utilizan las membresías y los permisos de grupo del usuario de la clave de API. Ser administrador de la instancia no amplía el acceso de una clave de API a grupos o contenido; usa la API de servidor para administrar la instancia.

Usa la clave de API de la cuenta de usuario de Loomio que realizará las acciones. Una cuenta dedicada para un bot resulta útil cuando una integración no debe recibir invitaciones a encuestas ni notificaciones.

Los usuarios que han iniciado sesión pueden encontrar la clave de API y los ID de grupo en la [página de acceso a la API](/profile/api_access).

Envía la clave de API en una cabecera `Authorization: Bearer`. Las claves de API en cadenas de consulta se rechazan porque los proxies y los registros de acceso pueden guardar las URL.

```text
Authorization: Bearer YOUR_API_KEY
```

Los ejemplos utilizan `YOUR_API_KEY`, el ID de grupo `123` y `https://www.loomio.com/`. Sustitúyelos por tu clave de API, el ID de tu grupo y la URL de tu instalación de Loomio.

<!-- translation-section: request-bodies -->

### Enviar cuerpos de solicitud

Envía JSON con `Content-Type: application/json`. Los ejemplos de cURL utilizan `--json`, que establece esta cabecera automáticamente. Los endpoints de creación y edición de discusiones, comentarios y encuestas aceptan tanto un objeto plano como un objeto anidado bajo el nombre del recurso, como `{"poll": {...}}`.

Envía los arrays como arrays JSON, por ejemplo, `"options": ["foo", "bar"]`. Si utilizas codificación de formulario, los arrays necesitan nombres de campo con corchetes, como `options[]=foo&options[]=bar`; repetir `options=foo&options=bar` conserva solo el último valor.

Comprueba el estado HTTP y el cuerpo de la respuesta después de cada solicitud. Un fallo de validación devuelve `422` con un objeto `errors`; la creación correcta de una encuesta devuelve la encuesta en `polls` y las opciones en `poll_options`.

<!-- translation-section: endpoint-summary -->

## Resumen de endpoints

| Método | Endpoint | Finalidad |
| --- | --- | --- |
| `POST` | `/api/user0/comments` | Crear un comentario o una respuesta |
| `PATCH` | `/api/user0/comments/:id` | Editar un comentario |
| `DELETE` | `/api/user0/comments/:id` | Eliminar un comentario conservando el registro |
| `POST` | `/api/user0/discussions` | Crear una discusión |
| `GET` | `/api/user0/discussions/:id` | Obtener una discusión |
| `GET` | `/api/user0/discussions` | Listar las discusiones de un grupo |
| `PATCH` | `/api/user0/discussions/:id` | Editar una discusión |
| `DELETE` | `/api/user0/discussions/:id` | Eliminar una discusión conservando el registro |
| `GET` | `/api/user0/groups` | Listar los grupos del usuario de la clave de API |
| `GET` | `/api/user0/groups/:id_or_key_or_handle` | Obtener un grupo visible |
| `GET` | `/api/user0/memberships` | Listar las membresías de un grupo |
| `POST` | `/api/user0/memberships` | Añadir miembros y, opcionalmente, eliminar los miembros ausentes de la lista |
| `GET` | `/api/user0/reports` | Generar un informe de participación |
| `POST` | `/api/user0/polls` | Crear una encuesta |
| `GET` | `/api/user0/polls/:id` | Obtener una encuesta |
| `GET` | `/api/user0/polls` | Listar las encuestas de un grupo |
| `PATCH` | `/api/user0/polls/:id` | Editar una encuesta |
| `DELETE` | `/api/user0/polls/:id` | Eliminar una encuesta conservando el registro |
| `GET` | `/api/user0/search` | Buscar discusiones, comentarios, encuestas, votos y conclusiones visibles |
| `GET` | `/api/user0/threads` | Listar los hilos visibles de discusión y de encuestas independientes |
| `GET` | `/api/user0/threads/:topic_id` | Obtener un hilo |
| `GET` | `/api/user0/threads/:topic_id/items` | Obtener los elementos ordenados de un hilo |
| `GET` | `/api/user0/threads/:topic_id/markdown` | Obtener un hilo completo en Markdown |
| `GET` | `/api/user0/chatbots` | Listar las integraciones de chat y los webhooks de un grupo |
| `POST` | `/api/user0/chatbots` | Crear una integración de chat o un webhook |
| `PATCH` | `/api/user0/chatbots/:id` | Actualizar una integración de chat o un webhook |
| `DELETE` | `/api/user0/chatbots/:id` | Eliminar una integración de chat o un webhook |
| `POST` | `/api/user0/chatbots/check` | Enviar una prueba de conexión de un webhook |

<!-- translation-section: pagination -->

## Paginación

Las discusiones, los grupos, las membresías, las encuestas, los hilos, los elementos de los hilos y los webhooks aceptan `limit` (valor predeterminado: `50`) y `offset` (valor predeterminado: `0`). Los grupos, los elementos de los hilos y los webhooks limitan `limit` a `500`.

Incrementa `offset` en el número de registros principales devueltos para obtener la página siguiente. `meta.total` es el número total de coincidencias; los registros relacionados no cuentan para el tamaño de la página.

Los informes de participación devuelven todos los datos solicitados y la búsqueda devuelve hasta 20 resultados. Ninguno admite paginación.

Las discusiones, las encuestas y las membresías también aceptan los alias heredados `per` para `limit` y `from` para `offset`. Usa `limit` y `offset` para las nuevas integraciones.

<!-- translation-section: response-size-and-related-records -->

## Registros relacionados

Las respuestas de la API de usuario utilizan un formato compuesto: los registros principales van acompañados de registros relacionados, como temas, grupos, usuarios, encuestas y reacciones. Esto permite que un cliente complete un almacén local de registros con una sola solicitud, pero puede incluir más datos de los que necesita una integración sencilla.

Pasa `compact=1` para omitir los registros relacionados voluminosos de temas, grupos, grupos principales, membresías, reacciones, etiquetas y traducciones. Los registros principales y los registros relacionados necesarios para interpretar el contenido siguen presentes.

```bash
curl 'https://www.loomio.com/api/user0/threads/123/items?compact=1' \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

Para tener un control directo, pasa `exclude_types` con los tipos de registro en singular separados por espacios. Por ejemplo, `exclude_types=group reaction` omite los grupos y las reacciones relacionados. Los valores habituales son `topic`, `group`, `parent`, `membership`, `reaction`, `tag`, `translation`, `user`, `discussion`, `poll`, `poll_option`, `stance`, `stance_choice`, `outcome` y `topic_item`. Las exclusiones se aplican a los registros relacionados, no al recurso principal solicitado al endpoint.

Las respuestas de colecciones incluyen `meta.total` cuando se define un tamaño exacto de la colección. El total se calcula antes de aplicar `limit` y `offset`. Los endpoints, como el de búsqueda, que devuelven intencionadamente un conjunto limitado de resultados omiten `meta.total` en lugar de devolver `null`.

<!-- translation-section: comments -->

## Comentarios

<!-- translation-section: create-comment -->

### Crear un comentario

Crea un comentario en una discusión como el usuario de la clave de API.

`POST /api/user0/comments`

<!-- translation-section: params-7 -->

#### Parámetros

| Nombre | Descripción |
| --- | --- |
| `discussion_id` | Entero, obligatorio. ID de la discusión en la que comentar |
| `body` | Cuerpo del comentario, obligatorio salvo que se proporcione un archivo adjunto |
| `body_format` | `md` o `html`, opcional, valor predeterminado: `md` |

<!-- translation-section: example-9 -->

#### Ejemplo

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

### Editar un comentario

Edita un comentario como el usuario de la clave de API. Se aplican los mismos permisos que en Loomio: el usuario debe tener permiso para editar ese comentario.

`PATCH /api/user0/comments/:id`

<!-- translation-section: params-8 -->

#### Parámetros

| Nombre | Descripción |
| --- | --- |
| `body` | Cuerpo actualizado del comentario |
| `body_format` | `md` o `html`, opcional, valor predeterminado: `md` |

<!-- translation-section: example-10 -->

#### Ejemplo

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

### Eliminar un comentario de forma lógica

Elimina un comentario de forma lógica como el usuario de la clave de API. Esto descarta el comentario, oculta el cuerpo del comentario y conserva el registro del comentario.

`DELETE /api/user0/comments/:id`

<!-- translation-section: example-11 -->

#### Ejemplo

```bash
curl https://www.loomio.com/api/user0/comments/123 \
  -X DELETE \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

<!-- translation-section: discussions -->

## Discusiones

<!-- translation-section: create-discussion -->

### Crear una discusión

Crea una discusión como el usuario de la clave de API.

`POST /api/user0/discussions`

<!-- translation-section: params-3 -->

#### Parámetros

| Nombre | Descripción |
| --- | --- |
| `group_id` | Grupo en el que estará el hilo |
| `title` | Título del hilo, obligatorio |
| `description` | Contexto del hilo, opcional |
| `description_format` | `md` o `html`, opcional, por defecto `md` |
| `recipient_audience` | `group` o null. Si es `group`, se notificará a todo el grupo sobre el nuevo hilo |
| `recipient_user_ids` | Array de ID de usuarios a los que notificar o invitar al hilo |
| `recipient_emails` | Array de direcciones de correo electrónico de las personas a las que invitar al hilo |
| `recipient_message` | Mensaje que se incluye en la invitación por correo electrónico |

<!-- translation-section: example-2 -->

#### Ejemplo

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

### Mostrar una discusión

Obtén una discusión usando el ID de la discusión, un número entero, o la clave, una cadena de texto.

`GET /api/user0/discussions/:id`

<!-- translation-section: example-3 -->

#### Ejemplo

```bash
curl https://www.loomio.com/api/user0/discussions/abc123 \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

<!-- translation-section: list-discussions -->

### Listar discusiones

Lista las discusiones de un grupo visibles para el usuario de la clave API. En un grupo visible públicamente, una persona que no sea miembro puede listar las discusiones públicas del grupo; las discusiones privadas siguen restringidas a los usuarios que pueden leerlas en Loomio.

`GET /api/user0/discussions`

<!-- translation-section: params-4 -->

#### Parámetros

| Nombre | Descripción |
| --- | --- |
| `group_id` | Número entero, obligatorio. ID del grupo cuyas discusiones se van a listar |
| `status` | Cadena de texto, opcional, valor predeterminado `open`. Valores: `open`, `closed`, `all` |
| `limit` | Número entero, opcional, valor predeterminado 50. Tamaño de página |
| `offset` | Número entero, opcional, valor predeterminado 0. Desplazamiento para la paginación |

Compatibilidad con versiones anteriores: `per` y `from` se aceptan como alias de `limit` y `offset` y seguirán funcionando.

<!-- translation-section: example-4 -->

#### Ejemplo

```bash
curl 'https://www.loomio.com/api/user0/discussions?group_id=123' \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

<!-- translation-section: edit-discussion -->

### Editar una discusión

Edita una discusión como el usuario de la clave API. Se aplican los mismos permisos que en Loomio: el usuario debe tener permiso para editar esa discusión.

`PATCH /api/user0/discussions/:id`

<!-- translation-section: params-6 -->

#### Parámetros

| Nombre | Descripción |
| --- | --- |
| `title` | Título actualizado |
| `description` | Contexto actualizado |
| `description_format` | `md` o `html`, opcional, valor predeterminado `md` |
| `recipient_audience` | `group` o null. Si es `group`, se notificará a todo el grupo sobre la edición |
| `recipient_user_ids` | Lista de IDs de usuarios a los que notificar o invitar al hilo |
| `recipient_emails` | Lista de direcciones de correo electrónico de las personas a las que invitar al hilo |
| `recipient_message` | Mensaje que se incluirá en la invitación por correo electrónico |

<!-- translation-section: example-7 -->

#### Ejemplo

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

### Eliminar una discusión de forma lógica

Elimina una discusión de forma lógica como el usuario de la clave de API. Esto descarta la discusión y conserva el registro de la discusión.

`DELETE /api/user0/discussions/:id`

<!-- translation-section: example-8 -->

#### Ejemplo

```bash
curl https://www.loomio.com/api/user0/discussions/123 \
  -X DELETE \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

<!-- translation-section: groups -->

## Grupos

<!-- translation-section: list-groups -->

<!-- translation-correction: {"before":"ministradores del grupo |\n| `delegates_count` | Número de delegados |\n| `discussions_count` | Número de ","after":"ministradores del grupo |\n| `discussions_count` | Número de "} -->

### Listar grupos

Devuelve los grupos en los que el usuario de la clave de API tiene una membresía activa.

`GET /api/user0/groups`

| Nombre | Descripción |
| --- | --- |
| `limit` | Entero, opcional, valor predeterminado 50, máximo 500. Tamaño de página |
| `offset` | Entero, opcional, valor predeterminado 0. Desplazamiento para la paginación |

```bash
curl 'https://www.loomio.com/api/user0/groups?limit=50&offset=0' \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

La respuesta contiene una página de `groups` ordenada por ID de grupo ascendente, con el número total de grupos coincidentes en `meta.total`. Incluye grupos principales y subgrupos, incluidos los grupos cuya suscripción no está activa actualmente. Comprueba el campo `enabled` cuando una integración deba operar solo en grupos habilitados.

Entre los campos importantes de los grupos se incluyen:

| Campo | Descripción |
| --- | --- |
| `id` | ID numérico del grupo utilizado por otros endpoints de la API de usuario |
| `key` | Clave corta y estable utilizada en las URL de Loomio |
| `handle` | Identificador del grupo legible para las personas |
| `name` | Nombre del grupo |
| `full_name` | Nombre del grupo que incluye el contexto del grupo principal |
| `parent_id` | ID numérico del grupo principal de un subgrupo; en los demás casos, `null` |
| `enabled` | Indica si el grupo y la suscripción están activos |
| `memberships_count` | Número de membresías activas y pendientes |
| `accepted_memberships_count` | Número de membresías aceptadas |
| `pending_memberships_count` | Número de invitaciones pendientes |
| `admin_memberships_count` | Número de administradores del grupo |
| `discussions_count` | Número de discusiones directamente en el grupo |
| `polls_count` | Número de encuestas directamente en el grupo |
| `subgroups_count` | Número de subgrupos |

La respuesta puede incluir ajustes adicionales del grupo, registros relacionados del grupo principal y las membresías del usuario de la API. Los clientes deben ignorar los campos que no utilizan.

<!-- translation-section: get-a-group -->

### Obtener un grupo

Devuelve un grupo visible para el usuario de la clave de API.

`GET /api/user0/groups/:id_or_key_or_handle`

El identificador puede ser el ID numérico, la clave o el identificador legible del grupo.

```bash
curl https://www.loomio.com/api/user0/groups/123 \
  -H 'Authorization: Bearer YOUR_API_KEY'

curl https://www.loomio.com/api/user0/groups/example-group \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

La respuesta contiene el grupo en el array `groups` y utiliza los mismos campos que el endpoint de listado. Una solicitud de un grupo al que el usuario de la clave de API no puede acceder devuelve un error de permisos.

<!-- translation-section: memberships -->

## Membresías

<!-- translation-section: list-memberships -->

### Listar membresías

Lista las membresías visibles para el usuario de la clave de API. Los miembros del grupo pueden consultar los nombres, los ID, los títulos y los roles de los miembros. Las direcciones de correo electrónico solo se incluyen para la cuenta del propio usuario de la clave de API o cuando ese usuario es administrador del grupo.

`GET /api/user0/memberships`

<!-- translation-section: params-12 -->

#### Parámetros

| Nombre | Descripción |
| --- | --- |
| `group_id` | Entero, obligatorio. ID del grupo cuyas membresías se listarán |
| `limit` | Entero, opcional, valor predeterminado 50. Tamaño de página |
| `offset` | Entero, opcional, valor predeterminado 0. Desplazamiento para la paginación |

Compatibilidad con versiones anteriores: `per` y `from` se aceptan como alias de `limit` y `offset` y seguirán funcionando.

La respuesta contiene una página de `memberships` y los registros de `users` relacionados. `meta.total` es el número total de membresías visibles en el grupo antes de aplicar la paginación.

<!-- translation-section: example-17 -->

#### Ejemplo

```bash
curl 'https://www.loomio.com/api/user0/memberships?group_id=123&limit=50&offset=0' \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

<!-- translation-section: manage-memberships -->

### Gestionar membresías

Envía una lista de direcciones de correo electrónico. Se enviará una invitación al grupo a todas las direcciones nuevas. A diferencia de la consulta de membresías, esta operación requiere permisos de administrador del grupo.

`POST /api/user0/memberships`

<!-- translation-section: params-13 -->

#### Parámetros

| Nombre | Descripción |
| --- | --- |
| `group_id` | Entero, obligatorio. ID del grupo cuyas membresías se gestionarán |
| `emails` | Array de cadenas de texto, obligatorio. Direcciones de correo electrónico de las personas a las que invitar al grupo |
| `remove_absent` | Booleano. Si es true, elimina del grupo a cualquier persona cuya dirección de correo electrónico no esté en la lista |

<!-- translation-section: example-18 -->

#### Ejemplo

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

Si pasas `remove_absent=1`, se eliminarán del grupo todos los miembros que no estén incluidos en la lista. Ten cuidado, podrías eliminar a todos los miembros de tu grupo.

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

Esto devuelve un objeto con `{added_emails: ["person@added.com"], removed_emails: ["person@removed.com"]}`.

<!-- translation-section: participation-report -->

## Informe de participación

Devuelve los mismos datos agregados de participación que utiliza el informe de participación de Loomio.

`GET /api/user0/reports`

<!-- translation-section: params-2 -->

### Parámetros

| Nombre | Descripción |
| --- | --- |
| `section` | Sección del informe: `base`, `users` o `countries`. Usa `users` para la actividad por persona |
| `group_scope` | `custom` o `my`. El valor antiguo `all` se trata como `my` porque las claves de la API de usuario nunca reciben acceso a toda la instancia |
| `group_ids` | ID de grupos separados por comas cuando `group_scope=custom`. Se ignoran los ID de grupos a los que el usuario de la API no pertenece |
| `start_month` | Primer mes que se incluye, en formato `YYYY-MM`; por defecto, hace 12 meses |
| `end_month` | Último mes que se incluye, en formato `YYYY-MM`; por defecto, el mes actual |
| `interval` | Intervalo para la sección `base`: `day`, `week`, `month` o `year` |
| `member_type` | Establécelo en `delegate` con `section=users` para devolver solo los delegados actuales |

Una persona es delegada cuando tiene una membresía activa como delegada en cualquiera de los grupos seleccionados. Sus recuentos se agregan para todos los grupos seleccionados. Se devuelven las filas de los delegados incluso cuando todos los recuentos de actividad son cero. Los recuentos abarcan hilos, comentarios, encuestas, votos, conclusiones y reacciones; no son tasas de participación en las votaciones. Las filas de usuarios también incluyen las papeletas de votaciones identificadas que se han emitido, utilizado para votar o dejado sin utilizar. Las encuestas anónimas se excluyen de todos los recuentos de votación por persona. `all_votes_cast` es verdadero solo cuando se ha emitido al menos una papeleta y se han utilizado todas las papeletas emitidas para votar.

La API aplica las mismas reglas de visibilidad de los grupos que el informe de la aplicación. Una clave de la API de usuario no puede revelar datos del informe de grupos a los que ese usuario no puede acceder.

<!-- translation-section: example -->

### Ejemplo

```bash
curl 'https://www.loomio.com/api/user0/reports?section=users&group_scope=custom&group_ids=123&member_type=delegate&start_month=2026-01&end_month=2026-09' \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

El array `users` contiene filas completas de actividad:

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

## Encuestas

<!-- translation-section: create-poll -->

### Crear una encuesta

Crea una encuesta como el usuario de la clave de API.

`POST /api/user0/polls`

<!-- translation-section: params-9 -->

#### Parámetros

| Nombre | Descripción |
| --- | --- |
| `group_id` | Entero, opcional, null por defecto. ID del grupo de la encuesta. Si se proporciona `discussion_id`, se ignora `group_id` |
| `discussion_id` | Entero, opcional, null por defecto. ID del hilo de discusión al que añadir esta encuesta |
| `title` | Cadena de texto, obligatoria. Título de la encuesta |
| `poll_type` | Cadena de texto, obligatoria. Valores: `proposal`, `poll`, `count`, `score`, `ranked_choice`, `meeting`, `dot_vote` |
| `details` | Cadena de texto, opcional. Texto del cuerpo de la encuesta |
| `details_format` | Cadena de texto, opcional, `md` por defecto. Valores: `md` o `html` |
| `options` | Nombres simples de opciones como array de cadenas de texto. Para `proposal`, usa `agree`, `disagree`, `abstain` o `block` para obtener las etiquetas, los iconos, los significados y las preguntas estándar. Para `meeting`, proporciona cadenas de texto con fechas o fechas y horas en formato ISO 8601. Para los demás tipos de encuesta, proporciona nombres de opciones. Para opciones detalladas, usa `poll_options_attributes` en su lugar |
| `poll_options_attributes` | Alternativa a `options`: un array de objetos de opciones con nombres, significados, preguntas, iconos y orden. Consulta [Crear una encuesta con opciones detalladas](#create-a-poll-with-detailed-options) |
| `reason_prompt` | Cadena de texto, opcional. Pregunta compartida para el motivo del voto, utilizada por los tipos de encuesta sin preguntas por opción, como `poll`, `score` y `ranked_choice` |
| `stance_reason_required` | Cadena de texto, `optional` por defecto. Valores: `disabled`, `optional`, `required`, `required_for_disagree_or_block`, `required_for_block`. Los dos últimos se aplican a los iconos `disagree` y `block`. Las encuestas anónimas deshabilitan los motivos del voto |
| `closing_at` | Cadena de texto en formato ISO 8601 o null, null por defecto. Ejemplo: `2026-09-01T12:00:00Z`. Si es null, la votación está deshabilitada y la encuesta se considera en preparación |
| `specified_voters_only` | Booleano, opcional, false por defecto. Si es true, solo pueden votar las personas especificadas. Si es false, se invitará a votar a todas las personas del grupo |
| `hide_results` | Cadena de texto, opcional, `off` por defecto. Valores: `off`, `until_vote`, `until_closed` |
| `shuffle_options` | Booleano, false por defecto. Muestra las opciones a los votantes en orden aleatorio |
| `anonymous` | Booleano, opcional, false por defecto. Oculta las identidades de los votantes |
| `recipient_audience` | `group` o null, opcional, null por defecto. Si es `group`, se notificará a todo el grupo |
| `notify_on_closing_soon` | Cadena de texto, opcional, `nobody` por defecto. Valores: `nobody`, `author`, `voters_uncast`, `voters` |
| `recipient_user_ids` | Array de IDs de usuarios a quienes notificar o invitar |
| `recipient_emails` | Array de direcciones de correo electrónico de personas a quienes invitar a votar |
| `recipient_message` | Mensaje que se incluirá en la invitación por correo electrónico |
| `notify_recipients` | Booleano, false por defecto. Si es false, añade personas sin enviar notificaciones. Si es true, todas las personas invitadas en esta solicitud recibirán una notificación por correo electrónico |

<!-- translation-section: example-12 -->

#### Ejemplo

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

#### Crear un borrador de encuesta con muchas opciones

Envía todos los nombres de las opciones en el array `options`. Omitir `closing_at` crea una encuesta en preparación con la votación deshabilitada; no oculta la encuesta a las personas que pueden leer el hilo. Añade un valor futuro de `closing_at` cuando estés listo para abrir la votación.

Añade todos los nombres de tus opciones al array:

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

#### Crear una encuesta con opciones detalladas

Usa `options` para una lista de nombres, o `poll_options_attributes` cuando cada opción necesite un significado, una pregunta para el motivo del voto o un icono. Elige un formato por solicitud. Ambos formatos funcionan en un cuerpo JSON plano o dentro de un objeto `poll`.

Cada objeto de `poll_options_attributes` acepta estos campos:

| Campo | Descripción |
| --- | --- |
| `name` | Cadena de texto, obligatoria para una opción nueva. La etiqueta que se muestra a los votantes |
| `meaning` | Cadena de texto, opcional. Explica qué significa elegir esta opción |
| `prompt` | Cadena de texto, opcional. Pregunta para el motivo del voto que se muestra al seleccionar esta opción en una encuesta de tipo `proposal`, `count` o `check`. Para los demás tipos de encuesta, establece `reason_prompt` en la encuesta |
| `icon` | Cadena de texto, opcional. Para `proposal`, `count` y `check`, usa `agree`, `disagree`, `abstain` o `block` |
| `priority` | Entero. Orden de las opciones, empezando por `0`. Proporciona una prioridad distinta para cada opción; las opciones de reunión se ordenan por fecha |
| `test_operator` | Cadena de texto o null, opcional. Requisito de proporción de votos: `gte` significa como mínimo y `lte` significa como máximo. Establece null para deshabilitar el requisito |
| `test_percent` | Entero, opcional. Porcentaje para el requisito de proporción de votos, de `0` a `100` |
| `test_against` | Cadena de texto, opcional. `score_percent` compara la proporción de la opción respecto a la puntuación total o los puntos asignados; `voter_percent` compara los votantes de la opción con todos los votantes con derecho a voto |
| `id` | Entero. Inclúyelo al editar una opción existente; omítelo para una opción nueva |
| `_destroy` | Booleano, opcional. Establece `true` junto con el `id` de una opción existente para eliminarla |

Crea una propuesta con etiquetas y preguntas personalizadas para las opciones:

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

Para una encuesta normal, usa el mismo formato de opciones detalladas con un `reason_prompt` compartido en la encuesta:

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

Estos ejemplos omiten `closing_at`, por lo que la votación permanece deshabilitada hasta que se establezca una fecha de cierre futura.

<!-- translation-section: show-poll -->

### Mostrar una encuesta

Obtén una encuesta mediante el ID de la encuesta, un entero, o la clave, una cadena de texto.

`GET /api/user0/polls/:id`

<!-- translation-section: example-13 -->

#### Ejemplo

```bash
curl https://www.loomio.com/api/user0/polls/abc123 \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

<!-- translation-section: list-polls -->

### Listar encuestas

Lista las encuestas de un grupo visibles para el usuario de la clave de API. En un grupo visible públicamente, una persona que no sea miembro puede listar las encuestas públicas; las encuestas privadas siguen restringidas a los usuarios que pueden leerlas en Loomio. La respuesta incluye la conclusión actual de cada encuesta visible, por lo que puedes usar `status=closed` para listar las propuestas sobre las que ya se ha tomado una decisión.

`GET /api/user0/polls`

<!-- translation-section: params-10 -->

#### Parámetros

| Nombre | Descripción |
| --- | --- |
| `group_id` | Entero, obligatorio. ID del grupo cuyas encuestas se listarán |
| `status` | Cadena de texto, opcional, `active` por defecto. Valores: `active`, `closed`, `all` |
| `limit` | Entero, opcional, 50 por defecto. Tamaño de página |
| `offset` | Entero, opcional, 0 por defecto. Desplazamiento para la paginación |

Compatibilidad con versiones anteriores: `per` y `from` se aceptan como alias de `limit` y `offset` y seguirán funcionando.

<!-- translation-section: example-14 -->

#### Ejemplo

```bash
curl 'https://www.loomio.com/api/user0/polls?group_id=123' \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

<!-- translation-section: edit-poll -->

### Editar una encuesta

Edita una encuesta como el usuario de la clave de API. Se aplican los mismos permisos que en Loomio: el usuario debe tener permiso para editar esa encuesta.

`PATCH /api/user0/polls/:id`

<!-- translation-section: params-11 -->

#### Parámetros

| Nombre | Descripción |
| --- | --- |
| `title` | Título actualizado |
| `details` | Detalles actualizados de la encuesta |
| `details_format` | `md` o `html`, opcional, `md` por defecto |
| `options` | Nombres actualizados de las opciones. Cambiar las opciones puede afectar a los votos existentes según el estado de la encuesta |
| `poll_options_attributes` | Alternativa a `options`. Actualiza los objetos de opciones detalladas mediante `id`, añade objetos sin `id` o elimina una opción con `id` y `_destroy: true`. Las opciones omitidas permanecen sin cambios |
| `reason_prompt` | Pregunta compartida actualizada para el motivo del voto en los tipos de encuesta sin preguntas por opción |
| `stance_reason_required` | Requisito actualizado para el motivo del voto; se aplican los mismos valores que al crear una encuesta |
| `closing_at` | Cadena de texto en formato ISO 8601 o null |
| `recipient_audience` | `group` o null. Si es `group`, se notificará a todo el grupo |
| `recipient_user_ids` | Array de IDs de usuarios a quienes notificar o invitar |
| `recipient_emails` | Array de direcciones de correo electrónico de personas a quienes invitar a votar |
| `recipient_message` | Mensaje que se incluirá en la invitación por correo electrónico |

<!-- translation-section: example-15 -->

#### Ejemplo

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

#### Editar opciones detalladas

Obtén los IDs de las opciones del array `poll_options` en una respuesta de creación o consulta. Envía solo los campos que quieras cambiar, junto con el `id` de cada opción existente:

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

Los IDs de las opciones deben pertenecer a la encuesta que se está editando. Para editarla, necesitas permiso para editar la encuesta, y las encuestas cerradas no se pueden editar. Las encuestas anónimas también bloquean los cambios en la configuración de las opciones después de que se emita el primer voto.

<!-- translation-section: soft-delete-poll -->

### Eliminar una encuesta de forma lógica

Elimina una encuesta de forma lógica como el usuario de la clave de API. Esto descarta la encuesta y conserva el registro de la encuesta.

`DELETE /api/user0/polls/:id`

<!-- translation-section: example-16 -->

#### Ejemplo

```bash
curl https://www.loomio.com/api/user0/polls/123 \
  -X DELETE \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

<!-- translation-section: search -->

## Buscar

Busca discusiones, comentarios, encuestas, votos y conclusiones visibles para el usuario de la clave API. Los resultados incluyen contenido público incluso cuando el usuario no es miembro del grupo al que pertenece ese contenido; el contenido privado sigue sujeto a las reglas habituales de visibilidad de los temas.

`GET /api/user0/search`

<!-- translation-section: params -->

### Parámetros

| Nombre | Descripción |
| --- | --- |
| `query` | Texto de búsqueda. Se admiten coincidencias exactas y aproximadas |
| `group_id` | Restringe los resultados a un grupo visible |
| `org_id` | Restringe los resultados a un grupo principal visible y a sus subgrupos visibles. Usa `0` para las discusiones directas |
| `type` | Restringe los resultados a un tipo: `Discussion`, `Comment`, `Poll`, `Stance` u `Outcome` |
| `types` | Lista de tipos de resultados separados por comas |
| `tag` | Restringe los resultados a los temas con esta etiqueta |
| `author_id` | Restringe los resultados al contenido de un autor. Sin `query`, devuelve la actividad reciente visible de ese autor |
| `order` | Establécelo en `authored_at_desc` para ordenar el contenido coincidente por fecha de creación |

```bash
curl 'https://www.loomio.com/api/user0/search?query=quarterly+planning&type=Discussion' \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

La respuesta contiene un array `search_results`. Cada resultado identifica el registro coincidente y el contexto visible de ese registro mediante campos como `searchable_type`, `searchable_id`, `highlight`, `group_id`, `group_name`, `discussion_key`, `poll_key`, `author_id`, `author_name`, `authored_at` y `tags`. Los campos que no se aplican a un resultado tienen el valor `null`.

<!-- translation-section: threads -->

## Hilos

<!-- translation-section: list-threads -->

### Listar hilos

Lista los hilos de discusión y de encuesta visibles para el usuario de la clave API, ordenados por la actividad más reciente. El ID de un hilo es el valor de `topic_id`.

`GET /api/user0/threads`

<!-- translation-section: params-5 -->

#### Parámetros

| Nombre | Descripción |
| --- | --- |
| `limit` | Número entero, opcional, valor predeterminado 50. Tamaño de página |
| `offset` | Número entero, opcional, valor predeterminado 0. Desplazamiento para la paginación |

<!-- translation-section: example-5 -->

#### Ejemplo

```bash
curl 'https://www.loomio.com/api/user0/threads?limit=50&offset=0' \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

<!-- translation-section: read-thread -->

### Leer un hilo

Lee un hilo, la secuencia ordenada de eventos del hilo o el documento Markdown con todo el contenido visible del hilo.

`GET /api/user0/threads/:topic_id`

`GET /api/user0/threads/:topic_id/items`

`GET /api/user0/threads/:topic_id/markdown`

El endpoint `items` acepta estos parámetros de paginación:

| Nombre | Descripción |
| --- | --- |
| `limit` | Número entero, opcional, valor predeterminado 50, máximo 500. Tamaño de página |
| `offset` | Número entero, opcional, valor predeterminado 0. Desplazamiento para la paginación |

<!-- translation-section: example-6 -->

#### Ejemplo

```text
GET https://www.loomio.com/api/user0/threads/<topic_id>
GET https://www.loomio.com/api/user0/threads/<topic_id>/items?limit=50&offset=0
GET https://www.loomio.com/api/user0/threads/<topic_id>/markdown
```

El endpoint `items` devuelve una página de la secuencia de eventos en orden ascendente, incluidos los comentarios, las encuestas, los votos y las conclusiones visibles. `meta.total` es el número total de elementos del hilo. Obtén las páginas siguientes para leer toda la secuencia. El endpoint `markdown` devuelve todo el contenido visible del hilo en un único documento Markdown. Los motivos de los votos solo se incluyen cuando son visibles para el usuario de la clave API.

Todos los endpoints de hilos aplican los mismos permisos que la interfaz de Loomio. La clave API no concede acceso a un hilo que el usuario no pueda abrir normalmente.

<!-- translation-section: webhooks -->

## Webhooks

La API de usuario se basa en solicitudes: una integración llama a Loomio cuando quiere leer o modificar datos. Un webhook de grupo permite enviar los datos en la dirección contraria. Loomio envía los eventos seleccionados del grupo a tu endpoint a medida que ocurren, por lo que una integración no necesita consultar periódicamente la API REST para detectar cambios.

Los webhooks se configuran por grupo y requieren permisos de administrador del grupo. Puedes gestionarlos desde la interfaz de Loomio:

1. Abre el grupo.
2. Abre el menú del grupo y selecciona **Integraciones de chat**.
3. Añade la integración que coincida con el formato de datos que acepta tu endpoint. Para un endpoint de uso general, usa el formato Mattermost/Markdown.
4. Introduce un nombre y la URL de destino.
5. Selecciona los eventos que Loomio debe enviar automáticamente.
6. Guarda la integración y usa **Conexión de prueba** para enviar un mensaje de prueba.

Usa un destino HTTPS con una URL que no se pueda adivinar. Loomio exige que el destino resuelva a una dirección pública y bloquea las solicitudes a direcciones de redes locales o privadas.

Los agentes y otras integraciones también pueden gestionar webhooks mediante los endpoints de chatbots con autenticación Bearer descritos a continuación. El recurso se llama `chatbots` por compatibilidad con las integraciones de chat de Loomio, pero también representa webhooks salientes de uso general.

<!-- translation-section: list-webhooks -->

### Listar webhooks

Devuelve las integraciones de chat configuradas para un grupo. El usuario de la clave de API debe ser administrador de ese grupo. La respuesta incluye las URL de destino, por lo que no debe exponerse a los miembros del grupo que no sean administradores.

`GET /api/user0/chatbots?group_id=123`

| Nombre | Descripción |
| --- | --- |
| `group_id` | Número entero, obligatorio. ID del grupo cuyos webhooks se listarán |
| `limit` | Número entero, opcional, valor predeterminado 50, máximo 500. Tamaño de página |
| `offset` | Número entero, opcional, valor predeterminado 0. Desplazamiento para la paginación |

```bash
curl 'https://www.loomio.com/api/user0/chatbots?group_id=123&limit=50&offset=0' \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

La respuesta contiene una página de `chatbots` ordenada por ID de integración ascendente, con el número total de integraciones del grupo en `meta.total`. Cada integración tiene estos campos:

| Campo | Descripción |
| --- | --- |
| `id` | ID de la integración utilizado para actualizarla y eliminarla |
| `group_id` | Grupo que recibe los eventos |
| `name` | Nombre administrativo de la integración |
| `kind` | `webhook` para un webhook saliente o `matrix` para una integración de Matrix |
| `webhook_kind` | Formato de los datos: `markdown`, `slack`, `discord`, `microsoft` o `webex` |
| `server` | URL de destino |
| `event_kinds` | Eventos enviados automáticamente |
| `notification_only` | Indica si los mensajes contienen solo el encabezado de la notificación |

<!-- translation-section: create-a-webhook -->

### Crear un webhook

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

El usuario de la clave de API debe ser administrador del grupo indicado por `group_id`. Antes de guardar el destino, se comprueba que sea una URL pública.

<!-- translation-section: update-a-webhook -->

### Actualizar un webhook

`PATCH /api/user0/chatbots/:id`

Envía los campos que deban cambiar. No se puede transferir el webhook a otro grupo cambiando `group_id`.

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

### Probar el destino de un webhook

Envía un mensaje de prueba compatible con Markdown a un destino antes o después de guardar la configuración.

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

### Eliminar un webhook

`DELETE /api/user0/chatbots/:id`

```bash
curl https://www.loomio.com/api/user0/chatbots/456 \
  -X DELETE \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

Eliminar la configuración detiene los envíos futuros. No elimina ningún contenido del grupo de Loomio.

<!-- translation-section: event-types -->

### Tipos de eventos

Un webhook puede suscribirse a estos tipos de eventos:

| Evento | Cuándo se envía |
| --- | --- |
| `new_discussion` | Se inicia una discusión |
| `discussion_edited` | Se edita una discusión |
| `new_comment` | Se crea un comentario |
| `poll_created` | Se inicia una encuesta |
| `poll_edited` | Se edita una encuesta |
| `poll_closing_soon` | Se acerca la hora de cierre de una encuesta |
| `poll_expired` | Una encuesta alcanza la hora de cierre |
| `poll_closed_by_user` | Una persona cierra una encuesta manualmente |
| `poll_reopened` | Se reabre una encuesta |
| `outcome_created` | Se publica una conclusión |
| `outcome_updated` | Se actualiza una conclusión |
| `outcome_review_due` | Llega la fecha de revisión de una conclusión |
| `stance_created` | Se emite un voto |
| `stance_updated` | Se cambia un voto |

El webhook pertenece a un grupo y recibe los eventos de ese grupo a los que está suscrito. Las personas también pueden seleccionar explícitamente la integración al compartir o enviar algunas notificaciones, incluso cuando el evento automático correspondiente no está seleccionado.

<!-- translation-section: http-delivery -->

### Envío HTTP

Loomio envía una petición HTTP `POST` asíncrona a la URL configurada con esta cabecera:

```text
Content-Type: application/json; charset=utf-8
```

El tiempo de espera de la petición es de cinco segundos. Una respuesta `2xx`, incluida `204 No Content`, se considera satisfactoria. Los servicios que reciben webhooks deben responder con rapidez, procesar las tareas más largas de forma asíncrona y admitir envíos duplicados o fuera de orden.

Actualmente, Loomio no añade una firma del webhook, una cabecera con un secreto compartido, un ID de evento ni un ID de envío. Trata la URL de destino completa como una credencial, no la expongas públicamente e incluye en ella un token que no se pueda adivinar cuando el servicio receptor lo admita. Si necesitas un esquema de eventos estable y legible por máquinas o un envío firmado, usa el webhook como notificación de cambios y obtén los registros actuales mediante la API de usuario autenticada.

<!-- translation-section: payload-formats -->

### Formatos de los datos enviados

Los datos enviados por los webhooks son mensajes destinados a servicios de chat y preparados para mostrarse. No son registros completos serializados de Loomio. Los enlaces del mensaje identifican el contenido de Loomio afectado; una integración puede consultar después la API de usuario cuando necesite el estado actual en un formato estructurado.

| Formato de integración | Campos JSON principales |
| --- | --- |
| Mattermost/Markdown | `text`, `icon_url`, `username` |
| Slack | `text` |
| Discord | `content`, limitado a aproximadamente 1900 caracteres |
| Microsoft Teams | `@type`, `@context`, `themeColor`, `text`, `sections` |
| Webex | `markdown` |

Por ejemplo, el formato general de Markdown envía un cuerpo con esta estructura:

```json
{
  "text": "Ada started a discussion: [Quarterly planning](https://example.loomio.org/d/example)",
  "icon_url": "https://example.loomio.org/path/to/group-logo.png",
  "username": "Loomio"
}
```

El texto exacto del mensaje depende del evento, la configuración regional del grupo, el ajuste de solo notificaciones y la versión de Loomio. Los servicios receptores deben basarse en los campos de nivel superior documentados del formato seleccionado, en lugar de analizar la redacción de las frases.
