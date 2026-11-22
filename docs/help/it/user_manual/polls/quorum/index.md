---
title: Quorum
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/polls/quorum/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
sections:
  introduction: 885a154beca10592
  example-scenario: 2c4be2012a2bcba4
generated:
  introduction: 11719bf2e53ae120
  example-scenario: ec1dab9bbe2747b5
title_source: 18ed8b6c5ab90343
title_generated: 18ed8b6c5ab90343
---

<!-- translation-section: introduction -->

# Quorum

Il quorum è la percentuale minima di elettori aventi diritto che devono partecipare affinché un sondaggio possa essere approvato. Usalo quando il tuo processo decisionale richiede un livello minimo di partecipazione.

Con il [voto ponderato](/en/user_manual/polls/weighted_voting), il quorum si basa sui pesi di voto. Per esempio, Jamie ha un peso del voto di `2`, Samira di `1` e Alex di `1`. Se vota solo Jamie, ha partecipato la metà del peso totale dei voti degli elettori aventi diritto. Se vota anche Samira, la partecipazione raggiunge il 75 percento, soddisfacendo un quorum del 60 percento.

Quando crei un sondaggio, apri **Altre impostazioni** e inserisci la percentuale richiesta in **Quorum**. Lascia il campo vuoto quando non è richiesto un quorum.

![L'impostazione Quorum con un quorum di partecipazione del 60 percento](./quorum-section.png)

Puoi anche impostare un quorum in un [modello di sondaggio](/en/user_manual/polls/poll_templates/) affinché i sondaggi creati da quel modello lo utilizzino per impostazione predefinita.

Se un sondaggio si chiude senza raggiungere il quorum, Loomio mostra che il quorum non è stato raggiunto. Il sondaggio non viene prorogato né annullato automaticamente: un amministratore della conversazione può riaprire il sondaggio (se consentito) o condividere una conclusione che spieghi cosa succede dopo.

<!-- translation-section: example-scenario -->

## Scenario di esempio

La cooperativa Oatmilk sta discutendo una sperimentazione di sei settimane con bottiglie a rendere e deve approvare il budget per la sperimentazione.

Jamie seleziona **Inizia una votazione**, sceglie un modello di proposta e compila il titolo, i dettagli, le opzioni, la durata e le impostazioni degli elettori.

![Il titolo, i dettagli, le opzioni, la durata e le impostazioni degli elettori della proposta](proposal-options.png)

Jamie limita il voto alle cinque persone responsabili del budget per la sperimentazione. Poiché la cooperativa richiede una partecipazione del 60 percento per le decisioni importanti, Jamie inserisce **60** in **Quorum** e avvia la proposta.

Prima che qualcuno voti, il pannello dei risultati mostra che il quorum non è stato raggiunto.

![Nessun voto espresso e quorum del 60 percento non ancora raggiunto](pie-chart-0.png)

Jamie vota Accordo e Samira vota Disaccordo. Il grafico si aggiorna, ma due elettori aventi diritto su cinque rappresentano solo il 40 percento di partecipazione, quindi il quorum non è ancora raggiunto.

![Due voti espressi su cinque e quorum non ancora raggiunto](pie-chart-40.png)

Alex vota poi Accordo. Tre elettori aventi diritto su cinque hanno partecipato, raggiungendo il quorum del 60 percento. Il requisito ora mostra un segno di spunta verde. Jamie può chiudere il sondaggio in anticipo o aspettare gli elettori rimanenti.

![Tre voti espressi su cinque e quorum del 60 percento raggiunto](pie-chart-60.png)
