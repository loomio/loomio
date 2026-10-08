---
title: API utente
source_revision: c27ee3b193231816878f1c074ff9fc2a086a88c0
source_file: docs/en/user_manual/integrations/api/user-api.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-02'
sections:
  introduction: a43c8b800d13fd33
  authentication-change: 06b5c2cd9d9e72a0
  response-size-and-related-records: 1ffc59ad606a87e7
  endpoint-summary: 52c480c59d3669e3
  groups: 0473f1f7fb78f074
  list-groups: 2b783ec54f27b2ce
  get-a-group: dffef659cb92745e
  webhooks: f65fa289f8c1b808
  list-webhooks: a8b52c1a9bfdb16c
  create-a-webhook: 007312bcc204853a
  update-a-webhook: 124b07d2c401e319
  test-a-webhook-destination: 8fc3ac4ad10de6f6
  delete-a-webhook: 34eda1e07d65db80
  event-types: 73bfe87c8b790af3
  http-delivery: a32c763b6f816e65
  payload-formats: ca728b0ef542305c
  search: bb5a1cfc7a6179aa
  params: 7eebe4e259830976
  participation-report: a1798112a78390fe
  params-2: 464322ffc1ac56e5
  example: 63bed6e82107f992
  create-discussion: ad202a0bdbfa7c2e
  params-3: 529f10e32be74c5c
  example-2: f25daafbba33718c
  show-discussion: b61aea6bf3d55e16
  example-3: e095e8e34cd562a0
  list-discussions: f209b8feb7c795a6
  params-4: 3ec197245f595be6
  example-4: 37d59c03fee8a15b
  list-threads: 34edc6c34552e136
  params-5: a5f41285afccdc8b
  example-5: 81c145ad5f6eb232
  read-thread: 0de1409aaa00b9ac
  example-6: 7c7553e1a3e94070
  edit-discussion: 1ab04653354b8036
  params-6: 4d3f5862a5f948b4
  example-7: d2a61a34af9e99c3
  soft-delete-discussion: fdb0d4db8470524c
  example-8: 423894a70b5ce489
  create-comment: bf95ee58b610f2fd
  params-7: 7af2127e1f721b66
  example-9: 4e7d49ac39938c12
  edit-comment: 49e722ec6bca25a1
  params-8: b2be783e4398d866
  example-10: bf626a7f693182c3
  soft-delete-comment: afb51bf4074aeab7
  example-11: e39b758ad0d7aa62
  create-poll: b2a11ae34ce22151
  params-9: 3e592c12f9cbb757
  example-12: f5d6029049637276
  show-poll: 2e7a14ac23eeffa6
  example-13: 1a5acf0b8a6f62f2
  list-polls: 606f27566d6d5f98
  params-10: 1b1a6f003f91eb9a
  example-14: 710a82f6b2203f48
  edit-poll: 42b85770aebd8ef2
  params-11: 52d278a2f38d6a9f
  example-15: 8f7d523fc36f5da7
  soft-delete-poll: 0f1b24e1263dcfbe
  example-16: ec71cfcd4a0b98ab
  list-memberships: 82712683aa3a424a
  params-12: d2fc821e97d53145
  example-17: 266443e0eb35078c
  manage-memberships: 3c821029101515ad
  params-13: 249b307203206387
  example-18: ffd950cd7ab5aaec
generated:
  introduction: 4fd1db00db0cb17c
  authentication-change: fd222696d560e097
  response-size-and-related-records: 18252aa0939027fa
  endpoint-summary: 27f73ad1bcdf2a38
  groups: 42011ba3c7a9e4fd
  list-groups: fa1437ff6f8d57ff
  get-a-group: d4f06d08dfd1ae19
  webhooks: a1f033b6fb23cbe7
  list-webhooks: 0a0baee15cbcdb66
  create-a-webhook: 2d67c4722121e614
  update-a-webhook: 3bc2cb8d79d345c9
  test-a-webhook-destination: 2de7ee7826f077ea
  delete-a-webhook: 6f290b607cf10b9f
  event-types: e18164a7fae70ef3
  http-delivery: 186b4cb88d591c83
  payload-formats: ded2ccd043b604b9
  search: 55bd6b3af01069f4
  params: 4d32c98357d82f07
  participation-report: 8e800a3ae5453d42
  params-2: 0a16ef60104137ce
  example: 84c84693cf8559f9
  create-discussion: 854f60fcacec213b
  params-3: 589ca5fdad0f8b2e
  example-2: 31210b378082b54f
  show-discussion: 28ed270d5dfde016
  example-3: 24844d6efe2025bf
  list-discussions: 81c7f47895c306bd
  params-4: fd99111f2bfaa401
  example-4: 68cc95e0d84d0449
  list-threads: 9b07dff78d209474
  params-5: 2286519a115cee16
  example-5: aaada67349ae9821
  read-thread: e6bde1266415635a
  example-6: 5bce588e0ecd5d59
  edit-discussion: ba248b6c47ef8a9d
  params-6: 76a7c483f6117db8
  example-7: f5e59e4dfc6d485d
  soft-delete-discussion: 05cb5d88cdb53ff4
  example-8: 2b73fc94de6b63d1
  create-comment: 10ce4d1c38637f92
  params-7: b4635601c1beef80
  example-9: d4759f76bbd035f1
  edit-comment: 92d30dc22dcc93c0
  params-8: f4b6c0d113c91617
  example-10: 209381bd47b3e380
  soft-delete-comment: c7d7c6e3c6a474eb
  example-11: f6df5bd89872e531
  create-poll: 1de7ce59e39b6722
  params-9: c0bf55593122afce
  example-12: 9cb3b7724fdd8eb0
  show-poll: 649402ae0acc61ff
  example-13: f08d34bfaa3ea688
  list-polls: aec06dd49a6602ba
  params-10: b7a932bd23bc0020
  example-14: e7924e10d172b242
  edit-poll: 2b53d9de26a72f73
  params-11: d3b473c9e13f0235
  example-15: 156d9c3b92f7a1fb
  soft-delete-poll: 6782c78aba9a1c91
  example-16: 68b7f1079a5b149a
  list-memberships: 55569e453c027c99
  params-12: f4b2bda5c44e1d5c
  example-17: c076310bc023c187
  manage-memberships: af994b94a4985f0d
  params-13: c1078369276e386e
  example-18: 9ae484be78895872
