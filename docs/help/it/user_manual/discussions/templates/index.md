---
title: Modelli di discussione
source_revision: c6076258c3438c0dd6dc8fbf1fc0b0df47c0aeb5
source_file: docs/en/user_manual/discussions/templates/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
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
  introduction: 99c0d868c6f66383
  how-templates-are-used: ce39b24829dd3e38
  choose-who-is-notified-by-default: ff962121c0f764c6
  template-settings: 9c268506d645904b
  example-bottle-trial-review: 589d545faca4e8ef
  create-a-template: 2c97964c3151dbca
  manage-the-template-list: dea7c70a5be3627b
  share-templates-between-groups: b7a681dd8e122175
  let-members-create-templates: 493aff5d847f1e60
  templates-for-non-members: fc85c9de3acd217d
  related: 7c622437a7751c12
title_source: 5ac608aa42806d13
title_generated: e69d3a4bcbeae260
---

<!-- translation-section: introduction -->

# Modelli di discussione

I modelli di discussione aiutano il tuo gruppo ad avviare le discussioni nello stesso modo ogni volta. Un modello può fornire un titolo, un contesto, tag e istruzioni per chi avvia la discussione. Imposta anche valori predefiniti, ad esempio se avvisare tutto il gruppo e quali sondaggi suggerire.

Ogni nuova discussione in un gruppo parte da un modello. Quando qualcuno seleziona **Inizia la discussione**, Loomio mostra i modelli del gruppo. Anche **Modello vuoto** è un modello, quindi il tuo gruppo può modificarne i valori predefiniti.

I modelli sono utili per i processi che il tuo gruppo ripete, come le revisioni dei progetti, i processi di consultazione, la preparazione delle riunioni, le decisioni sui finanziamenti o l'approvazione dei documenti. Chi avvia la discussione può comunque modificare tutto prima di avviarla.

<!-- translation-section: how-templates-are-used -->

## Come si usano i modelli

1. Un membro seleziona **Inizia la discussione** nella pagina del gruppo.
2. Loomio elenca i modelli visibili del gruppo. Ogni modello mostra il titolo e il sottotitolo.
3. Il membro seleziona un modello. Loomio apre il modulo per la nuova discussione, compilato con i contenuti del modello.
4. Le istruzioni del modello compaiono nella parte superiore del modulo come guida.
5. Il membro modifica il titolo, il contesto, i tag e l'elenco degli invitati, poi seleziona **Inizia la discussione**.

![](list.png)

La modifica di un modello riguarda solo le discussioni avviate dopo la modifica. Le discussioni già avviate da quel modello mantengono i propri contenuti e le proprie impostazioni.

<!-- translation-section: choose-who-is-notified-by-default -->

## Scegli chi riceve le notifiche per impostazione predefinita

L'impostazione **Invita** determina chi viene invitato per impostazione predefinita nel modulo per la nuova discussione. Ha due opzioni:

- **Tutti nel gruppo**: il gruppo compare nel campo **Invita** del modulo della discussione e ogni membro riceve una notifica quando la discussione viene avviata.
- **Nessuno**: il campo **Invita** è inizialmente vuoto. Nessuno riceve una notifica a meno che l'autore non aggiunga delle persone.

I modelli integrati di Loomio, incluso **Modello vuoto**, usano **Tutti nel gruppo**. Se il tuo gruppo non vuole che ogni nuova discussione invii una notifica a tutti i membri, modifica i modelli che il gruppo usa e imposta **Invita** su **Nessuno**.

![](use.png)

L'autore può sempre modificare l'elenco degli invitati prima di avviare la discussione. Può rimuovere il gruppo per non avvisare nessuno oppure aggiungere persone specifiche. Questa impostazione riguarda solo le notifiche. I membri del gruppo possono comunque trovare e leggere la discussione nel gruppo, qualunque opzione tu scelga.

Il gruppo viene aggiunto all'elenco degli invitati solo quando l'autore ha il permesso di avvisare tutto il gruppo. Gli amministratori possono sempre farlo. I membri possono farlo quando **I membri possono avvisare tutti i membri del gruppo** è abilitato nei permessi del gruppo.

<!-- translation-section: template-settings -->

## Impostazioni del modello

Gli amministratori del gruppo possono modificare un modello dal menu delle azioni accanto al modello nell'elenco. Il modulo contiene queste impostazioni:

![](form.png)

