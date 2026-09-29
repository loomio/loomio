---
title: Requisiti di quota di voto
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/polls/vote_share_requirements/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-29'
sections:
  introduction: c97281f29d615dea
  eligible-voters-and-votes-cast: 930bbc475f734396
  different-vote-share-requirements: 0d25794ec996d42c
  detailed-example: dc765c43a22a28a1
generated:
  introduction: 7431a9b63ebadfa3
  eligible-voters-and-votes-cast: 2614cf490c66e354
  different-vote-share-requirements: 02b5dccffc043771
  detailed-example: 85ebc4da9cc3ce5c
title_source: a654891ca817844e
title_generated: d852e35efaa49f9a
---

<!-- translation-section: introduction -->

# Requisiti di quota di voto

Imposta un requisito di quota di voto per un'opzione quando, per essere approvata, una proposta deve ottenere una determinata percentuale di sostegno o non superare una determinata percentuale di opposizione.

Puoi combinare i requisiti di quota di voto con un [quorum](/en/user_manual/polls/quorum/) per richiedere sia una partecipazione sufficiente sia una determinata distribuzione dei voti.

Quando crei una proposta, seleziona l'icona di modifica accanto a un'opzione.

![L'icona di modifica accanto all'opzione Consenso](edit-highlight-on-option.png)

<!-- translation-section: eligible-voters-and-votes-cast -->

## Elettori aventi diritto e voti espressi

La percentuale può essere calcolata in base ai **Voti espressi** o agli **Elettori aventi diritto**.

![Scelta tra voti espressi ed elettori aventi diritto per il requisito di quota di voto](./eligible-vs-cast.png)

**Elettori aventi diritto** indica tutte le persone che possono votare sulla proposta. **Voti espressi** indica solo i voti già inviati.

Un requisito del 75% di voti favorevoli tra gli elettori aventi diritto può essere soddisfatto solo se almeno il 75% di tutti gli aventi diritto vota per quell'opzione.

Un requisito del 60% di voti favorevoli tra i voti espressi può essere soddisfatto se il 60% dei voti inviati sostiene l'opzione, indipendentemente dalla partecipazione complessiva. Aggiungi un quorum se il tuo processo richiede anche una partecipazione minima.

<!-- translation-section: different-vote-share-requirements -->

## Requisiti di quota di voto diversi

Puoi impostare requisiti per più opzioni della stessa proposta. Per esempio:

- I voti favorevoli devono rappresentare almeno il 75% degli elettori aventi diritto
- Le astensioni non devono superare il 30% dei voti espressi
- I voti di blocco non devono superare lo 0% dei voti espressi

Puoi anche aggiungere requisiti a un [modello di sondaggio](/en/user_manual/polls/poll_templates/), così le nuove proposte create dal modello li useranno per impostazione predefinita.

<!-- translation-section: detailed-example -->

## Esempio dettagliato

La cooperativa Oatmilk sta decidendo se approvare il budget per una prova di sei settimane con bottiglie a rendere. Cinque persone hanno diritto di voto.

Jamie usa il modello di proposta **Consenso**, modifica l'opzione Consenso e attiva il relativo requisito di quota di voto.

Il processo della cooperativa richiede il sostegno di almeno il 75% degli elettori aventi diritto. Jamie imposta il requisito su **Almeno il 75% degli Elettori aventi diritto**.

![L'opzione Consenso richiede il sostegno di almeno il 75% degli elettori aventi diritto](./consent-vote-option.png)

Jamie imposta anche un quorum del 60%. Jamie e Samira votano a favore. Tutti i voti espressi sostengono la proposta, ma rappresentano solo il 40% degli elettori aventi diritto. Nessuno dei due requisiti è quindi soddisfatto.

![Due persone su cinque hanno votato a favore e nessuno dei due requisiti è soddisfatto](./first-vote-breakdown.png)

Poi Alex e Morgan votano a favore, mentre Taylor vota contro. Tutte e cinque le persone hanno votato, raggiungendo il quorum, e quattro elettori aventi diritto su cinque sono favorevoli. Il sostegno dell'80% supera il requisito di quota di voto del 75%, quindi entrambi i requisiti mostrano un segno di spunta verde.

![Tutte e cinque le persone hanno votato ed entrambi i requisiti sono soddisfatti](./final-vote-breakdown.png)
