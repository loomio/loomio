---
title: Gestionar a los votantes
source_revision: adca14fde066a1ed3f6b2bb163d402235efbc709
source_file: docs/help/en/user_manual/polls/manage_voters/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-29'
sections:
  introduction: ea21036eb694c27f
  invite-people-to-vote-in-a-poll: c087ce6e0173270f
  invite-guests-or-experts: c6e4d0e0811de6f2
  engage-people-while-a-poll-is-running: d0eb90b4b53003bc
  add-voters-to-the-poll: 621bd4bf8ed67895
  remove-people-from-the-poll: be96ad95169a79a3
  remind-people-to-vote: ab98343bd2bc18eb
  view-notification-history: 675d77824d320d89
  close-early: e09d92a63b72c516
  reopen: f80ab5f17351d679
  choose-an-audience: a7a00bf75338b395
  check-your-recipients: 7c3de537341ecd1b
  send-the-invitations: 7ca4926c4ff46564
generated:
  introduction: 28ec353f803df4bd
  invite-people-to-vote-in-a-poll: 351ed80eacfc72f6
  invite-guests-or-experts: 5622cae3a2c57c40
  engage-people-while-a-poll-is-running: b524cdc8a75e01c8
  add-voters-to-the-poll: bf6b70de91a4d7c4
  remove-people-from-the-poll: 60676c00ca535afe
  remind-people-to-vote: 6243bee73c4a0151
  view-notification-history: 7ccc412ad8d76a29
  close-early: ebc5ee74c335a60a
  reopen: 20d595d6750615ad
  choose-an-audience: a426315088a9af0f
  check-your-recipients: 9eb05ea4a3d11f3c
  send-the-invitations: c7e734e4dde1ac39
title_source: 10858faa0464257e
title_generated: e9c1bdb2e9300008
needs_review:
  reopen: check the interface label "**Reabierto**" for "**Reopen**"
---

<!-- translation-section: introduction -->

# Gestionar a los votantes

Usa **Gestionar a los votantes** para dar a las personas derecho a votar e invitarlas a participar en una propuesta o encuesta.

<!-- translation-section: invite-people-to-vote-in-a-poll -->

<a id="invite-people-to-vote-in-a-poll"></a>
<a id="add-voters-to-the-poll"></a>

## Invita a personas a votar

Después de iniciar una encuesta con **Solo para personas seleccionadas**, se abre la ventana **Gestionar a los votantes**. También puedes abrirla seleccionando **Gestionar a los votantes** en la encuesta.

![El botón Gestionar a los votantes en la parte inferior de una encuesta](proposal_after_start.png)

<!-- translation-section: choose-an-audience -->

### Elige a quién invitar

Haz clic en el campo vacío **Buscar o invitar a los votantes** para ver sugerencias. Aparecen en este orden:

- tu grupo
- **Delegados de** tu grupo, si tu grupo tiene [votantes delegados](/en/user_manual/groups/delegated_voters)
- salas de chat conectadas, como Slack o Microsoft Teams
- subgrupos y el grupo principal
- miembros individuales

En un [hilo directo](/en/user_manual/discussions/direct_discussions), la lista ofrece **Todos en el hilo** en lugar de un grupo.

![La ventana Gestionar a los votantes con sugerencias del grupo, sus delegados, una sala de chat y un subgrupo](proposal_invite.png)

<a id="invite-a-subgroup-to-vote"></a>

Selecciona un conjunto de destinatarios para invitar a esas personas juntas. Por ejemplo, al seleccionar **Oatmilk Cooperative**, se incluyen las personas de ese grupo. También puedes seleccionar una sala de chat conectada para publicar allí la invitación. Publicar en una sala de chat no añade a sus miembros como votantes.

<!-- translation-section: check-your-recipients -->

### Comprueba quién está incluido

Después de seleccionar un conjunto de destinatarios, el campo muestra su nombre y cuántas personas están incluidas. Comprueba esta cifra antes de enviar la invitación.

![Oatmilk Cooperative seleccionado, con el número de destinatarios debajo del campo](proposal_invite_members.png)