title_source: c23fb6526b722360
title_generated: 431e416c4c7bba9a
---

<!-- translation-section: introduction -->

# Documentazione dell'API utente di Loomio

<!-- seo-description: Usa l'API utente di Loomio per creare e gestire discussioni, commenti, sondaggi, conversazioni e iscrizioni ai gruppi da altri software. -->

`/api/b2` è l'API orientata agli utenti per le integrazioni con Loomio. Usa la chiave API di un account utente e ogni azione viene eseguita come quell'utente.

Le operazioni sui gruppi usano le iscrizioni e i permessi nei gruppi dell'utente titolare della chiave API. Il ruolo di amministratore dell'istanza non amplia l'accesso di una chiave API ai gruppi o ai contenuti; usa l'API server per l'amministrazione a livello di istanza.

Usa la chiave API dell'account utente Loomio che eseguirà le azioni. Un account bot dedicato è utile quando un'integrazione non deve essere invitata ai sondaggi o ricevere notifiche.

Gli utenti che hanno effettuato l'accesso possono trovare la propria chiave API e gli ID dei gruppi nella [pagina di accesso API](/profile/api_access).

Invia la chiave API in un'intestazione `Authorization: Bearer`. Le chiavi API nelle stringhe di query vengono rifiutate perché gli URL possono essere registrati dai proxy e nei log di accesso.

<!-- translation-section: authentication-change -->

### Modifica dell'autenticazione

In precedenza, la chiave API veniva accettata come parametro URL `api_key`. Le richieste che usano `?api_key=YOUR_API_KEY` non funzionano più. Usa invece l'intestazione HTTP `Authorization`:

```text
Authorization: Bearer YOUR_API_KEY
```

Gli esempi usano `YOUR_API_KEY`, l'ID gruppo `123` e `https://www.loomio.com/`. Sostituiscili con la tua chiave API, l'ID del tuo gruppo e l'URL della tua installazione di Loomio.

<!-- translation-section: response-size-and-related-records -->

## Dimensione delle risposte e record correlati

Le risposte dell'API utente usano un formato composto: i record principali sono accompagnati da record correlati, come topic, gruppi, utenti, sondaggi e reazioni. Questo consente a un client di popolare un archivio locale di record con una sola richiesta, ma può includere più dati di quanti ne servano a una semplice integrazione.

