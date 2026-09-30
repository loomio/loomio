---
title: API de usuario
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
  introduction: 4a6714c378107e07
  authentication-change: 8ae857071b05cb15
  response-size-and-related-records: 2bbb49f05592e717
  endpoint-summary: 2f5a2d0eff5d32a4
  groups: '0778b0182dde2603'
  list-groups: 3d11013fa2678809
  get-a-group: 90ff5110c3275ebc
  webhooks: c397960a4c82d693
  list-webhooks: 60a892548b64839d
  create-a-webhook: 5108b7ada71d0d0b
  update-a-webhook: '0941d32071634bf3'
  test-a-webhook-destination: e1d66abdb9e7e7e3
  delete-a-webhook: 2a069efa46b04429
  event-types: c7f9c64570e1c63a
  http-delivery: 448050be27fbd94b
  payload-formats: 82115b6643bad305
  search: c9d3725f156a0ab5
  params: 4e2cb2e70f68c037
  participation-report: a796de7538c054b4
  params-2: f7d0ea80d707a7fa
  example: 0dd6f52b8f4a18fe
  create-discussion: 6bac4a8487cbc893
  params-3: bb9aa13a27bf8829
  example-2: 6502aeec7d19bbe6
  show-discussion: ad47c822bf157dca
  example-3: c315fa111faefb23
  list-discussions: 9f4f349099c325f7
  params-4: 83a240bd64a0f39f
  example-4: a7c45776f624802d
  list-threads: b84b522503b3a5ae
  params-5: dba6989597d00cae
  example-5: 5b6da55fb16a9c6b
  read-thread: b0b4bcad30c49325
  example-6: 371cc16527b4fc6d
  edit-discussion: 67d0d16aad7a0845
  params-6: faae86a91d0f0648
  example-7: 7e7273520e4afc3a
  soft-delete-discussion: 61dd3db21fb6cb0f
  example-8: 3e203c4bbfe00500
  create-comment: 8e138a1bff62445c
  params-7: 7d42f7f45eb3c2f2
  example-9: 76f831e77b8a90e5
  edit-comment: 28438fbf769d53e9
  params-8: fb8932d4823f6d6f
  example-10: b95dc68e01c877c4
  soft-delete-comment: 45aed03f76e6e105
  example-11: fc0e61d015b5c387
  create-poll: 6deddc4d5fa0acce
  params-9: df1c1eaddc1c5e37
  example-12: 5713dda14cde04cd
  show-poll: a0ee4fe10fb136a6
  example-13: 32ad455899fec490
  list-polls: e1db8f8880ed94c1
  params-10: f9ee8d71e83dab93
  example-14: '08378332fc4c4365'
  edit-poll: be4c8b38d1e46b63
  params-11: 8eee00b0585e0d17
  example-15: de7e83eb4abfdc0d
  soft-delete-poll: dc8d428d079ec34d
  example-16: 73c8acbb6e22d141
  list-memberships: 0760ecc564adec04
  params-12: 2dac2401533696fc
  example-17: 4d7c09e1aef3acb7
  manage-memberships: f742adc7e05d75e2
  params-13: 21b2a775a0dbdbea
  example-18: 47dd41fc7325cc88
title_source: c23fb6526b722360
title_generated: 5bccf15677959a14
---

<!-- translation-section: introduction -->

# Documentación de la API de usuario de Loomio

<!-- seo-description: Usa la API de usuario de Loomio para crear y gestionar discusiones, comentarios, sondeos, hilos y pertenencias a grupos desde otro software. -->

`/api/b2` es la API de usuario para integraciones con Loomio. Usa la clave de API de una cuenta de usuario y realiza cada acción en nombre de esa persona.

Las operaciones de grupo se rigen por las pertenencias y los permisos de grupo de la persona titular de la clave de API. Ser administrador de la instancia no amplía el acceso de la clave a grupos ni a contenidos. Para administrar la instancia, usa la API de servidor.

Usa la clave de API de la cuenta de Loomio que realizará las acciones. Una cuenta de bot dedicada puede ser útil si la integración no debe recibir invitaciones a sondeos ni notificaciones.

Si has iniciado sesión, puedes encontrar tu clave de API y los identificadores de tus grupos en la [página de acceso a la API](/profile/api_access).

Envía la clave de API en una cabecera `Authorization: Bearer`. Se rechazan las claves de API en las cadenas de consulta porque los servidores proxy y los registros de acceso pueden guardar las URL.

<!-- translation-section: authentication-change -->

### Cambio en la autenticación

Antes se aceptaba la clave de API como parámetro de URL `api_key`. Las solicitudes que usan `?api_key=YOUR_API_KEY` ya no funcionan. Usa la cabecera HTTP `Authorization`:

