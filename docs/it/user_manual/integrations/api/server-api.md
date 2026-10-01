---
title: API del server
source_revision: c27ee3b193231816878f1c074ff9fc2a086a88c0
source_file: docs/en/user_manual/integrations/api/server-api.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-02'
sections:
  introduction: a357cdc2bfc0223e
  authentication: cbabcc874f053455
  user-object: c3a00ec4e3d66b09
  list-users: c7d62eee05e7a6a4
  example: 2f817ab1533206e6
  show-user: 36fa596a6a5c2fd8
  examples: 522d17246020d82f
  update-user: 39d632ce15d489d3
  params: 368f797e2a2b5c3d
  examples-2: 3aab846e77253829
  deactivate-user: 132d435583a46920
  examples-3: d8c7c152ab2b0ace
  reactivate-user: 309592dead978456
  examples-4: 95251484d1fd7e1d
  redact-user: 47ea30122aa92fae
  examples-5: 9d3bb1c3a865f3e0
  delete-user: 2d5a1dbd23324e6f
  examples-6: 71ae30577730b261
  sso-profile-sync-settings: 416144004d040e4f
generated:
  introduction: 84f1587202b6687a
  authentication: 28eaa840cd3f452d
  user-object: 1725eb51a00632f1
  list-users: d9168e09de1e8717
  example: dfe44221be7dda5e
  show-user: 5a20f6944c78628a
  examples: 2d6efddc918bf689
  update-user: eb7af8ac40d94fb3
  params: 3f569599d046e817
  examples-2: 64c6bc11f541a84e
  deactivate-user: 386cfaf95f6c6b42
  examples-3: 6abeaf19808d5841
  reactivate-user: c939366d0f223ef5
  examples-4: 512758bd8a575333
  redact-user: e11345126fa61a6f
  examples-5: 14a3ec9e57da4250
  delete-user: fde62e265dbd7176
  examples-6: f45dd892571c348d
  sso-profile-sync-settings: d8380e2b0eba60a5
title_source: 370e81eb20eece44
title_generated: fb011755307eb06b
---

<!-- translation-section: introduction -->

# Documentazione delle API del server Loomio

<!-- seo-description: Usa le API del server Loomio per gestire gli account utente su un'installazione Loomio ospitata sul tuo server. -->

`/api/b3` serve per le operazioni a livello di server. Usa `/api/b2` per le azioni eseguite con un account utente Loomio.

<!-- translation-section: authentication -->

## Autenticazione

Imposta `B3_API_KEY` su un valore segreto di oltre 16 caratteri.

Invia la chiave come token bearer:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
```

Invia le credenziali solo nell'intestazione `Authorization`. Le chiavi API nelle stringhe di query o nei corpi delle richieste vengono rifiutate.

<!-- translation-section: user-object -->

## Oggetto utente

Le risposte relative agli utenti usano questa struttura:

```json
{
  "id": 123,
  "name": "Ada Lovelace",
  "username": "ada",
  "email": "ada@example.org",
  "active": true,
  "deactivated_at": null,
  "identities": [
    {
      "id": 456,
      "identity_type": "oauth",
      "uid": "external-123",
      "email": "ada@example.org",
      "name": "Ada Lovelace"
    }
  ]
}
```

<!-- translation-section: list-users -->

## Elenca gli utenti

Elenca tutti gli account utente dell'installazione Loomio.

`GET /api/b3/users`

<!-- translation-section: example -->

### Esempio

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
```

Restituisce:

```json
{
  "users": []
}
```

<!-- translation-section: show-user -->

## Mostra un utente

Trova un utente tramite il suo ID utente Loomio o la sua identità esterna.

`GET /api/b3/users/:id`

`GET /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples -->

### Esempi

Tramite ID utente Loomio:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123
```

Tramite identità esterna:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123
```

Restituisce:

```json
{
  "user": {}
}
```

<!-- translation-section: update-user -->

## Aggiorna un utente

Aggiorna i campi del profilo di un utente trovato tramite il suo ID utente Loomio o la sua identità esterna.

`PATCH /api/b3/users/:id`

`PATCH /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: params -->

### Parametri

| Campo | Descrizione |
| --- | --- |
| `name` | Nome visualizzato |
| `username` | Nome utente Loomio |
| `email` | Indirizzo email |