Passa `compact=1` per omettere i record correlati voluminosi relativi a topic, gruppi, gruppi principali, iscrizioni, reazioni, tag e traduzioni. I record principali e i record correlati necessari per interpretarne il contenuto restano presenti.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads/123/items?compact=1'
```

Per un controllo diretto, passa `exclude_types` con i tipi di record al singolare separati da spazi. Ad esempio, `exclude_types=group reaction` omette i gruppi e le reazioni correlati. I valori comuni sono `topic`, `group`, `parent`, `membership`, `reaction`, `tag`, `translation`, `user`, `discussion`, `poll`, `poll_option`, `stance`, `stance_choice`, `outcome` e `topic_item`. Le esclusioni si applicano ai record correlati, non alla risorsa principale richiesta dall'endpoint.

Le risposte relative a raccolte includono `meta.total` quando è definita una dimensione esatta della raccolta. Il totale viene calcolato prima di applicare `limit` e `offset`. Gli endpoint come quello di ricerca, che restituiscono intenzionalmente un insieme limitato di risultati, omettono `meta.total` anziché restituire `null`.

<!-- translation-section: endpoint-summary -->

## Riepilogo degli endpoint

| Metodo | Endpoint | Scopo |
| --- | --- | --- |
| `GET` | `/api/b2/groups` | Elenca i gruppi dell'utente titolare della chiave API |
| `GET` | `/api/b2/groups/:id_or_key_or_handle` | Recupera un gruppo visibile |
| `GET` | `/api/b2/reports` | Genera un rapporto sulla partecipazione |
| `GET` | `/api/b2/search` | Cerca discussioni, commenti, sondaggi, voti e conclusioni visibili |
| `POST` | `/api/b2/discussions` | Crea una discussione |
| `GET` | `/api/b2/discussions/:id` | Recupera una discussione |
| `GET` | `/api/b2/discussions` | Elenca le discussioni di un gruppo |
| `PATCH` | `/api/b2/discussions/:id` | Modifica una discussione |
| `DELETE` | `/api/b2/discussions/:id` | Elimina logicamente una discussione |
| `GET` | `/api/b2/threads` | Elenca le conversazioni visibili delle discussioni e dei sondaggi autonomi |
| `GET` | `/api/b2/threads/:topic_id` | Recupera una conversazione |
| `GET` | `/api/b2/threads/:topic_id/items` | Recupera gli elementi ordinati di una conversazione |
| `GET` | `/api/b2/threads/:topic_id/markdown` | Recupera una conversazione completa in formato Markdown |
| `POST` | `/api/b2/comments` | Crea un commento o una risposta |
| `PATCH` | `/api/b2/comments/:id` | Modifica un commento |
| `DELETE` | `/api/b2/comments/:id` | Elimina logicamente un commento |
| `POST` | `/api/b2/polls` | Crea un sondaggio |
| `GET` | `/api/b2/polls/:id` | Recupera un sondaggio |
| `GET` | `/api/b2/polls` | Elenca i sondaggi di un gruppo |
| `PATCH` | `/api/b2/polls/:id` | Modifica un sondaggio |
| `DELETE` | `/api/b2/polls/:id` | Elimina logicamente un sondaggio |
| `GET` | `/api/b2/memberships` | Elenca le iscrizioni a un gruppo |
| `POST` | `/api/b2/memberships` | Aggiunge membri e, facoltativamente, rimuove i membri assenti dall'elenco |
| `GET` | `/api/b2/chatbots` | Elenca le integrazioni di chat e i webhook di un gruppo |
| `POST` | `/api/b2/chatbots` | Crea un'integrazione di chat o un webhook |
| `PATCH` | `/api/b2/chatbots/:id` | Aggiorna un'integrazione di chat o un webhook |
| `DELETE` | `/api/b2/chatbots/:id` | Elimina un'integrazione di chat o un webhook |
| `POST` | `/api/b2/chatbots/check` | Invia un test di connessione a un webhook |

<!-- translation-section: groups -->

## Gruppi

<!-- translation-section: list-groups -->

### Elenca i gruppi

Restituisce i gruppi in cui l'utente titolare della chiave API ha un'iscrizione attiva.

`GET /api/b2/groups`

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups
```

La risposta contiene tutti i record corrispondenti in un array `groups` senza paginazione. Include gruppi principali e sottogruppi, anche quelli il cui abbonamento non è attualmente attivo. Controlla il campo `enabled` quando un'integrazione deve operare solo sui gruppi abilitati.

Tra i campi importanti dei gruppi ci sono:

| Campo | Descrizione |
| --- | --- |
| `id` | ID numerico del gruppo usato dagli altri endpoint dell'API utente |
| `key` | Chiave breve e stabile usata negli URL di Loomio |
| `handle` | Identificativo leggibile del gruppo |
| `name` | Nome del gruppo |
| `full_name` | Nome del gruppo che include il contesto del gruppo principale |
| `parent_id` | ID numerico del gruppo principale per un sottogruppo, altrimenti `null` |
| `enabled` | Indica se il gruppo e il suo abbonamento sono attivi |
| `memberships_count` | Numero di iscrizioni attive e in attesa |
| `accepted_memberships_count` | Numero di iscrizioni accettate |
| `pending_memberships_count` | Numero di inviti in attesa |
| `admin_memberships_count` | Numero di amministratori del gruppo |
| `discussions_count` | Numero di discussioni direttamente nel gruppo |
| `polls_count` | Numero di sondaggi direttamente nel gruppo |
| `subgroups_count` | Numero di sottogruppi |

La risposta può includere ulteriori impostazioni del gruppo, record correlati del gruppo principale e le iscrizioni dell'utente API. I client dovrebbero ignorare i campi che non usano.

<!-- translation-section: get-a-group -->

### Recupera un gruppo

Restituisce un gruppo visibile all'utente titolare della chiave API.

`GET /api/b2/groups/:id_or_key_or_handle`

L'identificatore può essere l'ID numerico, la chiave o l'identificativo leggibile del gruppo.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/123
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/example-group
```

La risposta contiene il gruppo nell'array `groups` e usa gli stessi campi dell'endpoint che elenca i gruppi. Una richiesta per un gruppo a cui l'utente titolare della chiave API non può accedere restituisce un errore di autorizzazione.

<!-- translation-section: webhooks -->

## Webhook

L'API utente si basa sulle richieste: un'integrazione chiama Loomio quando vuole leggere o modificare dati. Un webhook di gruppo permette invece a Loomio di inviare gli aggiornamenti. Loomio invia gli eventi selezionati del gruppo al tuo endpoint quando si verificano, quindi un'integrazione non deve interrogare periodicamente l'API REST per rilevare le modifiche.

I webhook vengono configurati per ciascun gruppo e richiedono i permessi di amministratore del gruppo. Puoi gestirli tramite l'interfaccia di Loomio:

1. Apri il gruppo.
2. Apri il menu del gruppo e seleziona **Integrazioni di chat**.
3. Aggiungi l'integrazione corrispondente al formato del payload accettato dal tuo endpoint. Per un endpoint generico, usa il formato Mattermost/Markdown.
4. Inserisci un nome e l'URL di destinazione.
5. Seleziona gli eventi che Loomio deve inviare automaticamente.
6. Salva l'integrazione e usa **Test connection** per inviare un messaggio di prova.

Usa una destinazione HTTPS con un URL impossibile da indovinare. Loomio richiede che la destinazione si risolva in un indirizzo pubblico e blocca le richieste verso indirizzi di rete locali o privati.

Gli agenti e le altre integrazioni possono invece gestire i webhook tramite gli endpoint chatbot con autenticazione Bearer descritti di seguito. La risorsa si chiama `chatbots` per compatibilità con le integrazioni di chat di Loomio, ma rappresenta anche webhook generici in uscita.

<!-- translation-section: list-webhooks -->

### Elenca i webhook

Restituisce le integrazioni di chat configurate per un gruppo. L'utente titolare della chiave API deve essere un amministratore di quel gruppo. La risposta include gli URL di destinazione, quindi non deve essere resa accessibile ai membri ordinari del gruppo.

`GET /api/b2/chatbots?group_id=123`

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/chatbots?group_id=123'
```

