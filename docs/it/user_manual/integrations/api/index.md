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
  introduction: 0113c3d493bb33f9
  user-api: 84271536cdd8acf2
  server-api: 939002f54677f230
title_source: c8e5998f6a3955c2
title_generated: c8e5998f6a3955c2
---

<!-- translation-section: introduction -->

# API di Loomio

Usa l'API di Loomio per collegare Loomio ad altri software e flussi di lavoro automatizzati.

Il [contratto OpenAPI 3.1](openapi.yaml) descrive ogni operazione pubblica dell'API utente e dell'API server in un formato leggibile dalle macchine. Importalo in un client API oppure usalo per generare codice client con tipi definiti. Le guide seguenti spiegano flussi di lavoro, permessi e comportamenti che il contratto non descrive completamente.

<!-- translation-section: user-api -->

## API utente

L'[API utente](/en/user_manual/integrations/api/user-api) esegue azioni come utente Loomio. Può elencare i gruppi e creare o gestire conversazioni, commenti, sondaggi e appartenenze ai gruppi in base ai permessi di quell'utente.

Per le integrazioni basate su notifiche push, i [webhook del gruppo](/en/user_manual/integrations/api/user-api#webhooks) inviano eventi selezionati di Loomio a un endpoint web in formato JSON. Usa gli endpoint REST per leggere o modificare i dati di Loomio e un webhook quando un'integrazione deve ricevere eventi senza effettuare richieste periodiche.

<!-- translation-section: server-api -->

## API server

L'[API server](/en/user_manual/integrations/api/server-api) consente a chi gestisce installazioni di Loomio su server propri di gestire gli account utente. L'autenticazione avviene tramite un segreto valido per l'intero server.
