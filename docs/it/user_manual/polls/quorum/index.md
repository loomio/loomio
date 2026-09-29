---
title: Quorum
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/polls/quorum/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-29'
sections:
  introduction: 0bf465006210877b
  example-scenario: 6596ad44e1c046b4
generated:
  introduction: 01db52dc371a0ad2
  example-scenario: b9f91c3bb60d1665
title_source: 18ed8b6c5ab90343
title_generated: 18ed8b6c5ab90343
---

<!-- translation-section: introduction -->

# Quorum

Il quorum è la percentuale minima di persone aventi diritto al voto che devono partecipare perché un sondaggio sia valido. Usalo quando il processo decisionale del tuo gruppo richiede un determinato livello di partecipazione.

Quando crei un sondaggio, apri **Altre impostazioni** e inserisci la percentuale richiesta in **Quorum di partecipazione**. Lascia il campo vuoto se non è richiesto un quorum.

![L'impostazione Quorum con un quorum di partecipazione del 60 percento](./quorum-section.png)

Puoi anche impostare un quorum in un [modello di sondaggio](/en/user_manual/polls/poll_templates/), così i sondaggi creati da quel modello lo useranno per impostazione predefinita.

<!-- translation-section: example-scenario -->

## Esempio

La cooperativa Oatmilk sta discutendo una prova di sei settimane con bottiglie a rendere. La discussione è arrivata al punto in cui la cooperativa deve approvare il budget della prova.

Jamie seleziona **Inizia una votazione**, sceglie il modello di proposta **Consenso** e compila titolo, dettagli, opzioni, durata e impostazioni degli aventi diritto al voto.

![Il titolo, i dettagli, le opzioni, la durata e le impostazioni degli aventi diritto al voto della proposta](proposal-options.png)

Jamie limita la votazione alle cinque persone responsabili del budget della prova.

La cooperativa richiede una partecipazione del 60 percento per le decisioni importanti. Jamie inserisce quindi **60** nel campo del quorum di partecipazione e avvia la proposta.

Prima che qualcuno voti, il riquadro dei risultati indica che il quorum non è stato raggiunto.

![Nessun voto espresso e quorum del 60 percento non ancora raggiunto](pie-chart-0.png)

Jamie è d'accordo e Samira non è d'accordo. Il grafico si aggiorna, ma due persone su cinque aventi diritto al voto corrispondono solo al 40 percento di partecipazione. Il quorum non è ancora raggiunto.

![Due voti espressi su cinque e quorum non ancora raggiunto](pie-chart-40.png)

Anche Alex è d'accordo. Hanno partecipato tre persone su cinque aventi diritto al voto, raggiungendo il quorum del 60 percento. Accanto al requisito compare ora un segno di spunta verde. Jamie può chiudere il sondaggio in anticipo o attendere le persone che devono ancora votare.

![Tre voti espressi su cinque e quorum del 60 percento raggiunto](pie-chart-60.png)
