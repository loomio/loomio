---
title: Modelli di discussione
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/discussions/templates/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-29'
sections:
  introduction: 9b2b30212a057b4b
  how-templates-are-used: 7d5681170fe9911e
  choose-who-is-notified-by-default: e9fe4c939442f514
  template-settings: 2e71090b3d149213
  example-bottle-trial-review: 20009020c0b68fdf
  create-a-template: 223eee427ebb52bb
  manage-the-template-list: 9a4957687be2b34d
  share-templates-between-groups: 2bff30bad2a0eb4a
  let-members-create-templates: 0cfd990ff48a1a09
  templates-for-non-members: ebaf610bf85e81a9
  related: 6f4cc2ccf8e709d3
generated:
  introduction: 79796b59073fbe4f
  how-templates-are-used: f9bd0dc8e31ccc96
  choose-who-is-notified-by-default: 8bd3109a6da79d11
  template-settings: becdcc112a116751
  example-bottle-trial-review: 98991340a8a5e1a7
  create-a-template: d40102df7aa6d589
  manage-the-template-list: d2fa1ab45f796aa3
  share-templates-between-groups: ad07d223d0e44936
  let-members-create-templates: 2d95a81637f3c725
  templates-for-non-members: 846589df85303ced
  related: 957759e9f2e102a2
title_source: 5ac608aa42806d13
title_generated: e69d3a4bcbeae260
---

<!-- translation-section: introduction -->

# Modelli di discussione

I modelli di discussione aiutano il tuo gruppo ad avviare le discussioni seguendo ogni volta lo stesso processo. Un modello può fornire un titolo, un contesto, etichette e istruzioni per chi avvia la discussione. Imposta anche valori predefiniti, per esempio se avvisare tutto il gruppo e quali sondaggi suggerire.

Ogni nuova discussione in un gruppo parte da un modello. Quando qualcuno seleziona **Inizia la discussione**, Loomio mostra i modelli del gruppo. Anche **Modello vuoto** è un modello, quindi il tuo gruppo può modificarne le impostazioni predefinite.

I modelli sono utili per i processi che il tuo gruppo ripete, come la valutazione di progetti, la richiesta di pareri, la preparazione di riunioni, le decisioni sui finanziamenti o l'approvazione di documenti. Chi avvia la discussione può comunque modificare tutto prima di avviarla.

<!-- translation-section: how-templates-are-used -->

## Come si usano i modelli

1. Un membro seleziona **Inizia la discussione** nella pagina del gruppo.
2. Loomio elenca i modelli visibili del gruppo. Ognuno mostra il proprio titolo e sottotitolo.
3. Il membro seleziona un modello. Loomio apre il modulo della nuova discussione, compilato con i contenuti del modello.
4. Le istruzioni del modello compaiono in cima al modulo.
5. Il membro modifica il titolo, il contesto, le etichette e l'elenco degli invitati, poi seleziona **Inizia la discussione**.

![](list.png)

Le modifiche a un modello si applicano solo alle discussioni avviate dopo la modifica. Le discussioni già avviate con quel modello conservano i propri contenuti e le proprie impostazioni.

<!-- translation-section: choose-who-is-notified-by-default -->

## Scegli chi riceve una notifica per impostazione predefinita

L'impostazione **Invita** determina chi viene invitato per impostazione predefinita nel modulo della nuova discussione. Ha due opzioni:

- **Tutti nel gruppo**: il gruppo compare nel campo **Invita** del modulo della discussione e ogni membro riceve una notifica quando la discussione viene avviata.
- **Nessuno**: il campo **Invita** è inizialmente vuoto. Nessuno riceve una notifica, a meno che l'autore non aggiunga delle persone.

I modelli inclusi in Loomio, compreso **Modello vuoto**, usano **Tutti nel gruppo**. Se il tuo gruppo non vuole avvisare tutti i membri per ogni nuova discussione, modifica i modelli che usa e imposta **Invita** su **Nessuno**.

![](use.png)

L'autore può sempre modificare l'elenco degli invitati prima di avviare la discussione. Può rimuovere il gruppo per non avvisare nessuno oppure aggiungere persone specifiche. Questa impostazione riguarda solo le notifiche. I membri del gruppo possono comunque trovare e leggere la discussione nel gruppo, qualunque opzione tu scelga.

Il gruppo viene aggiunto all'elenco degli invitati solo se l'autore ha il permesso di avvisare tutto il gruppo. Gli amministratori possono sempre farlo. I membri possono farlo quando **I membri possono avvisare tutti i membri del gruppo** è abilitato nei permessi del gruppo.

<!-- translation-section: template-settings -->

## Impostazioni del modello

Gli amministratori del gruppo possono modificare un modello dal menu delle azioni accanto al modello nell'elenco. Il modulo contiene queste impostazioni:

![](form.png)

