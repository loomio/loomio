---
title: API utente
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/integrations/api/user-api.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-30'
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
  introduction: 24e237d80342efe4
  authentication-change: 7e136a5dd8cd9695
  response-size-and-related-records: 65e1eccafaaf3f26
  endpoint-summary: c3856d95ff6f65ff
  groups: 42011ba3c7a9e4fd
  list-groups: 809f400313251b01
  get-a-group: 0fc388a2d3575b73
  webhooks: 33dc1907e312f7e1
  list-webhooks: 85ac3dc5de84850c
  create-a-webhook: 11a9f3b49de06b5e
  update-a-webhook: 9f8786eb34de80eb
  test-a-webhook-destination: 6b0ff34306591abb
  delete-a-webhook: feffd5132f1d89b3
  event-types: d4114cc4ff6ec086
  http-delivery: 19ed8d415cd8bc62
  payload-formats: efc40ffaf701c455
  search: c01e2c8d63f3c7f9
  params: f816b1a6024bb91b
  participation-report: aca8daac6b125888
  params-2: 2bacccf0fbb9dfbc
  example: 3492f806d7e32618
  create-discussion: 9a4844fd3363f401
  params-3: 176a15b0d4eed9d4
  example-2: 31210b378082b54f
  show-discussion: 98603e07684a93a0
  example-3: 24844d6efe2025bf
  list-discussions: e5b787f6f3954666
  params-4: 259edf432b55d110
  example-4: 68cc95e0d84d0449
  list-threads: e1e8e52a22cd9026
  params-5: 6b91d7a39545c50c
  example-5: aaada67349ae9821
  read-thread: d4ad64929cdddbbc
  example-6: 196777a1f36b94b5
  edit-discussion: 0bcdfabae278ab41
  params-6: 79162055257a85a8
  example-7: f5e59e4dfc6d485d
  soft-delete-discussion: 319c0c9a8be65fd7
  example-8: 2b73fc94de6b63d1
  create-comment: 9ebd2ff69b19f20a
  params-7: eb923375eaa541cd
  example-9: d4759f76bbd035f1
  edit-comment: 43a823c39b026091
  params-8: 1f09d9b7aab0eba9
  example-10: 209381bd47b3e380
  soft-delete-comment: 97736d5caf6347db
  example-11: f6df5bd89872e531
  create-poll: d4750e3629e66744
  params-9: f158fcfb9bab04b9
  example-12: 9cb3b7724fdd8eb0
  show-poll: 7a1d1df562da7eca
  example-13: f08d34bfaa3ea688
  list-polls: 4fafca040e47794c
  params-10: d517f726ce039625
  example-14: e7924e10d172b242
  edit-poll: a9cebdae4d9ae211
  params-11: 60dc01edcbbc4485
  example-15: 156d9c3b92f7a1fb
  soft-delete-poll: 43ee4ed83655c024
  example-16: 68b7f1079a5b149a
  list-memberships: 8b0a72ae3d4825c5
  params-12: f4b2bda5c44e1d5c
  example-17: c076310bc023c187
  manage-memberships: 959cc0d6478e18c3
  params-13: 640bb82434317855
  example-18: 697b34854c9361a4
title_source: c23fb6526b722360
title_generated: 431e416c4c7bba9a
---

<!-- translation-section: introduction -->

# Documentazione dell'API utente di Loomio

<!-- seo-description: Usa l'API utente di Loomio per creare e gestire discussioni, commenti, sondaggi, thread e partecipazioni ai gruppi da altri software. -->

`/api/b2` è l'API utente per le integrazioni con Loomio. Usa la chiave API di un account utente ed esegue ogni azione a nome di quell'utente.

Le operazioni sui gruppi rispettano le partecipazioni e i permessi dell'utente a cui appartiene la chiave API. Il ruolo di amministratore dell'istanza non amplia l'accesso della chiave API ai gruppi o ai contenuti; per amministrare l'istanza, usa la Server API.

Usa la chiave API dell'account Loomio che eseguirà le azioni. Un account bot dedicato è utile se l'integrazione non deve ricevere inviti ai sondaggi o notifiche.

Se hai effettuato l'accesso, trovi la tua chiave API e gli ID dei gruppi nella [pagina di accesso API](/profile/api_access).

Invia la chiave API nell'intestazione `Authorization: Bearer`. Le chiavi API nelle stringhe di query vengono rifiutate perché gli URL possono essere registrati dai proxy e nei log di accesso.

<!-- translation-section: authentication-change -->

### Modifica dell'autenticazione

In precedenza, la chiave API poteva essere passata come parametro URL `api_key`. Le richieste che usano `?api_key=YOUR_API_KEY` non funzionano più. Usa invece l'intestazione HTTP `Authorization`:

```text
Authorization: Bearer YOUR_API_KEY
```

Gli esempi usano `YOUR_API_KEY`, l'ID di gruppo `123` e `https://www.loomio.com/`. Sostituiscili con la tua chiave API, l'ID del gruppo e l'URL della tua installazione di Loomio.

<!-- translation-section: response-size-and-related-records -->

## Dimensioni delle risposte e record correlati

Le risposte dell'API utente hanno un formato composito: i record principali sono accompagnati da record correlati, come topic, gruppi, utenti, sondaggi e reazioni. Questo consente a un client di popolare un archivio locale con una sola richiesta, ma può includere più dati di quanti ne servano a una semplice integrazione.

Passa `compact=1` per omettere i record correlati più voluminosi: topic, gruppi, gruppi principali, partecipazioni, reazioni, tag e traduzioni. I record principali e quelli correlati necessari per interpretarne il contenuto restano presenti.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads/123/items?compact=1'
```

Per controllare direttamente le esclusioni, passa `exclude_types` con i tipi di record al singolare separati da spazi. Per esempio, `exclude_types=group reaction` omette i gruppi e le reazioni correlati. I valori comuni sono `topic`, `group`, `parent`, `membership`, `reaction`, `tag`, `translation`, `user`, `discussion`, `poll`, `poll_option`, `stance`, `stance_choice`, `outcome` e `topic_item`. Le esclusioni si applicano ai record correlati, non alla risorsa principale richiesta dall'endpoint.

Le risposte che contengono raccolte includono `meta.total` quando è definita la dimensione esatta della raccolta. Il totale viene calcolato prima di applicare `limit` e `offset`. Gli endpoint come la ricerca, che restituiscono intenzionalmente un insieme limitato di risultati, omettono `meta.total` invece di restituire `null`.

<!-- translation-section: endpoint-summary -->

## Riepilogo degli endpoint

| Metodo | Endpoint | Scopo |
| --- | --- | --- |
| `GET` | `/api/b2/groups` | Elenca i gruppi dell'utente a cui appartiene la chiave API |
| `GET` | `/api/b2/groups/:id_or_key_or_handle` | Recupera un gruppo visibile |
| `GET` | `/api/b2/reports` | Genera un rapporto sulla partecipazione |
| `GET` | `/api/b2/search` | Cerca discussioni, commenti, sondaggi, voti e conclusioni visibili |
| `POST` | `/api/b2/discussions` | Crea una discussione |
| `GET` | `/api/b2/discussions/:id` | Recupera una discussione |
| `GET` | `/api/b2/discussions` | Elenca le discussioni di un gruppo |
| `PATCH` | `/api/b2/discussions/:id` | Modifica una discussione |
| `DELETE` | `/api/b2/discussions/:id` | Elimina una discussione senza rimuoverne il record |
| `GET` | `/api/b2/threads` | Elenca i thread visibili delle discussioni e dei sondaggi autonomi |
| `GET` | `/api/b2/threads/:topic_id` | Recupera un thread |
| `GET` | `/api/b2/threads/:topic_id/items` | Recupera gli elementi ordinati di un thread |
| `GET` | `/api/b2/threads/:topic_id/markdown` | Recupera un thread completo in formato Markdown |
| `POST` | `/api/b2/comments` | Crea un commento o una risposta |
| `PATCH` | `/api/b2/comments/:id` | Modifica un commento |
| `DELETE` | `/api/b2/comments/:id` | Elimina un commento senza rimuoverne il record |
| `POST` | `/api/b2/polls` | Crea un sondaggio |
| `GET` | `/api/b2/polls/:id` | Recupera un sondaggio |
| `GET` | `/api/b2/polls` | Elenca i sondaggi di un gruppo |
| `PATCH` | `/api/b2/polls/:id` | Modifica un sondaggio |
| `DELETE` | `/api/b2/polls/:id` | Elimina un sondaggio senza rimuoverne il record |
| `GET` | `/api/b2/memberships` | Elenca le partecipazioni a un gruppo |
| `POST` | `/api/b2/memberships` | Aggiunge membri e, facoltativamente, rimuove quelli assenti dall'elenco |
| `GET` | `/api/b2/chatbots` | Elenca le integrazioni di chat e i webhook di un gruppo |
| `POST` | `/api/b2/chatbots` | Crea un'integrazione di chat o un webhook |
| `PATCH` | `/api/b2/chatbots/:id` | Aggiorna un'integrazione di chat o un webhook |
| `DELETE` | `/api/b2/chatbots/:id` | Elimina un'integrazione di chat o un webhook |
| `POST` | `/api/b2/chatbots/check` | Invia un test di connessione a un webhook |

<!-- translation-section: groups -->

## Gruppi

<!-- translation-section: list-groups -->

### Elencare i gruppi

Restituisce i gruppi di cui l'utente a cui appartiene la chiave API è membro attivo.

`GET /api/b2/groups`

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups
```