```text
Authorization: Bearer YOUR_API_KEY
```

Los ejemplos usan `YOUR_API_KEY`, el identificador de grupo `123` y `https://www.loomio.com/`. Sustitúyelos por tu clave de API, el identificador de tu grupo y la URL de tu instalación de Loomio.

<!-- translation-section: response-size-and-related-records -->

## Tamaño de las respuestas y registros relacionados

Las respuestas de la API de usuario tienen un formato compuesto: los registros principales van acompañados de registros relacionados, como temas, grupos, usuarios, sondeos y reacciones. Así, un cliente puede llenar su almacén local de registros con una sola solicitud, aunque la respuesta puede incluir más datos de los que necesita una integración sencilla.

Usa `compact=1` para omitir los temas, grupos, grupos principales, pertenencias, reacciones, etiquetas y traducciones relacionados que ocupan más espacio. Se mantienen los registros principales y los registros relacionados necesarios para interpretar su contenido.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads/123/items?compact=1'
```

Para controlar las exclusiones directamente, usa `exclude_types` con tipos de registro en singular separados por espacios. Por ejemplo, `exclude_types=group reaction` omite los grupos y las reacciones relacionados. Los valores habituales son `topic`, `group`, `parent`, `membership`, `reaction`, `tag`, `translation`, `user`, `discussion`, `poll`, `poll_option`, `stance`, `stance_choice`, `outcome` y `topic_item`. Las exclusiones se aplican a los registros relacionados, no al recurso principal solicitado al endpoint.

Las respuestas de colecciones incluyen `meta.total` cuando se conoce el tamaño exacto de la colección. El total se calcula antes de aplicar `limit` y `offset`. Los endpoints como el de búsqueda, que devuelven deliberadamente un conjunto limitado de resultados, omiten `meta.total` en lugar de devolver `null`.

<!-- translation-section: endpoint-summary -->

## Resumen de endpoints

| Método | Endpoint | Función |
| --- | --- | --- |
| `GET` | `/api/b2/groups` | Listar los grupos de la persona titular de la clave de API |
| `GET` | `/api/b2/groups/:id_or_key_or_handle` | Obtener un grupo visible |
| `GET` | `/api/b2/reports` | Generar un informe de participación |
| `GET` | `/api/b2/search` | Buscar discusiones, comentarios, sondeos, votos y conclusiones visibles |
| `POST` | `/api/b2/discussions` | Crear una discusión |
| `GET` | `/api/b2/discussions/:id` | Obtener una discusión |
| `GET` | `/api/b2/discussions` | Listar las discusiones de un grupo |
| `PATCH` | `/api/b2/discussions/:id` | Editar una discusión |
| `DELETE` | `/api/b2/discussions/:id` | Eliminar una discusión sin borrar su registro |
| `GET` | `/api/b2/threads` | Listar los hilos visibles de discusiones y sondeos independientes |
| `GET` | `/api/b2/threads/:topic_id` | Obtener un hilo |
| `GET` | `/api/b2/threads/:topic_id/items` | Obtener los elementos de un hilo en orden |
| `GET` | `/api/b2/threads/:topic_id/markdown` | Obtener un hilo completo en Markdown |
| `POST` | `/api/b2/comments` | Crear un comentario o una respuesta |
| `PATCH` | `/api/b2/comments/:id` | Editar un comentario |
| `DELETE` | `/api/b2/comments/:id` | Eliminar un comentario sin borrar su registro |
| `POST` | `/api/b2/polls` | Crear un sondeo |
| `GET` | `/api/b2/polls/:id` | Obtener un sondeo |
| `GET` | `/api/b2/polls` | Listar los sondeos de un grupo |
| `PATCH` | `/api/b2/polls/:id` | Editar un sondeo |
| `DELETE` | `/api/b2/polls/:id` | Eliminar un sondeo sin borrar su registro |
| `GET` | `/api/b2/memberships` | Listar las pertenencias a un grupo |
| `POST` | `/api/b2/memberships` | Añadir integrantes y, opcionalmente, quitar a quienes no figuren en la lista |
| `GET` | `/api/b2/chatbots` | Listar las integraciones de chat y los webhooks de un grupo |
| `POST` | `/api/b2/chatbots` | Crear una integración de chat o un webhook |
| `PATCH` | `/api/b2/chatbots/:id` | Actualizar una integración de chat o un webhook |
| `DELETE` | `/api/b2/chatbots/:id` | Eliminar una integración de chat o un webhook |
| `POST` | `/api/b2/chatbots/check` | Enviar una prueba de conexión de un webhook |

<!-- translation-section: groups -->

## Grupos

<!-- translation-section: list-groups -->

### Listar grupos

Devuelve los grupos en los que la persona titular de la clave de API tiene una pertenencia activa.

`GET /api/b2/groups`

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups
```

