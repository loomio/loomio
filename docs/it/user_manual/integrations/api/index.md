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
  introduction: 623bd9f11f83f8f9
  user-api: a2850ea33de71d69
  server-api: 46f8ac4798434822
title_source: c8e5998f6a3955c2
title_generated: c8e5998f6a3955c2
---

<!-- translation-section: introduction -->

# API di Loomio

Usa l'API di Loomio per collegare Loomio ad altri software e flussi di lavoro automatizzati.

La [specifica OpenAPI 3.1](openapi.yaml) descrive tutte le operazioni pubbliche dell'API utente e dell'API server in un formato leggibile dalle macchine. Importala in un client API o usala per generare codice client tipizzato. Le guide qui sotto spiegano flussi di lavoro, permessi e comportamenti che la specifica non descrive completamente.

<!-- translation-section: user-api -->

## API utente

L'[API utente](/en/user_manual/integrations/api/user-api) esegue azioni per conto di un utente Loomio. Può elencare i gruppi e creare o gestire discussioni, commenti, sondaggi e iscrizioni ai gruppi in base ai permessi dell'utente.

Per le integrazioni che ricevono eventi automaticamente, i [webhook di gruppo](/en/user_manual/integrations/api/user-api#webhooks) inviano gli eventi Loomio selezionati a un endpoint web in formato JSON. Usa gli endpoint REST per leggere o modificare i dati di Loomio e un webhook quando l'integrazione deve ricevere eventi senza effettuare richieste periodiche.

<!-- translation-section: server-api -->

## API server

L'[API server](/en/user_manual/integrations/api/server-api) consente a chi gestisce installazioni di Loomio su server propri di amministrare gli account utente. L'autenticazione avviene tramite un segreto valido per l'intero server.
