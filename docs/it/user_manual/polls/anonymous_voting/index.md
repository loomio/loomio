---
title: Voto anonimo
source_revision: c6076258c3438c0dd6dc8fbf1fc0b0df47c0aeb5
source_file: docs/en/user_manual/polls/anonymous_voting/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
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
  introduction: 7e7213629eca1215
  how-anonymous-voting-protects-voters: 2fd667beba6e2192
  while-voting-is-open: 8d61bcebde6f83fb
  votes-cannot-be-changed: ec431ebf9c79de34
  why-anonymous-votes-do-not-have-reasons: 93985f2de5392241
  results-and-exports: 7a229b6a71de5f01
  participation-verification: 964df08466cafe9b
  reminders: 60731ee0eafb75fa
  what-coordinators-and-administrators-can-see: 07e146e412ff6330
  limits-of-anonymous-voting: 55a34d6c54071f28
  questions: 5e4bf1632f15b07f
  can-a-coordinator-see-how-i-voted: 522093058100d6fa
  can-i-see-my-vote-after-submitting-it: 0a67d76e5c0e36d7
  can-i-change-or-withdraw-my-vote: be3dbd061181d219
  will-i-receive-an-email-confirming-my-vote: a4cd87ed7091ef1a
  does-a-public-poll-reveal-more-information: db8d01c3127680d6
  is-anonymous-voting-suitable-for-every-election: ce892d433e2e2038
title_source: 1bc4567506ad4d51
title_generated: 5749c9ba228fdb8a
---

<!-- translation-section: introduction -->

# Voto anonimo

Il voto anonimo, noto anche come voto alla cieca, separa la registrazione di chi ha votato dai voti stessi. Dopo la chiusura del sondaggio, chiunque possa vedere i risultati può vedere chi ha partecipato. Nessuno che utilizza Loomio può collegare un voto inviato alla persona che lo ha inviato.

Questa pagina spiega le protezioni offerte dal voto anonimo, le informazioni conservate e i limiti della garanzia.

<!-- translation-section: how-anonymous-voting-protects-voters -->

## Come il voto anonimo protegge gli elettori

Un sondaggio anonimo conserva due insiemi separati di registrazioni:

| Registrazioni della partecipazione | Voti inviati |
| --- | --- |
| Chi ha diritto di voto | Le opzioni o i punteggi selezionati |
| Chi è stato invitato e da chi | Il sondaggio a cui appartiene il voto |
| Se ogni persona avente diritto ha votato | Nessun nome o account utente |
| Nessuna opzione o punteggio selezionato | Nessun collegamento a una registrazione della partecipazione |

Non esiste un identificativo condiviso che colleghi queste registrazioni. I voti inviati non includono nemmeno l'orario effettivo di invio, le informazioni sull'invito, i motivi scritti, gli allegati e altri metadati che potrebbero aiutare a identificare un elettore.

Questa separazione viene applicata quando il voto viene memorizzato. Non dipende soltanto dal nascondere i nomi nell'interfaccia.

<!-- translation-section: while-voting-is-open -->

## Mentre la votazione è aperta

I risultati rimangono nascosti a tutti fino alla chiusura del sondaggio. Questo vale anche per i coordinatori del sondaggio, gli amministratori del gruppo e gli amministratori dell'istanza che utilizzano l'applicazione.

Quando una persona vota:

- il voto inviato viene memorizzato senza il suo nome o la sua registrazione della partecipazione;
- la sua registrazione della partecipazione viene contrassegnata per indicare che ha votato;
- non viene creato alcun evento di voto, notifica, email, commento o voce di attività;
- dopo l'invio non viene restituita alcuna copia delle sue selezioni; e
- l'interfaccia conferma soltanto che il suo voto è stato registrato.

La registrazione della partecipazione non memorizza un orario preciso del voto della persona. I voti inviati non sono ordinati in base all'orario di invio.

