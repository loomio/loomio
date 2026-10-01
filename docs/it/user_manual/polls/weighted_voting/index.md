---
sections:
  introduction: 301b7440aa148d0b
  set-members-vote-weights: 47b8d7c9222794d8
  use-weighted-voting-in-a-poll: d8af319ed1e38e4d
  results: 3cd10f104ced0ed5
generated:
  introduction: 2b955580868bef17
  set-members-vote-weights: 8d930ad65a36f011
  use-weighted-voting-in-a-poll: 246c153be894137a
  results: 672f32e79733bd13
title: Voto ponderato
title_source: 0b971991dfcacbab
title_generated: bf17af91b8f4e433
source_revision: 9c60c42fc739483fa23f15d9f34a1e9245518092
source_file: docs/en/user_manual/polls/weighted_voting/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
---

<!-- translation-section: introduction -->

# Voto ponderato

Il voto ponderato permette ad alcuni voti di contare più di altri. Ogni elettore ha un peso di voto. Per esempio:

- Una comunità abitativa assegna un voto a ogni proprietà. Un membro che rappresenta tre proprietà ha un peso di voto di `3`.
- Il consiglio di amministrazione di una cooperativa prende la decisione, ma il personale operativo partecipa alla discussione. I membri del consiglio hanno un peso di voto di `1`. Il personale operativo ha un peso di voto di `0`, quindi i suoi voti vengono registrati ma non modificano il risultato.
- Un'azienda assegna agli azionisti voti in proporzione alla loro partecipazione azionaria. Chi possiede il 12,5% delle azioni ha un peso di voto di `12.5`.

<!-- translation-section: set-members-vote-weights -->

## Imposta i pesi di voto dei membri

Un amministratore del gruppo può aprire la pagina **Membri** del gruppo e selezionare **Modifica i pesi di voto**. Inserisci i pesi di voto e seleziona **Salva i pesi di voto**. I pesi di voto possono essere pari a `0` o superiori, con un massimo di tre cifre decimali. Cerca per nome o email per trovare una persona. Per assegnare lo stesso peso di voto a ogni membro, seleziona **Imposta tutti i pesi di voto**.

![Pesi di voto dei membri del gruppo](member-weights.png)

Il peso di voto di un membro viene copiato in ogni sondaggio a cui viene aggiunto. Modificarlo in seguito non cambia i sondaggi in cui è già stato copiato.

<!-- translation-section: use-weighted-voting-in-a-poll -->

## Usa il voto ponderato in un sondaggio

Seleziona **Usa il voto ponderato** nelle impostazioni avanzate del sondaggio. Puoi attivarlo o disattivarlo dopo l'apertura della votazione. Disattivandolo, tutti i pesi di voto del sondaggio vengono impostati a `1` e tutti i pesi di voto che hai modificato per quel sondaggio vanno persi.

Se il tuo gruppo usa il voto ponderato per un processo consolidato, seleziona **Usa il voto ponderato** in un [modello di sondaggio](/en/user_manual/polls/poll_templates). I sondaggi avviati da quel modello usano il voto ponderato.

![L'impostazione Usa il voto ponderato in un sondaggio](poll-setting.png)

Il voto ponderato funziona con questi tipi di sondaggio: [Proposta](/en/user_manual/polls/proposals), [Scegliere](/en/user_manual/polls/choose), [Punto](/en/user_manual/polls/score), [Assegnare](/en/user_manual/polls/allocate) e [Rango](/en/user_manual/polls/rank).

Non puoi usare il voto ponderato e la [votazione anonima](/en/user_manual/polls/anonymous_voting) nello stesso sondaggio.

Per modificare il peso di voto di un elettore, seleziona **Gestisci gli elettori**, poi seleziona il peso di voto accanto al suo nome. Per modificarlo per tutti, seleziona **Imposta tutti i pesi di voto**. Puoi copiare dal gruppo il peso di voto di ogni membro oppure assegnare a tutti lo stesso valore. Agli elettori che non sono membri del gruppo viene assegnato un peso di voto di `1`.

![Il pulsante Gestisci gli elettori in un sondaggio](poll-manage-voters.png)

![Elettori in un sondaggio con pesi di voto individuali](poll-voter-weights.png)

<!-- translation-section: results -->

## Risultati

I risultati mostrano i totali non ponderati e i totali ponderati affiancati:

- I sondaggi Proposta e Scegliere mostrano **Voti** e **Voti ponderati**.
- I sondaggi Punto, Assegnare e Rango mostrano **Punti** e **Punti ponderati**.

Il grafico mostra il risultato ponderato. Seleziona l'intestazione di una colonna per visualizzare nel grafico i dati di quella colonna. Il conteggio degli aventi diritto al voto e il quorum si basano sul numero di persone, non sui pesi di voto. Chiunque possa vedere i voti può vedere il peso di voto di ogni elettore.

![Il risultato di una proposta con voti e voti ponderati](weighted-proposal-result.png)
