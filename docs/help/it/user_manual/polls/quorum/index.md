---
title: Quorum
source_revision: c6076258c3438c0dd6dc8fbf1fc0b0df47c0aeb5
source_file: docs/en/user_manual/polls/quorum/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: 0bf465006210877b
  example-scenario: 6596ad44e1c046b4
generated:
  introduction: 6dce789b0e44e03a
  example-scenario: a0e543de40d51b97
title_source: 18ed8b6c5ab90343
title_generated: 18ed8b6c5ab90343
---

<!-- translation-section: introduction -->

# Quorum

Il quorum è la percentuale minima di elettori aventi diritto che devono partecipare affinché un sondaggio sia valido. Usalo quando il tuo processo di governance richiede un determinato livello di partecipazione.

Quando crei un sondaggio, apri **Altre impostazioni** e inserisci la percentuale richiesta in **Quorum di partecipazione**. Lascia il campo vuoto quando non è richiesto un quorum.

![L'impostazione Quorum con un quorum di partecipazione del 60 percento](./quorum-section.png)

Puoi anche impostare un quorum in un [modello di sondaggio](/en/user_manual/polls/poll_templates/) affinché i sondaggi creati da quel modello lo utilizzino per impostazione predefinita.

<!-- translation-section: example-scenario -->

## Scenario di esempio

La cooperativa Oatmilk sta discutendo una sperimentazione di sei settimane con bottiglie a rendere. La discussione è arrivata al punto in cui la cooperativa deve approvare il budget per la sperimentazione.

Jamie seleziona **Inizia una votazione**, sceglie il modello di proposta **Consenso** e compila il titolo, i dettagli, le opzioni, la durata e le impostazioni degli elettori.

![Il titolo, i dettagli, le opzioni, la durata e le impostazioni degli elettori della proposta](proposal-options.png)

Jamie limita il voto alle cinque persone responsabili del budget per la sperimentazione.

La cooperativa richiede una partecipazione del 60 percento per le decisioni importanti, quindi Jamie inserisce **60** nel campo del quorum di partecipazione e avvia la proposta.

Prima che qualcuno voti, il pannello dei risultati mostra che il quorum non è stato raggiunto.

![Nessun voto espresso e quorum del 60 percento non ancora raggiunto](pie-chart-0.png)

Jamie vota Accordo e Samira vota Disaccordo. Il grafico si aggiorna, ma due elettori aventi diritto su cinque rappresentano solo il 40 percento di partecipazione, quindi il quorum non è ancora raggiunto.

![Due voti espressi su cinque e quorum non ancora raggiunto](pie-chart-40.png)

Alex vota poi Accordo. Tre elettori aventi diritto su cinque hanno partecipato, raggiungendo il quorum del 60 percento. Il requisito ora mostra un segno di spunta verde. Jamie può chiudere il sondaggio in anticipo o aspettare gli elettori rimanenti.

![Tre voti espressi su cinque e quorum del 60 percento raggiunto](pie-chart-60.png)
