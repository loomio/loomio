---
title: Voto anonimo
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/polls/anonymous_voting/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-29'
sections:
  introduction: d5c276b2785919c3
  how-anonymous-voting-protects-voters: f2be8477636489af
  while-voting-is-open: dda23e517269b9cf
  votes-cannot-be-changed: 1e317297688ba902
  why-anonymous-votes-do-not-have-reasons: 39c1a8362550ae40
  results-and-exports: eb2429afd442dad2
  participation-verification: cdaa1f5c3ca1e179
  reminders: 0afad473c90f2f03
  what-coordinators-and-administrators-can-see: 51460c8a6b663aba
  limits-of-anonymous-voting: 912141560342d073
  questions: 60cc6f1a0163ec5d
  can-a-coordinator-see-how-i-voted: 3dd2c9e6d06debda
  can-i-see-my-vote-after-submitting-it: c558e29729aed45f
  can-i-change-or-withdraw-my-vote: dd1a385fa8d225a5
  will-i-receive-an-email-confirming-my-vote: 8616fc9a0b9809ac
  does-a-public-poll-reveal-more-information: 2ba76a1748304f96
  is-anonymous-voting-suitable-for-every-election: d1b723178449c0da
generated:
  introduction: a6405143d35cf8b8
  how-anonymous-voting-protects-voters: 0b85f15662332879
  while-voting-is-open: 8906c72314114e3f
  votes-cannot-be-changed: 1c4dc42769d2ba73
  why-anonymous-votes-do-not-have-reasons: 3415850b0c9584be
  results-and-exports: b16f09dc277f56cf
  participation-verification: f8bce69cc57ba4c2
  reminders: b07a9c28cf043fba
  what-coordinators-and-administrators-can-see: e2e18eaa1af61b0f
  limits-of-anonymous-voting: 6aca991150283d9b
  questions: 5e4bf1632f15b07f
  can-a-coordinator-see-how-i-voted: 6929d6a0a277fc5a
  can-i-see-my-vote-after-submitting-it: 405e7859ece045d8
  can-i-change-or-withdraw-my-vote: b2b878e660578d45
  will-i-receive-an-email-confirming-my-vote: 16cb7d6b4224a600
  does-a-public-poll-reveal-more-information: 0b40dd0cc56f5575
  is-anonymous-voting-suitable-for-every-election: fe7e7974b858eaff
title_source: 1bc4567506ad4d51
title_generated: 5749c9ba228fdb8a
---

<!-- translation-section: introduction -->

# Voto anonimo

Il voto anonimo, detto anche voto segreto, separa la registrazione di chi ha votato dai voti espressi. Chi coordina il sondaggio può vedere chi aveva diritto di voto e, dopo che almeno tre persone hanno votato, verificare la partecipazione. Chi usa l'applicazione non può collegare un voto alla persona che lo ha espresso.

Questa pagina spiega come viene protetto il voto anonimo, quali informazioni vengono conservate e quali sono i limiti di questa tutela.

<!-- translation-section: how-anonymous-voting-protects-voters -->

## Come il voto anonimo protegge chi vota

Un sondaggio anonimo conserva due insiemi distinti di dati:

| Dati sulla partecipazione | Voti espressi |
| --- | --- |
| Chi ha diritto di voto | Le opzioni selezionate o i punteggi assegnati |
| Chi è stato invitato e da chi | Il sondaggio a cui appartiene il voto |
| Se ciascuna persona avente diritto ha votato | Nessun nome o account utente |
| Nessuna opzione selezionata o punteggio assegnato | Nessun collegamento ai dati sulla partecipazione |

Non esiste un identificativo condiviso che colleghi questi dati. I voti espressi non includono nemmeno l'ora effettiva dell'invio, le informazioni sugli inviti, le motivazioni scritte, gli allegati o altri metadati che potrebbero aiutare a identificare chi ha votato.

Questa separazione viene applicata quando il voto viene memorizzato. Non dipende soltanto dal fatto che i nomi siano nascosti nell'interfaccia.