<!-- translation-section: examples-2 -->

### Esempi

Tramite ID utente Loomio:

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/b3/users/123
```

Tramite identità esterna:

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/b3/users/identity/oauth/external-123
```

Restituisce l'utente aggiornato:

```json
{
  "user": {}
}
```

<!-- translation-section: deactivate-user -->

## Disattiva un utente

Disattiva un account utente trovato tramite il suo ID utente Loomio o la sua identità esterna.

`POST /api/b3/users/:id/deactivate`

`POST /api/b3/users/identity/:identity_type/:uid/deactivate`

<!-- translation-section: examples-3 -->

### Esempi

Tramite ID utente Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/deactivate
```

Tramite identità esterna:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/deactivate
```

Restituisce:

```json
{
  "success": true,
  "user": {}
}
```

<!-- translation-section: reactivate-user -->

## Riattiva utente

Riattiva un account utente disattivato individuato tramite il suo ID utente Loomio o la sua identità esterna.

`POST /api/b3/users/:id/reactivate`

`POST /api/b3/users/identity/:identity_type/:uid/reactivate`

<!-- translation-section: examples-4 -->

### Esempi

Tramite ID utente Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/reactivate
```

Tramite identità esterna:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/reactivate
```

Restituisce:

```json
{
  "success": true,
  "user": {}
}
```

<!-- translation-section: redact-user -->

## Rimuovi i dati personali dell'utente

La rimozione dei dati personali conserva i commenti dell'utente e gli altri contenuti che ha creato nei suoi gruppi, ma rimuove le informazioni identificative personali note, come nome, biografia, foto del profilo, indirizzo email, credenziali di accesso, identità e sessioni attive.

Questo è il metodo consigliato per rimuovere un utente da Loomio.

`POST /api/b3/users/:id/redact`

`POST /api/b3/users/identity/:identity_type/:uid/redact`

<!-- translation-section: examples-5 -->

### Esempi

Tramite ID utente Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123/redact
```

Tramite identità esterna:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123/redact
```

Restituisce:

```json
{
  "success": true
}
```

<!-- translation-section: delete-user -->

## Elimina utente

L'eliminazione rimuove l'utente e i record che ha creato. I commenti vengono rimossi dalle conversazioni, i voti vengono rimossi dai sondaggi e anche i gruppi, le discussioni, i sondaggi e gli altri record creati dall'utente possono essere eliminati tramite le associazioni del database.

Questa operazione è molto distruttiva. È fortemente consigliato usare invece la rimozione dei dati personali.

`DELETE /api/b3/users/:id`

`DELETE /api/b3/users/identity/:identity_type/:uid`

<!-- translation-section: examples-6 -->

### Esempi

Tramite ID utente Loomio:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/123
```

Tramite identità esterna:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users/identity/oauth/external-123
```

Restituisce:

```json
{
  "success": true
}
```

<!-- translation-section: sso-profile-sync-settings -->

## Impostazioni di sincronizzazione del profilo SSO

Usa queste impostazioni quando un altro sistema gestisce i campi del profilo Loomio.

```env
LOOMIO_DISABLE_EDIT_USER_PROFILE=1
# LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1
```

`LOOMIO_DISABLE_EDIT_USER_PROFILE=1` impedisce agli utenti di modificare autonomamente questi campi:

| Campo | Note |
| --- | --- |
| `name` | Gestito dalla sincronizzazione esterna |
| `username` | Gestito dalla sincronizzazione esterna |
| `email` | Gestito dalla sincronizzazione esterna |
| `avatar_kind` / `uploaded_avatar` | Gestito dalla sincronizzazione esterna |

Gli utenti possono comunque modificare i campi locali di Loomio, come `short_bio` e `location`.

`LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1` aggiorna `name` ed `email` usando i dati di accesso SSO. Lascia questa impostazione commentata o non impostata quando uno script di sincronizzazione esterna deve essere l'unica fonte di questi aggiornamenti.

`LOOMIO_SSO_FORCE_USER_ATTRS` continua a funzionare per le installazioni esistenti. Impedisce le modifiche da parte degli utenti e aggiorna `name` ed `email` all'accesso tramite SSO.
