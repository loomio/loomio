---
title: Matrix
source_revision: c6076258c3438c0dd6dc8fbf1fc0b0df47c0aeb5
source_file: docs/en/user_manual/integrations/matrix/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: e54de0b6d9ea9ffb
generated:
  introduction: 61d82b081da458e3
title_source: 76a2171c057b730f
title_generated: 76a2171c057b730f
---

<!-- translation-section: introduction -->

# Integración con Matrix

Loomio puede enviar notificaciones a tus canales de Matrix cuando se crean nuevas discusiones, propuestas, comentarios, votos y conclusiones.

Matrix permite usar algo de HTML en la sala de chat, y Loomio aprovecha esta función.

Nuestra integración con Matrix es un poco diferente de nuestras otras integraciones de chat: no utiliza un webhook. Hemos creado un cliente de bot específico para esta integración.

Necesitarás crear un usuario de Matrix para que el bot inicie sesión con esa cuenta.

Una vez que hayas creado un usuario para el bot, inicia sesión con esa cuenta para obtener la siguiente información.

En esta guía usamos Element.

---

Desde tu grupo de Loomio, añade una integración de chat con Matrix
![menú del bot de Matrix en Loomio](loomio-add-matrix-bot.png)

Este es el formulario que debes completar
![formulario del bot de Matrix en Loomio](loomio-matrix-bot-form.png)

Aquí puedes empezar a buscar tu token de acceso
![menú de ajustes de Matrix](matrix-settings-menu.png)

Esta es la página de ajustes
![ajustes de Matrix](matrix-settings.png)

Este es el token de acceso
![token de acceso de Matrix](matrix-access-token.png)

Ahora necesitas el identificador de la sala
![ajustes de la sala de Matrix](matrix-room-settings.png)

Aquí está
![identificador de la sala de Matrix](matrix-room-id.png)
