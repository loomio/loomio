---
title: API del server
source_revision: 81fbad246f674a34694bb2ebfc8416dd04e46ee6
source_file: docs/help/en/user_manual/integrations/api/server-api.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-28'
sections:
  introduction: 33c4ce1c59342826
  authentication: a215188bb0ae2b38
  user-object: 7e9e8ff3e48a4055
  list-users: 16e557db2983e597
  example: 5a370a67d3dc961f
  show-user: ef061aab9e142a98
  examples: 5b98557c8af42e29
  update-user: fc52abc60aa4eb6e
  params: 368f797e2a2b5c3d
  examples-2: b6bc03ca1e104210
  deactivate-user: 19c9b37ded7cad07
  examples-3: 706a02fb50225d20
  reactivate-user: 03bccb45ded4f11c
  examples-4: 5c9cf19d21267502
  redact-user: 9560a30820cb43cc
  examples-5: df81d06971fb0391
  delete-user: 1aad5e4da586e0ed
  examples-6: 23542029b0bc8237
  sso-profile-sync-settings: 416144004d040e4f
  provisioning: de7ad238bf914455
generated:
  introduction: 3bd00ddb4ee57d7d
  authentication: dfb6d2337335c607
  user-object: b2067f06a976d4d0
  list-users: 06b9d6558a1647fb
  example: 5c48ad89e464b145
  show-user: 42c00caf537d87da
  examples: b613208cdf040c78
  update-user: 309b37489735e46b
  params: 3f569599d046e817
  examples-2: 786203033b6e3ce2
  deactivate-user: 103fb606cd92a747
  examples-3: c458aafaa9483fc6
  reactivate-user: 2c62663fbe8680d0
  examples-4: b3b623d401fdeab3
  redact-user: 927e534b41a177ef
  examples-5: c70bd46a3a9dabb7
  delete-user: 8d93164661b3bdb5
  examples-6: 3dbba9d400f9b08b
  sso-profile-sync-settings: d8380e2b0eba60a5
  provisioning: f9e1bf6afa24d3ef
title_source: 370e81eb20eece44
title_generated: fb011755307eb06b
---

<!-- translation-section: introduction -->

# Documentazione delle API del server Loomio

<!-- seo-description: Usa le API del server Loomio per creare account utente, trovare gruppi e gestire le appartenenze ai gruppi su un'installazione Loomio ospitata sul tuo server. -->

`/api/server0` serve per le operazioni a livello di server. Usa `/api/user0` per le azioni eseguite con un account utente Loomio.

Usa un'unica chiave del server per creare e gestire account, trovare gruppi nell'intera installazione e gestire le appartenenze e i ruoli nei gruppi. Non sono necessari un account bot, una chiave API utente o l'appartenenza ai gruppi. Le chiavi API utente continuano a rispettare i permessi dell'utente nei gruppi.

<!-- translation-section: authentication -->

## Autenticazione

La chiave è il valore dell'impostazione `SERVER_API_KEY` nell'ambiente del server. `create_env.sh` ne genera una per le nuove installazioni.

Invia la chiave come token bearer:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users
```

Invia le credenziali solo nell'intestazione `Authorization`. Le chiavi API nelle stringhe di query o nei corpi delle richieste vengono rifiutate.

<!-- translation-section: provisioning -->

## Crea account e gestisci le appartenenze ai gruppi

| Metodo | Endpoint | Scopo |
| --- | --- | --- |
| `POST` | `/api/server0/users` | Creare un account |
| `GET` | `/api/server0/groups` | Trovare gruppi nell'intera installazione |
| `GET` | `/api/server0/memberships` | Elencare le appartenenze a un gruppo |
| `POST` | `/api/server0/memberships` | Invitare membri o sincronizzare un elenco completo dei membri |
| `PATCH` | `/api/server0/memberships/:id` | Modificare i ruoli di amministratore e delegato del gruppo |
| `DELETE` | `/api/server0/memberships/:id` | Revocare un'appartenenza |

Gli endpoint esistenti per l'aggiornamento, la disattivazione, la riattivazione, l'anonimizzazione e l'eliminazione degli account sono descritti di seguito.

### Crea un account

`POST /api/server0/users`

Invia un oggetto `user` con il campo obbligatorio `email`. Gli spazi iniziali e finali degli indirizzi email vengono rimossi e gli indirizzi vengono convertiti in minuscolo. I campi facoltativi sono `name`, `username` e `is_admin`. Qui `is_admin` indica un amministratore dell'istanza; i ruoli di amministratore del gruppo vengono gestiti tramite le appartenenze. Ometti `username` per generarne uno automaticamente. I campi sconosciuti vengono rifiutati.

```bash
curl https://loomio.example.org/api/server0/users \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  --json '{
    "user": {
      "email": "ada@example.org",
      "name": "Ada Lovelace",
      "username": "ada",
      "is_admin": false
    }
  }'