La risposta contiene tutti i record corrispondenti in un array `groups` senza paginazione. Include gruppi principali e sottogruppi, anche se il loro abbonamento non è attualmente attivo. Controlla il campo `enabled` se l'integrazione deve operare solo sui gruppi abilitati.

I principali campi dei gruppi sono:

| Campo | Descrizione |
| --- | --- |
| `id` | ID numerico del gruppo usato dagli altri endpoint dell'API utente |
| `key` | Chiave breve e stabile usata negli URL di Loomio |
| `handle` | Identificativo leggibile del gruppo |
| `name` | Nome del gruppo |
| `full_name` | Nome del gruppo con il contesto del gruppo principale |
| `parent_id` | ID numerico del gruppo principale per un sottogruppo, altrimenti `null` |
| `enabled` | Indica se il gruppo e il suo abbonamento sono attivi |
| `memberships_count` | Numero di partecipazioni attive e in attesa |
| `accepted_memberships_count` | Numero di partecipazioni accettate |
| `pending_memberships_count` | Numero di inviti in attesa |
| `admin_memberships_count` | Numero di amministratori del gruppo |
| `delegates_count` | Numero di delegati |
| `discussions_count` | Numero di discussioni presenti direttamente nel gruppo |
| `polls_count` | Numero di sondaggi presenti direttamente nel gruppo |
| `subgroups_count` | Numero di sottogruppi |

La risposta può includere altre impostazioni del gruppo, i record correlati del gruppo principale e le partecipazioni dell'utente API. I client dovrebbero ignorare i campi che non usano.

<!-- translation-section: get-a-group -->

### Recuperare un gruppo

Restituisce un gruppo visibile all'utente a cui appartiene la chiave API.

`GET /api/b2/groups/:id_or_key_or_handle`

Puoi identificare il gruppo tramite il suo ID numerico, la chiave o l'identificativo.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/123
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/groups/example-group
```

La risposta contiene il gruppo nell'array `groups` e usa gli stessi campi dell'endpoint che elenca i gruppi. Una richiesta per un gruppo a cui l'utente a cui appartiene la chiave API non può accedere restituisce un errore di autorizzazione.

<!-- translation-section: webhooks -->

## Webhook

L'API utente funziona tramite richieste: un'integrazione chiama Loomio quando vuole leggere o modificare dati. Un webhook di gruppo consente il flusso nella direzione opposta. Loomio invia al tuo endpoint gli eventi del gruppo selezionati quando si verificano, quindi l'integrazione non deve interrogare periodicamente l'API REST per rilevare le modifiche.

I webhook si configurano per singolo gruppo e richiedono i permessi di amministratore del gruppo. Puoi gestirli dall'interfaccia di Loomio:

1. Apri il gruppo.
2. Apri il menu del gruppo e seleziona **Integrazioni di chat**.
3. Aggiungi l'integrazione con il formato del payload accettato dal tuo endpoint. Per un endpoint generico, usa il formato Mattermost/Markdown.
4. Inserisci un nome e l'URL di destinazione.
5. Seleziona gli eventi che Loomio deve inviare automaticamente.
6. Salva l'integrazione e usa **Test connection** per inviare un messaggio di prova.

Usa una destinazione HTTPS con un URL difficile da indovinare. Loomio richiede che la destinazione corrisponda a un indirizzo pubblico e blocca le richieste verso indirizzi di reti locali o private.

Gli agenti e le altre integrazioni possono gestire i webhook tramite gli endpoint chatbot descritti sotto, autenticati con Bearer. La risorsa si chiama `chatbots` per compatibilità con le integrazioni di chat di Loomio, ma rappresenta anche webhook in uscita generici.

<!-- translation-section: list-webhooks -->

### Elencare i webhook

Restituisce le integrazioni di chat configurate per un gruppo. L'utente a cui appartiene la chiave API deve essere amministratore di quel gruppo. La risposta include gli URL di destinazione, quindi non deve essere resa accessibile ai normali membri del gruppo.

`GET /api/b2/chatbots?group_id=123`

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/chatbots?group_id=123'
```

La risposta contiene un array `chatbots` con questi campi:

| Campo | Descrizione |
| --- | --- |
| `id` | ID dell'integrazione usato per aggiornarla ed eliminarla |
| `group_id` | Gruppo che riceve gli eventi |
| `name` | Nome amministrativo dell'integrazione |
| `kind` | `webhook` per un webhook in uscita o `matrix` per un'integrazione Matrix |
| `webhook_kind` | Formato del payload: `markdown`, `slack`, `discord`, `microsoft` o `webex` |
| `server` | URL di destinazione |
| `event_kinds` | Eventi inviati automaticamente |
| `notification_only` | Indica se i messaggi contengono solo il titolo della notifica |

