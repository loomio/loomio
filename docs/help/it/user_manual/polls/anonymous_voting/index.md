---
title: Voto anonimo
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/polls/anonymous_voting/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
sections:
  introduction: ffcecd2f4297c47d
  how-anonymous-voting-protects-voters: 3b757a1b4a7bda96
  while-voting-is-open: aafc698ee8108194
  votes-cannot-be-changed: 3a99e6c3f48e10ee
  why-anonymous-votes-do-not-have-reasons: 4027d6c1fbf4d29c
  results-and-exports: 5c10ab43a5f890b4
  participation-verification: e77ece0fc0d6cd73
  reminders: f711a180ae7c948f
  what-coordinators-and-administrators-can-see: d873cd48677fc324
  limits-of-anonymous-voting: 9ab54b74a4716e19
  questions: 60cc6f1a0163ec5d
  can-a-coordinator-see-how-i-voted: bfa1baf48f41cdd1
  can-i-see-my-vote-after-submitting-it: 435010e0c2ecf488
  can-i-change-or-withdraw-my-vote: 676d5401bf4d73cc
  will-i-receive-an-email-confirming-my-vote: 9660f10e8ffb9f9c
  does-a-public-poll-reveal-more-information: '087defb00bb8b99f'
  is-anonymous-voting-suitable-for-every-election: 9fae56c0661f0ec9
generated:
  introduction: f43c3ca84ef703cf
  how-anonymous-voting-protects-voters: 513927d9d0de5e53
  while-voting-is-open: 58ff031faba65ec6
  votes-cannot-be-changed: f5b192b57a95c5b8
  why-anonymous-votes-do-not-have-reasons: 42552fae3e49278a
  results-and-exports: 537355be5100b957
  participation-verification: 136638ef97d495c2
  reminders: 436d497a4b8072dc
  what-coordinators-and-administrators-can-see: 4c230fdfefbef1bb
  limits-of-anonymous-voting: a840cc3e7d335490
  questions: 5e4bf1632f15b07f
  can-a-coordinator-see-how-i-voted: f4acf289a1d0d3e5
  can-i-see-my-vote-after-submitting-it: d678b89b27885df5
  can-i-change-or-withdraw-my-vote: 4d0e0e022ccfc04a
  will-i-receive-an-email-confirming-my-vote: c4f5ad47d348f6df
  does-a-public-poll-reveal-more-information: db8d01c3127680d6
  is-anonymous-voting-suitable-for-every-election: 4c1ee81d333b67fe
title_source: 1bc4567506ad4d51
title_generated: 5749c9ba228fdb8a
---

<!-- translation-section: introduction -->

# Voto anonimo

Il voto anonimo, noto anche come voto alla cieca, separa i dati su chi ha votato dai voti stessi. Dopo la chiusura del sondaggio, chiunque possa vedere i risultati può vedere chi ha partecipato, ma nessuno che usa Loomio può collegare un voto alla persona che lo ha espresso.

Questa pagina spiega come funziona il voto anonimo, quali informazioni vengono conservate e i limiti di questa protezione.

<!-- translation-section: how-anonymous-voting-protects-voters -->

## Come il voto anonimo protegge gli elettori

Un sondaggio anonimo conserva due insiemi separati di dati:

| Dati di partecipazione | Voti inviati |
| --- | --- |
| Chi può votare | Le opzioni o i punteggi selezionati |
| Chi è stato invitato e da chi | Il sondaggio a cui appartiene il voto |
| Se ogni persona avente diritto ha votato | Nessun nome o account utente |
| Nessuna opzione o punteggio selezionato | Nessun collegamento ai dati di partecipazione |

Nessun identificatore condiviso collega questi dati. I voti inviati non includono neppure gli orari di invio, i dettagli degli inviti, i motivi dei voti, gli allegati e altri metadati che potrebbero identificare un elettore.

Questa separazione avviene quando il voto viene salvato e non si basa soltanto sul nascondere i nomi nell'interfaccia.

