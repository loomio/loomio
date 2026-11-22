---
title: Matrix
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/integrations/matrix/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
sections:
  introduction: 114ab8c916ca5fba
generated:
  introduction: ddd9bbe7a34474b9
title_source: 76a2171c057b730f
title_generated: 76a2171c057b730f
---

<!-- translation-section: introduction -->

# Integración con Matrix

Loomio puede enviar notificaciones a una sala de Matrix cuando se crean nuevas discusiones, encuestas, comentarios, votos y conclusiones. Debes ser admin del grupo para añadir una integración de chat.

A diferencia de las otras integraciones de chat de Loomio, Matrix no utiliza un webhook. Loomio se conecta a través de una cuenta de usuario de Matrix que actúa como bot y publica mensajes con formato en tu sala.

Esta guía utiliza el cliente Element.

---

1. Crea una cuenta de usuario de Matrix para Loomio, inicia sesión con ella en Element e invita a esa cuenta a la sala de Matrix donde quieras que aparezcan las notificaciones. Mantén esta sesión abierta: al cerrar sesión, se invalida el token de acceso.

2. En tu grupo de Loomio, abre el menú del grupo, selecciona **Integraciones de chat** y añade una integración de chat con **Matriz**.

   ![menú del bot de Matrix en Loomio](loomio-add-matrix-bot.png)

   ![formulario del bot de Matrix en Loomio](loomio-matrix-bot-form.png)

3. En Element, abre el menú de la cuenta del bot y selecciona **Todos los ajustes**.

   ![menú de ajustes de Matrix](matrix-settings-menu.png)

4. Abre **Ayuda y acerca de** y desplázate hasta la sección **Avanzado**.

   ![ajustes de Matrix](matrix-settings.png)

5. Copia el **Token de acceso** y pégalo en el formulario de Loomio.

   ![token de acceso de Matrix](matrix-access-token.png)

6. Abre el menú **Configuración ** de la sala y ve a **Avanzado**.

   ![ajustes de la sala de Matrix](matrix-room-settings.png)

7. Copia el **Identificador interno de la sala**, pégalo en el formulario de Loomio y guarda la integración.

   ![identificador de la sala de Matrix](matrix-room-id.png)