<!-- translation-section: create-a-webhook -->

### Creare un webhook

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

L'utente a cui appartiene la chiave API deve essere amministratore di `group_id`. Prima del salvataggio, Loomio verifica che la destinazione sia un URL pubblico.

<!-- translation-section: update-a-webhook -->

### Aggiornare un webhook

`PATCH /api/b2/chatbots/:id`

Invia i campi da modificare. Non puoi trasferire il webhook a un altro gruppo modificando `group_id`.

```bash
curl -X PATCH \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"name":"Planning events","event_kinds":["new_discussion","outcome_created"]}' \
  https://www.loomio.com/api/b2/chatbots/456
```

<!-- translation-section: test-a-webhook-destination -->

### Verificare la destinazione di un webhook

Invia un messaggio di prova compatibile con Markdown alla destinazione, prima o dopo averne salvato la configurazione.

`POST /api/b2/chatbots/check`

```bash
curl -X POST \
  -H 'Authorization: Bearer YOUR_API_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"group_id":123,"server":"https://hooks.example.org/loomio/unguessable-token"}' \
  https://www.loomio.com/api/b2/chatbots/check
```

<!-- translation-section: delete-a-webhook -->

### Eliminare un webhook

`DELETE /api/b2/chatbots/:id`

```bash
curl -X DELETE -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/chatbots/456
```

Eliminando la configurazione interrompi gli invii futuri. I contenuti del gruppo Loomio restano disponibili.

<!-- translation-section: event-types -->

### Tipi di evento

Un webhook può ricevere questi tipi di evento:

| Evento | Quando viene inviato |
| --- | --- |
| `new_discussion` | Viene avviata una discussione |
| `discussion_edited` | Viene modificata una discussione |
| `new_comment` | Viene creato un commento |
| `poll_created` | Viene avviato un sondaggio |
| `poll_edited` | Viene modificato un sondaggio |
| `poll_closing_soon` | Si avvicina la scadenza di un sondaggio |
| `poll_expired` | Un sondaggio raggiunge la scadenza |
| `poll_closed_by_user` | Una persona chiude manualmente un sondaggio |
| `poll_reopened` | Viene riaperto un sondaggio |
| `outcome_created` | Viene pubblicata una conclusione |
| `outcome_updated` | Viene aggiornata una conclusione |
| `outcome_review_due` | Arriva la scadenza per la revisione di una conclusione |
| `stance_created` | Viene espresso un voto |
| `stance_updated` | Viene modificato un voto |

Il webhook appartiene a un solo gruppo e riceve da quel gruppo gli eventi a cui è iscritto. Le persone possono anche selezionare esplicitamente l'integrazione quando condividono contenuti o inviano alcune notifiche, anche se l'evento automatico corrispondente non è selezionato.

<!-- translation-section: http-delivery -->

### Invio HTTP

Loomio invia una richiesta HTTP `POST` asincrona all'URL configurato con questa intestazione:

```text
Content-Type: application/json; charset=utf-8
```

Il timeout della richiesta è di cinque secondi. Una risposta `2xx`, incluso `204 No Content`, è considerata riuscita. Il servizio che riceve il webhook dovrebbe rispondere rapidamente, elaborare in modo asincrono le operazioni più lunghe e gestire invii duplicati o fuori ordine.

Attualmente Loomio non aggiunge una firma del webhook, un'intestazione con un segreto condiviso, un ID evento o un ID invio. Tratta l'URL completo di destinazione come una credenziale: non renderlo pubblico e includi nell'URL un token difficile da indovinare se il servizio ricevente lo supporta. Se ti serve uno schema degli eventi stabile e leggibile da software o un invio firmato, usa il webhook come notifica delle modifiche e recupera i dati aggiornati tramite l'API utente autenticata.

<!-- translation-section: payload-formats -->

### Formati dei payload

I payload dei webhook sono messaggi pensati per essere mostrati nei servizi di chat. Non contengono tutti i dati dei record Loomio. I link nel messaggio identificano i contenuti Loomio interessati; un'integrazione può usare l'API utente per ottenere i dati strutturati aggiornati.

| Formato dell'integrazione | Campi JSON principali |
| --- | --- |
| Mattermost/Markdown | `text`, `icon_url`, `username` |
| Slack | `text` |
| Discord | `content`, limitato a circa 1.900 caratteri |
| Microsoft Teams | `@type`, `@context`, `themeColor`, `text`, `sections` |
| Webex | `markdown` |

