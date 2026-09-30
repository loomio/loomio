---
title: Matrix
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/integrations/matrix/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-30'
sections:
  introduction: e54de0b6d9ea9ffb
generated:
  introduction: 37be03c9d1558148
title_source: 76a2171c057b730f
title_generated: 76a2171c057b730f
---

<!-- translation-section: introduction -->

# Integración con Matrix

Loomio puede enviar notificaciones a tus canales de Matrix cuando hay nuevas discusiones, propuestas, comentarios, votos y conclusiones.

Matrix permite usar algo de HTML en las salas de chat, y Loomio aprovecha esa función.

La integración con Matrix funciona de otra manera que las demás integraciones de chat de Loomio: no usa un webhook. Hemos creado un bot para esta integración.

Necesitas crear una cuenta de Matrix para que el bot inicie sesión.

Cuando hayas creado la cuenta del bot, inicia sesión con ella para obtener la siguiente información.

En esta guía usamos Element.

---

Desde tu grupo de Loomio, añade una integración de chat con Matrix
![Menú del bot de Matrix en Loomio](loomio-add-matrix-bot.png)

Completa este formulario
![Formulario del bot de Matrix en Loomio](loomio-matrix-bot-form.png)

Empieza aquí para encontrar tu token de acceso
![Menú de configuración de Matrix](matrix-settings-menu.png)

Esta es la página de configuración
![Configuración de Matrix](matrix-settings.png)

Aquí está el token de acceso
![Token de acceso de Matrix](matrix-access-token.png)

Ahora necesitas el ID de la sala
![Configuración de la sala de Matrix](matrix-room-settings.png)

Aquí está
![ID de la sala de Matrix](matrix-room-id.png)