La risposta contiene un array `chatbots` con questi campi:

| Campo | Descrizione |
| --- | --- |
| `id` | ID dell'integrazione usato per gli aggiornamenti e l'eliminazione |
| `group_id` | Gruppo che riceve gli eventi |
| `name` | Nome dell'integrazione per uso amministrativo |
| `kind` | `webhook` per un webhook in uscita o `matrix` per un'integrazione Matrix |
| `webhook_kind` | Formato del payload: `markdown`, `slack`, `discord`, `microsoft` o `webex` |
| `server` | URL di destinazione |
| `event_kinds` | Eventi inviati automaticamente |
| `notification_only` | Indica se i messaggi contengono solo il titolo della notifica |

<!-- translation-section: create-a-webhook -->

### Crea un webhook

`POST /api/b2/chatbots`

```bash
curl -X POST \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{
    "group_id": 123,
    "name": "Planning system",
    "kind": "webhook",
    "webhook_kind": "markdown",
    "server": "https://hooks.example.org/loomio/unguessable-token",
    "event_kinds": ["new_discussion", "new_comment", "poll_created", "outcome_created"],
    "notification_only": false
  }' \
  https://www.loomio.com/api/b2/chatbots
```

L'utente titolare della chiave API deve essere un amministratore del gruppo indicato da `group_id`. Prima del salvataggio, viene verificato che la destinazione sia un URL pubblico.

<!-- translation-section: update-a-webhook -->

### Aggiorna un webhook

`PATCH /api/b2/chatbots/:id`

Invia tutti i campi da modificare. Non puoi trasferire il webhook a un altro gruppo modificando `group_id`.

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"name":"Planning events","event_kinds":["new_discussion","outcome_created"]}' \
  https://www.loomio.com/api/b2/chatbots/456
```

<!-- translation-section: test-a-webhook-destination -->

### Verifica una destinazione webhook

Invia un messaggio di prova compatibile con Markdown a una destinazione prima o dopo averne salvato la configurazione.

`POST /api/b2/chatbots/check`

```bash
curl -X POST \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"group_id":123,"server":"https://hooks.example.org/loomio/unguessable-token"}' \
  https://www.loomio.com/api/b2/chatbots/check
```

<!-- translation-section: delete-a-webhook -->

### Elimina un webhook

`DELETE /api/b2/chatbots/:id`

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/chatbots/456
```

L'eliminazione della configurazione interrompe gli invii futuri. Non elimina alcun contenuto del gruppo Loomio.

<!-- translation-section: event-types -->

### Tipi di evento

Un webhook può iscriversi a questi tipi di evento:

| Evento | Quando viene inviato |
| --- | --- |
| `new_discussion` | Viene avviata una discussione |
| `discussion_edited` | Viene modificata una discussione |
| `new_comment` | Viene creato un commento |
| `poll_created` | Viene avviato un sondaggio |
| `poll_edited` | Viene modificato un sondaggio |
| `poll_closing_soon` | Un sondaggio si avvicina all'orario di chiusura |
| `poll_expired` | Un sondaggio raggiunge l'orario di chiusura |
| `poll_closed_by_user` | Una persona chiude manualmente un sondaggio |
| `poll_reopened` | Viene riaperto un sondaggio |
| `outcome_created` | Viene pubblicata una conclusione |
| `outcome_updated` | Viene aggiornata una conclusione |
| `outcome_review_due` | Arriva la scadenza per la revisione di una conclusione |
| `stance_created` | Viene espresso un voto |
| `stance_updated` | Viene modificato un voto |

Il webhook appartiene a un gruppo e riceve da quel gruppo gli eventi a cui è iscritto. Le persone possono anche selezionare esplicitamente l'integrazione quando condividono contenuti o inviano alcune notifiche, anche quando l'evento automatico corrispondente non è selezionato.

<!-- translation-section: http-delivery -->

### Invio HTTP

Loomio invia una richiesta HTTP `POST` asincrona all'URL configurato con questa intestazione:

```text
Content-Type: application/json; charset=utf-8
```

Il timeout della richiesta è di cinque secondi. Una risposta `2xx`, inclusa `204 No Content`, viene considerata riuscita. I servizi che ricevono i webhook dovrebbero rispondere rapidamente, elaborare le operazioni più lunghe in modo asincrono e gestire invii duplicati o fuori ordine.

