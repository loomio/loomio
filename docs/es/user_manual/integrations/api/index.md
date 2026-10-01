---
title: API
source_revision: c6076258c3438c0dd6dc8fbf1fc0b0df47c0aeb5
source_file: docs/en/user_manual/integrations/api/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: 99e59473b33baba1
  user-api: 8424224e38edf17f
  server-api: f1bf07c1162ff08b
generated:
  introduction: 4e35a9aabc9f17c7
  user-api: 9ab9163969f45df3
  server-api: 63bda90d159f43c7
title_source: c8e5998f6a3955c2
title_generated: c8e5998f6a3955c2
---

<!-- translation-section: introduction -->

# API de Loomio

Usa la API de Loomio para conectar Loomio con otro software y flujos de trabajo automatizados.

El [contrato OpenAPI 3.1](openapi.yaml) describe todas las operaciones públicas de la API de usuario y la API de servidor en un formato legible por máquinas. Impórtalo en un cliente de API o úsalo para generar código de cliente tipado. Las guías siguientes explican los flujos de trabajo, los permisos y los comportamientos que el contrato no describe por completo.

<!-- translation-section: user-api -->

## API de usuario

La [API de usuario](/en/user_manual/integrations/api/user-api) realiza acciones como un usuario de Loomio. Puede listar grupos y crear o gestionar hilos, comentarios, encuestas y membresías de grupo según los permisos de ese usuario.

Para las integraciones basadas en el envío de eventos, los [webhooks de grupo](/en/user_manual/integrations/api/user-api#webhooks) envían eventos seleccionados de Loomio a un punto de conexión web en formato JSON. Usa los puntos de conexión REST para leer o modificar datos de Loomio y un webhook cuando una integración deba recibir eventos sin realizar consultas periódicas.

<!-- translation-section: server-api -->

## API de servidor

La [API de servidor](/en/user_manual/integrations/api/server-api) permite a quienes operan instalaciones autoalojadas de Loomio gestionar cuentas de usuario. La autenticación se realiza mediante un secreto válido para todo el servidor.