La respuesta contiene todos los registros coincidentes en un array `groups` sin paginación. Incluye grupos principales y subgrupos, incluso si su suscripción no está activa en ese momento. Comprueba el campo `enabled` si la integración solo debe operar con grupos habilitados.

Estos son algunos campos importantes de los grupos:

| Campo | Descripción |
| --- | --- |
| `id` | Identificador numérico del grupo que usan otros endpoints de la API de usuario |
| `key` | Clave corta y estable usada en las URL de Loomio |
| `handle` | Identificador legible del grupo |
| `name` | Nombre del grupo |
| `full_name` | Nombre del grupo con el contexto de su grupo principal |
| `parent_id` | Identificador numérico del grupo principal de un subgrupo; en caso contrario, `null` |
| `enabled` | Indica si el grupo y su suscripción están activos |
| `memberships_count` | Número de pertenencias activas y pendientes |
| `accepted_memberships_count` | Número de pertenencias aceptadas |
| `pending_memberships_count` | Número de invitaciones pendientes |
| `admin_memberships_count` | Número de administradores del grupo |
| `delegates_count` | Número de delegados |
| `discussions_count` | Número de discusiones directamente en el grupo |
| `polls_count` | Número de sondeos directamente en el grupo |
| `subgroups_count` | Número de subgrupos |

La respuesta puede incluir otros ajustes del grupo, registros relacionados del grupo principal y las pertenencias de la persona titular de la clave de API. Los clientes deben ignorar los campos que no utilicen.

<!-- translation-section: get-a-group -->

### Obtener un grupo

Devuelve un grupo visible para la persona titular de la clave de API.

`GET /api/b2/groups/:id_or_key_or_handle`

Puedes identificar el grupo por su identificador numérico, clave o identificador legible.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/123
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/example-group
```

La respuesta contiene el grupo en el array `groups` y usa los mismos campos que el endpoint de listado. Si la persona titular de la clave de API no puede acceder al grupo solicitado, se devuelve un error de permisos.

<!-- translation-section: webhooks -->

## Webhooks

La API de usuario funciona mediante solicitudes: una integración llama a Loomio cuando quiere leer o cambiar datos. Un webhook de grupo permite recibir cambios automáticamente. Loomio envía a tu endpoint los eventos seleccionados del grupo cuando ocurren, por lo que la integración no necesita consultar periódicamente la API REST.

Los webhooks se configuran por grupo y requieren permisos de administrador del grupo. Puedes gestionarlos desde la interfaz de Loomio:

1. Abre el grupo.
2. Abre el menú del grupo y selecciona **Integraciones de chat**.
3. Añade la integración cuyo formato de datos acepte tu endpoint. Para un endpoint de uso general, usa el formato Mattermost/Markdown.
4. Introduce un nombre y la URL de destino.
5. Selecciona los eventos que Loomio debe enviar automáticamente.
6. Guarda la integración y usa **Conexión de prueba** para enviar un mensaje de prueba.

Usa un destino HTTPS con una URL difícil de adivinar. Loomio exige que el destino se resuelva a una dirección pública y bloquea las solicitudes a direcciones de redes locales o privadas.

Los agentes y otras integraciones también pueden gestionar los webhooks mediante los endpoints de chatbots con autenticación Bearer descritos más abajo. El recurso se llama `chatbots` por compatibilidad con las integraciones de chat de Loomio, pero también representa webhooks salientes de uso general.

<!-- translation-section: list-webhooks -->

### Listar webhooks

Devuelve las integraciones de chat configuradas para un grupo. La persona titular de la clave de API debe ser administradora de ese grupo. La respuesta incluye las URL de destino, por lo que no debe mostrarse a integrantes sin permisos de administración.

`GET /api/b2/chatbots?group_id=123`

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/chatbots?group_id=123'
```

La respuesta contiene un array `chatbots` con estos campos:

| Campo | Descripción |
| --- | --- |
| `id` | ID de la integración utilizado para actualizarla y eliminarla |
| `group_id` | Grupo que recibe los eventos |
| `name` | Nombre de la integración para su administración |
| `kind` | `webhook` para un webhook saliente o `matrix` para una integración con Matrix |
| `webhook_kind` | Formato de los datos enviados: `markdown`, `slack`, `discord`, `microsoft` o `webex` |
| `server` | URL de destino |
| `event_kinds` | Eventos enviados automáticamente |
| `notification_only` | Indica si los mensajes contienen solo el encabezado de la notificación |

