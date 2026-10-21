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
  introduction: 04d7781c11e06db0
  user-api: 354fab200c67a992
  server-api: d7ef52058ab76750
title_source: c8e5998f6a3955c2
title_generated: c8e5998f6a3955c2
---

<!-- translation-section: introduction -->

# Loomio API

Nutze die Loomio API, um Loomio mit anderer Software und automatisierten Arbeitsabläufen zu verbinden.

Die [OpenAPI-3.1-Spezifikation](openapi.yaml) beschreibt jede öffentliche Operation der User API und der Server API in einem maschinenlesbaren Format. Importiere sie in einen API-Client oder nutze sie, um typisierten Client-Code zu generieren. Die folgenden Anleitungen erklären Arbeitsabläufe, Berechtigungen und Verhaltensweisen, die in der Spezifikation nicht vollständig beschrieben sind.

<!-- translation-section: user-api -->

## User API

Die [User API](/en/user_manual/integrations/api/user-api) führt Aktionen im Namen einer Person aus, die Loomio nutzt. Sie kann Gruppen auflisten sowie Threads, Kommentare, Abstimmungen und Gruppenmitgliedschaften entsprechend den Berechtigungen dieser Person erstellen oder verwalten.

Für Push-basierte Integrationen senden [Gruppen-Webhooks](/en/user_manual/integrations/api/user-api#webhooks) ausgewählte Loomio-Ereignisse als JSON an einen Web-Endpunkt. Nutze die REST-Endpunkte, um Loomio-Daten zu lesen oder zu ändern, und einen Webhook, wenn eine Integration Ereignisse ohne regelmäßige Abfragen empfangen soll.

<!-- translation-section: server-api -->

## Server API

Mit der [Server API](/en/user_manual/integrations/api/server-api) können Betreibende selbst gehosteter Loomio-Installationen Benutzerkonten verwalten. Die Authentifizierung erfolgt mit einem serverweit gültigen Geheimnis.