Haz clic en el nombre del conjunto de destinatarios para desplegar la lista de personas. Después puedes seleccionar la **×** junto a una persona para excluirla de esta invitación. Esto no la elimina del grupo.

![Los destinatarios del grupo desplegados como una lista de personas con sus nombres, cada una con un control para quitarla](proposal_invite_expand.png)

<!-- translation-section: invite-guests-or-experts -->

<a id="invite-guests-or-experts"></a>

### Añade personas por nombre o correo electrónico

También puedes escribir el nombre de una persona y seleccionarla entre las sugerencias, o introducir una dirección de correo electrónico para invitar a alguien nuevo. Puedes añadir a varias personas a la misma invitación.

![Una invitación dirigida a un miembro del grupo y a una persona invitada por correo electrónico, con un mensaje listo para enviar](proposal_invite_guest.png)

Las personas invitadas reciben acceso a esta encuesta. Si la encuesta está dentro de un hilo, también pueden leer ese hilo y sus comentarios. La invitación no les da permiso para comentar en el hilo, votar en otras encuestas del hilo ni ver otros hilos del grupo.

<!-- translation-section: send-the-invitations -->

### Envía las invitaciones

Añade un mensaje que explique qué pides a las personas que decidan y selecciona **Invitar**. Deja marcada la opción **Enviar notificaciones** para notificar a las personas que estás invitando. Desmárcala para añadir votantes sin enviar una notificación.

En una encuesta programada, selecciona **Agregar votantes**. Las personas reciben la invitación cuando se abre la votación.

<!-- translation-section: engage-people-while-a-poll-is-running -->

<a id="engage-people-while-a-poll-is-running"></a>

## Después de invitar a las personas

<!-- translation-section: add-voters-to-the-poll -->

### Añade más votantes

Puedes volver a abrir **Gestionar a los votantes** para añadir personas en cualquier momento, incluso antes de que se abra una encuesta programada. La ventana también muestra los votantes existentes, con las personas añadidas más recientemente en primer lugar. Escribe un nombre para encontrar a alguien o usa los controles de paginación para recorrer una lista más larga.

<!-- translation-section: remove-people-from-the-poll -->

### Elimina personas de la encuesta

Selecciona el botón de la papelera junto a una persona y confirma **Eliminar votante** para quitarle el derecho a votar en esta encuesta. Por ejemplo, alguien que prepara una votación de una junta puede eliminarse a sí mismo si no tiene derecho a votar.

![La ventana Gestionar a los votantes con los votantes existentes y el botón de la papelera de un votante resaltado](proposal_invite_remove.png)

No se pueden eliminar personas de una encuesta anónima. En las encuestas con [pesos del voto](/en/user_manual/polls/weighted_voting), los admins del hilo también pueden revisar y editar los pesos aquí.

<!-- translation-section: remind-people-to-vote -->

### Recuerda a las personas que voten

Selecciona **Recordar ** en la encuesta, elige quién debe recibir el recordatorio, añade un mensaje y selecciona **Recordar ** para enviarlo. Puedes seleccionar **Personas sin votar** para dirigirte a las personas cuyas respuestas aún se necesitan.

![Un recordatorio dirigido a personas sin votar, con un mensaje sobre el plazo para tomar la decisión](proposal_remind.png)

<!-- translation-section: view-notification-history -->

### Consulta el historial de notificaciones

Abre el menú de tres puntos (**⋯**) de la encuesta y selecciona **Historial de notificaciones** para ver quién ha recibido una invitación, cuándo se envió cada invitación y si se ha leído, cuando esa información esté disponible.

![Historial de notificaciones que muestra los destinatarios de una invitación a una encuesta](../../discussions/notifying_people/poll_notification_example.png)

<!-- translation-section: close-early -->

### Cierra antes de tiempo

Selecciona **Cierre temprano** cuando todas las personas hayan votado o la encuesta ya no necesite permanecer abierta.

<!-- translation-section: reopen -->

### Reabrir

Selecciona **Reabrir** en una encuesta cerrada y establece una nueva fecha y hora de cierre. Las encuestas que ocultan los resultados hasta que se cierra la votación, incluidas las encuestas anónimas, no se pueden reabrir; puedes ampliar el plazo de cierre mientras sigan abiertas.