<!-- translation-section: create-a-webhook -->

### Crear un webhook

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

La persona propietaria de la clave de API debe administrar el grupo indicado en `group_id`. Antes de guardar la configuración, se comprueba que el destino sea una URL pública.

<!-- translation-section: update-a-webhook -->

### Actualizar un webhook

`PATCH /api/b2/chatbots/:id`

Envía los campos que quieras cambiar. No puedes trasladar el webhook a otro grupo cambiando `group_id`.

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"name":"Planning events","event_kinds":["new_discussion","outcome_created"]}' \
  https://www.loomio.com/api/b2/chatbots/456
```

<!-- translation-section: test-a-webhook-destination -->

### Probar el destino de un webhook

Envía un mensaje de prueba compatible con Markdown al destino antes o después de guardar su configuración.

`POST /api/b2/chatbots/check`

```bash
curl -X POST \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"group_id":123,"server":"https://hooks.example.org/loomio/unguessable-token"}' \
  https://www.loomio.com/api/b2/chatbots/check
```

<!-- translation-section: delete-a-webhook -->

### Eliminar un webhook

`DELETE /api/b2/chatbots/:id`

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/chatbots/456
```

Al eliminar la configuración, se detienen los envíos futuros. No se elimina ningún contenido del grupo en Loomio.

<!-- translation-section: event-types -->

### Tipos de eventos

Un webhook puede suscribirse a estos tipos de eventos:

| Evento | Cuándo se envía |
| --- | --- |
| `new_discussion` | Se inicia una discusión |
| `discussion_edited` | Se edita una discusión |
| `new_comment` | Se crea un comentario |
| `poll_created` | Se inicia un sondeo |
| `poll_edited` | Se edita un sondeo |
| `poll_closing_soon` | Se acerca la hora de cierre de un sondeo |
| `poll_expired` | Un sondeo llega a su hora de cierre |
| `poll_closed_by_user` | Una persona cierra manualmente un sondeo |
| `poll_reopened` | Se reabre un sondeo |
| `outcome_created` | Se publica una conclusión |
| `outcome_updated` | Se actualiza una conclusión |
| `outcome_review_due` | Llega la fecha de revisión de una conclusión |
| `stance_created` | Se emite un voto |
| `stance_updated` | Se cambia un voto |

El webhook pertenece a un grupo y recibe los eventos de ese grupo a los que está suscrito. También se puede seleccionar explícitamente la integración al compartir contenido o enviar ciertas notificaciones, aunque no se haya seleccionado el evento automático correspondiente.

<!-- translation-section: http-delivery -->

### Entrega HTTP

Loomio envía una solicitud HTTP `POST` asíncrona a la URL configurada con este encabezado:

```text
Content-Type: application/json; charset=utf-8
```

La solicitud tiene un tiempo de espera de cinco segundos. Una respuesta `2xx`, incluida `204 No Content`, se considera correcta. Los servicios que reciben webhooks deben responder con rapidez, procesar de forma asíncrona las tareas más largas y admitir entregas duplicadas o fuera de orden.

Actualmente, Loomio no añade una firma al webhook, un encabezado con un secreto compartido, un ID de evento ni un ID de entrega. Trata la URL de destino completa como una credencial, no la publiques e incluye en ella un token difícil de adivinar si el servicio receptor lo admite. Si necesitas un esquema de eventos estable y legible por máquina o entregas firmadas, usa el webhook como aviso de cambios y consulta los registros actuales mediante la API de usuario autenticada.

<!-- translation-section: payload-formats -->

### Formatos de los datos enviados

Los datos enviados por los webhooks son mensajes preparados para servicios de chat. No contienen registros completos de Loomio en formato serializado. Los enlaces del mensaje identifican el contenido de Loomio afectado; una integración puede consultar después la API de usuario si necesita datos estructurados y actualizados.

| Formato de integración | Campos JSON principales |
| --- | --- |
| Mattermost/Markdown | `text`, `icon_url`, `username` |
| Slack | `text` |
| Discord | `content`, limitado a unos 1.900 caracteres |
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

El texto exacto del mensaje depende del evento, el idioma del grupo, la configuración de solo notificaciones y la versión de Loomio. Los servicios receptores deben utilizar los campos de nivel superior documentados para el formato seleccionado, en lugar de analizar el texto de las frases.

<!-- translation-section: search -->

## Buscar

Busca discusiones, comentarios, sondeos, votos y conclusiones visibles para la persona propietaria de la clave de API. Los resultados incluyen contenido público aunque esa persona no pertenezca al grupo. El contenido privado sigue sujeto a las reglas habituales de visibilidad de los temas.

