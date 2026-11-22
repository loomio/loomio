---
sections:
  introduction: 566ce8dda668a638
  set-members-vote-weights: 2a3d29ebb9840017
  use-weighted-voting-in-a-poll: feddef738da4567d
  results: ab86e178359702a0
generated:
  introduction: 3e93dcac18860419
  set-members-vote-weights: 222fa7b354fd7f17
  use-weighted-voting-in-a-poll: 9cc9f9005c5efa9a
  results: 39bd55b243a08583
title: Voto ponderato
title_source: 0b971991dfcacbab
title_generated: bf17af91b8f4e433
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/polls/weighted_voting/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
needs_review:
  use-weighted-voting-in-a-poll: use "Ripartizione" instead of "Assegnare" for "Allocate"
---

<!-- translation-section: introduction -->

# Voto ponderato

Il voto ponderato permette ad alcuni voti di contare più di altri assegnando a ogni elettore un peso del voto. Per esempio:

- Una comunità abitativa assegna un voto a ogni proprietà. Un membro che rappresenta tre proprietà ha un peso del voto di `3`.
- Una cooperativa di lavoratori concede il diritto di voto dopo un periodo prestabilito di appartenenza alla cooperativa. I membri più recenti ricevono un peso del voto di `0`, così possono partecipare alla discussione e provare a votare senza influire sul risultato.
- Un'azienda assegna agli azionisti voti in proporzione alla loro quota di partecipazione. Chi possiede il 12,5% delle azioni ha un peso del voto di `12.5`.

<!-- translation-section: set-members-vote-weights -->

## Imposta i pesi di voto dei membri

Un amministratore del gruppo può aprire la pagina **Membri** del gruppo e selezionare **Modifica i pesi di voto**. Inserisci i pesi di voto (`0` o superiori, con un massimo di tre cifre decimali) e seleziona **Salva i pesi di voto**. Puoi cercare per nome o email per trovare una persona, oppure selezionare **Imposta tutti i pesi di voto** per assegnare lo stesso peso del voto a ogni membro.

![Pesi di voto dei membri del gruppo](member-weights.png)

Il peso del voto di un membro viene copiato in ogni sondaggio quando il membro viene aggiunto. Modificarlo in seguito non influisce sui sondaggi esistenti.

<!-- translation-section: use-weighted-voting-in-a-poll -->

## Usa il voto ponderato in un sondaggio

Apri **Altre impostazioni** nel modulo del sondaggio e seleziona **Usa il voto ponderato**. Puoi attivare o disattivare il voto ponderato dopo l'apertura della votazione. Disattivandolo, tutti i pesi di voto nel sondaggio vengono reimpostati a `1` e tutti i pesi personalizzati per quel sondaggio vengono persi.

Se il tuo gruppo usa il voto ponderato per un processo regolare, attiva **Usa il voto ponderato** in un [modello di sondaggio](/en/user_manual/polls/poll_templates). I sondaggi avviati da quel modello useranno il voto ponderato per impostazione predefinita.

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

Il grafico mostra il risultato ponderato. Seleziona l'intestazione di una colonna per visualizzare nel grafico i dati di quella colonna. Chiunque possa vedere i voti può vedere il peso del voto di ogni elettore.

Nei sondaggi Proposta e Scelta, **Non ha votato** mostra il numero di elettori che non hanno ancora votato nella colonna **Voti** e il loro peso del voto complessivo nella colonna **Voti ponderati**. Queste colonne e **% del peso dei voti aventi diritto** includono nel grafico chi non ha votato. **% del peso dei voti espressi** lascia vuota la voce **Non ha votato** e la esclude dal grafico.

I pesi di voto si applicano anche al [quorum](/en/user_manual/polls/quorum) e ai [requisiti sulla quota di voti](/en/user_manual/polls/vote_share_requirements).

Nell'esempio qui sotto, Jamie vota **Accordo** con peso `2`. Tre persone votano **Disaccordo**, con pesi `1`, `0` e `0`. Due persone, con pesi `2` e `1`, non hanno votato.

Accordo ha uno dei quattro voti espressi, ma due terzi del peso dei voti espressi. Ha partecipato metà del peso dei voti aventi diritto, quindi il quorum del 60 percento non è stato raggiunto.

![Il risultato di una proposta con voti e voti ponderati](weighted-proposal-result.png)
