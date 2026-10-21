---
title: Invitar a votar
source_revision: c6076258c3438c0dd6dc8fbf1fc0b0df47c0aeb5
source_file: docs/en/user_manual/polls/inviting_people/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: 0635cf23fcaaa95b
  invite-people-to-vote-in-a-poll: cfbf5caf71d1d5ca
  invite-guests-or-experts: 0717537bbd36fa07
  invite-a-subgroup-to-vote: 3ac684bdca4b3365
  engage-people-while-a-poll-is-running: 69971de8d56c0a74
  add-voters-to-the-poll: 48f3b4a1edb5a037
  remove-people-from-the-poll: ceec3f0319728807
  remind-people-to-vote: 177c881cb1b0dfb9
  view-notification-history: 52d930341c048008
  close-early: 0c46e8066719fc2f
  reopen: 9575383179a411cc
generated:
  introduction: 61bf30560f2f1e91
  invite-people-to-vote-in-a-poll: bde9aa4ad5f05264
  invite-guests-or-experts: 7378413fc25a700b
  invite-a-subgroup-to-vote: 6cb3df6751415df1
  engage-people-while-a-poll-is-running: e7be24b2d7ec53c0
  add-voters-to-the-poll: af06c4b9ebdcc280
  remove-people-from-the-poll: '08af9b7253ef289a'
  remind-people-to-vote: 862f07ec46c0e97c
  view-notification-history: 78fd86aa8bc76e8a
  close-early: 81408c02b77cd418
  reopen: 055cd3caf4a37c2d
title_source: 4801d1a3dba7ce3d
title_generated: 3a1a9d984f78a737
needs_review:
  remind-people-to-vote: check the interface label "**Recordar **" for "**Remind**"
  reopen: check the interface label "**Reabierto**" for "**Reopen**"
---

<!-- translation-section: introduction -->

# Invitar a votar

<!-- translation-section: invite-people-to-vote-in-a-poll -->

## Invita a personas a votar en una encuesta

Invita a personas a tu encuesta enviándoles una notificación.

Después de iniciar una encuesta, aparece el cuadro **Invitar a votar**. Selecciona a quién invitar, por ejemplo, **Todos en el hilo** o tu grupo, o introduce nombres y direcciones de correo electrónico individuales.

![](proposal_invite.png)

Puedes incluir un mensaje opcional con la invitación.

![](proposal_invite_members.png)

Selecciona la etiqueta de un grupo para desplegar la lista de personas a las que estás invitando. Selecciona la x junto a un nombre para quitar a esa persona de la invitación.

![](proposal_invite_expand.png)

<!-- translation-section: invite-guests-or-experts -->

### Invita a invitados o expertos

También puedes invitar a una persona invitada a la encuesta introduciendo su dirección de correo electrónico. Tendrá permiso para participar únicamente en esta encuesta.

Si la encuesta está dentro de un hilo, esa persona también podrá ver el hilo y sus comentarios. No podrá comentar, participar en otras encuestas del hilo ni ver otros hilos del grupo.

![](proposal_invite_guest.png)

<!-- translation-section: invite-a-subgroup-to-vote -->

### Invita a un subgrupo a votar

Para limitar la votación a las personas invitadas, selecciona **Solo para personas seleccionadas** al crear la encuesta. Después puedes invitar a un subgrupo del grupo principal. Consulta también [Votantes delegados](/en/user_manual/groups/delegated_voters/).

![Seleccionar solo a las personas invitadas](invited-people-only.png)
![Invitar a un subgrupo a votar](invite-voters-subgroup.png)

<!-- translation-section: engage-people-while-a-poll-is-running -->

## Fomenta la participación mientras la encuesta está abierta

En la parte inferior de la encuesta hay varias funciones que te ayudan a fomentar la participación una vez que la encuesta está abierta.

![](proposal_after_start.png)

<!-- translation-section: add-voters-to-the-poll -->

### Añade votantes a la encuesta

Puedes añadir nuevas personas a la encuesta en cualquier momento, incluso antes de que se abra la votación en una encuesta programada.

Selecciona **Gestionar a los votantes** para abrir la ventana de gestión de votantes. Puedes invitar a todas las personas del grupo, añadir miembros por nombre o añadir invitados por correo electrónico si se permiten las invitaciones a invitados. Al escribir en **Buscar o invitar a los votantes**, también se filtran las personas que ya están en la encuesta. Los votantes añadidos más recientemente aparecen primero; usa los controles de paginación para recorrer la lista completa.

Si la encuesta tiene una hora de apertura programada y la votación aún no se ha abierto, los votantes no recibirán una notificación inmediata. Recibirán una notificación cuando se abra la votación.

<!-- translation-section: remove-people-from-the-poll -->

### Elimina personas de la encuesta

Selecciona **Gestionar a los votantes**, busca el nombre de la persona en la ventana de gestión de votantes, selecciona el botón de la papelera junto al nombre y confirma **Eliminar votante**.

![El botón de la papelera junto a un votante en la ventana de gestión de votantes](proposal_invite_remove.png)

No se pueden eliminar personas de una encuesta anónima.

Por ejemplo, un administrador que crea una encuesta en nombre de los miembros de una junta puede eliminarse a sí mismo si no tiene autorización para votar.

En las encuestas que usan pesos del voto, la misma ventana permite a los coordinadores de la encuesta [revisar y editar los pesos del voto](/en/user_manual/polls/weighted_voting).

<!-- translation-section: remind-people-to-vote -->

### Recordar a las personas que voten

Selecciona **Recordar** para enviar una notificación a las personas que no han votado. **Todos invitados a votar** está seleccionado de forma predeterminada. Selecciona la etiqueta para ver o cambiar los destinatarios.

![](proposal_remind.png)

<!-- translation-section: view-notification-history -->

### Consulta el historial de notificaciones

Abre el menú de tres puntos (**⋯**) en la parte inferior de la encuesta y selecciona **Historial de notificaciones**.

![Historial de notificaciones en el menú de acciones de una encuesta](../../discussions/notifying_people/poll_notification_history.png)

El historial muestra quién ha recibido una invitación a votar, cuándo se envió cada invitación y si se ha leído, cuando esa información está disponible.

![Historial de notificaciones de una encuesta](../../discussions/notifying_people/poll_notification_example.png)

<!-- translation-section: close-early -->

### Cierra antes de tiempo

Selecciona **Cierre temprano** para cerrar una encuesta antes de la hora de cierre programada.

Puedes hacerlo cuando todas las personas hayan votado o cuando la encuesta ya no necesite permanecer abierta.

![](proposal_close_early.png)

<!-- translation-section: reopen -->

### Reabrir

Selecciona **Reabrir** en una encuesta cerrada y establece una nueva fecha de cierre y hora.

Las encuestas anónimas no se pueden reabrir.

![](proposal_reopen.png)
