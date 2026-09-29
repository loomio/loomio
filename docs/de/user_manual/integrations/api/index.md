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
  introduction: c7e23b50b37f3cf0
  user-api: a23b9153612af306
  server-api: 23dbfbdce8fc52fa
title_source: c8e5998f6a3955c2
title_generated: c8e5998f6a3955c2
---

<!-- translation-section: introduction -->

# Loomio-API

Verbinde Loomio über die API mit anderer Software und automatisierten Abläufen.

Die [OpenAPI-3.1-Spezifikation](openapi.yaml) beschreibt alle öffentlichen Funktionen der Benutzer-API und der Server-API in einem maschinenlesbaren Format. Importiere sie in einen API-Client oder nutze sie, um typisierten Client-Code zu erzeugen. Die folgenden Anleitungen erklären Abläufe, Berechtigungen und Verhalten, die in der Spezifikation nicht vollständig beschrieben sind.

<!-- translation-section: user-api -->

## Benutzer-API

Mit der [Benutzer-API](/en/user_manual/integrations/api/user-api) kannst du Aktionen als Loomio-Nutzer ausführen. Abhängig von den Berechtigungen dieses Nutzers kannst du Gruppen auflisten sowie Diskussionen, Kommentare, Abstimmungen und Gruppenmitgliedschaften erstellen oder verwalten.

Für Integrationen mit automatischer Ereignisübermittlung senden [Gruppen-Webhooks](/en/user_manual/integrations/api/user-api#webhooks) ausgewählte Loomio-Ereignisse als JSON an einen Web-Endpunkt. Nutze die REST-Endpunkte, um Loomio-Daten zu lesen oder zu ändern. Mit einem Webhook kann deine Integration Ereignisse empfangen, ohne regelmäßig nach ihnen zu fragen.

<!-- translation-section: server-api -->

## Server-API

Mit der [Server-API](/en/user_manual/integrations/api/server-api) können Betreiber selbst gehosteter Loomio-Installationen Benutzerkonten verwalten. Die Authentifizierung erfolgt über ein serverweites Geheimnis.
