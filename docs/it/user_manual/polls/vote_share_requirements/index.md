---
title: Requisiti di quota di voto
source_revision: 9c60c42fc739483fa23f15d9f34a1e9245518092
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
  introduction: af319a773f26a490
  eligible-voters-and-votes-cast: 2614cf490c66e354
  different-vote-share-requirements: eec4a5ba8242b195
  detailed-example: 1379438e7a2c866e
title_source: a654891ca817844e
title_generated: d852e35efaa49f9a
---

<!-- translation-section: introduction -->

# Requisiti di quota di voto

Imposta un requisito di quota di voto per un'opzione quando, per essere approvata, una proposta deve ottenere una determinata percentuale di sostegno o non superare una determinata percentuale di opposizione.

Puoi combinare i requisiti di quota di voto con un [quorum](/en/user_manual/polls/quorum/) per richiedere sia una partecipazione sufficiente sia una determinata distribuzione dei voti.

Nel modulo della proposta, seleziona l'icona di modifica accanto a un'opzione.

![L'icona di modifica accanto all'opzione Favorevole](edit-highlight-on-option.png)

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

Impostare un'opzione su **Non più di 0%** è una pratica comune. Significa che la proposta non può essere approvata se qualcuno sceglie quell'opzione. Usa questa impostazione per **Blocco**, così un singolo voto di blocco impedisce l'approvazione della proposta.

Puoi anche aggiungere requisiti a un [modello di sondaggio](/en/user_manual/polls/poll_templates/), così le nuove proposte create dal modello li useranno per impostazione predefinita.

<!-- translation-section: detailed-example -->

## Esempio dettagliato

La cooperativa Oatmilk sta decidendo se avviare una prova di sei settimane con bottiglie a rendere. Cinque persone hanno diritto di voto.

Il processo della cooperativa richiede che almeno il 75% degli elettori aventi diritto sia favorevole. Jamie modifica l'opzione **Favorevole** della proposta, attiva il relativo requisito di quota di voto e lo imposta su **Almeno il 75% degli Elettori aventi diritto**.

![L'opzione Favorevole richiede il sostegno di almeno il 75% degli elettori aventi diritto](./agree-vote-option.png)

Jamie imposta anche un quorum del 60%. Jamie e Samira votano a favore. Tutti i voti espressi sostengono la proposta, ma rappresentano solo il 40% degli elettori aventi diritto. Nessuno dei due requisiti è quindi soddisfatto.

![Due persone su cinque hanno votato a favore e nessuno dei due requisiti è soddisfatto](./first-vote-breakdown.png)

Poi Alex e Morgan votano a favore, mentre Taylor vota contro. Tutte e cinque le persone hanno votato, raggiungendo il quorum, e quattro elettori aventi diritto su cinque sono favorevoli. Il sostegno dell'80% supera il requisito di quota di voto del 75%, quindi entrambi i requisiti mostrano un segno di spunta verde.

![Tutte e cinque le persone hanno votato ed entrambi i requisiti sono soddisfatti](./final-vote-breakdown.png)