Per esempio, il formato Markdown generico invia un corpo di questo tipo:

```json
{
  "text": "Ada started a discussion: [Quarterly planning](https://example.loomio.org/d/example)",
  "icon_url": "https://example.loomio.org/path/to/group-logo.png",
  "username": "Loomio"
}
```

Il testo esatto del messaggio dipende dall'evento, dalla lingua del gruppo, dall'impostazione che limita il messaggio alla notifica e dalla versione di Loomio. I servizi riceventi dovrebbero usare i campi principali documentati per il formato selezionato, senza interpretare il testo delle frasi.

<!-- translation-section: search -->

## Ricerca

Cerca discussioni, commenti, sondaggi, voti e conclusioni visibili all'utente a cui appartiene la chiave API. I risultati includono contenuti pubblici anche se l'utente non è membro del gruppo; i contenuti privati seguono le normali regole di visibilità dell'argomento.

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
| `tag` | Limita i risultati agli argomenti con questa etichetta |
| `author_id` | Limita i risultati ai contenuti di un autore. Senza `query`, restituisce le attività recenti e visibili di quell'autore |
| `order` | Imposta `authored_at_desc` per ordinare i contenuti corrispondenti in base alla data di creazione |

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/search?query=quarterly+planning&type=Discussion'
```

La risposta contiene un array `search_results`. Ogni risultato identifica il record trovato e il suo contesto visibile tramite campi tra cui `searchable_type`, `searchable_id`, `highlight`, `group_id`, `group_name`, `discussion_key`, `poll_key`, `author_id`, `author_name`, `authored_at` e `tags`. I campi non pertinenti a un risultato hanno valore `null`.

<!-- translation-section: participation-report -->

## Report sulla partecipazione

Restituisce gli stessi dati aggregati usati nel report sulla partecipazione di Loomio.

`GET /api/b2/reports`

<!-- translation-section: params-2 -->

### Parametri

| Nome | Descrizione |
| --- | --- |
| `section` | Sezione del report: `base`, `users` o `countries`. Usa `users` per le attività delle singole persone |
| `group_scope` | `custom` o `my`. Il valore precedente `all` è trattato come `my` perché le chiavi dell'API utente non danno accesso all'intera istanza |
| `group_ids` | ID dei gruppi separati da virgole quando `group_scope=custom`. Gli ID dei gruppi di cui l'utente API non è membro vengono ignorati |
| `start_month` | Primo mese da includere nel formato `YYYY-MM`; per impostazione predefinita è il mese di 12 mesi fa |
| `end_month` | Ultimo mese da includere nel formato `YYYY-MM`; per impostazione predefinita è il mese corrente |
| `interval` | Intervallo per la sezione `base`: `day`, `week`, `month` o `year` |
| `member_type` | Imposta `delegate` con `section=users` per restituire solo i delegati attuali |

Una persona è delegata se ha un'adesione attiva come delegata in almeno uno dei gruppi selezionati. I suoi conteggi sono aggregati per tutti i gruppi selezionati. Le righe dei delegati vengono restituite anche quando tutti i conteggi delle attività sono pari a zero. I conteggi riguardano discussioni, commenti, sondaggi, voti, conclusioni e reazioni; non sono tassi di partecipazione al voto. Le righe degli utenti includono anche il numero di schede di voto nominative assegnate, compilate e non compilate. I sondaggi anonimi sono esclusi da tutti i conteggi dei voti per persona. `all_votes_cast` è true solo se è stata assegnata almeno una scheda di voto e tutte le schede assegnate sono state compilate.

L'API applica le stesse regole di visibilità dei gruppi del report in Loomio. La chiave API di un utente non può esporre i dati dei report relativi a gruppi a cui quell'utente non ha accesso.

<!-- translation-section: example -->

### Esempio

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/reports?section=users&group_scope=custom&group_ids=123&member_type=delegate&start_month=2026-01&end_month=2026-09'
```

L'array `users` contiene righe con tutti i dati delle attività:

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

## Creare una discussione

Crea una discussione usando l'account associato alla chiave API.

`POST /api/b2/discussions`

<!-- translation-section: params-3 -->

### Parametri

| Nome | Descrizione |
| --- | --- |
| `group_id` | Gruppo in cui verrà creata la discussione |
| `title` | Titolo della discussione, obbligatorio |
| `description` | Contesto della discussione, facoltativo |
| `description_format` | `md` o `html`, facoltativo; valore predefinito: `md` |
| `recipient_audience` | `group` o null. Se è `group`, l'intero gruppo riceverà una notifica della nuova discussione |
| `recipient_user_ids` | Elenco di ID utente delle persone a cui inviare una notifica o un invito alla discussione |
| `recipient_emails` | Elenco di indirizzi email delle persone da invitare alla discussione |
| `recipient_message` | Messaggio da includere nell'invito via email |