<!-- translation-section: while-voting-is-open -->

## Mentre il sondaggio è aperto

I risultati rimangono nascosti a tutti fino alla chiusura del sondaggio, compresi gli amministratori della conversazione, gli amministratori del gruppo e gli amministratori dell'istanza.

Quando qualcuno vota:

- il suo voto viene memorizzato senza il suo nome o i suoi dati di partecipazione;
- i suoi dati di partecipazione vengono aggiornati per indicare che ha votato;
- non viene creato alcun evento di voto, notifica, email, commento o voce di attività;
- dopo l'invio non viene restituita alcuna copia delle sue scelte; e
- lo schermo conferma soltanto che il suo voto è stato registrato.

I dati di partecipazione non conservano l'ora precisa in cui una persona ha votato e i voti inviati non sono ordinati in base all'ora di invio.

<!-- translation-section: votes-cannot-be-changed -->

## I voti non possono essere modificati

Ogni persona avente diritto può votare una sola volta. Un voto anonimo inviato non può essere consultato, modificato, ritirato o sostituito, nemmeno da un amministratore.

Consentire a una persona di recuperare o sostituire il proprio voto richiederebbe un collegamento tra quella persona e il voto, che il voto anonimo evita intenzionalmente.

Controlla attentamente le tue scelte prima di inviare il voto.

<!-- translation-section: why-anonymous-votes-do-not-have-reasons -->

## Perché i voti anonimi non hanno motivi

I voti anonimi non possono includere un motivo del voto o un allegato. I motivi possono contenere nomi, dettagli personali, caratteristiche dello stile di scrittura o menzioni che identificano l'elettore e potrebbero rendere più facile distinguere i singoli voti nei risultati.

I partecipanti possono comunque discutere del sondaggio nella sua conversazione. Questi commenti sono normali contributi con il nome dell'autore e non sono collegati a un voto anonimo.

<!-- translation-section: results-and-exports -->

## Risultati ed esportazioni

Dopo la chiusura del sondaggio, Loomio calcola i risultati a partire dai voti separati dai dati di partecipazione e mostra i totali per quel tipo di sondaggio.

Loomio non pubblica gli identificatori dei voti, l'ordine di invio o gli orari di invio. Le esportazioni dei sondaggi contengono soltanto risultati aggregati anziché una riga per ogni voto. L'unica eccezione è un'elezione STV chiusa, che può essere esportata in formato BLT per ricontare i voti. Un'esportazione BLT elenca gli ordini di preferenza dei candidati (raggruppati quando più schede coincidono), senza le identità degli elettori o i metadati delle schede.

Un sondaggio anonimo non può essere riaperto dopo la chiusura.

<!-- translation-section: participation-verification -->

## Chi ha partecipato

Dopo la chiusura di un sondaggio anonimo, chiunque possa vedere i suoi risultati può vedere chi ha partecipato. Nessuno può vedere questa informazione mentre il sondaggio è aperto.

Seleziona **Visualizza i voti** per vedere l'elenco. Mostra sempre chi aveva diritto di voto e non mostra mai come o quando ha votato una persona. L'informazione che indica se ogni persona ha votato appare soltanto se hanno partecipato abbastanza persone: almeno il quorum del sondaggio (se impostato), altrimenti almeno la metà degli elettori aventi diritto, e in ogni caso almeno tre voti.

I membri del gruppo e gli elettori del sondaggio vedono anche quando ogni persona è entrata nel gruppo e chi l'ha invitata. Gli amministratori del gruppo vedono anche gli indirizzi email, per distinguere le persone con lo stesso nome.

Poiché chiunque possa vedere i risultati può vedere chi ha votato, un risultato in cui tutti i voti sono per la stessa opzione può rivelare come hanno votato le persone. Per esempio, se ogni voto è Accordo, tutte le persone che hanno votato erano d'accordo.

Gli amministratori possono aggiungere elettori aventi diritto mentre il sondaggio è aperto, anche dopo che altre persone hanno votato. Gli elettori già presenti non possono essere rimossi da un sondaggio anonimo.