Al momento Loomio non aggiunge una firma del webhook, un'intestazione con un segreto condiviso, un ID evento o un ID invio. Tratta l'URL di destinazione completo come una credenziale, non esporlo pubblicamente e includi nell'URL un token impossibile da indovinare quando il servizio ricevente lo supporta. Se ti serve uno schema degli eventi stabile e leggibile da software o un invio firmato, usa il webhook come notifica di modifica e recupera i record aggiornati tramite l'API utente autenticata.

<!-- translation-section: payload-formats -->

### Formati del payload

I payload dei webhook sono messaggi destinati ai servizi di chat e pensati per la visualizzazione. Non sono record Loomio serializzati completi. I link nel messaggio identificano il contenuto Loomio interessato; un'integrazione può recuperare ulteriori informazioni tramite l'API utente quando le serve lo stato attuale in forma strutturata.

| Formato dell'integrazione | Campi JSON principali |
| --- | --- |
| Mattermost/Markdown | `text`, `icon_url`, `username` |
| Slack | `text` |
| Discord | `content`, limitato a circa 1.900 caratteri |
| Microsoft Teams | `@type`, `@context`, `themeColor`, `text`, `sections` |
| Webex | `markdown` |

Ad esempio, il formato Markdown generico invia un corpo con questa struttura:

```json
{
  "text": "Ada started a discussion: [Quarterly planning](https://example.loomio.org/d/example)",
  "icon_url": "https://example.loomio.org/path/to/group-logo.png",
  "username": "Loomio"
}
```

Il testo esatto del messaggio dipende dall'evento, dalle impostazioni locali del gruppo, dall'impostazione che limita i messaggi alla sola notifica e dalla versione di Loomio. I servizi riceventi dovrebbero basarsi sui campi di primo livello documentati del formato selezionato, anziché analizzare la formulazione delle frasi.

<!-- translation-section: search -->

## Ricerca

Cerca discussioni, commenti, sondaggi, voti e conclusioni visibili all'utente della chiave API. I risultati includono i contenuti pubblici anche quando l'utente non è membro del relativo gruppo; i contenuti privati restano soggetti alle normali regole di visibilità delle conversazioni.

`GET /api/b2/search`

<!-- translation-section: params -->

### Parametri

| Nome | Descrizione |
| --- | --- |
| `query` | Testo da cercare. Sono supportate corrispondenze esatte e approssimative |
| `group_id` | Limita i risultati a un gruppo visibile |
| `org_id` | Limita i risultati a un gruppo principale visibile e ai suoi sottogruppi visibili. Usa `0` per le discussioni dirette |
| `type` | Limita i risultati a un tipo: `Discussion`, `Comment`, `Poll`, `Stance` o `Outcome` |
| `types` | Elenco dei tipi di risultato separati da virgole |
| `tag` | Limita i risultati alle conversazioni con questo tag |
| `author_id` | Limita i risultati ai contenuti di un autore. Senza `query`, restituisce l'attività recente visibile di quell'autore |
| `order` | Imposta su `authored_at_desc` per ordinare i contenuti corrispondenti in base al momento della creazione |

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/search?query=quarterly+planning&type=Discussion'
```

La risposta contiene un array `search_results`. Ogni risultato identifica il record corrispondente e il suo contesto visibile con campi che includono `searchable_type`, `searchable_id`, `highlight`, `group_id`, `group_name`, `discussion_key`, `poll_key`, `author_id`, `author_name`, `authored_at` e `tags`. I campi non applicabili a un risultato sono `null`.

<!-- translation-section: participation-report -->

## Report sulla partecipazione

Restituisce gli stessi dati aggregati sulla partecipazione usati dal report sulla partecipazione di Loomio.

`GET /api/b2/reports`

<!-- translation-section: params-2 -->

### Parametri

| Nome | Descrizione |
| --- | --- |
| `section` | Sezione del report: `base`, `users` o `countries`. Usa `users` per l'attività per persona |
| `group_scope` | `custom` o `my`. Il valore precedente `all` viene trattato come `my` perché le chiavi dell'API utente non ricevono mai accesso all'intera istanza |
| `group_ids` | ID dei gruppi separati da virgole quando `group_scope=custom`. Gli ID dei gruppi a cui l'utente API non appartiene vengono ignorati |
| `start_month` | Primo mese da includere, nel formato `YYYY-MM`; il valore predefinito è 12 mesi fa |
| `end_month` | Ultimo mese da includere, nel formato `YYYY-MM`; il valore predefinito è il mese corrente |
| `interval` | Intervallo per la sezione `base`: `day`, `week`, `month` o `year` |
| `member_type` | Imposta su `delegate` con `section=users` per restituire solo i delegati attuali |

Una persona è un delegato quando è membro attivo con il ruolo di delegato in almeno uno dei gruppi selezionati. I suoi conteggi vengono aggregati su tutti i gruppi selezionati. Le righe dei delegati vengono restituite anche quando tutti i conteggi delle attività sono pari a zero. I conteggi riguardano conversazioni, commenti, sondaggi, voti, conclusioni e reazioni; non sono tassi di partecipazione al voto. Le righe degli utenti includono anche le schede di voto identificato assegnate, compilate e non compilate. I sondaggi anonimi sono esclusi da tutti i conteggi dei voti per persona. `all_votes_cast` è true solo quando è stata assegnata almeno una scheda di voto e tutte le schede assegnate sono state compilate.

L'API applica le stesse regole di visibilità dei gruppi del report nell'applicazione. Una chiave API utente non può esporre dati del report relativi a gruppi a cui quell'utente non può accedere.

<!-- translation-section: example -->

### Esempio

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/reports?section=users&group_scope=custom&group_ids=123&member_type=delegate&start_month=2026-01&end_month=2026-09'
```

