---
title: Voto anonimo
source_revision: c27ee3b193231816878f1c074ff9fc2a086a88c0
source_file: docs/en/user_manual/polls/anonymous_voting/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-02'
sections:
  introduction: 2b9b7da01da020b3
  how-anonymous-voting-protects-voters: f2be8477636489af
  while-voting-is-open: dda23e517269b9cf
  votes-cannot-be-changed: 1e317297688ba902
  why-anonymous-votes-do-not-have-reasons: 39c1a8362550ae40
  results-and-exports: eb2429afd442dad2
  participation-verification: 87bc3647be4bbfb8
  reminders: 0afad473c90f2f03
  what-coordinators-and-administrators-can-see: 07faa9f646665b64
  limits-of-anonymous-voting: 912141560342d073
  questions: 60cc6f1a0163ec5d
  can-a-coordinator-see-how-i-voted: 574fc18f3a9871c3
  can-i-see-my-vote-after-submitting-it: c558e29729aed45f
  can-i-change-or-withdraw-my-vote: dd1a385fa8d225a5
  will-i-receive-an-email-confirming-my-vote: 8616fc9a0b9809ac
  does-a-public-poll-reveal-more-information: 27acfa7744a0790d
  is-anonymous-voting-suitable-for-every-election: d1b723178449c0da
generated:
  introduction: e46fc8d2f0abd936
  how-anonymous-voting-protects-voters: 5fa366a01b25311c
  while-voting-is-open: 7ba38dae70a307a8
  votes-cannot-be-changed: 12a89f833c90e9fb
  why-anonymous-votes-do-not-have-reasons: fe912eb9eb87aad1
  results-and-exports: eed9e119bd424a76
  participation-verification: 43a67017d98f2551
  reminders: 3568d0256b22e857
  what-coordinators-and-administrators-can-see: 371dda1777668a92
  limits-of-anonymous-voting: 9947cc8cc24920a1
  questions: 5e4bf1632f15b07f
  can-a-coordinator-see-how-i-voted: faa5d8392a9822f4
  can-i-see-my-vote-after-submitting-it: 3902f8879d724d6a
  can-i-change-or-withdraw-my-vote: be3dbd061181d219
  will-i-receive-an-email-confirming-my-vote: 10684e339f5e59e6
  does-a-public-poll-reveal-more-information: db8d01c3127680d6
  is-anonymous-voting-suitable-for-every-election: 7bed33f67a82e4b2
title_source: 1bc4567506ad4d51
title_generated: 5749c9ba228fdb8a
---

<!-- translation-section: introduction -->

# Voto anonimo

Il voto anonimo, noto anche come voto alla cieca, separa i dati su chi ha votato dai voti stessi. Dopo la chiusura del sondaggio, chiunque possa vedere i risultati può vedere chi ha partecipato. Nessuno che usa Loomio può collegare un voto inviato alla persona che lo ha inviato.

Questa pagina spiega le protezioni offerte dal voto anonimo, le informazioni conservate e i limiti della garanzia.

<!-- translation-section: how-anonymous-voting-protects-voters -->

## Come il voto anonimo protegge gli elettori

Un sondaggio anonimo conserva due insiemi separati di dati:

| Dati di partecipazione | Voti inviati |
| --- | --- |
| Chi può votare | Le opzioni o i punteggi selezionati |
| Chi è stato invitato e da chi | Il sondaggio a cui appartiene il voto |
| Se ogni persona avente diritto ha votato | Nessun nome o account utente |
| Nessuna opzione o punteggio selezionato | Nessun collegamento ai dati di partecipazione |

Non esiste un identificatore condiviso che colleghi questi dati. I voti inviati non includono neppure l'ora effettiva di invio, le informazioni sugli inviti, i motivi scritti, gli allegati e altri metadati che potrebbero aiutare a identificare un elettore.

Questa separazione viene applicata quando il voto viene memorizzato. Non dipende soltanto dal nascondere i nomi nell'interfaccia.

<!-- translation-section: while-voting-is-open -->

## Mentre il sondaggio è aperto

I risultati rimangono nascosti a tutti fino alla chiusura del sondaggio. Questo vale anche per i coordinatori del sondaggio, gli amministratori del gruppo e gli amministratori dell'istanza che usano l'applicazione.

