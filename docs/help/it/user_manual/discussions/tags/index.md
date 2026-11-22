---
title: Etichette di categoria
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/discussions/tags/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
sections:
  introduction: bf6ecd043c19cd78
  apply-tags: dfa06440d6c97396
  create-tags: 97aa7a1a0f420951
  edit-tags: c9978a1615026863
  edit-tag-in-thread-or-poll: b71467aa1248d110
  template-tags: 3ddcc6c204aa843f
  tag-contributions: b42bdd723f9d5ddc
  find-tagged-contributions: 98ec0cbfdec75f7f
  global-search: 5a7777699988e006
generated:
  introduction: aecfe1abf4e661c9
  apply-tags: c71f4f84706ffddf
  create-tags: c6d4c1db3efb040a
  edit-tags: 4e7648b4e15bb49c
  edit-tag-in-thread-or-poll: 1fe5ef9c6eda6223
  template-tags: 0a0643d35ddbb413
  tag-contributions: 997036bd2a640f13
  find-tagged-contributions: 78a2b4c88235b70f
  global-search: 2ac60219b2647eaa
title_source: c86f6830bf302394
title_generated: 8b48a1d5453587c7
---

<!-- translation-section: introduction -->

# Tag di categoria

I tag di categoria ti aiutano a trovare discussioni, sondaggi, conclusioni e commenti su un argomento o un ambito di lavoro.

I tag appartengono all'intera organizzazione. Un tag creato in un gruppo principale è condiviso con i suoi sottogruppi, così puoi seguire attività correlate tra i gruppi. Loomio elenca i tag in ordine alfabetico con un punto colorato accanto a ciascun nome.

Nella pagina del tuo gruppo, seleziona **Etichette** sopra l'elenco delle conversazioni e scegli un tag per mostrare le conversazioni che contengono almeno un elemento con quel tag. Digita nel campo di filtro per cercare in un elenco lungo.

![](tags_view.png)

<!-- translation-section: apply-tags -->

## Applica tag

Puoi applicare tag alle tue discussioni, ai tuoi sondaggi, alle tue conclusioni e ai tuoi commenti. Gli amministratori del gruppo, gli amministratori della conversazione e le persone autorizzate a modificare il contesto della discussione possono applicare tag a qualsiasi elemento in una conversazione non bloccata. Nelle conversazioni dirette, tutti i partecipanti possono applicare tag a qualsiasi elemento.

Quando avvii una conversazione o un sondaggio, seleziona il campo **Etichette** e scegli uno o più tag.

![](tags_add_new.png)

Inizia a digitare per filtrare l'elenco. Seleziona di nuovo un tag, oppure seleziona **×** sul tag, per rimuoverlo.

<!-- translation-section: create-tags -->

## Crea tag

Chi può creare tag dipende dai ruoli e dai permessi nel gruppo:

- Gli **amministratori del gruppo principale** possono sempre creare tag per il gruppo principale e i suoi sottogruppi.
- Gli **amministratori dei sottogruppi** possono creare tag quando li applicano ai contenuti del proprio sottogruppo.
- I **Membri del gruppo** che possono applicare tag ai contenuti possono anche creare tag quando **I membri possono creare tag** è attivo (per impostazione predefinita). Se un amministratore del gruppo disattiva questo permesso, i membri possono usare solo i tag esistenti dell'organizzazione e i tag predefiniti dei modelli di quel gruppo.

Per creare un tag mentre avvii una conversazione o un sondaggio, digita il suo nome nel campo **Etichette** e premi Invio.

![crea un nuovo tag](tags_create_new.png)

![nuovo tag creato](tags_created_new.png)

Usa nomi brevi e riconoscibili, come Finanze, Governance, Imballaggi o Collaborazioni con i bar.

<!-- translation-section: template-tags -->

## Tag nei modelli

I modelli di discussione e di sondaggio memorizzano i nomi dei tag predefiniti. Chiunque possa creare o modificare un modello può cambiarne i tag predefiniti. Salvare un modello non aggiunge questi nomi all'elenco dei tag dell'organizzazione e rinominare o eliminare un tag dell'organizzazione non modifica i valori predefiniti dei modelli.