<!-- translation-section: votes-cannot-be-changed -->

## I voti non possono essere modificati

Ogni persona avente diritto può votare una sola volta. Un voto anonimo inviato non può essere consultato, modificato, ritirato o sostituito, nemmeno da un coordinatore o un amministratore.

Consentire a una persona di recuperare o sostituire il proprio voto richiederebbe un collegamento persistente tra quella persona e il voto. Il voto anonimo non crea deliberatamente questo collegamento.

Controlla attentamente le tue selezioni prima di inviarle.

<!-- translation-section: why-anonymous-votes-do-not-have-reasons -->

## Perché i voti anonimi non hanno motivi

I nuovi voti anonimi non possono includere un motivo scritto o un allegato. I motivi possono contenere nomi, dettagli personali, caratteristiche dello stile di scrittura, menzioni o altre informazioni che identificano l'elettore. Renderebbero inoltre più facile distinguere i singoli voti dal risultato aggregato.

I partecipanti possono comunque discutere del sondaggio nella sua conversazione, dove è disponibile la discussione. Questi commenti sono normali contributi alla discussione associati al nome dell'autore e non sono collegati a un voto anonimo.

<!-- translation-section: results-and-exports -->

## Risultati ed esportazioni

Dopo la chiusura del sondaggio, i risultati vengono calcolati a partire dai voti separati dalle registrazioni della partecipazione e visualizzati come totali e altri risultati aggregati supportati dal tipo di sondaggio.

L'applicazione non pubblica gli identificativi dei voti, l'ordine di invio o gli orari di invio. Le esportazioni dei sondaggi contengono risultati aggregati anziché una riga per ogni voto anonimo, con l'eccezione delle elezioni STV chiuse, che possono essere esportate in formato BLT. Un'esportazione BLT contiene le classifiche dei candidati necessarie per ripetere il conteggio dell'elezione, raggruppate quando più schede hanno la stessa classifica, senza le identità degli elettori o i metadati delle schede.

Un sondaggio anonimo non può essere riaperto dopo la chiusura.

<!-- translation-section: participation-verification -->

## Chi ha partecipato

Dopo la chiusura di un sondaggio anonimo, chiunque possa vedere i risultati può vedere chi ha partecipato. Nessuno può vedere questa informazione mentre la votazione è aperta.

Seleziona **Visualizza i voti** per vedere l'elenco. L'elenco mostra sempre chi aveva diritto di voto. Mostra se ogni persona ha votato soltanto quando ha votato un numero sufficiente di persone. La soglia è il quorum del sondaggio, se previsto, altrimenti la metà degli elettori aventi diritto, e in ogni caso non meno di tre voti. L'elenco non mostra mai come o quando una persona ha votato.

I membri del gruppo e gli elettori del sondaggio vedono anche quando ogni persona si è unita al gruppo e chi l'ha invitata. Gli amministratori del gruppo vedono anche gli indirizzi email, per distinguere le persone con lo stesso nome.

Poiché chiunque possa vedere i risultati può vedere chi ha votato, un risultato in cui tutti i voti sono per la stessa opzione può rivelare come hanno votato le persone. Ad esempio, se ogni voto è Accordo, tutte le persone che hanno votato erano d'accordo.

I coordinatori possono aggiungere persone aventi diritto mentre la votazione è aperta, anche dopo che altre persone hanno votato. Gli elettori già presenti non possono essere rimossi da un sondaggio anonimo.

<!-- translation-section: reminders -->

## Promemoria

Per un sondaggio anonimo che dura almeno 24 ore, le persone aventi diritto che non hanno votato ricevono un solo promemoria automatico nelle ultime 24 ore.

I destinatari del promemoria vengono selezionati soltanto in base alle registrazioni della partecipazione. Il controllo non esamina i voti inviati e non crea alcun collegamento con essi. Se la scadenza cambia, il controllo orario dei promemoria utilizza la scadenza attuale senza mantenere un promemoria programmato separato per il sondaggio.

