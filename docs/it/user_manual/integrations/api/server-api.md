---
title: API del server
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/integrations/api/server-api.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-30'
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
  introduction: cd7bb3139b79d72c
  authentication: 4cfb211ba5a12bd4
  user-object: ba8f268dc0637010
  list-users: 7e2caa0ed2713f4e
  example: dfe44221be7dda5e
  show-user: 32689ce36d79c257
  examples: 2d6efddc918bf689
  update-user: 2ccaacc51b6f8a7b
  params: 3f569599d046e817
  examples-2: 64c6bc11f541a84e
  deactivate-user: aaa713728b4deb4b
  examples-3: 6abeaf19808d5841
  reactivate-user: 1e26b8aa6c4bf6c4
  examples-4: 512758bd8a575333
  redact-user: 683d84595f87429a
  examples-5: 14a3ec9e57da4250
  delete-user: 9721eeb3e80c89cb
  examples-6: f45dd892571c348d
  sso-profile-sync-settings: d853cd394f6dc8da
title_source: 370e81eb20eece44
title_generated: fb011755307eb06b
---

<!-- translation-section: introduction -->

# Documentazione dell'API del server Loomio

<!-- seo-description: Usa l'API del server Loomio per gestire gli account utente in un'installazione Loomio ospitata sul tuo server. -->

`/api/b3` serve per le operazioni a livello di server. Usa `/api/b2` per le operazioni eseguite tramite un account utente Loomio.

<!-- translation-section: authentication -->

## Autenticazione

Imposta `B3_API_KEY` su un valore segreto di più di 16 caratteri.

Invia la chiave come bearer token:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/b3/users
```

Invia le credenziali solo nell'header `Authorization`. Le chiavi API nelle stringhe di query o nel corpo delle richieste vengono rifiutate.

<!-- translation-section: user-object -->

## Oggetto utente

Le risposte relative agli utenti hanno questa struttura:

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

## Elencare gli utenti

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

## Visualizzare un utente

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

## Aggiornare un utente

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

## Disattivare un utente

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

## Riattivare un utente

Riattiva un account utente disattivato trovato tramite il suo ID utente Loomio o la sua identità esterna.

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

## Rimuovere i dati personali di un utente

La rimozione dei dati personali conserva i commenti e gli altri contenuti creati dall'utente nei suoi gruppi, ma elimina le informazioni personali note che possono identificarlo, come nome, biografia, foto del profilo, indirizzo email, credenziali di accesso, identità e sessioni attive.

È il metodo consigliato per rimuovere un utente da Loomio.

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

## Eliminare un utente

L'eliminazione rimuove l'utente e i contenuti che ha creato. I commenti vengono rimossi dalle discussioni e i voti dai sondaggi. Anche i gruppi, le discussioni, i sondaggi e altri contenuti creati dall'utente possono essere eliminati tramite le associazioni del database.

Questa operazione può eliminare molti contenuti. Ti consigliamo di oscurare i dati personali dell'utente.

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

`LOOMIO_DISABLE_EDIT_USER_PROFILE=1` impedisce agli utenti di modificare direttamente questi campi:

| Campo | Note |
| --- | --- |
| `name` | Gestito dalla sincronizzazione esterna |
| `username` | Gestito dalla sincronizzazione esterna |
| `email` | Gestito dalla sincronizzazione esterna |
| `avatar_kind` / `uploaded_avatar` | Gestito dalla sincronizzazione esterna |

Gli utenti possono comunque modificare i campi gestiti in Loomio, come `short_bio` e `location`.

`LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN=1` aggiorna `name` e `email` con i dati di accesso SSO. Lascialo commentato o non impostato se uno script di sincronizzazione esterno deve essere l'unica fonte di questi aggiornamenti.

`LOOMIO_SSO_FORCE_USER_ATTRS` funziona ancora nelle installazioni esistenti. Impedisce agli utenti di modificare il profilo e aggiorna `name` e `email` all'accesso tramite SSO.
