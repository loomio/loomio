---
title: Integraciones de chat
source_revision: c6076258c3438c0dd6dc8fbf1fc0b0df47c0aeb5
source_file: docs/en/user_manual/integrations/chatbots/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: af3f509fd0a87c7d
  what-it-looks-like-in-chat: c425490496cb0ed2
  generate-a-webhook-url: a4a95bf5c61e8e3f
  set-up-a-chat-integration: d9c5b87891a0d747
  invite-to-poll: 70a0e025c79a13f0
  automatic-notifications: 381b622ece95e244
generated:
  introduction: 3381485ca927f887
  what-it-looks-like-in-chat: d40d0565895ad9b2
  generate-a-webhook-url: 54e123133a44e37a
  set-up-a-chat-integration: c900b1663edd5c3c
  invite-to-poll: bf3818fe5363e1a2
  automatic-notifications: 77e7ee3b36a502be
title_source: 0eca19d30c6d7d3c
title_generated: 350b622c3d69c10b
---

<!-- translation-section: introduction -->

# Integraciones de chat

Loomio puede enviar notificaciones a tu sala de chat.

Las herramientas de chat y Loomio funcionan bien juntas. Usa el chat para conversaciones rápidas y actualizaciones puntuales. Traslada los temas importantes a Loomio cuando las personas necesiten tiempo para participar, cuando haya que tomar una decisión o cuando el grupo necesite un registro duradero.

Loomio es compatible con Slack, Discord, Microsoft Teams, Matrix y Mattermost.

Puedes enviar notificaciones a tu sala de chat cuando quieras, de la misma forma que invitarías a personas a votar o a unirse a un hilo.

También puedes configurar las notificaciones para que se envíen siempre que ocurra un evento específico, como cuando alguien inicia un hilo.

<!-- translation-section: what-it-looks-like-in-chat -->

## Cómo se ve en el chat
![](chatbot_in_slack.png)

<!-- translation-section: generate-a-webhook-url -->

## Genera una URL de webhook
Hemos preparado guías paso a paso para cada servicio compatible. Sigue la guía correspondiente a tu servicio para obtener la URL de webhook que necesitarás para añadir la integración de chat en Loomio.

- [Slack](../slack/)
- [Microsoft Teams](../microsoft_teams/)
- [Discord](../discord/)
- [Matrix](../matrix/)
- [Mattermost](../mattermost/)

Nuestro sistema basado en webhooks también puede utilizarse con otros sistemas que admitan webhooks entrantes con formato HTML o Markdown, como Zapier o Rocketchat. Selecciona el bot de Mattermost y usa una URL de webhook personalizada.

<!-- translation-section: set-up-a-chat-integration -->

## Configura una integración de chat

Después de configurar el servicio que hayas elegido (ver arriba), tendrás una URL de webhook. Abre **Integraciones de chat** desde el menú del grupo y añade una nueva integración de chat para tu grupo.

![](loomio-group-settings.png)
![](loomio-settings-chatbots.png)

Por ahora, probablemente prefieras dejar todas las casillas sin marcar. Introduce el nombre (por ejemplo, "Discord #general") y la URL, y haz clic en el botón de guardar al final del formulario.

![](loomio-chatbot-form.png)

Si más adelante decides que quieres que la integración reciba notificaciones automáticas, vuelve a la configuración y selecciona los eventos correspondientes.

<!-- translation-section: invite-to-poll -->

### Invita a una encuesta

Así puedes enviar una notificación a tu sala de chat para invitar a las personas a votar en una propuesta. El proceso es el mismo para Compartir conclusión, Invitar al hilo, Recordar que voten, Encuesta editada, etc.

![](invite_button_on_proposal.png)

![](invite_to_vote_1.png)

![](invite_to_vote_2.png)

![](chatbot_in_slack.png)

<!-- translation-section: automatic-notifications -->

### Notificaciones automáticas
Para enviar una notificación cada vez que ocurra un evento específico, edita la integración de chat y selecciona ese evento.

![](chatbot_enable_automatic_notifications.png)