<!-- translation-section: example-2 -->

### Esempio

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example thread", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/discussions
```

<!-- translation-section: show-discussion -->

## Visualizzare una discussione

Recupera una discussione tramite il suo ID numerico o la sua chiave testuale.

`GET /api/b2/discussions/:id`

<!-- translation-section: example-3 -->

### Esempio

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/discussions/abc123
```

<!-- translation-section: list-discussions -->

## Elencare le discussioni

Elenca le discussioni di un gruppo visibili all'utente associato alla chiave API. Se il gruppo è visibile pubblicamente, anche chi non ne fa parte può elencare le sue discussioni pubbliche. Le discussioni private restano accessibili solo agli utenti che possono leggerle in Loomio.

`GET /api/b2/discussions`

<!-- translation-section: params-4 -->

### Parametri

| Nome | Descrizione |
| --- | --- |
| `group_id` | Numero intero, obbligatorio. ID del gruppo di cui elencare le discussioni |
| `status` | Stringa, facoltativa; valore predefinito: `open`. Valori: `open`, `closed`, `all` |
| `limit` | Numero intero, facoltativo; valore predefinito: 50. Dimensione della pagina |
| `offset` | Numero intero, facoltativo; valore predefinito: 0. Posizione iniziale per la paginazione |

Per compatibilità, `per` e `from` sono accettati come alias di `limit` e `offset` e continueranno a funzionare.

<!-- translation-section: example-4 -->

### Esempio

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/discussions?group_id=123'
```

<!-- translation-section: list-threads -->

## Elencare i thread

Elenca i thread delle discussioni e dei sondaggi visibili all'utente associato alla chiave API, ordinati per attività più recente. L'ID di un thread è il suo `topic_id`.

`GET /api/b2/threads`

<!-- translation-section: params-5 -->

### Parametri

| Nome | Descrizione |
| --- | --- |
| `limit` | Numero intero, facoltativo; valore predefinito: 50. Dimensione della pagina |
| `offset` | Numero intero, facoltativo; valore predefinito: 0. Posizione iniziale per la paginazione |

<!-- translation-section: example-5 -->

### Esempio

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/threads?limit=50&offset=0'
```

<!-- translation-section: read-thread -->

## Leggere un thread

Leggi un thread, la sua sequenza ordinata di eventi o il documento Markdown completo dei contenuti visibili.

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

L'endpoint `items` restituisce la sequenza ordinata degli eventi, inclusi commenti, sondaggi, voti e conclusioni visibili. L'endpoint `markdown` restituisce l'intero thread visibile come un unico documento Markdown. Le motivazioni dei voti sono incluse solo se sono visibili all'utente associato alla chiave API.

Tutti gli endpoint dei thread applicano gli stessi permessi dell'interfaccia di Loomio. La chiave API non consente di accedere a un thread che l'utente normalmente non può aprire.

<!-- translation-section: edit-discussion -->

## Modificare una discussione

Modifica una discussione usando l'account associato alla chiave API. Si applicano gli stessi permessi di Loomio: l'utente deve essere autorizzato a modificare la discussione.

`PATCH /api/b2/discussions/:id`

<!-- translation-section: params-6 -->

### Parametri

| Nome | Descrizione |
| --- | --- |
| `title` | Titolo aggiornato |
| `description` | Contesto aggiornato |
| `description_format` | `md` o `html`, facoltativo; valore predefinito: `md` |
| `recipient_audience` | `group` o null. Se è `group`, l'intero gruppo riceverà una notifica della modifica |
| `recipient_user_ids` | Elenco di ID utente delle persone a cui inviare una notifica o un invito alla discussione |
| `recipient_emails` | Elenco di indirizzi email delle persone da invitare alla discussione |
| `recipient_message` | Messaggio da includere nell'invito via email |

<!-- translation-section: example-7 -->

### Esempio

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated thread title", "description":"updated context", "description_format":"md"}' https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: soft-delete-discussion -->

## Eliminare una discussione senza rimuoverne il record

Elimina una discussione usando l'account associato alla chiave API. La discussione viene scartata, ma il suo record viene conservato.

`DELETE /api/b2/discussions/:id`

<!-- translation-section: example-8 -->

### Esempio

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/discussions/123
```

<!-- translation-section: create-comment -->

## Creare un commento

Crea un commento in una discussione usando l'account associato alla chiave API.

`POST /api/b2/comments`

<!-- translation-section: params-7 -->

### Parametri

| Nome | Descrizione |
| --- | --- |
| `discussion_id` | Numero intero, obbligatorio. ID della discussione da commentare |
| `body` | Testo del commento, obbligatorio se non viene fornito un allegato |
| `body_format` | `md` o `html`, facoltativo; valore predefinito: `md` |

<!-- translation-section: example-9 -->

### Esempio

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"discussion_id": 123, "body":"example comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments
```