L'array `users` contiene righe complete sulle attività:

```json
{
  "users": [
    {
      "id": 456,
      "name": "Ada Lovelace",
      "country": "NZ",
      "delegate": true,
      "threads": 2,
      "comments": 8,
      "polls": 1,
      "votes": 5,
      "votes_cast": 5,
      "votes_issued": 6,
      "votes_missed": 1,
      "all_votes_cast": false,
      "outcomes": 1,
      "reactions": 4
    }
  ]
}
```

<!-- translation-section: create-discussion -->

## Crea una discussione

Crea una discussione come utente della chiave API.

`POST /api/b2/discussions`

<!-- translation-section: params-3 -->

### Parametri

| Nome | Descrizione |
| --- | --- |
| `group_id` | Gruppo in cui verrà creata la conversazione |
| `title` | Titolo della conversazione, obbligatorio |
| `description` | Contesto della conversazione, facoltativo |
| `description_format` | `md` o `html`, facoltativo, valore predefinito `md` |
| `recipient_audience` | `group` o null. Se è `group`, l'intero gruppo riceverà una notifica sulla nuova conversazione |
| `recipient_user_ids` | Array di ID degli utenti da notificare o invitare alla conversazione |
| `recipient_emails` | Array di indirizzi email delle persone da invitare alla conversazione |
| `recipient_message` | Messaggio da includere nell'invito via email |

<!-- translation-section: example-2 -->

### Esempio

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example thread", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/discussions
```

<!-- translation-section: show-discussion -->

## Visualizza una discussione

Recupera una discussione usando il suo ID, un numero intero, oppure la sua chiave, una stringa.

`GET /api/b2/discussions/:id`

<!-- translation-section: example-3 -->

### Esempio

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/discussions/abc123
```

<!-- translation-section: list-discussions -->

## Elenca le discussioni

Elenca le discussioni di un gruppo visibili all'utente della chiave API. Per un gruppo visibile pubblicamente, anche chi non ne è membro può elencare le discussioni pubbliche; le discussioni private restano accessibili solo agli utenti che possono leggerle in Loomio.

`GET /api/b2/discussions`

<!-- translation-section: params-4 -->

### Parametri

| Nome | Descrizione |
| --- | --- |
| `group_id` | Numero intero, obbligatorio. ID del gruppo di cui elencare le discussioni |
| `status` | Stringa, facoltativa, valore predefinito `open`. Valori: `open`, `closed`, `all` |
| `limit` | Numero intero, facoltativo, valore predefinito 50. Dimensione della pagina |
| `offset` | Numero intero, facoltativo, valore predefinito 0. Scostamento per la paginazione |

Compatibilità con le versioni precedenti: `per` e `from` sono accettati come alias di `limit` e `offset` e continueranno a funzionare.

<!-- translation-section: example-4 -->

### Esempio

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/discussions?group_id=123'
```

<!-- translation-section: list-threads -->

## Elenca le conversazioni

Elenca le conversazioni delle discussioni e dei sondaggi visibili all'utente della chiave API, ordinate per attività più recente. L'ID di una conversazione è il suo `topic_id`.

`GET /api/b2/threads`

<!-- translation-section: params-5 -->

### Parametri

| Nome | Descrizione |
| --- | --- |
| `limit` | Numero intero, facoltativo, valore predefinito 50. Dimensione della pagina |
| `offset` | Numero intero, facoltativo, valore predefinito 0. Scostamento per la paginazione |

<!-- translation-section: example-5 -->

### Esempio

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads?limit=50&offset=0'
```

<!-- translation-section: read-thread -->

## Leggi una conversazione

Leggi una conversazione, la sua sequenza ordinata di eventi oppure il suo documento Markdown completo con tutti i contenuti visibili.

`GET /api/b2/threads/:topic_id`

`GET /api/b2/threads/:topic_id/items`

`GET /api/b2/threads/:topic_id/markdown`

<!-- translation-section: example-6 -->

### Esempio

```text
GET https://www.loomio.com/api/b2/threads/<topic_id>
GET https://www.loomio.com/api/b2/threads/<topic_id>/items
GET https://www.loomio.com/api/b2/threads/<topic_id>/markdown
```

L'endpoint `items` restituisce la sequenza ordinata di eventi, inclusi commenti, sondaggi, voti e conclusioni visibili. L'endpoint `markdown` restituisce l'intera conversazione visibile in un unico documento Markdown. I motivi dei voti sono inclusi solo quando sono visibili all'utente della chiave API.

Tutti gli endpoint delle conversazioni applicano gli stessi permessi dell'interfaccia di Loomio. La chiave API non concede l'accesso a una conversazione che l'utente non può normalmente aprire.

<!-- translation-section: edit-discussion -->

## Modifica una discussione

Modifica una discussione come utente della chiave API. Si applicano gli stessi permessi di Loomio: l'utente deve essere autorizzato a modificare quella discussione.

`PATCH /api/b2/discussions/:id`