- **Titolo del modello**: il nome breve mostrato nell'elenco dei modelli.
- **Sottotitolo del modello**: una riga che spiega quando usare il modello.
- **Aiuto modello**: le istruzioni mostrate nella parte superiore del modulo per la nuova discussione. Usale per spiegare il processo e inserire link alle risorse. Non fanno parte della discussione.
- **Gruppo**: indica se il modello avvia una discussione nel gruppo o una discussione diretta. Una discussione diretta è visibile solo alle persone invitate.
- **Titolo predefinito**: un titolo inserito in ogni nuova discussione. L'autore può modificarlo.
- **Titolo di esempio**: un esempio mostrato nel campo del titolo quando è vuoto. Usalo quando un titolo predefinito non sarebbe adatto a tutte le discussioni.
- **Etichette**: i tag applicati a ogni nuova discussione. L'autore può rimuoverli.
- **Contesto**: il testo iniziale della discussione. Usa titoli, domande o link per guidare ciò che le persone scrivono.
- **Invita**: indica se invitare tutti nel gruppo per impostazione predefinita. Vedi [Scegli chi riceve le notifiche per impostazione predefinita](#choose-who-is-notified-by-default).
- **Modelli di sondaggio**: i sondaggi suggeriti per questo processo. Sono elencati nel modulo per la nuova discussione. Compaiono anche per primi quando qualcuno avvia un sondaggio nella discussione. Non si avviano automaticamente.
- **Consenti sondaggi simultanei**: indica se nella discussione può essere aperto più di un sondaggio contemporaneamente.
- **limite di lunghezza dei commenti**: una lunghezza massima facoltativa per i commenti.

Usa un titolo predefinito solo quando resterà appropriato. Altrimenti, scrivi un titolo di esempio che inviti l'autore a indicare la revisione, il periodo, il documento o la decisione specifici.

<!-- translation-section: example-bottle-trial-review -->

## Esempio: revisione della sperimentazione delle bottiglie a rendere

Oatmilk Cooperative esamina la propria sperimentazione delle bottiglie a rendere dopo ogni ciclo. Il suo modello si intitola "Revisione della sperimentazione delle bottiglie a rendere" e ha un titolo predefinito. Aggiunge il tag "Sperimentazione delle bottiglie a rendere". Il contesto chiede ai membri di leggere il rapporto settimanale e considerare i tassi di restituzione, i registri dei lavaggi, i riscontri dei bar e i costi di trasporto. Suggerisce una verifica delle opinioni seguita da Consenso.

Questo funziona come modello perché lo scopo e i dati da esaminare restano gli stessi a ogni ciclo. Cambiano solo le osservazioni e le decisioni.

<!-- translation-section: create-a-template -->

## Crea un modello

Gli amministratori del gruppo possono selezionare **Nuovo modello** dall'elenco dei modelli. Scegli un esempio dalla galleria di Loomio oppure parti da un modello vuoto, poi adattalo e salvalo.

Puoi cercare nella galleria o filtrarla. Un esempio viene aggiunto al tuo gruppo solo quando lo salvi.

<!-- translation-section: manage-the-template-list -->

## Gestisci l'elenco dei modelli

Quando viene creato un gruppo, Loomio aggiunge una serie di modelli adatti al tipo di gruppo. All'inizio sono visibili solo **Modello vuoto** e **Discussione pratica**. Gli altri sono nascosti e gli amministratori possono renderli visibili.

Gli amministratori del gruppo possono usare il menu delle azioni accanto a un modello per:

- modificarne i contenuti e le impostazioni;
- nasconderlo dall'elenco dei modelli;
- renderlo visibile da **Modelli nascosti**;
- cambiare l'ordine dei modelli visibili;
- esportarlo come file JSON; oppure
- eliminarlo.

Nascondere un modello lo conserva per un uso successivo. Eliminare un modello non elimina le discussioni avviate da quel modello.

<!-- translation-section: share-templates-between-groups -->

## Condividi i modelli tra gruppi

Seleziona **Esporta in formato JSON** nel menu delle azioni di un modello per scaricarlo come file. Per usarlo in un altro gruppo, seleziona **Nuovo modello**, poi **Importa JSON**. Il modulo si apre con i contenuti importati, così puoi verificarli prima di salvare.

I link ai modelli di sondaggio personalizzati non sono inclusi nel file. Esporta e importa quei modelli di sondaggio separatamente.

<!-- translation-section: let-members-create-templates -->

## Consenti ai membri di creare modelli

Per impostazione predefinita, solo gli amministratori del gruppo possono creare e modificare i modelli. Un amministratore può abilitare **I membri possono creare modelli** in **Impostazioni del gruppo** → **Permessi**.

Quando questa impostazione è abilitata, i membri possono creare modelli di discussione e di sondaggio e modificare quelli che hanno creato. Gli amministratori possono modificare tutti i modelli del gruppo. Il modello di un membro compare nell'elenco dei modelli del gruppo appena viene salvato, quindi concorda con il gruppo come nominare e verificare i modelli prima di abilitare questo permesso.

<!-- translation-section: templates-for-non-members -->

## Modelli per i non membri

Se **Anche i non membri possono avviare discussioni** è abilitato, le persone esterne al gruppo scelgono dallo stesso elenco di modelli. Il loro modulo della discussione non invita mai il gruppo per impostazione predefinita. Vedi [Raccogli contributi privati](/en/user_manual/discussions/private_submissions).

<!-- translation-section: related -->

## Pagine correlate

- [Modelli di sondaggio](/en/user_manual/polls/poll_templates)