Quando qualcuno vota:

- il voto inviato viene memorizzato senza il suo nome o i suoi dati di partecipazione;
- i suoi dati di partecipazione vengono aggiornati per indicare che ha votato;
- non viene creato alcun evento di voto, notifica, email, commento o voce di attività;
- dopo l'invio non viene restituita alcuna copia delle sue selezioni; e
- l'interfaccia conferma soltanto che il suo voto è stato registrato.

I dati di partecipazione non conservano l'ora precisa in cui la persona ha votato. I voti inviati non sono ordinati in base all'ora di invio.

<!-- translation-section: votes-cannot-be-changed -->

## I voti non possono essere modificati

Ogni persona avente diritto può votare una sola volta. Un voto anonimo inviato non può essere consultato, modificato, ritirato o sostituito, nemmeno da un coordinatore o un amministratore.

Consentire a una persona di recuperare o sostituire il proprio voto richiederebbe un collegamento persistente tra quella persona e il voto. Il voto anonimo non crea questo collegamento per scelta.

Controlla attentamente le tue selezioni prima di inviare il voto.

<!-- translation-section: why-anonymous-votes-do-not-have-reasons -->

## Perché i voti anonimi non hanno motivi

I nuovi voti anonimi non possono includere un motivo scritto o un allegato. I motivi possono contenere nomi, dettagli personali, caratteristiche dello stile di scrittura, menzioni o altre informazioni che identificano l'elettore. Renderebbero inoltre più facile distinguere i singoli voti dal risultato aggregato.

I partecipanti possono comunque discutere del sondaggio nella sua conversazione, dove è disponibile la discussione. Questi commenti sono normali contributi alla discussione con il nome dell'autore e non sono collegati a un voto anonimo.

<!-- translation-section: results-and-exports -->

## Risultati ed esportazioni

Dopo la chiusura del sondaggio, i risultati vengono calcolati a partire dai voti separati dai dati di partecipazione e mostrati come totali e altri risultati aggregati supportati dal tipo di sondaggio.

L'applicazione non pubblica gli identificatori dei voti, l'ordine di invio o gli orari di invio. Le esportazioni dei sondaggi contengono risultati aggregati anziché una riga per ogni voto anonimo, con un'eccezione: un'elezione STV chiusa può essere esportata in formato BLT. Un'esportazione BLT contiene gli ordini di preferenza dei candidati necessari per ricontare i voti dell'elezione, raggruppati quando più schede hanno lo stesso ordine di preferenza, senza le identità degli elettori o i metadati delle schede.

Un sondaggio anonimo non può essere riaperto dopo la chiusura.

<!-- translation-section: participation-verification -->

## Chi ha partecipato

Dopo la chiusura di un sondaggio anonimo, chiunque possa vedere i suoi risultati può vedere chi ha partecipato. Nessuno può vedere questa informazione mentre il sondaggio è aperto.

Seleziona **Visualizza i voti** per vedere l'elenco. Mostra sempre chi aveva diritto di voto. Mostra se ogni persona ha votato soltanto se hanno votato abbastanza persone. La soglia corrisponde al quorum del sondaggio, se previsto, altrimenti alla metà degli elettori aventi diritto, e non è mai inferiore a tre voti. L'elenco non mostra mai come o quando ha votato una persona.

I membri del gruppo e gli elettori del sondaggio vedono anche quando ogni persona è entrata nel gruppo e chi l'ha invitata. Gli amministratori del gruppo vedono anche gli indirizzi email, per distinguere le persone con lo stesso nome.

Poiché chiunque possa vedere i risultati può vedere chi ha votato, un risultato in cui tutti i voti sono per la stessa opzione può rivelare come hanno votato le persone. Per esempio, se ogni voto è Accordo, tutte le persone che hanno votato erano d'accordo.

I coordinatori possono aggiungere persone aventi diritto mentre il sondaggio è aperto, anche dopo che altre persone hanno votato. Gli elettori già presenti non possono essere rimossi da un sondaggio anonimo.

<!-- translation-section: reminders -->

## Promemoria