<!-- translation-section: params-6 -->

### Parametri

| Nome | Descrizione |
| --- | --- |
| `title` | Titolo aggiornato |
| `description` | Contesto aggiornato |
| `description_format` | `md` oppure `html`, facoltativo, valore predefinito `md` |
| `recipient_audience` | `group` oppure null. Se è `group`, l'intero gruppo riceverà una notifica della modifica |
| `recipient_user_ids` | Array di ID degli utenti da notificare o invitare alla conversazione |
| `recipient_emails` | Array di indirizzi email delle persone da invitare alla conversazione |
| `recipient_message` | Messaggio da includere nell'invito via email |

<!-- translation-section: example-7 -->

### Esempio

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated thread title", "description":"updated context", "description_format":"md"}' https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: soft-delete-discussion -->

## Elimina una discussione senza cancellarne il record

Elimina una discussione come utente titolare della chiave API. La discussione viene rimossa, ma il suo record viene conservato.

`DELETE /api/b2/discussions/:id`

<!-- translation-section: example-8 -->

### Esempio

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: create-comment -->

## Crea un commento

Crea un commento in una discussione come utente titolare della chiave API.

`POST /api/b2/comments`

<!-- translation-section: params-7 -->

### Parametri

| Nome | Descrizione |
| --- | --- |
| `discussion_id` | Numero intero, obbligatorio. ID della discussione da commentare |
| `body` | Testo del commento, obbligatorio se non viene fornito un allegato |
| `body_format` | `md` o `html`, facoltativo, valore predefinito `md` |

<!-- translation-section: example-9 -->

### Esempio

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"discussion_id": 123, "body":"example comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments
```

<!-- translation-section: edit-comment -->

## Modifica un commento

Modifica un commento come utente titolare della chiave API. Si applicano gli stessi permessi di Loomio: l'utente deve essere autorizzato a modificare quel commento.

`PATCH /api/b2/comments/:id`

<!-- translation-section: params-8 -->

### Parametri

| Nome | Descrizione |
| --- | --- |
| `body` | Testo aggiornato del commento |
| `body_format` | `md` o `html`, facoltativo, valore predefinito `md` |

<!-- translation-section: example-10 -->

### Esempio

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"body":"updated comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments/123
```

<!-- translation-section: soft-delete-comment -->

## Elimina un commento senza cancellarne il record

Elimina un commento come utente titolare della chiave API. Il commento viene rimosso e il suo testo viene nascosto, ma il suo record viene conservato.

`DELETE /api/b2/comments/:id`

<!-- translation-section: example-11 -->

### Esempio

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/comments/123
```

<!-- translation-section: create-poll -->

## Crea un sondaggio

Crea un sondaggio come utente titolare della chiave API.

`POST /api/b2/polls`

<!-- translation-section: params-9 -->

### Parametri

| Nome | Descrizione |
| --- | --- |
| `group_id` | Intero, facoltativo, valore predefinito null. ID del gruppo del sondaggio. Se viene passato `discussion_id`, `group_id` viene ignorato |
| `discussion_id` | Intero, facoltativo, valore predefinito null. ID della conversazione della discussione a cui aggiungere questo sondaggio |
| `title` | Stringa, obbligatoria. Titolo del sondaggio |
| `poll_type` | Stringa, obbligatoria. Valori: `proposal`, `poll`, `count`, `score`, `ranked_choice`, `meeting`, `dot_vote` |
| `details` | Stringa, facoltativa. Testo del sondaggio |
| `details_format` | Stringa, facoltativa, valore predefinito `md`. Valori: `md` o `html` |
| `options` | Array di stringhe. Se `poll_type` è `proposal`, i valori validi sono `agree`, `disagree`, `abstain`, `block`. Se `poll_type` è `meeting`, fornisci stringhe di data o data e ora in formato ISO 8601. Per tutti gli altri tipi di sondaggio, qualsiasi stringa è valida |
| `closing_at` | Stringa ISO 8601 o null, valore predefinito null. Esempio: `2026-09-01T12:00:00Z`. Se null, il voto è disabilitato e il sondaggio è considerato in preparazione |
| `specified_voters_only` | Booleano, facoltativo, valore predefinito false. Se true, solo le persone specificate possono votare. Se false, tutte le persone del gruppo saranno invitate a votare |
| `hide_results` | Stringa, facoltativa, valore predefinito `off`. Valori: `off`, `until_vote`, `until_closed` |
| `shuffle_options` | Booleano, valore predefinito false. Mostra le opzioni agli elettori in ordine casuale |
| `anonymous` | Booleano, facoltativo, valore predefinito false. Nasconde le identità degli elettori |
| `recipient_audience` | `group` o null, facoltativo, valore predefinito null. Se `group`, tutto il gruppo riceverà una notifica |
| `notify_on_closing_soon` | Stringa, facoltativa, valore predefinito `nobody`. Valori: `nobody`, `author`, `undecided_voters`, `voters` |
| `recipient_user_ids` | Array di ID degli utenti a cui inviare una notifica o un invito |
| `recipient_emails` | Array di indirizzi email delle persone da invitare a votare |
| `recipient_message` | Messaggio da includere nell'invito via email |
| `notify_recipients` | Booleano, valore predefinito false. Se false, aggiunge le persone senza inviare notifiche. Se true, tutte le persone invitate con questa richiesta riceveranno una notifica via email |

<!-- translation-section: example-12 -->

### Esempio

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example poll", "poll_type": "proposal", "options": ["agree", "disagree"], "closing_at": "2026-09-01T12:00:00Z", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/polls
```