`GET /api/b2/search`

<!-- translation-section: params -->

### Parámetros

| Nombre | Descripción |
| --- | --- |
| `query` | Texto de búsqueda. Admite coincidencias exactas y aproximadas |
| `group_id` | Limita los resultados a un grupo visible |
| `org_id` | Limita los resultados a un grupo principal visible y sus subgrupos visibles. Usa `0` para las discusiones directas |
| `type` | Limita los resultados a un tipo: `Discussion`, `Comment`, `Poll`, `Stance` u `Outcome` |
| `types` | Lista de tipos de resultados separados por comas |
| `tag` | Limita los resultados a los temas con esta etiqueta |
| `author_id` | Limita los resultados al contenido de una persona. Sin `query`, devuelve su actividad visible reciente |
| `order` | Establece `authored_at_desc` para ordenar el contenido coincidente por fecha de creación |

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/search?query=quarterly+planning&type=Discussion'
```

La respuesta contiene un array `search_results`. Cada resultado identifica el registro coincidente y su contexto visible mediante campos como `searchable_type`, `searchable_id`, `highlight`, `group_id`, `group_name`, `discussion_key`, `poll_key`, `author_id`, `author_name`, `authored_at` y `tags`. Los campos que no corresponden a un resultado tienen el valor `null`.

<!-- translation-section: participation-report -->

## Informe de participación

Devuelve los mismos datos agregados de participación que utiliza el informe de participación de Loomio.

`GET /api/b2/reports`

<!-- translation-section: params-2 -->

### Parámetros

| Nombre | Descripción |
| --- | --- |
| `section` | Sección del informe: `base`, `users` o `countries`. Usa `users` para consultar la actividad de cada persona |
| `group_scope` | `custom` o `my`. El valor antiguo `all` se trata como `my` porque las claves de la API de usuario nunca dan acceso a toda la instancia |
| `group_ids` | ID de grupos separados por comas cuando `group_scope=custom`. Se ignoran los ID de grupos a los que no pertenece la persona propietaria de la clave de API |
| `start_month` | Primer mes que se incluirá, en formato `YYYY-MM`; de forma predeterminada, el de hace 12 meses |
| `end_month` | Último mes que se incluirá, en formato `YYYY-MM`; de forma predeterminada, el mes actual |
| `interval` | Intervalo para la sección `base`: `day`, `week`, `month` o `year` |
| `member_type` | Establece `delegate` con `section=users` para devolver solo las personas que actualmente son delegadas |

Una persona es delegada si tiene una membresía activa como delegada en cualquiera de los grupos seleccionados. Sus recuentos se agregan entre todos esos grupos. Se devuelven filas de personas delegadas incluso cuando todos sus recuentos de actividad son cero. Los recuentos incluyen hilos, comentarios, sondeos, votos, conclusiones y reacciones; no representan tasas de participación en las votaciones. Las filas de personas también incluyen las papeletas identificadas emitidas, depositadas y no respondidas. Los sondeos anónimos se excluyen de todos los recuentos de votos por persona. `all_votes_cast` solo es verdadero si se emitió al menos una papeleta y se depositaron todas las emitidas.

La API aplica las mismas reglas de visibilidad de grupos que el informe de Loomio. Una clave de la API de usuario no puede mostrar datos de informes de grupos a los que esa persona no tiene acceso.

<!-- translation-section: example -->

### Ejemplo

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/reports?section=users&group_scope=custom&group_ids=123&member_type=delegate&start_month=2026-01&end_month=2026-09'
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

<!-- translation-section: create-discussion -->

## Crear una discusión

Crea una discusión con la cuenta a la que pertenece la clave de API.

`POST /api/b2/discussions`

<!-- translation-section: params-3 -->

### Parámetros

| Nombre | Descripción |
| --- | --- |
| `group_id` | Grupo al que pertenecerá el hilo |
| `title` | Título del hilo, obligatorio |
| `description` | Contexto del hilo, opcional |
| `description_format` | `md` o `html`, opcional; valor predeterminado: `md` |
| `recipient_audience` | `group` o null. Si es `group`, se notificará a todo el grupo sobre el nuevo hilo |
| `recipient_user_ids` | Lista de ID de usuarios a quienes notificar o invitar al hilo |
| `recipient_emails` | Lista de direcciones de correo electrónico de las personas a quienes invitar al hilo |
| `recipient_message` | Mensaje que se incluirá en la invitación por correo electrónico |

<!-- translation-section: example-2 -->

### Ejemplo

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example thread", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/discussions
```

<!-- translation-section: show-discussion -->

