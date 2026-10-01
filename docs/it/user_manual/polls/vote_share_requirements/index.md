---
title: Requisiti di quota di voto
source_revision: c6076258c3438c0dd6dc8fbf1fc0b0df47c0aeb5
source_file: docs/en/user_manual/polls/vote_share_requirements/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: 57d7127721bebf93
  eligible-voters-and-votes-cast: 930bbc475f734396
  different-vote-share-requirements: cfdfd13a0a6a8b38
  detailed-example: 395dbccb0e6427fc
generated:
  introduction: 57968292811710c0
  eligible-voters-and-votes-cast: 2f1c6cf1b0195cbe
  different-vote-share-requirements: d31565d13080a9c9
  detailed-example: 298a7a8db2bc7b0a
title_source: a654891ca817844e
title_generated: d852e35efaa49f9a
---

<!-- translation-section: introduction -->

# Requisiti di quota di voto

Imposta un requisito di quota di voto su un'opzione quando, per essere approvata, una proposta deve ricevere una determinata percentuale di sostegno o rimanere al di sotto di una determinata percentuale di opposizione.

I requisiti di quota di voto possono essere combinati con un [quorum](/en/user_manual/polls/quorum/) per richiedere sia una partecipazione sufficiente sia una determinata distribuzione dei voti.

Nel modulo della proposta, seleziona l'icona di modifica accanto a un'opzione.

![L'icona di modifica accanto all'opzione Accordo](edit-highlight-on-option.png)

<!-- translation-section: eligible-voters-and-votes-cast -->

## Elettori aventi diritto e voti espressi

La percentuale può essere calcolata sui **Voti espressi** o sugli **Elettori aventi diritto**.

![Scelta tra voti espressi ed elettori aventi diritto come base per un requisito di quota di voto](./eligible-vs-cast.png)

**Elettori aventi diritto** indica tutte le persone che possono votare sulla proposta. **Voti espressi** indica solo i voti che sono stati inviati.

Un requisito di accordo del 75 percento degli elettori aventi diritto può essere soddisfatto solo quando almeno il 75 percento di tutti gli elettori aventi diritto vota per quell'opzione.

Un requisito di accordo del 60 percento dei voti espressi può essere soddisfatto quando il 60 percento dei voti inviati sostiene l'opzione, indipendentemente dalla partecipazione complessiva. Aggiungi un quorum quando il tuo processo richiede anche un livello minimo di partecipazione.

<!-- translation-section: different-vote-share-requirements -->

## Diversi requisiti di quota di voto

Una proposta può avere requisiti su più di un'opzione. Per esempio:

- Accordo deve raggiungere almeno il 75 percento degli elettori aventi diritto
- Astensione non deve superare il 30 percento dei voti espressi
- Blocco non deve superare lo 0 percento dei voti espressi

Impostare un'opzione su **Non più dello 0%** è una pratica comune. Significa che la proposta non può essere approvata se qualcuno sceglie quell'opzione. Usa questa impostazione su **Blocco** affinché un singolo blocco fermi la proposta.

Puoi anche aggiungere requisiti a un [modello di sondaggio](/en/user_manual/polls/poll_templates/) affinché le nuove proposte create dal modello li usino per impostazione predefinita.

<!-- translation-section: detailed-example -->

## Esempio dettagliato

La cooperativa Oatmilk sta decidendo se avviare una sperimentazione di sei settimane con bottiglie a rendere. Cinque persone hanno diritto di voto.

Il processo della cooperativa richiede che almeno il 75 percento degli elettori aventi diritto esprima accordo. Jamie modifica l'opzione **Favorevole** della proposta, attiva il relativo requisito di quota di voto e lo imposta su **Almeno il 75% degli Elettori aventi diritto**.

![L'opzione Accordo con un requisito di almeno il 75 percento degli elettori aventi diritto](./agree-vote-option.png)

Jamie imposta anche un quorum del 60 percento. Jamie e Samira votano Accordo. Tutti i voti inviati sostengono la proposta, ma rappresentano solo il 40 percento degli elettori aventi diritto, quindi nessuno dei due requisiti è stato soddisfatto.

![Due persone su cinque hanno votato Accordo e nessuno dei due requisiti è soddisfatto](./first-vote-breakdown.png)

Alex e Morgan votano poi Accordo, mentre Taylor vota Disaccordo. Tutte e cinque le persone hanno votato, raggiungendo il quorum, e quattro elettori aventi diritto su cinque hanno espresso accordo. L'accordo dell'80 percento supera il requisito di quota di voto del 75 percento, quindi entrambi i requisiti mostrano un segno di spunta verde.

![Tutte e cinque le persone hanno votato ed entrambi i requisiti sono soddisfatti](./final-vote-breakdown.png)
