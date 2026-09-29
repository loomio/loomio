---
title: API
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/integrations/api/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-30'
sections:
  introduction: 99e59473b33baba1
  user-api: 8424224e38edf17f
  server-api: f1bf07c1162ff08b
generated:
  introduction: 4facbacabfbc1a04
  user-api: d718de9e4ceaab41
  server-api: a55048b9c827f32e
title_source: c8e5998f6a3955c2
title_generated: c8e5998f6a3955c2
---

<!-- translation-section: introduction -->

# API de Loomio

Usa la API de Loomio para conectar Loomio con otras aplicaciones y flujos de trabajo automatizados.

La [especificación OpenAPI 3.1](openapi.yaml) describe todas las operaciones públicas de la API de usuario y la API de servidor en un formato legible por máquina. Impórtala en un cliente de API o úsala para generar código de cliente con tipos. Las guías siguientes explican flujos de trabajo, permisos y comportamientos que la especificación no describe por completo.

<!-- translation-section: user-api -->

## API de usuario

La [API de usuario](/en/user_manual/integrations/api/user-api) realiza acciones como usuario de Loomio. Permite consultar grupos y crear o gestionar hilos, comentarios, encuestas y miembros de grupos según los permisos de ese usuario.

Para las integraciones que reciben eventos, los [webhooks de grupo](/en/user_manual/integrations/api/user-api#webhooks) envían determinados eventos de Loomio a un endpoint web en formato JSON. Usa los endpoints REST para consultar o modificar datos de Loomio y un webhook cuando una integración deba recibir eventos sin hacer consultas periódicas.

<!-- translation-section: server-api -->

## API de servidor

La [API de servidor](/en/user_manual/integrations/api/server-api) permite a quienes administran instalaciones de Loomio alojadas en sus propios servidores gestionar cuentas de usuario. Se autentica mediante una clave secreta válida para todo el servidor.