- **Titolo del modello**: il nome breve mostrato nell'elenco dei modelli.
- **Sottotitolo del modello**: una riga che spiega quando usare il modello.
- **Aiuto modello**: le istruzioni mostrate in cima al modulo della nuova discussione. Usale per spiegare il processo e inserire link a risorse utili. Non fanno parte della discussione.
- **Gruppo**: indica se il modello avvia una discussione nel gruppo o una discussione diretta. Una discussione diretta è visibile solo alle persone invitate.
- **Titolo predefinito**: un titolo inserito in ogni nuova discussione. L'autore può modificarlo.
- **Titolo di esempio**: un esempio mostrato quando il campo del titolo è vuoto. Usalo se un titolo predefinito non sarebbe adatto a tutte le discussioni.
- **Etichette**: le etichette applicate a ogni nuova discussione. L'autore può rimuoverle.
- **Contesto**: il testo iniziale della discussione. Usa titoli, domande o link per aiutare le persone a scrivere i propri contributi.
- **Invita**: indica se invitare per impostazione predefinita tutti i membri del gruppo. Vedi [Scegli chi riceve una notifica per impostazione predefinita](#choose-who-is-notified-by-default).
- **Modelli di sondaggio**: i sondaggi suggeriti per questo processo. Sono elencati nel modulo della nuova discussione. Compaiono anche per primi quando qualcuno avvia un sondaggio nella discussione. Non si avviano automaticamente.
- **Consenti sondaggi simultanei**: indica se nella discussione può essere aperto più di un sondaggio alla volta.
- **limite di lunghezza dei commenti**: una lunghezza massima facoltativa per i commenti.

Usa un titolo predefinito solo se resterà appropriato. Altrimenti, scrivi un titolo di esempio che inviti l'autore a indicare la valutazione, il periodo, il documento o la decisione specifica.

<!-- translation-section: example-bottle-trial-review -->

## Esempio: valutazione della prova delle bottiglie

La Cooperativa Oatmilk valuta la prova delle bottiglie a rendere dopo ogni ciclo. Il suo modello si intitola "Valutazione della prova delle bottiglie" e ha un titolo predefinito. Aggiunge l'etichetta "Prova delle bottiglie". Il contesto chiede ai membri di leggere il rapporto settimanale e considerare i tassi di restituzione, i registri di lavaggio, i riscontri dei bar e i costi di trasporto. Suggerisce una verifica del parere del gruppo seguita da una decisione per consenso.

Questo processo si presta a un modello perché lo scopo e le informazioni da esaminare restano gli stessi a ogni ciclo. Cambiano solo le osservazioni e le decisioni.

<!-- translation-section: create-a-template -->

## Crea un modello

Gli amministratori del gruppo possono selezionare **Nuovo modello** dall'elenco dei modelli. Scegli un esempio dalla galleria di Loomio oppure parti da un modello vuoto, poi adattalo e salvalo.

Puoi cercare o filtrare i modelli nella galleria. Un esempio viene aggiunto al tuo gruppo solo quando lo salvi.

<!-- translation-section: manage-the-template-list -->

## Gestisci l'elenco dei modelli

Quando viene creato un gruppo, Loomio aggiunge una serie di modelli adatti al tipo di gruppo. All'inizio sono visibili solo **Modello vuoto** e **Discussione pratica**. Gli altri sono nascosti e gli amministratori possono renderli visibili.

Gli amministratori del gruppo possono usare il menu delle azioni accanto a un modello per:

- modificarne il contenuto e le impostazioni;
- nasconderlo dall'elenco dei modelli;
- renderlo visibile da **Modelli nascosti**;
- cambiare l'ordine dei modelli visibili;
- esportarlo come file JSON; oppure
- eliminarlo.

Se nascondi un modello, puoi usarlo di nuovo in seguito. Se elimini un modello, le discussioni avviate con quel modello non vengono eliminate.

<!-- translation-section: share-templates-between-groups -->

## Condividi i modelli tra gruppi

Seleziona **Esporta in formato JSON** nel menu delle azioni di un modello per scaricarlo come file. Per usarlo in un altro gruppo, seleziona **Nuovo modello**, poi **Importa JSON**. Il modulo si apre con il contenuto importato, così puoi controllarlo prima di salvarlo.

I collegamenti ai modelli di sondaggio personalizzati non sono inclusi nel file. Esporta e importa quei modelli di sondaggio separatamente.

<!-- translation-section: let-members-create-templates -->

## Consenti ai membri di creare modelli

Per impostazione predefinita, solo gli amministratori del gruppo possono creare e modificare i modelli. Un amministratore può abilitare **I membri possono creare modelli** in **Impostazioni del gruppo** → **Permessi**.

Quando questa opzione è abilitata, i membri possono creare modelli di discussione e di sondaggio e modificare quelli che hanno creato. Gli amministratori possono modificare tutti i modelli del gruppo. Il modello creato da un membro compare nell'elenco dei modelli del gruppo appena viene salvato. Concordate quindi come nominare e rivedere i modelli prima di abilitare questo permesso.

<!-- translation-section: templates-for-non-members -->

## Modelli per chi non è membro

Se **Anche i non membri possono avviare discussioni** è abilitato, le persone esterne al gruppo scelgono dallo stesso elenco di modelli. Il loro modulo di discussione non invita mai il gruppo per impostazione predefinita. Vedi [Raccogli contributi privati](/en/user_manual/discussions/private_submissions).

<!-- translation-section: related -->

## Argomenti correlati

- [Modelli di sondaggio](/en/user_manual/polls/poll_templates)