<!-- translation-section: while-voting-is-open -->

## Durante la votazione

I risultati restano nascosti a tutti fino alla chiusura del sondaggio. Questo vale anche per chi coordina il sondaggio e per chi amministra il gruppo o l'istanza tramite l'applicazione.

Quando una persona vota:

- il suo voto viene memorizzato senza il suo nome né un collegamento ai suoi dati sulla partecipazione;
- i suoi dati sulla partecipazione vengono aggiornati per indicare che ha votato;
- non vengono creati eventi di voto, notifiche, email, commenti o voci di attività;
- dopo l'invio non viene restituita una copia delle sue scelte; e
- l'interfaccia conferma soltanto che il voto è stato registrato.

I dati sulla partecipazione non conservano l'ora precisa in cui la persona ha votato. I voti espressi non sono ordinati in base all'ora di invio.

<!-- translation-section: votes-cannot-be-changed -->

## I voti non possono essere modificati

Ogni persona avente diritto può votare una sola volta. Un voto anonimo inviato non può essere consultato, modificato, ritirato o sostituito, nemmeno da chi coordina o amministra il sondaggio.

Per consentire a una persona di recuperare o sostituire il proprio voto, servirebbe un collegamento permanente tra la persona e il voto. Il voto anonimo non crea questo collegamento.

Controlla con attenzione le tue scelte prima di inviare il voto.

<!-- translation-section: why-anonymous-votes-do-not-have-reasons -->

## Perché i voti anonimi non includono motivazioni

I nuovi voti anonimi non possono includere una motivazione scritta o un allegato. Le motivazioni possono contenere nomi, dati personali, modi di scrivere riconoscibili, menzioni o altre informazioni che identificano chi vota. Renderebbero inoltre più facile distinguere i singoli voti dal risultato complessivo.

Le persone possono comunque parlare del sondaggio nella relativa discussione, se i commenti sono disponibili. Quei commenti sono normali contributi attribuiti a chi li scrive e non sono collegati a un voto anonimo.

<!-- translation-section: results-and-exports -->

## Risultati ed esportazioni

Dopo la chiusura del sondaggio, i risultati vengono calcolati dai voti separati dalle identità e mostrati come totali e altri risultati complessivi previsti dal tipo di sondaggio.

L'applicazione non pubblica gli identificativi dei voti, l'ordine di invio o le ore di invio. Le esportazioni dei sondaggi contengono risultati complessivi anziché una riga per ogni voto anonimo. Fa eccezione un'elezione STV chiusa, che può essere esportata in formato BLT. Un'esportazione BLT contiene le classifiche dei candidati necessarie per ricontare l'elezione. Le schede con la stessa classifica sono raggruppate e non vengono incluse le identità di chi ha votato né i metadati delle schede.

Un sondaggio anonimo non può essere riaperto dopo la chiusura.

<!-- translation-section: participation-verification -->

## Verifica della partecipazione

Chi coordina il sondaggio può vedere i dati sulla partecipazione associati ai nomi. Questi mostrano sempre chi aveva diritto di voto. Dopo che almeno tre persone hanno votato, mostrano anche se ciascuna persona ha votato, ma mai come ha votato. Se un sondaggio si chiude con meno di tre voti, lo stato di partecipazione resta nascosto.

Le altre persone che partecipano al sondaggio non possono vedere queste informazioni nominative. L'accesso ai risultati del sondaggio non dà accesso ai dati sulla partecipazione.

Chi coordina il sondaggio può aggiungere persone aventi diritto mentre la votazione è aperta, anche dopo che altre persone hanno votato. Chi ha già votato non può essere rimosso da un sondaggio anonimo.

<!-- translation-section: reminders -->

## Promemoria

Per un sondaggio anonimo che dura almeno 24 ore, le persone aventi diritto che non hanno votato ricevono un promemoria automatico nelle ultime 24 ore.

