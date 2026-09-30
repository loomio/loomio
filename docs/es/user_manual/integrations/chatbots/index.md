---
title: Integraciones de chat
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/integrations/chatbots/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-30'
sections:
  introduction: af3f509fd0a87c7d
  what-it-looks-like-in-chat: c425490496cb0ed2
  generate-a-webhook-url: a4a95bf5c61e8e3f
  set-up-a-chat-integration: d9c5b87891a0d747
  invite-to-poll: 70a0e025c79a13f0
  automatic-notifications: 381b622ece95e244
generated:
  introduction: daf977df30a0c8b4
  what-it-looks-like-in-chat: d40d0565895ad9b2
  generate-a-webhook-url: c01da35fb122f8bc
  set-up-a-chat-integration: dbe4f75dbea943cf
  invite-to-poll: 3ce28ce3f601a84f
  automatic-notifications: 3f3e4e7e52ab85f6
title_source: 0eca19d30c6d7d3c
title_generated: 350b622c3d69c10b
---

<!-- translation-section: introduction -->

# Integraciones de chat

Loomio puede enviar notificaciones a tu sala de chat.

Las herramientas de chat y Loomio se complementan. Usa el chat para conversar rápidamente y recibir novedades a tiempo. Lleva los temas importantes a Loomio cuando las personas necesiten tiempo para participar, haya que tomar una decisión o el grupo necesite conservar un registro.

Loomio es compatible con Slack, Discord, Microsoft Teams, Matrix y Mattermost.

Puedes enviar notificaciones a tu sala de chat cuando quieras, igual que invitas a personas a votar o a unirse a un hilo.

También puedes configurar notificaciones automáticas para eventos concretos, como el inicio de un hilo.

<!-- translation-section: what-it-looks-like-in-chat -->

## Cómo se ve en el chat
![](chatbot_in_slack.png)

<!-- translation-section: generate-a-webhook-url -->

## Generar una URL de webhook
Hemos preparado guías paso a paso para cada servicio compatible. Sigue la guía de tu servicio para obtener la URL de webhook que necesitarás para añadir la integración de chat en Loomio.

- [Slack](../slack/)
- [Microsoft Teams](../microsoft_teams/)
- [Discord](../discord/)
- [Matrix](../matrix/)
- [Mattermost](../mattermost/)

El sistema de webhooks también puede funcionar con otros servicios que acepten webhooks entrantes con formato HTML o Markdown, como Zapier o Rocketchat. Selecciona el bot de Mattermost y usa una URL de webhook personalizada.

<!-- translation-section: set-up-a-chat-integration -->

## Configurar una integración de chat

Después de configurar el servicio que hayas elegido (consulta las guías anteriores), tendrás una URL de webhook. Abre **Integraciones de chat** desde el menú del grupo y añade una nueva integración de chat para tu grupo.

![](loomio-group-settings.png)
![](loomio-settings-chatbots.png)

Por ahora, deja las casillas sin marcar. Escribe un nombre (por ejemplo, «Discord #general») y la URL. Después, haz clic en el botón para guardar al final del formulario.

![](loomio-chatbot-form.png)

Si más adelante quieres que la integración reciba notificaciones automáticas, vuelve a su configuración y selecciona los eventos correspondientes.

<!-- translation-section: invite-to-poll -->

### Invitar a votar

Así puedes enviar una notificación a tu sala de chat para invitar a las personas a votar en una propuesta. El proceso es el mismo para compartir una conclusión, invitar a un hilo, recordar que se puede votar o notificar que se ha editado un sondeo.

![](invite_button_on_proposal.png)

![](invite_to_vote_1.png)

![](invite_to_vote_2.png)

![](chatbot_in_slack.png)

<!-- translation-section: automatic-notifications -->

### Notificaciones automáticas
Para enviar una notificación cada vez que ocurra un evento concreto, edita la integración de chat y selecciona ese evento.

![](chatbot_enable_automatic_notifications.png)