```

La risposta è HTTP `201` con un oggetto `user`. Campi non validi oppure un indirizzo email o un nome utente già in uso restituiscono HTTP `422`. La creazione di un account non invia un invito, non fa accedere la persona e non contrassegna il suo indirizzo email come verificato. Invita la persona in un gruppo tramite l'endpoint delle appartenenze per inviare un invito attraverso il normale flusso di notifiche.

### Trova i gruppi

`GET /api/server0/groups`

Elenca tutti i gruppi che non sono stati eliminati, inclusi i gruppi privati e quelli con abbonamenti scaduti. I risultati sono ordinati per ID crescente. Usa `limit` (valore predefinito e massimo `50`) e `offset` (valore predefinito `0`) per scorrerli per pagina.

```bash
curl 'https://loomio.example.org/api/server0/groups?limit=50&offset=0' \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY'
```

```json
{
  "groups": [
    {
      "id": 123,
      "key": "examplegroup",
      "name": "Planning group",
      "handle": "planning",
      "parent_id": null,
      "group_privacy": "secret"
    }
  ],
  "meta": {
    "total": 1
  }
}
```

### Elenca le appartenenze

`GET /api/server0/memberships?group_id=123`

`group_id` è obbligatorio. I risultati includono le appartenenze accettate e gli inviti in attesa, ordinati per ID di appartenenza crescente. Le appartenenze revocate sono escluse. Usa `limit` (valore predefinito e massimo `50`) e `offset` (valore predefinito `0`) per la paginazione.

```bash
curl 'https://loomio.example.org/api/server0/memberships?group_id=123&limit=50&offset=0' \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY'
```

```json
{
  "memberships": [
    {
      "id": 456,
      "group_id": 123,
      "user_id": 789,
      "user_email": "ada@example.org",
      "user_name": "Ada Lovelace",
      "admin": false,
      "delegate": false,
      "accepted_at": null,
      "pending": true
    }
  ],
  "meta": {
    "total": 1
  }
}
```

`admin` e `delegate` sono ruoli del gruppo. `accepted_at` indica la data e l'ora di accettazione, oppure `null` mentre un invito è in attesa. Questo endpoint non espone token di invito, credenziali di accesso o voti.

### Invita o sincronizza i membri

`POST /api/server0/memberships`

Invia i campi obbligatori `group_id` e `emails`, quest'ultimo come array. Per impostazione predefinita, vengono aggiunte le persone elencate che non hanno già un'appartenenza attiva, mantenendo tutti gli altri membri. Gli spazi iniziali e finali degli indirizzi email vengono rimossi, gli indirizzi vengono convertiti in minuscolo e i duplicati vengono eliminati. Per i nuovi indirizzi vengono creati account e inviti in attesa. I membri già verificati di un altro gruppo attivo nella stessa organizzazione vengono accettati automaticamente, come nel flusso di invito delle API utente.

```bash
curl https://loomio.example.org/api/server0/memberships \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  --json '{
    "group_id": 123,
    "emails": [
      "ada@example.org",
      "alex@example.org"
    ]
  }'
```

Per sincronizzare un elenco completo dei membri, imposta esplicitamente `remove_absent` su `true`. Chiunque non sia presente nell'elenco viene rimosso dal gruppo e dai suoi sottogruppi. Un array vuoto con `remove_absent: true` rimuove tutti, inclusi gli amministratori del gruppo. Ometti `remove_absent` o impostalo su `false` quando vuoi solo aggiungere persone. Sono accettati anche i valori precedenti `1` e `0`.

```bash
curl https://loomio.example.org/api/server0/memberships \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  --json '{
    "group_id": 123,
    "emails": [
      "ada@example.org"
    ],
    "remove_absent": true
  }'