## Consultar una discusión

Consulta una discusión mediante su ID numérico o su clave de texto.

`GET /api/b2/discussions/:id`

<!-- translation-section: example-3 -->

### Ejemplo

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/discussions/abc123
```

<!-- translation-section: list-discussions -->

## Listar discusiones

Lista las discusiones de un grupo que puede ver la cuenta a la que pertenece la clave de API. Si el grupo es público, una persona que no sea miembro puede listar sus discusiones públicas. Las discusiones privadas solo están disponibles para quienes pueden leerlas en Loomio.

`GET /api/b2/discussions`

<!-- translation-section: params-4 -->

### Parámetros

| Nombre | Descripción |
| --- | --- |
| `group_id` | Número entero obligatorio. ID del grupo cuyas discusiones quieres listar |
| `status` | Cadena opcional; valor predeterminado: `open`. Valores: `open`, `closed`, `all` |
| `limit` | Número entero opcional; valor predeterminado: 50. Tamaño de página |
| `offset` | Número entero opcional; valor predeterminado: 0. Desplazamiento para la paginación |

Por compatibilidad, `per` y `from` se aceptan como alias de `limit` y `offset` y seguirán funcionando.

<!-- translation-section: example-4 -->

### Ejemplo

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/discussions?group_id=123'
```

<!-- translation-section: list-threads -->

## Listar hilos

Lista los hilos de discusiones y sondeos que puede ver la cuenta a la que pertenece la clave de API, ordenados por actividad más reciente. El ID de un hilo es su `topic_id`.

`GET /api/b2/threads`

<!-- translation-section: params-5 -->

### Parámetros

| Nombre | Descripción |
| --- | --- |
| `limit` | Número entero opcional; valor predeterminado: 50. Tamaño de página |
| `offset` | Número entero opcional; valor predeterminado: 0. Desplazamiento para la paginación |

<!-- translation-section: example-5 -->

### Ejemplo

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads?limit=50&offset=0'
```

<!-- translation-section: read-thread -->

## Leer un hilo

Lee un hilo, su secuencia ordenada de eventos o el documento Markdown completo que puedes ver.

`GET /api/b2/threads/:topic_id`

`GET /api/b2/threads/:topic_id/items`

`GET /api/b2/threads/:topic_id/markdown`

<!-- translation-section: example-6 -->

### Ejemplo

```text
GET https://www.loomio.com/api/b2/threads/<topic_id>
GET https://www.loomio.com/api/b2/threads/<topic_id>/items
GET https://www.loomio.com/api/b2/threads/<topic_id>/markdown
```

El endpoint `items` devuelve la secuencia ordenada de eventos, incluidos los comentarios, sondeos, votos y conclusiones visibles. El endpoint `markdown` devuelve todo el contenido visible del hilo en un único documento Markdown. Las razones de los votos solo se incluyen cuando la cuenta a la que pertenece la clave de API puede verlas.

Todos los endpoints de hilos aplican los mismos permisos que la interfaz de Loomio. La clave de API no da acceso a un hilo que la cuenta no pueda abrir normalmente.

<!-- translation-section: edit-discussion -->

## Editar una discusión

Edita una discusión con la cuenta a la que pertenece la clave de API. Se aplican los mismos permisos que en Loomio: la cuenta debe tener permiso para editar esa discusión.

`PATCH /api/b2/discussions/:id`

<!-- translation-section: params-6 -->

### Parámetros

| Nombre | Descripción |
| --- | --- |
| `title` | Título actualizado |
| `description` | Contexto actualizado |
| `description_format` | `md` o `html`, opcional; valor predeterminado: `md` |
| `recipient_audience` | `group` o null. Si es `group`, se notificará a todo el grupo sobre la edición |
| `recipient_user_ids` | Lista de ID de usuarios a quienes notificar o invitar al hilo |
| `recipient_emails` | Lista de direcciones de correo electrónico de las personas a quienes invitar al hilo |
| `recipient_message` | Mensaje que se incluirá en la invitación por correo electrónico |

<!-- translation-section: example-7 -->

### Ejemplo

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated thread title", "description":"updated context", "description_format":"md"}' https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: soft-delete-discussion -->

## Eliminar una discusión sin borrar su registro

Elimina una discusión con la cuenta a la que pertenece la clave de API. La discusión se descarta, pero su registro se conserva.

`DELETE /api/b2/discussions/:id`

<!-- translation-section: example-8 -->

### Ejemplo

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: create-comment -->

## Crear un comentario

Crea un comentario en una discusión con la cuenta a la que pertenece la clave de API.

`POST /api/b2/comments`

<!-- translation-section: params-7 -->

### Parámetros

| Nombre | Descripción |
| --- | --- |
| `discussion_id` | Número entero obligatorio. ID de la discusión en la que quieres comentar |
| `body` | Texto del comentario, obligatorio salvo que se adjunte un archivo |
| `body_format` | `md` o `html`, opcional; valor predeterminado: `md` |

<!-- translation-section: example-9 -->

### Ejemplo

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"discussion_id": 123, "body":"example comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments
```