<!-- translation-section: edit-comment -->

## Modificare un commento

Modifica un commento usando l'account associato alla chiave API. Si applicano gli stessi permessi di Loomio: l'utente deve essere autorizzato a modificare il commento.

`PATCH /api/b2/comments/:id`

<!-- translation-section: params-8 -->

### Parametri

| Nome | Descrizione |
| --- | --- |
| `body` | Testo aggiornato del commento |
| `body_format` | `md` o `html`, facoltativo; valore predefinito: `md` |

<!-- translation-section: example-10 -->

### Esempio

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"body":"updated comment", "body_format":"md"}' https://www.loomio.com/api/b2/comments/123
```

<!-- translation-section: soft-delete-comment -->

## Eliminare un commento senza rimuoverne il record

Elimina un commento usando l'account associato alla chiave API. Il commento viene scartato e il suo testo nascosto, ma il record viene conservato.

`DELETE /api/b2/comments/:id`

<!-- translation-section: example-11 -->

### Esempio

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/comments/123
```

<!-- translation-section: create-poll -->

## Crea un sondaggio

Crea un sondaggio usando l'account associato alla chiave API.

`POST /api/b2/polls`

<!-- translation-section: params-9 -->

### Parametri

| Nome | Descrizione |
| --- | --- |
| `group_id` | Numero intero, facoltativo, valore predefinito null. ID del gruppo del sondaggio. Se viene passato `discussion_id`, `group_id` viene ignorato |
| `discussion_id` | Numero intero, facoltativo, valore predefinito null. ID della discussione a cui aggiungere il sondaggio |
| `title` | Stringa obbligatoria. Titolo del sondaggio |
| `poll_type` | Stringa obbligatoria. Valori: `proposal`, `poll`, `count`, `score`, `ranked_choice`, `meeting`, `dot_vote` |
| `details` | Stringa facoltativa. Testo del sondaggio |
| `details_format` | Stringa facoltativa, valore predefinito `md`. Valori: `md` o `html` |
| `options` | Array di stringhe. Se `poll_type` è `proposal`, i valori validi sono `agree`, `disagree`, `abstain`, `block`. Se `poll_type` è `meeting`, fornisci date o date e ore nel formato ISO 8601. Per gli altri tipi di sondaggio, è valida qualsiasi stringa |
| `closing_at` | Stringa ISO 8601 o null, valore predefinito null. Esempio: `2026-09-01T12:00:00Z`. Se il valore è null, non si può votare e il sondaggio è considerato in preparazione |
| `specified_voters_only` | Valore booleano facoltativo, predefinito false. Se true, possono votare solo le persone indicate. Se false, tutte le persone del gruppo saranno invitate a votare |
| `hide_results` | Stringa facoltativa, valore predefinito `off`. Valori: `off`, `until_vote`, `until_closed` |
| `shuffle_options` | Valore booleano, predefinito false. Mostra le opzioni ai votanti in ordine casuale |
| `anonymous` | Valore booleano facoltativo, predefinito false. Nasconde l'identità dei votanti |
| `recipient_audience` | `group` o null, facoltativo, valore predefinito null. Se `group`, tutto il gruppo riceverà una notifica |
| `notify_on_closing_soon` | Stringa facoltativa, valore predefinito `nobody`. Valori: `nobody`, `author`, `undecided_voters`, `voters` |
| `recipient_user_ids` | Array di ID utente delle persone da avvisare o invitare |
| `recipient_emails` | Array di indirizzi email delle persone da invitare a votare |
| `recipient_message` | Messaggio da includere nell'email di invito |
| `notify_recipients` | Valore booleano, predefinito false. Se false, aggiunge le persone senza inviare notifiche. Se true, tutte le persone invitate con questa richiesta riceveranno un'email di notifica |

<!-- translation-section: example-12 -->

### Esempio

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "title":"example poll", "poll_type": "proposal", "options": ["agree", "disagree"], "closing_at": "2026-09-01T12:00:00Z", "recipient_emails":["person@example.com"]}' https://www.loomio.com/api/b2/polls
```

<!-- translation-section: show-poll -->

## Visualizza un sondaggio

Recupera un sondaggio tramite il suo ID numerico o la sua chiave, che è una stringa.

`GET /api/b2/polls/:id`

<!-- translation-section: example-13 -->

### Esempio

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' https://www.loomio.com/api/b2/polls/abc123
```