Il promemoria viene inviato in base ai soli dati sulla partecipazione. Non esamina i voti espressi né crea un collegamento con essi. Se la scadenza cambia, il controllo orario dei promemoria usa la scadenza corrente, senza mantenere un promemoria programmato separato per il sondaggio.

I sondaggi con un periodo di votazione complessivo inferiore a 24 ore non inviano questo promemoria automatico.

<!-- translation-section: what-coordinators-and-administrators-can-see -->

## Cosa possono vedere coordinatori e amministratori

Tramite l'applicazione, chi coordina il sondaggio o amministra il gruppo o l'istanza può avere accesso a:

- il sondaggio e le persone aventi diritto di voto;
- l'indicazione che ciascuna persona avente diritto abbia votato, se il suo ruolo consente l'accesso e almeno tre persone hanno votato; e
- i risultati complessivi dopo la chiusura del sondaggio.

Le funzionalità dell'applicazione non consentono loro di vedere:

- quali scelte appartengono a una persona;
- i singoli voti o i modi in cui le persone hanno votato;
- quando è stato inviato un determinato voto; o
- una motivazione, un allegato, un evento o una notifica associati a un voto inviato.

<!-- translation-section: limits-of-anonymous-voting -->

## Limiti del voto anonimo

Queste tutele impediscono a chi usa l'applicazione di collegare un voto alla persona che lo ha espresso. Non offrono una protezione crittografica contro un operatore che possa esaminare il database, i backup, i log del server, la memoria dei processi, il traffico di rete o una versione modificata dell'applicazione.

Anche il risultato può rivelare informazioni. Se le persone aventi diritto sono poche, il risultato è unanime, una combinazione di scelte è particolare o vengono condivise informazioni fuori dal sondaggio, può essere più facile dedurre le scelte di una persona. Chi vota può anche scegliere di identificarsi nella discussione, al di fuori del voto inviato.

Per decidere se il voto anonimo nell'applicazione è adatto, considera il numero di elettori e la delicatezza della decisione.

<!-- translation-section: questions -->

## Domande

<!-- translation-section: can-a-coordinator-see-how-i-voted -->

### Un coordinatore può vedere come ho votato?

No. Dopo che almeno tre persone hanno votato, un coordinatore può verificare se hai votato, ma non può associare il tuo nome a un voto inviato tramite l'applicazione. Finché i voti sono meno di tre, la tua partecipazione resta nascosta.

<!-- translation-section: can-i-see-my-vote-after-submitting-it -->

### Posso vedere il mio voto dopo averlo inviato?

No. L'applicazione conferma che il tuo voto è stato registrato, poi rimuove le tue scelte dall'interfaccia di voto. Non può recuperare il tuo voto senza creare il collegamento che il voto anonimo è progettato per evitare.

<!-- translation-section: can-i-change-or-withdraw-my-vote -->

### Posso cambiare o ritirare il mio voto?

No. Non esiste un collegamento che permetta all'applicazione di identificare quale voto inviato modificare o rimuovere.

<!-- translation-section: will-i-receive-an-email-confirming-my-vote -->

### Riceverò un'email di conferma del mio voto?

No. Il voto produce solo una conferma sullo schermo e aggiorna il tuo registro di partecipazione. Non invia un'email di conferma né crea una notifica o un evento nel registro delle attività.

<!-- translation-section: does-a-public-poll-reveal-more-information -->

### Un sondaggio pubblico rivela più informazioni?

L'accesso pubblico può permettere di vedere il sondaggio e i risultati aggregati dopo la sua chiusura. Non rende visibili i registri di partecipazione con i nomi né i singoli voti anonimi.

<!-- translation-section: is-anonymous-voting-suitable-for-every-election -->

### Il voto anonimo è adatto a ogni elezione?

No. Separa le identità dai voti all'interno dell'applicazione. Per le decisioni che richiedono protezione dagli operatori del sistema o elezioni crittografiche verificabili in modo indipendente, serve un sistema progettato per questi requisiti.
