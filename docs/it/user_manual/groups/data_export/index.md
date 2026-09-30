---
title: Esportazione dei dati
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/groups/data_export/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-29'
sections:
  introduction: 5e29f67f9a2084ec
  export-data: 58b5e1d4e6f0b917
  export-group-data-as-csv: 53286ec33e7300d6
  export-group-data-as-html: 101671937dcd6f36
  export-group-data-as-json: 4ec883363fb166ee
  print-thread-to-pdf: 39c48383953f9fd5
  import-your-group-data-on-another-loomio-server: 910ee8af48049e82
generated:
  introduction: b911ede0f83d3e31
  export-data: 18bc6ba67f7b5064
  export-group-data-as-csv: d8d1382fbef8d89f
  export-group-data-as-html: fb231bdb79659808
  export-group-data-as-json: fbc65e666e712389
  print-thread-to-pdf: b2a47b98eb9cdcad
  import-your-group-data-on-another-loomio-server: dad9a9d2d9d3accc
title_source: 29049648f87b87f5
title_generated: ea7bba9669375d58
---

<!-- translation-section: introduction -->

# Backup o esportazione dei dati del gruppo

Con la funzione di esportazione dei dati del gruppo puoi:

- Scaricare un file con i dati dei membri per verificare le appartenenze al gruppo.
- Scaricare i contenuti del gruppo, compresi i testi delle discussioni e dei sondaggi, per archiviarli o analizzarli.
- Aprire i risultati dei sondaggi in un foglio di calcolo o con un linguaggio di scripting.
- [Stampare o salvare in PDF una discussione o un sondaggio per archiviarli.](#print-thread-to-pdf)
- Trasferire il gruppo, con tutti gli utenti, le discussioni, i sondaggi e i file, su un altro server Loomio.

Se vuoi passare dai server gestiti da Loomio [a un server gestito da te](https://github.com/loomio/loomio), puoi usare questa funzione.

Se gestisci un server Loomio e preferisci passare a un servizio gestito, Loomio offre hosting negli Stati Uniti, nell'Unione europea e in Australia. Per trasferire il tuo gruppo su uno di questi server, [contattaci](/contact).

[Contattaci](/contact) se vuoi trasferire il tuo gruppo dal servizio globale di Loomio su loomio.com a uno dei nostri servizi regionali: loomio.eu per l'Europa o loomio.nz per l'Australia e la Nuova Zelanda.

<!-- translation-section: export-data -->

## Esportare i dati

Apri il menu del gruppo facendo clic sui tre puntini e seleziona **Esporta i dati del gruppo**.

![Opzione Esporta i dati del gruppo nel menu di Oatmilk Cooperative](group_export_group_data.png)

<!-- translation-section: export-group-data-as-csv -->

### Esportare i dati del gruppo in formato CSV

*Per lavorare con i dati del gruppo in un foglio di calcolo, come MS Excel o Google Sheets.*

Loomio prepara il file CSV in background e ti invia un link per scaricarlo via email quando è pronto. Il link resta disponibile per una settimana.

<!-- translation-section: export-group-data-as-html -->

### Esportare i dati del gruppo in formato HTML

*Per conservare i dati in un archivio.*

Loomio prepara il file HTML in background e ti invia un link per scaricarlo via email quando è pronto. Il link resta disponibile per una settimana.

<!-- translation-section: export-group-data-as-json -->

### Esportare i dati del gruppo in formato JSON

*Per trasferire i dati del gruppo su un'istanza Loomio ospitata da te.*

Per esportare un gruppo devi esserne un amministratore. L'esportazione JSON include:

- Il gruppo, i suoi membri e le richieste di adesione
- Discussioni, commenti, reazioni, tag, modelli, notifiche e record correlati dei gruppi inclusi
- Sondaggi, opzioni, voti e conclusioni; un sondaggio anonimo viene incluso solo dopo la chiusura
- I sottogruppi di cui fai parte
- I sottogruppi aperti e chiusi quando esporti il gruppo principale come suo amministratore, anche se non fai parte di quei sottogruppi
- I riferimenti ai file e alle immagini allegati ai contenuti inclusi

L'esportazione JSON non include:

- I sottogruppi segreti di cui non fai parte, compresi i loro membri e contenuti
- I sottogruppi in attesa di eliminazione
- I sondaggi anonimi non ancora chiusi
- Le discussioni dirette e i sondaggi che non appartengono al gruppo

Riceverai a breve un'email con un link per scaricare il file JSON.

<!-- translation-section: print-thread-to-pdf -->

## Stampare una discussione in PDF

Puoi estrarre una copia di una discussione per conservarla in un archivio separato.

La funzione **Stampa** conserva tutti i commenti, i sondaggi, i voti, le conclusioni e la formattazione della discussione.

Nel menu della discussione, fai clic sui tre puntini (⋯) e scegli **Stampa**. Loomio genera una pagina HTML che puoi stampare o «salvare come PDF» con la funzione di stampa del browser.

Puoi copiare la pagina e incollarla in un editor di documenti, in un file o in un archivio di dati.

![Opzione Stampa per la discussione sulle bottiglie a rendere](discussion_print_discussion.png#width-90)

<!-- translation-section: import-your-group-data-on-another-loomio-server -->

## Importare i dati del gruppo su un altro server Loomio

Per le istruzioni su come configurare un server Loomio, visita: https://github.com/loomio/loomio

Se ospiti una tua installazione di Loomio e vuoi importare i dati esportati:

Copia il file .json nella cartella `import` dell'istanza del container:

`scp your-group-data.json username@some-domain.org:loomio-deploy/import`

Accedi alla console Rails in esecuzione:

`docker exec -ti loomio-app rails console`

Richiama il servizio:

`GroupExportService.import('/import/your-group-data.json')`
