---
title: Integraciones de chat
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/integrations/chatbots/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
sections:
  introduction: 46c095b75ad63f90
  what-it-looks-like-in-chat: f317dcdbffe349dc
  generate-a-webhook-url: ededdedfffbe6bcb
  set-up-a-chat-integration: d671b54fe6ae3cd1
  invite-to-poll: ffa06cde4354b243
  automatic-notifications: 21e1f83202af63e1
generated:
  introduction: 1357ebd4157f6533
  what-it-looks-like-in-chat: 564d8859a43ac261
  generate-a-webhook-url: 0463cf44d1ff84ec
  set-up-a-chat-integration: de062cea2333b703
  invite-to-poll: 5176e2ada6f2eb34
  automatic-notifications: 305b8e94f40ee455
title_source: 0eca19d30c6d7d3c
title_generated: 350b622c3d69c10b
---

<!-- translation-section: introduction -->

# Integraciones de chat

Loomio puede enviar notificaciones a tu sala de chat.

Las herramientas de chat y Loomio funcionan bien juntas. Usa el chat para conversaciones rápidas y actualizaciones puntuales. Traslada los temas importantes a Loomio cuando las personas necesiten tiempo para participar, cuando haya que tomar una decisión o cuando el grupo necesite un registro duradero.

Loomio es compatible con Slack, Discord, Microsoft Teams, Matrix y Mattermost.

Puedes enviar notificaciones a tu sala de chat manualmente cuando invites a personas a un hilo o una encuesta. También puedes configurar notificaciones automáticas para eventos específicos, como cuando alguien inicia una discusión.

<!-- translation-section: what-it-looks-like-in-chat -->

## Cómo se ve en el chat

![](chatbot_in_slack.png)

<!-- translation-section: generate-a-webhook-url -->

## Conecta tu servicio de chat

Sigue la guía de tu servicio de chat para obtener una URL de webhook (o, para Matrix, un token de acceso del bot y un ID de sala):

- [Slack](../slack/)
- [Microsoft Teams](../microsoft_teams/)
- [Discord](../discord/)
- [Matrix](../matrix/)
- [Mattermost](../mattermost/)

También puedes conectar otros servicios que admitan webhooks entrantes con formato HTML o Markdown, como Zapier o Rocket.Chat. Elige la integración de chat **Lo más importante** en Loomio e introduce tu URL de webhook personalizada.

<!-- translation-section: set-up-a-chat-integration -->

## Configura una integración de chat

Debes ser admin del grupo para añadir o editar integraciones de chat.

1. Después de configurar tu servicio de chat (ver arriba), abre el menú del grupo en Loomio y selecciona **Integraciones de chat**.

   ![](loomio-group-settings.png)

   ![](loomio-settings-chatbots.png)

2. Añade una nueva integración de chat para tu servicio, introduce un nombre (por ejemplo, "Discord #general") y pega la URL de webhook.

   ![](loomio-chatbot-form.png)

3. Selecciona los eventos que quieras que se envíen automáticamente, o déjalos sin seleccionar si solo quieres enviar notificaciones manualmente, y guarda los cambios. Puedes cambiar estos ajustes en cualquier momento.

<!-- translation-section: invite-to-poll -->

### Envía una notificación manualmente

Para notificar a tu sala de chat sobre una encuesta o discusión, abre el elemento y selecciona **Invitar** (u otra acción de notificación como **Compartir conclusión**, **Recuerda votar** o **Encuesta editada**). Selecciona tu integración de chat en la lista de destinatarios y envía la notificación.

![](invite_button_on_proposal.png)

![](invite_to_vote_1.png)

![](invite_to_vote_2.png)

![](chatbot_in_slack.png)

<!-- translation-section: automatic-notifications -->

### Notificaciones automáticas

Para enviar una notificación cada vez que ocurra un evento específico, edita la integración de chat y selecciona ese evento.

![](chatbot_enable_automatic_notifications.png)