<!-- translation-section: list-polls -->

## Elenca i sondaggi

Elenca i sondaggi di un gruppo visibili all'utente associato alla chiave API. Se il gruppo è visibile pubblicamente, anche chi non ne è membro può elencare i sondaggi pubblici. I sondaggi privati restano accessibili solo a chi può leggerli in Loomio. La risposta include la conclusione corrente di ogni sondaggio visibile: puoi quindi usare `status=closed` per elencare le proposte su cui è stata presa una decisione.

`GET /api/b2/polls`

<!-- translation-section: params-10 -->

### Parametri

| Nome | Descrizione |
| --- | --- |
| `group_id` | Numero intero, obbligatorio. ID del gruppo di cui elencare i sondaggi |
| `status` | Stringa, facoltativa, valore predefinito `active`. Valori: `active`, `closed`, `all` |
| `limit` | Numero intero, facoltativo, valore predefinito 50. Dimensione della pagina |
| `offset` | Numero intero, facoltativo, valore predefinito 0. Posizione iniziale per la paginazione |

Per compatibilità, `per` e `from` sono accettati come alias di `limit` e `offset` e continueranno a funzionare.

<!-- translation-section: example-14 -->

### Esempio

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' 'https://www.loomio.com/api/b2/polls?group_id=123'
```

<!-- translation-section: edit-poll -->

## Modifica un sondaggio

Modifica un sondaggio usando l'account associato alla chiave API. Si applicano gli stessi permessi di Loomio: devi poter modificare quel sondaggio.

`PATCH /api/b2/polls/:id`

<!-- translation-section: params-11 -->

### Parametri

| Nome | Descrizione |
| --- | --- |
| `title` | Titolo aggiornato |
| `details` | Dettagli aggiornati del sondaggio |
| `details_format` | `md` o `html`, facoltativo, valore predefinito `md` |
| `options` | Nomi aggiornati delle opzioni. La modifica delle opzioni può influire sui voti esistenti, a seconda dello stato del sondaggio |
| `closing_at` | Stringa ISO 8601 o null |
| `recipient_audience` | `group` o null. Se `group`, tutto il gruppo riceverà una notifica |
| `recipient_user_ids` | Array di ID utente delle persone da avvisare o invitare |
| `recipient_emails` | Array di indirizzi email delle persone da invitare a votare |
| `recipient_message` | Messaggio da includere nell'email di invito |

<!-- translation-section: example-15 -->

### Esempio

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X PATCH -H 'Content-Type: application/json' -d '{"title":"updated poll title", "details":"updated details", "details_format":"md"}' https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: soft-delete-poll -->

## Elimina un sondaggio senza cancellarne il record

Elimina un sondaggio usando l'account associato alla chiave API. Il sondaggio viene scartato, ma il suo record resta nel sistema.

`DELETE /api/b2/polls/:id`

<!-- translation-section: example-16 -->

### Esempio

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X DELETE https://www.loomio.com/api/b2/polls/123
```

<!-- translation-section: list-memberships -->

## Elenca le iscrizioni

Elenca le iscrizioni visibili all'utente associato alla chiave API. I membri del gruppo possono leggere nomi, ID, titoli e ruoli degli altri membri. Gli indirizzi email sono inclusi solo per l'account associato alla chiave API o se quell'utente è amministratore del gruppo.

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

Invia un elenco di indirizzi email. I nuovi indirizzi riceveranno un invito a unirsi al gruppo. A differenza dell'elenco delle iscrizioni, questa operazione richiede i permessi di amministratore del gruppo.

`POST /api/b2/memberships`

<!-- translation-section: params-13 -->

### Parametri

| Nome | Descrizione |
| --- | --- |
| `group_id` | Numero intero obbligatorio. ID del gruppo di cui gestire le iscrizioni |
| `emails` | Array di stringhe obbligatorio. Indirizzi email delle persone da invitare nel gruppo |
| `remove_absent` | Valore booleano. Se true, rimuove dal gruppo tutte le persone il cui indirizzo email non è presente nell'elenco |

<!-- translation-section: example-18 -->

### Esempio

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"]}' https://www.loomio.com/api/b2/memberships
```

Se passi `remove_absent=1`, tutti i membri del gruppo non inclusi nell'elenco saranno rimossi. Fai attenzione: potresti rimuovere tutti i membri del tuo gruppo.

```bash
curl -H 'Authorization: Bearer YOUR_API_KEY' -X POST -H 'Content-Type: application/json' -d '{"group_id": 123, "emails":["person@example.com"], "remove_absent": 1}' https://www.loomio.com/api/b2/memberships
```

La risposta è un oggetto con `{added_emails: ["person@added.com"], removed_emails: ["person@removed.com"]}`.