Per un sondaggio anonimo che dura almeno 24 ore, le persone aventi diritto che non hanno votato ricevono un promemoria automatico durante le ultime 24 ore.

I destinatari del promemoria vengono selezionati soltanto in base ai dati di partecipazione. Il sistema non esamina i voti inviati e non crea un collegamento con essi. Se la scadenza cambia, il controllo orario dei promemoria usa la scadenza attuale senza conservare un promemoria programmato separato per il sondaggio.

I sondaggi con un periodo di voto complessivo inferiore a 24 ore non inviano questo promemoria automatico.

<!-- translation-section: what-coordinators-and-administrators-can-see -->

## Cosa possono vedere coordinatori e amministratori

Tramite l'applicazione, un coordinatore del sondaggio, un amministratore del gruppo o un amministratore dell'istanza può avere accesso a:

- il sondaggio e i suoi elettori aventi diritto;
- l'informazione che indica se ogni persona avente diritto ha votato, quando il suo ruolo consente l'accesso e hanno votato abbastanza persone; e
- i risultati aggregati dopo la chiusura del sondaggio.

Non può usare le funzioni dell'applicazione per vedere:

- quali selezioni appartengono a una persona;
- i singoli voti o gli schemi di voto;
- quando è stato inviato un determinato voto; o
- un motivo, un allegato, un evento o una notifica associati a un voto inviato.

<!-- translation-section: limits-of-anonymous-voting -->

## Limiti del voto anonimo

Queste protezioni impediscono agli utenti dell'applicazione di collegare un voto inviato al suo elettore. Non costituiscono una protezione crittografica contro un operatore che può esaminare il database, i backup, i log del server, la memoria dei processi, il traffico di rete o una versione modificata dell'applicazione.

Anche il risultato stesso può rivelare informazioni. Un elettorato ristretto, un risultato unanime, una combinazione particolare di selezioni o informazioni condivise al di fuori del sondaggio possono rendere più facile dedurre le scelte di una persona. Gli elettori possono anche scegliere di identificarsi nella discussione, al di fuori del voto inviato.

Considera le dimensioni dell'elettorato e la delicatezza della decisione quando valuti se il voto anonimo a livello di applicazione è adatto.

<!-- translation-section: questions -->

## Domande

<!-- translation-section: can-a-coordinator-see-how-i-voted -->

### Qualcuno può vedere come ho votato?

No. Una volta che hanno votato abbastanza persone, chi può vedere i risultati può vedere se hai votato. Nessuno può collegarti a un voto inviato tramite l'applicazione. Fino ad allora, l'informazione che indica se hai votato rimane nascosta.

<!-- translation-section: can-i-see-my-vote-after-submitting-it -->

### Posso vedere il mio voto dopo averlo inviato?

No. L'applicazione conferma che il tuo voto è stato registrato, poi elimina le scelte dall'interfaccia di voto. Non può recuperare il tuo voto senza creare il collegamento che il voto anonimo è progettato per evitare.

<!-- translation-section: can-i-change-or-withdraw-my-vote -->

### Posso modificare o ritirare il mio voto?

No. Non esiste un collegamento che permetta all'applicazione di identificare quale voto inviato modificare o rimuovere.

<!-- translation-section: will-i-receive-an-email-confirming-my-vote -->

### Riceverò un'email di conferma del mio voto?

No. Quando voti, l'applicazione mostra solo una conferma sullo schermo e aggiorna il tuo registro di partecipazione. Non invia un'email di conferma e non crea una notifica o un evento di attività.

<!-- translation-section: does-a-public-poll-reveal-more-information -->

### Un sondaggio pubblico rivela più informazioni?

Dopo la chiusura di un sondaggio pubblico, chiunque può vedere i risultati e chi ha partecipato. Non può vedere i singoli voti né i dettagli sull'appartenenza al gruppo e sugli inviti.

<!-- translation-section: is-anonymous-voting-suitable-for-every-election -->

### Il voto anonimo è adatto a ogni elezione?

No. Separa le identità dai voti a livello di applicazione. Le decisioni che richiedono protezione dagli operatori del sistema o elezioni crittografiche verificabili in modo indipendente hanno bisogno di un sistema progettato per questi requisiti.