<!-- translation-section: edit-comment -->

## Editar un comentario

Edita un comentario con la cuenta a la que pertenece la clave de API. Se aplican los mismos permisos que en Loomio: la cuenta debe tener permiso para editar ese comentario.

`PATCH /api/b2/comments/:id`

<!-- translation-section: params-8 -->

### Parámetros

| Nombre | Descripción |
| --- | --- |
| `body` | Texto actualizado del comentario |
| `body_format` | `md` o `html`, opcional; valor predeterminado: `md` |

<!-- translation-section: example-10 -->

### Ejemplo

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"body":"updated comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments/123
```

<!-- translation-section: soft-delete-comment -->

## Eliminar un comentario sin borrar su registro

Elimina un comentario con la cuenta a la que pertenece la clave de API. El comentario se descarta y su texto se oculta, pero su registro se conserva.

`DELETE /api/b2/comments/:id`

<!-- translation-section: example-11 -->

### Ejemplo

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/comments/123
```

<!-- translation-section: create-poll -->

## Crear un sondeo

Crea un sondeo con el usuario al que pertenece la clave de API.

`POST /api/b2/polls`

<!-- translation-section: params-9 -->

### Parámetros

| Nombre | Descripción |
| --- | --- |
| `group_id` | Entero, opcional, valor predeterminado: null. ID del grupo del sondeo. Si se proporciona `discussion_id`, se ignora `group_id` |
| `discussion_id` | Entero, opcional, valor predeterminado: null. ID del hilo de discusión al que se añadirá el sondeo |
| `title` | Cadena, obligatoria. Título del sondeo |
| `poll_type` | Cadena, obligatoria. Valores: `proposal`, `poll`, `count`, `score`, `ranked_choice`, `meeting`, `dot_vote` |
| `details` | Cadena, opcional. Texto del sondeo |
| `details_format` | Cadena, opcional, valor predeterminado: `md`. Valores: `md` o `html` |
| `options` | Array de cadenas. Si `poll_type` es `proposal`, los valores válidos son `agree`, `disagree`, `abstain` y `block`. Si `poll_type` es `meeting`, proporciona fechas o fechas y horas en formato ISO 8601. Para los demás tipos de sondeo, se admite cualquier cadena |
| `closing_at` | Cadena en formato ISO 8601 o null; valor predeterminado: null. Ejemplo: `2026-09-01T12:00:00Z`. Si es null, se desactiva la votación y el sondeo se considera en preparación |
| `specified_voters_only` | Booleano, opcional, valor predeterminado: false. Si es true, solo pueden votar las personas indicadas. Si es false, se invita a votar a todo el grupo |
| `hide_results` | Cadena, opcional, valor predeterminado: `off`. Valores: `off`, `until_vote`, `until_closed` |
| `shuffle_options` | Booleano, valor predeterminado: false. Muestra las opciones a quienes votan en orden aleatorio |
| `anonymous` | Booleano, opcional, valor predeterminado: false. Oculta la identidad de quienes votan |
| `recipient_audience` | `group` o null, opcional, valor predeterminado: null. Si es `group`, se notificará a todo el grupo |
| `notify_on_closing_soon` | Cadena, opcional, valor predeterminado: `nobody`. Valores: `nobody`, `author`, `undecided_voters`, `voters` |
| `recipient_user_ids` | Array de ID de usuarios a quienes notificar o invitar |
| `recipient_emails` | Array de direcciones de correo electrónico de las personas a quienes invitar a votar |
| `recipient_message` | Mensaje que se incluirá en la invitación por correo electrónico |
| `notify_recipients` | Booleano, valor predeterminado: false. Si es false, añade personas sin enviar notificaciones. Si es true, todas las personas invitadas mediante esta solicitud recibirán un correo electrónico de notificación |

<!-- translation-section: example-12 -->

### Ejemplo

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example poll", "poll_type": "proposal", "options": ["agree", "disagree"], "closing_at": "2026-09-01T12:00:00Z", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/polls
```

<!-- translation-section: show-poll -->

## Consultar un sondeo

Obtén un sondeo mediante su ID numérico o su clave de texto.

`GET /api/b2/polls/:id`

<!-- translation-section: example-13 -->

### Ejemplo

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/polls/abc123
```