<!-- translation-section: show-poll -->

## Mostra un sondaggio

Recupera un sondaggio usando il suo ID, un intero, oppure la sua chiave, una stringa.

`GET /api/b2/polls/:id`

<!-- translation-section: example-13 -->

### Esempio

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/polls/abc123
```

<!-- translation-section: list-polls -->

## Elenca i sondaggi

Elenca i sondaggi di un gruppo visibili all'utente della chiave API. Se il gruppo è visibile pubblicamente, anche chi non è membro può elencarne i sondaggi pubblici; i sondaggi privati restano accessibili solo agli utenti che possono leggerli in Loomio. La risposta include la conclusione attuale di ogni sondaggio visibile, quindi puoi usare `status=closed` per elencare le proposte su cui è stata presa una decisione.

`GET /api/b2/polls`

<!-- translation-section: params-10 -->

### Parametri

| Nome | Descrizione |
| --- | --- |
| `group_id` | Intero, obbligatorio. ID del gruppo di cui elencare i sondaggi |
| `status` | Stringa, facoltativa, valore predefinito `active`. Valori: `active`, `closed`, `all` |
| `limit` | Intero, facoltativo, valore predefinito 50. Dimensione della pagina |
| `offset` | Intero, facoltativo, valore predefinito 0. Scostamento per la paginazione |

Compatibilità con le versioni precedenti: `per` e `from` sono accettati come alias di `limit` e `offset` e continueranno a funzionare.

<!-- translation-section: example-14 -->

### Esempio

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/polls?group_id=123'
```

<!-- translation-section: edit-poll -->

## Modifica un sondaggio

Modifica un sondaggio come utente della chiave API. Si applicano gli stessi permessi di Loomio: l'utente deve essere autorizzato a modificare quel sondaggio.

`PATCH /api/b2/polls/:id`

<!-- translation-section: params-11 -->

### Parametri

| Nome | Descrizione |
| --- | --- |
| `title` | Titolo aggiornato |
| `details` | Dettagli aggiornati del sondaggio |
| `details_format` | `md` o `html`, facoltativo, valore predefinito `md` |
| `options` | Nomi aggiornati delle opzioni. La modifica delle opzioni può influire sui voti esistenti a seconda dello stato del sondaggio |
| `closing_at` | Stringa ISO 8601 o null |
| `recipient_audience` | `group` o null. Se `group`, tutto il gruppo riceverà una notifica |
| `recipient_user_ids` | Array di ID degli utenti a cui inviare una notifica o un invito |
| `recipient_emails` | Array di indirizzi email delle persone da invitare a votare |
| `recipient_message` | Messaggio da includere nell'invito via email |

<!-- translation-section: example-15 -->

### Esempio

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated poll title", "details":"updated details", "details_format":"md"}' https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: soft-delete-poll -->

## Elimina logicamente un sondaggio

Elimina logicamente un sondaggio come utente della chiave API. Questa operazione rimuove il sondaggio mantenendo il suo record nel database.

`DELETE /api/b2/polls/:id`

<!-- translation-section: example-16 -->

### Esempio

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: list-memberships -->

## Elenca le iscrizioni

Elenca le iscrizioni visibili all'utente della chiave API. I membri del gruppo possono leggere nomi, ID, titoli e ruoli dei membri. Gli indirizzi email sono inclusi solo per l'account dell'utente della chiave API o quando questo utente è un amministratore del gruppo.

`GET /api/b2/memberships`

<!-- translation-section: params-12 -->

### Parametri

| Nome | Descrizione |
| --- | --- |
| `group_id` | Numero intero, obbligatorio. ID del gruppo di cui elencare le iscrizioni |

<!-- translation-section: example-17 -->

### Esempio

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/memberships?group_id=123'
```

<!-- translation-section: manage-memberships -->

## Gestisci le iscrizioni

Invia un elenco di indirizzi email. Verrà inviato un invito al gruppo a tutti i nuovi indirizzi email. A differenza dell'elenco delle iscrizioni, questa operazione richiede i permessi di amministratore del gruppo.

`POST /api/b2/memberships`

<!-- translation-section: params-13 -->

### Parametri

| Nome | Descrizione |
| --- | --- |
| `group_id` | Numero intero, obbligatorio. ID del gruppo di cui gestire le iscrizioni |
| `emails` | Array di stringhe, obbligatorio. Indirizzi email delle persone da invitare nel gruppo |
| `remove_absent` | Booleano. Se true, rimuove dal gruppo chiunque abbia un indirizzo email non presente nell'elenco |

<!-- translation-section: example-18 -->

### Esempio

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"]}' https://www.loomio.com/api/b2/memberships
```

Se passi `remove_absent=1`, tutti i membri del gruppo non inclusi nell'elenco verranno rimossi dal gruppo. Fai attenzione: potresti rimuovere tutti i membri del tuo gruppo.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"], "remove_absent": 1}' https://www.loomio.com/api/b2/memberships
```

La risposta restituisce un oggetto con `{added_emails: ["person@added.com"], removed_emails: ["person@removed.com"]}`.