I sondaggi con un periodo di votazione totale inferiore a 24 ore non inviano questo promemoria automatico.

<!-- translation-section: what-coordinators-and-administrators-can-see -->

## Cosa possono vedere coordinatori e amministratori

Attraverso l'applicazione, un coordinatore del sondaggio, un amministratore del gruppo o un amministratore dell'istanza può avere accesso a:

- il sondaggio e i suoi elettori aventi diritto;
- l'informazione che indica se ogni persona avente diritto ha votato, quando il suo ruolo consente l'accesso e ha votato un numero sufficiente di persone; e
- i risultati aggregati dopo la chiusura del sondaggio.

Non possono utilizzare le funzionalità dell'applicazione per vedere:

- quali selezioni appartengono a una persona;
- i singoli voti o gli schemi di voto;
- quando è stato inviato un determinato voto; o
- un motivo, un allegato, un evento o una notifica associati a un voto inviato.

<!-- translation-section: limits-of-anonymous-voting -->

## Limiti del voto anonimo

Queste protezioni impediscono agli utenti dell'applicazione di collegare un voto inviato al suo elettore. Non costituiscono una protezione crittografica contro un operatore che può esaminare il database, i backup, i log del server, la memoria dei processi, il traffico di rete o una versione modificata dell'applicazione.

Anche il risultato stesso può rivelare informazioni. Un numero ridotto di elettori, un risultato unanime, una combinazione riconoscibile di selezioni o informazioni condivise al di fuori del sondaggio possono rendere più facile dedurre le scelte di una persona. Gli elettori possono anche scegliere di identificarsi nella discussione, al di fuori del voto inviato.

Considera il numero di elettori e la delicatezza della decisione quando valuti se il voto anonimo a livello di applicazione è adatto.

<!-- translation-section: questions -->

## Domande

<!-- translation-section: can-a-coordinator-see-how-i-voted -->

### Qualcuno può vedere come ho votato?

No. Quando ha votato un numero sufficiente di persone, chi può vedere i risultati può vedere se hai votato. Nessuno può collegarti a un voto inviato attraverso l'applicazione. Fino a quel momento, l'informazione che indica se hai votato rimane nascosta.

<!-- translation-section: can-i-see-my-vote-after-submitting-it -->

### Posso vedere il mio voto dopo averlo inviato?

No. L'applicazione conferma che il tuo voto è stato registrato, poi elimina le selezioni dall'interfaccia di voto. Non può recuperare il tuo voto senza creare il collegamento che il voto anonimo è progettato per evitare.

<!-- translation-section: can-i-change-or-withdraw-my-vote -->

### Posso modificare o ritirare il mio voto?

No. Non esiste un collegamento che permetta all'applicazione di identificare quale voto inviato modificare o rimuovere.

<!-- translation-section: will-i-receive-an-email-confirming-my-vote -->

### Riceverò un'email di conferma del mio voto?

No. Quando voti, viene mostrata solo una conferma sullo schermo e viene aggiornato il tuo registro di partecipazione. Non viene inviata un'email di conferma né viene creata una notifica o un evento di attività.

<!-- translation-section: does-a-public-poll-reveal-more-information -->

### Un sondaggio pubblico rivela più informazioni?

Dopo la chiusura di un sondaggio pubblico, chiunque può vedere i risultati e chi ha partecipato. Non può vedere i singoli voti né i dettagli sull'appartenenza al gruppo e sugli inviti.

<!-- translation-section: is-anonymous-voting-suitable-for-every-election -->

### Il voto anonimo è adatto a ogni elezione?

No. Offre una separazione tra identità e voti a livello di applicazione. Le decisioni che richiedono protezione dagli operatori del sistema o elezioni crittografiche verificabili in modo indipendente necessitano di un sistema progettato per questi requisiti.