<!-- translation-section: list-polls -->

## Listar sondeos

Lista los sondeos de un grupo visibles para el usuario al que pertenece la clave de API. Si el grupo es público, una persona que no sea miembro puede listar sus sondeos públicos. Los sondeos privados solo están disponibles para quienes pueden leerlos en Loomio. La respuesta incluye la conclusión actual de cada sondeo visible, por lo que puedes usar `status=closed` para listar las propuestas ya decididas.

`GET /api/b2/polls`

<!-- translation-section: params-10 -->

### Parámetros

| Nombre | Descripción |
| --- | --- |
| `group_id` | Entero, obligatorio. ID del grupo cuyos sondeos se listarán |
| `status` | Cadena, opcional, valor predeterminado: `active`. Valores: `active`, `closed`, `all` |
| `limit` | Entero, opcional, valor predeterminado: 50. Tamaño de página |
| `offset` | Entero, opcional, valor predeterminado: 0. Desplazamiento para la paginación |

Por compatibilidad, `per` y `from` se aceptan como alias de `limit` y `offset` y seguirán funcionando.

<!-- translation-section: example-14 -->

### Ejemplo

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/polls?group_id=123'
```

<!-- translation-section: edit-poll -->

## Editar un sondeo

Edita un sondeo con el usuario al que pertenece la clave de API. Se aplican los mismos permisos que en Loomio: el usuario debe tener permiso para editar ese sondeo.

`PATCH /api/b2/polls/:id`

<!-- translation-section: params-11 -->

### Parámetros

| Nombre | Descripción |
| --- | --- |
| `title` | Título actualizado |
| `details` | Detalles actualizados del sondeo |
| `details_format` | `md` o `html`, opcional, valor predeterminado: `md` |
| `options` | Nombres actualizados de las opciones. Cambiar las opciones puede afectar a los votos existentes según el estado del sondeo |
| `closing_at` | Cadena en formato ISO 8601 o null |
| `recipient_audience` | `group` o null. Si es `group`, se notificará a todo el grupo |
| `recipient_user_ids` | Array de ID de usuarios a quienes notificar o invitar |
| `recipient_emails` | Array de direcciones de correo electrónico de las personas a quienes invitar a votar |
| `recipient_message` | Mensaje que se incluirá en la invitación por correo electrónico |

<!-- translation-section: example-15 -->

### Ejemplo

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated poll title", "details":"updated details", "details_format":"md"}' https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: soft-delete-poll -->

## Eliminar un sondeo sin borrar su registro

Elimina un sondeo con el usuario al que pertenece la clave de API. El sondeo se descarta, pero se conserva su registro.

`DELETE /api/b2/polls/:id`

<!-- translation-section: example-16 -->

### Ejemplo

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: list-memberships -->

## Listar miembros

Lista las membresías visibles para el usuario al que pertenece la clave de API. Los miembros del grupo pueden ver los nombres, ID, cargos y roles de los demás miembros. Las direcciones de correo electrónico solo se incluyen para la cuenta del propio usuario o si este administra el grupo.

`GET /api/b2/memberships`

<!-- translation-section: params-12 -->

### Parámetros

| Nombre | Descripción |
| --- | --- |
| `group_id` | Entero, obligatorio. ID del grupo cuyos miembros se listarán |

<!-- translation-section: example-17 -->

### Ejemplo

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/memberships?group_id=123'
```

<!-- translation-section: manage-memberships -->

## Gestionar miembros

Envía una lista de direcciones de correo electrónico. Se invitará al grupo a todas las direcciones nuevas. Esta operación requiere permisos de administración del grupo.

`POST /api/b2/memberships`

<!-- translation-section: params-13 -->

### Parámetros

| Nombre | Descripción |
| --- | --- |
| `group_id` | Entero, obligatorio. ID del grupo cuyos miembros se gestionarán |
| `emails` | Array de cadenas, obligatorio. Direcciones de correo electrónico de las personas a quienes invitar al grupo |
| `remove_absent` | Booleano. Si es true, elimina del grupo a quienes no tengan una dirección de correo electrónico incluida en la lista |

<!-- translation-section: example-18 -->

### Ejemplo

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"]}' https://www.loomio.com/api/b2/memberships
```

Si pasas `remove_absent=1`, se eliminará del grupo a los miembros que no estén incluidos en la lista. Ten cuidado: podrías eliminar a todos los miembros de tu grupo.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"], "remove_absent": 1}' https://www.loomio.com/api/b2/memberships
```

La respuesta es un objeto con `{added_emails: ["person@added.com"], removed_emails: ["person@removed.com"]}`.