```

```json
{
  "added_emails": [],
  "removed_emails": [
    "alex@example.org"
  ]
}
```

Ripetere la stessa richiesta non crea appartenenze duplicate e non invia nuovamente gli inviti. Invitare di nuovo un membro la cui appartenenza è stata revocata ripristina il suo accesso al gruppo senza ripristinare un precedente ruolo di amministratore. I nuovi inviti e le modifiche ai ruoli usano il normale flusso di notifiche, senza registrare alcun utente come autore dell'azione.

Elenchi di indirizzi email mancanti o non correttamente formati e valori booleani non validi restituiscono HTTP `400`. Un account disattivato presente nell'elenco restituisce HTTP `422`; riattivalo esplicitamente prima di aggiungerlo. Dati dell'account non validi, limiti dell'abbonamento o altri errori annullano l'intera sincronizzazione, inclusi i nuovi account e le rimozioni delle appartenenze. Le aggiunte richiedono un gruppo attivo e restano soggette ai limiti sul numero di membri previsti dall'abbonamento.

### Aggiorna i ruoli di un'appartenenza

`PATCH /api/server0/memberships/:id`

Invia un oggetto `membership` contenente uno o entrambi i campi booleani `admin` e `delegate`. I ruoli omessi restano invariati. I campi sconosciuti vengono rifiutati; l'endpoint non può trasferire un'appartenenza, accettare un invito o modificare i pesi dei voti.

```bash
curl https://loomio.example.org/api/server0/memberships/456 \
  -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  --json '{
    "membership": {
      "admin": true,
      "delegate": false
    }
  }'
```

Restituisce un oggetto `membership` con gli stessi campi di un'appartenenza restituita nell'elenco. L'assegnazione di un ruolo genera la consueta notifica relativa al ruolo; ripetere un ruolo invariato non invia una nuova notifica. Le modifiche ai ruoli richiedono un gruppo attivo. Le appartenenze revocate restituiscono HTTP `404`.

### Rimuovi un'appartenenza

`DELETE /api/server0/memberships/:id`

```bash
curl https://loomio.example.org/api/server0/memberships/456 \
  -X DELETE \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY'
```

Restituisce `{"success": true}`. La rimozione revoca l'accesso al gruppo e ai suoi sottogruppi, inclusi l'accesso agli argomenti e il diritto di voto nei sondaggi attivi. Non elimina l'account, non modifica i gruppi non correlati e non revoca l'accesso diretto alle conversazioni. Ripetere una rimozione ha esito positivo. Puoi rimuovere appartenenze da gruppi con abbonamenti scaduti; i gruppi eliminati restituiscono HTTP `404`.

<!-- translation-section: user-object -->

## Oggetto utente

Le risposte relative agli utenti usano questa struttura:

```json
{
  "id": 123,
  "name": "Ada Lovelace",
  "username": "ada",
  "email": "ada@example.org",
  "is_admin": false,
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

`GET /api/server0/users`

<!-- translation-section: example -->

### Esempio

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users
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

`GET /api/server0/users/:id`

`GET /api/server0/users/identity/:identity_type/:uid`

<!-- translation-section: examples -->

### Esempi

Tramite ID utente Loomio:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123
```

Tramite identità esterna:

```bash
curl -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123
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

`PATCH /api/server0/users/:id`

`PATCH /api/server0/users/identity/:identity_type/:uid`

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
  https://www.loomio.com/api/server0/users/123
```

Tramite identità esterna:

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_SERVER_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"user":{"name":"Ada Lovelace","username":"ada","email":"ada@example.org"}}' \
  https://www.loomio.com/api/server0/users/identity/oauth/external-123
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

`POST /api/server0/users/:id/deactivate`

`POST /api/server0/users/identity/:identity_type/:uid/deactivate`

<!-- translation-section: examples-3 -->

### Esempi

Tramite ID utente Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123/deactivate
```

Tramite identità esterna:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123/deactivate
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

`POST /api/server0/users/:id/reactivate`

`POST /api/server0/users/identity/:identity_type/:uid/reactivate`

<!-- translation-section: examples-4 -->

### Esempi

Tramite ID utente Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123/reactivate
```

Tramite identità esterna:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123/reactivate
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

`POST /api/server0/users/:id/redact`

`POST /api/server0/users/identity/:identity_type/:uid/redact`

<!-- translation-section: examples-5 -->

### Esempi

Tramite ID utente Loomio:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123/redact
```

Tramite identità esterna:

```bash
curl -X POST -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123/redact
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

`DELETE /api/server0/users/:id`

`DELETE /api/server0/users/identity/:identity_type/:uid`

<!-- translation-section: examples-6 -->

### Esempi

Tramite ID utente Loomio:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/123
```

Tramite identità esterna:

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_SERVER_API_KEY' https://www.loomio.com/api/server0/users/identity/oauth/external-123
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
