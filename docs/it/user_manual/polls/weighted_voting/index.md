---
sections:
  introduction: 301b7440aa148d0b
  set-members-vote-weights: 47b8d7c9222794d8
  use-weighted-voting-in-a-poll: d8af319ed1e38e4d
  results: 3cd10f104ced0ed5
generated:
  introduction: 2ad4847eb880970e
  set-members-vote-weights: 3e6c4c6f54bb3dfb
  use-weighted-voting-in-a-poll: 8a7c5c7cac8a7b6a
  results: 8dd07bd976eda818
title: Voto ponderato
title_source: 0b971991dfcacbab
title_generated: bf17af91b8f4e433
source_revision: c6076258c3438c0dd6dc8fbf1fc0b0df47c0aeb5
source_file: docs/en/user_manual/polls/weighted_voting/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
needs_review:
  use-weighted-voting-in-a-poll: use "Ripartizione" instead of "Assegnare" for "Allocate"
---

<!-- translation-section: introduction -->

# Voto ponderato

Il voto ponderato permette ad alcuni voti di contare più di altri. Ogni elettore ha un peso del voto. Per esempio:

- Una comunità abitativa assegna un voto a ogni proprietà. Un membro che rappresenta tre proprietà ha un peso del voto di `3`.
- Il consiglio di amministrazione di una cooperativa prende la decisione, ma il personale operativo partecipa alla conversazione. I membri del consiglio hanno un peso del voto di `1`. Il personale operativo ha un peso del voto di `0`, quindi i suoi voti vengono registrati ma non modificano il risultato.
- Un'azienda assegna agli azionisti voti in proporzione alla loro quota di partecipazione. Chi possiede il 12,5% delle azioni ha un peso del voto di `12.5`.

<!-- translation-section: set-members-vote-weights -->

## Imposta i pesi di voto dei membri

Un amministratore del gruppo può aprire la pagina **Membri** del gruppo e selezionare **Modifica i pesi di voto**. Inserisci i pesi di voto e seleziona **Salva i pesi di voto**. I pesi di voto possono essere pari a `0` o superiori, con un massimo di tre cifre decimali. Cerca per nome o email per trovare una persona. Per assegnare lo stesso peso del voto a ogni membro, seleziona **Imposta tutti i pesi di voto**.

![Pesi di voto dei membri del gruppo](member-weights.png)

Il peso del voto di un membro viene copiato in ogni sondaggio a cui viene aggiunto. Modificarlo in seguito non modifica i sondaggi in cui è già stato copiato.

<!-- translation-section: use-weighted-voting-in-a-poll -->

## Usa il voto ponderato in un sondaggio

Seleziona **Usa il voto ponderato** nelle impostazioni avanzate del sondaggio. Puoi attivarlo o disattivarlo dopo l'apertura della votazione. Disattivandolo, tutti i pesi di voto nel sondaggio vengono impostati a `1` e le modifiche che hai apportato ai pesi di voto per quel sondaggio vengono perse.

Se il tuo gruppo usa il voto ponderato per un processo consolidato, seleziona **Usa il voto ponderato** in un [modello di sondaggio](/en/user_manual/polls/poll_templates). I sondaggi avviati da quel modello usano il voto ponderato.

![L'impostazione Usa il voto ponderato in un sondaggio](poll-setting.png)

Il voto ponderato funziona con questi tipi di sondaggio: [Proposta](/en/user_manual/polls/proposals), [Scelta](/en/user_manual/polls/choose), [Punteggio](/en/user_manual/polls/score), [Ripartizione](/en/user_manual/polls/allocate) e [Classifica](/en/user_manual/polls/rank).

Non puoi usare il voto ponderato e il [voto anonimo](/en/user_manual/polls/anonymous_voting) nello stesso sondaggio.

Per modificare il peso del voto di un elettore, seleziona **Gestisci gli elettori**, poi seleziona il peso del voto accanto al suo nome. Per modificare quello di tutti gli elettori, seleziona **Imposta tutti i pesi di voto**. Puoi copiare dal gruppo il peso del voto di ciascun membro oppure assegnare a tutti lo stesso valore. Gli elettori che non sono membri del gruppo ricevono un peso del voto di `1`.

![Il pulsante Gestisci gli elettori in un sondaggio](poll-manage-voters.png)

![Elettori in un sondaggio con pesi di voto individuali](poll-voter-weights.png)

<!-- translation-section: results -->

## Risultati

I risultati mostrano i totali non ponderati e i totali ponderati affiancati:

- I sondaggi Proposta e Scelta mostrano **Voti** e **Voti ponderati**.
- I sondaggi Punteggio, Ripartizione e Classifica mostrano **Punti** e **Punti ponderati**.

Il grafico mostra il risultato ponderato. Seleziona l'intestazione di una colonna per visualizzare nel grafico i dati di quella colonna. Il conteggio degli elettori aventi diritto e il quorum si basano sulle persone, non sui pesi di voto. Chiunque possa vedere i voti può vedere il peso del voto di ogni elettore.

![Il risultato di una proposta con voti e voti ponderati](weighted-proposal-result.png)
