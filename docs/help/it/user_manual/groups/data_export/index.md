---
title: Esportazione dei dati
source_revision: 95ce9afd64c99656f67e05a09fa9fc8a77af51d7
source_file: docs/help/en/user_manual/groups/data_export/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-26'
sections:
  introduction: 988679ffd3d29834
  export-data: '024783a0614721d2'
  export-group-data-as-csv: c0845f09bff828f2
  export-group-data-as-html: 659fd5e14956b00e
  export-group-data-as-json: 4c2131f4518b7469
  print-thread-to-pdf: 1a1d0598f4277ba1
  import-your-group-data-on-another-loomio-server: 33d49c6c25be163b
generated:
  introduction: 23c5e8f9a8712d16
  export-data: 963ea61a2a368b38
  export-group-data-as-csv: 1a9241da3a055958
  export-group-data-as-html: f4d29239587996fa
  export-group-data-as-json: c750b3b2930d84e9
  print-thread-to-pdf: 15cb1f4b6345bb43
  import-your-group-data-on-another-loomio-server: 11477484a5548500
title_source: 29049648f87b87f5
title_generated: ea7bba9669375d58
---

<!-- translation-section: introduction -->

# Backup o esportazione dei dati del gruppo

Con l'esportazione dei dati del gruppo puoi:

- Scaricare i dati dei membri per verificare chi appartiene al gruppo.
- Archiviare o analizzare le conversazioni, i commenti e i sondaggi del tuo gruppo.
- Aprire i risultati dei sondaggi in un foglio di calcolo o in uno script.
- [Stampare o salvare in PDF una conversazione o un sondaggio per conservarne una copia.](#print-thread-to-pdf)
- Trasferire il tuo gruppo, compresi i suoi utenti, le conversazioni, i sondaggi e i file, su un altro server Loomio.

Puoi usare questa funzione per passare dal servizio di hosting di Loomio a un [server gestito da te](https://github.com/loomio/loomio). Se gestisci un tuo server e vuoi passare all'hosting gestito da Loomio negli Stati Uniti, nell'Unione europea o in Australia, [contattaci](/contact).

[Contattaci](/contact) se vuoi trasferire un gruppo da loomio.com a un servizio regionale (loomio.eu per l'Europa o loomio.nz per l'Australia e la Nuova Zelanda).

<!-- translation-section: export-data -->

## Esporta i dati

Solo un amministratore del gruppo può esportare i dati del gruppo. Apri **Configurazione** nella pagina del gruppo e seleziona **Esporta i dati del gruppo**.

![Azione Esporta i dati del gruppo nella pagina di configurazione di Oatmilk Cooperative](group_export_group_data.png)

Loomio prepara l'esportazione in background e ti invia per email un link per scaricarla quando è pronta. Il link resta attivo per una settimana.

<!-- translation-section: export-group-data-as-csv -->

### Esporta i dati del gruppo in formato CSV

Usa il formato CSV per esaminare i dati del gruppo, compresi i dettagli e le attività dei membri, in un foglio di calcolo come Microsoft Excel o Google Sheets.

<!-- translation-section: export-group-data-as-html -->

### Esporta i dati del gruppo in formato HTML

Usa il formato HTML per salvare una copia leggibile delle discussioni e dei sondaggi del tuo gruppo a scopo di archiviazione.

<!-- translation-section: export-group-data-as-json -->

### Esporta i dati del gruppo in formato JSON

Usa il formato JSON per trasferire i dati del tuo gruppo su un server Loomio gestito da te.

L'esportazione JSON include:

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

<!-- translation-section: print-thread-to-pdf -->

## Stampa una conversazione in PDF

Per conservare una copia di una singola conversazione nel tuo archivio, apri il suo menu delle azioni e seleziona **Stampa**. Loomio genera una pagina HTML con i commenti, i sondaggi, i voti, le conclusioni e la formattazione della conversazione. Usa lo strumento di stampa del tuo browser per stamparla o salvarla in PDF, oppure copia il contenuto in un altro documento.

![Azione Stampa per la discussione sulle bottiglie a rendere](discussion_print_discussion.png#width-90)

<!-- translation-section: import-your-group-data-on-another-loomio-server -->

## Importa i dati del tuo gruppo su un altro server Loomio

Questa sezione è rivolta agli amministratori che gestiscono un proprio server Loomio. Per le istruzioni di configurazione, consulta il [repository di Loomio](https://github.com/loomio/loomio).

1. Copia il file `.json` nella cartella `import` del container:

```sh
scp your-group-data.json username@some-domain.org:loomio-deploy/import
```

2. Apri la console Rails nel container in esecuzione:

```sh
docker exec -ti loomio-app rails console
```

3. Esegui il servizio di importazione:

```ruby
GroupExportService.import('/import/your-group-data.json')
```
