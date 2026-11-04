---
title: API
source_revision: 2d360988a87765e6a1345dd06155bc988154178e
source_file: docs/help/en/user_manual/integrations/api/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-23'
sections:
  introduction: 99e59473b33baba1
  user-api: 8424224e38edf17f
  server-api: 42859c6715b7a994
generated:
  introduction: 0113c3d493bb33f9
  user-api: 84271536cdd8acf2
  server-api: 514cb121bafeb885
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

L'[API server](/en/user_manual/integrations/api/server-api) consente a chi gestisce installazioni di Loomio su server propri di creare e gestire account utente, trovare gruppi e gestire le iscrizioni e i ruoli nei gruppi. Utilizza un segreto valido per l'intero server e non richiede un account bot né l'iscrizione a ciascun gruppo.