Quando qualcuno avvia una discussione o un sondaggio da un modello, Loomio applica i tag corrispondenti dell'organizzazione oppure ne crea di nuovi se l'autore ha il permesso:

- I **membri che possono creare tag** mantengono tutti i tag predefiniti del modello.
- I **membri senza il permesso di creare tag** mantengono i tag esistenti dell'organizzazione e tutti i tag predefiniti definiti dai modelli nel gruppo di destinazione. I nomi dei tag di un modello di un altro gruppo che non trovano corrispondenza vengono scartati.

<!-- translation-section: edit-tags -->

## Modifica tag

Solo gli amministratori del gruppo principale possono rinominare i tag, cambiarne il colore, unirli o eliminarli. Le modifiche si applicano in tutta l'organizzazione, compresi tutti i sottogruppi.

Nella pagina del gruppo, apri **Etichette** e seleziona **Modifica etichette**.

![modifica i tag di categoria](tags_edit_new.png)

Seleziona l'icona della matita accanto a un tag per modificarlo.

![modifica i tag di categoria](tags_edit_new_pencil.png)

Modifica il nome del tag o scegli un colore, poi seleziona **Salva**.

![modifica il colore del tag](tags_edit_name.png)

Per unire un tag a un altro, seleziona l'icona di unione accanto al tag e scegli quello da mantenere. Tutti gli elementi con il vecchio tag passano al tag scelto.

Per eliminare un tag, seleziona **Cancella** (o l'icona del cestino). Il tag viene rimosso da ogni discussione, sondaggio, conclusione e commento dell'organizzazione.

![elimina il tag](tags_delete.png)

<!-- translation-section: edit-tag-in-thread-or-poll -->

### Modifica i tag in una conversazione o in un sondaggio

Per cambiare i tag di una conversazione o di un sondaggio esistente, apri la conversazione o il sondaggio e seleziona il pulsante dei tag accanto ai tag attuali, vicino al titolo.

Seleziona i tag per aggiungerli o rimuoverli. Le modifiche vengono salvate immediatamente.

Il selettore elenca i tag usati nel gruppo attuale, i tag dell'organizzazione non utilizzati e i tag selezionati per l'elemento. In un'organizzazione con più gruppi, seleziona **Mostra i tag degli altri gruppi** per includere i tag usati solo in altri gruppi, oppure **Mostra i tag utilizzati in questo gruppo** per restringere di nuovo l'elenco.

![modifica i tag nella conversazione](tags_thread_edit.png)

<!-- translation-section: tag-contributions -->

## Applica tag ai contributi

Apri il menu con i tre punti (**⋯**) di un sondaggio, di una conclusione o di un commento e seleziona **Inserisci etichette**. Aggiungi o rimuovi tag nel selettore; le modifiche vengono salvate immediatamente. Quando un contributo ha dei tag, questi e il relativo pulsante appaiono a destra nella riga dell'autore.

I tag si applicano all'elemento che selezioni. Non è possibile applicare tag ai voti o alle schede di voto.

<!-- translation-section: find-tagged-contributions -->

## Trova contributi con tag

Quando un commento, un sondaggio o una conclusione all'interno di una conversazione ha un tag, nella barra laterale della conversazione appare una sezione **Etichette** (o nel pannello di navigazione sui dispositivi mobili).

Seleziona un tag per filtrare la conversazione e mostrare gli elementi corrispondenti e quelli a cui rispondono. Per tornare alla conversazione completa, seleziona **×** sulla barra del filtro, seleziona di nuovo il tag oppure seleziona **Pulisci** nella barra laterale.

![Tag nella barra laterale della conversazione](tags_thread_sidebar.png)

<!-- translation-section: global-search -->

## Cerca per tag

Apri **Ricerca** dalla barra di navigazione in alto e seleziona il tuo gruppo principale per visualizzare il menu dei tag. Scegli un tag per trovare discussioni, sondaggi, conclusioni e commenti con quel tag.

Lascia vuoto il campo di ricerca per esplorare i contenuti per tag, oppure inserisci parole chiave per cercare negli elementi con tag. Seleziona **Qualsiasi etichetta** per rimuovere il filtro.

![Selezione di un tag nella ricerca globale dopo aver scelto il gruppo principale](tags_global_search.png)
