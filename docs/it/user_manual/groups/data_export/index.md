---
title: Esportazione dei dati
source_revision: cd2e1e63e611688362e80009f50b8ed25025ba8b
source_file: docs/en/user_manual/groups/data_export/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-07'
sections:
  introduction: 5e29f67f9a2084ec
  export-data: 58b5e1d4e6f0b917
  export-group-data-as-csv: 53286ec33e7300d6
  export-group-data-as-html: 101671937dcd6f36
  export-group-data-as-json: aa310889d0854550
  print-thread-to-pdf: 39c48383953f9fd5
  import-your-group-data-on-another-loomio-server: 910ee8af48049e82
generated:
  introduction: 1f927b13e546ddfd
  export-data: 18c848f5ada44af5
  export-group-data-as-csv: 53a693d5950de0be
  export-group-data-as-html: 20e1f21d5c4dd6af
  export-group-data-as-json: 48bc3d9b70eb8dd9
  print-thread-to-pdf: 02d3680574342030
  import-your-group-data-on-another-loomio-server: 160c567e2e49c3b4
title_source: 29049648f87b87f5
title_generated: ea7bba9669375d58
---

<!-- translation-section: introduction -->

# Backup o esportazione dei dati del gruppo

Con la funzione di esportazione dei dati del gruppo puoi:

- Scaricare un file con i dati dei membri per verificare chi appartiene al gruppo.
- Scaricare i contenuti del tuo gruppo, compresi i testi delle conversazioni e dei sondaggi, per archiviarli o analizzarli.
- Aprire i risultati dei sondaggi in un foglio di calcolo o in un linguaggio di scripting.
- [Stampare o salvare in PDF una conversazione o un sondaggio per archiviarli.](#print-thread-to-pdf)
- Trasferire il tuo gruppo, compresi tutti gli utenti, le conversazioni, i sondaggi e i file, su un altro server Loomio.

Se vuoi passare dai server gestiti da Loomio [a un tuo server](https://github.com/loomio/loomio), puoi usare questa funzione.

Se gestisci un tuo server Loomio e preferisci smettere di farlo, Loomio offre un servizio di hosting gestito negli Stati Uniti, nell'Unione europea e in Australia. Se vuoi trasferire il tuo gruppo su uno di questi server, [contattaci](/contact).

[Contattaci](/contact) se vuoi trasferire il tuo gruppo Loomio dal servizio globale ospitato su loomio.com a uno dei nostri servizi regionali: loomio.eu per l'Europa o loomio.nz per l'Australia e la Nuova Zelanda.

<!-- translation-section: export-data -->

## Esporta i dati

Apri il menu a discesa del gruppo facendo clic sui tre puntini e seleziona **Esporta i dati del gruppo**.

![Azione Esporta i dati del gruppo nel menu di Oatmilk Cooperative](group_export_group_data.png)

<!-- translation-section: export-group-data-as-csv -->

### Esporta i dati del gruppo in formato CSV

*Per lavorare con i dati del gruppo in un foglio di calcolo, come MS Excel o Google Sheets.*

Loomio prepara il file CSV in background e ti invia per email un link per scaricarlo quando è pronto. Il link è disponibile per una settimana.

<!-- translation-section: export-group-data-as-html -->

### Esporta i dati del gruppo in formato HTML

*Per salvare i dati a scopo di archiviazione.*

Loomio prepara il file HTML in background e ti invia per email un link per scaricarlo quando è pronto. Il link è disponibile per una settimana.

<!-- translation-section: export-group-data-as-json -->

### Esporta i dati del gruppo in formato JSON

*Per trasferire i dati del tuo gruppo su un'istanza Loomio ospitata su un tuo server.*

Devi essere un amministratore del gruppo per esportarlo. L'esportazione JSON include:

- Il gruppo, i suoi membri e le richieste di adesione
- Conversazioni, commenti, reazioni, tag, modelli, notifiche e record correlati dei gruppi inclusi
- Sondaggi, opzioni, voti e conclusioni; un sondaggio anonimo viene incluso solo dopo la sua chiusura
- I sottogruppi di cui fai parte
- I sottogruppi aperti, chiusi e visibili al gruppo principale quando esporti il loro gruppo principale come amministratore del gruppo principale, anche se non fai parte di quei sottogruppi
- Riferimenti ai file e alle immagini allegati ai contenuti inclusi

L'esportazione JSON non include:

- I sottogruppi segreti di cui non fai parte, compresi i loro membri e contenuti
- I sottogruppi in attesa di eliminazione
- I sondaggi anonimi che non sono stati chiusi
- Le conversazioni dirette e i sondaggi che non appartengono al gruppo

Riceverai a breve un'email con un link per scaricare il file JSON.

<!-- translation-section: print-thread-to-pdf -->

## Stampa una conversazione in PDF

Potresti aver bisogno di estrarre una copia di una conversazione per conservarla in un archivio di file separato.

La funzione **Stampa** della conversazione conserva tutti i commenti, i sondaggi, i voti e le conclusioni, insieme alla formattazione della conversazione.

Nel menu della conversazione, fai clic sul menu con i tre puntini (⋯) e scegli **Stampa**. Loomio genererà una pagina HTML che potrai stampare o "salvare in PDF" usando lo strumento di stampa del tuo browser.

Puoi copiare la pagina e incollarla in un editor di documenti, in un file o in un archivio di dati.

![Azione Stampa per la discussione sulle bottiglie a rendere](discussion_print_discussion.png#width-90)

<!-- translation-section: import-your-group-data-on-another-loomio-server -->

## Importa i dati del tuo gruppo su un altro server Loomio

Per le istruzioni su come configurare un tuo server Loomio, visita: https://github.com/loomio/loomio

Se ospiti una tua installazione di Loomio e vuoi importare i dati che hai esportato:

Copia il file .json nella cartella `import` dell'istanza del container:

`scp your-group-data.json username@some-domain.org:loomio-deploy/import`

Accedi alla console Rails in esecuzione:

`docker exec -ti loomio-app rails console`

Chiama il servizio:

`GroupExportService.import('/import/your-group-data.json')`