<!-- translation-section: reminders -->

## Promemoria

Per un sondaggio anonimo che dura almeno 24 ore, le persone aventi diritto che non hanno votato ricevono un promemoria automatico durante le ultime 24 ore.

Loomio seleziona i destinatari soltanto in base ai dati di partecipazione, senza controllare i voti inviati.

I sondaggi con un periodo di voto inferiore a 24 ore non inviano questo promemoria automatico.

<!-- translation-section: what-coordinators-and-administrators-can-see -->

## Cosa possono vedere gli amministratori

Tramite l'applicazione, un amministratore della conversazione, un amministratore del gruppo o un amministratore dell'istanza può vedere, se autorizzato:

- il sondaggio e i suoi elettori aventi diritto;
- se ogni persona avente diritto ha votato (quando il suo ruolo consente l'accesso e hanno votato abbastanza persone); e
- i risultati aggregati dopo la chiusura del sondaggio.

Non può usare l'applicazione per vedere:

- quali scelte appartengono a una persona;
- i singoli voti o gli schemi di voto;
- quando è stato inviato un voto; o
- un motivo del voto, un allegato, un evento o una notifica collegati a un voto.

<!-- translation-section: limits-of-anonymous-voting -->

## Limiti del voto anonimo

Il voto anonimo impedisce agli utenti di Loomio di collegare un voto a un elettore. Non costituisce una protezione crittografica contro un operatore del server che può esaminare il database, i backup, i log del server, la memoria dei processi, il traffico di rete o il codice modificato.

Anche i risultati stessi possono fornire indizi. Un gruppo piccolo, un voto unanime, una combinazione unica di scelte o commenti condivisi al di fuori del sondaggio possono rendere più facile dedurre il voto di una persona.

Considera le dimensioni del gruppo e la delicatezza della decisione prima di affidarti al voto anonimo a livello di applicazione.

<!-- translation-section: questions -->

## Domande

<!-- translation-section: can-a-coordinator-see-how-i-voted -->

### Qualcuno può vedere come ho votato?

No. Nessuno che usa Loomio può collegarti al tuo voto. Una volta che hanno votato abbastanza persone, chiunque possa vedere i risultati può vedere se hai partecipato. Prima che venga raggiunta quella soglia, anche l'informazione che indica se hai votato rimane nascosta.

<!-- translation-section: can-i-see-my-vote-after-submitting-it -->

### Posso vedere il mio voto dopo averlo inviato?

No. Loomio conferma che il tuo voto è stato registrato e cancella le tue selezioni dallo schermo. Non può recuperare il tuo voto senza creare il collegamento che il voto anonimo evita.

<!-- translation-section: can-i-change-or-withdraw-my-vote -->

### Posso modificare o ritirare il mio voto?

No. Poiché non esiste un collegamento tra te e il tuo voto, Loomio non può identificare quale voto modificare o rimuovere.

<!-- translation-section: will-i-receive-an-email-confirming-my-vote -->

### Riceverò un'email di conferma del mio voto?

No. Quando voti, l'applicazione mostra solo una conferma sullo schermo e aggiorna il tuo registro di partecipazione. Non invia un'email e non crea una notifica o una voce nel registro delle attività.

<!-- translation-section: does-a-public-poll-reveal-more-information -->

### Un sondaggio pubblico rivela più informazioni?

Dopo la chiusura di un sondaggio pubblico, chiunque può vedere i risultati e chi ha partecipato. Non può vedere i singoli voti né i dettagli sull'appartenenza al gruppo e sugli inviti.

<!-- translation-section: is-anonymous-voting-suitable-for-every-election -->

### Il voto anonimo è adatto a ogni elezione?

No. Separa gli elettori dai voti a livello di applicazione. Le elezioni che richiedono protezione dagli operatori del server o una verifica crittografica indipendente hanno bisogno di un sistema progettato per questi requisiti.
