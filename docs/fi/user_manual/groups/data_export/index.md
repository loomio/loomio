---
title: Tietojen vienti
source_revision: 924e704b41670a012a16528cf88edf90f8d6b572
source_file: docs/en/user_manual/groups/data_export/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: 5e29f67f9a2084ec
  export-data: 58b5e1d4e6f0b917
  export-group-data-as-csv: 53286ec33e7300d6
  export-group-data-as-html: 101671937dcd6f36
  export-group-data-as-json: 4ec883363fb166ee
  print-thread-to-pdf: 39c48383953f9fd5
  import-your-group-data-on-another-loomio-server: 910ee8af48049e82
generated:
  introduction: f7be21a56ade0912
  export-data: 4ed06cbe68ee3705
  export-group-data-as-csv: 3dcaa53b2b2618ec
  export-group-data-as-html: 7442c3d8a642f16d
  export-group-data-as-json: 8bc769c68d7f5ad3
  print-thread-to-pdf: bfd3f5bdbb886c9f
  import-your-group-data-on-another-loomio-server: d9abdb53881277da
title_source: 29049648f87b87f5
title_generated: b1e3420f6c63b367
---

<!-- translation-section: introduction -->

# Ryhmän tietojen varmuuskopiointi tai vienti

Ryhmän tietojen vientitoiminnolla voit:

- Ladata jäsentiedot sisältävän tiedoston ryhmän jäsenyyksien tarkistamista varten.
- Ladata ryhmäsi sisällön, mukaan lukien ketjujen ja kyselyjen tekstit, arkistointia tai analysointia varten.
- Avata kyselyjen tulokset taulukkolaskentaohjelmassa tai käsitellä niitä komentosarjakielellä.
- [Tulostaa ketjun tai kyselyn tai tallentaa sen PDF-tiedostona arkistointia varten.](#print-thread-to-pdf)
- Siirtää ryhmäsi kaikkine käyttäjineen, ketjuineen, kyselyineen ja tiedostoineen toiselle Loomio-palvelimelle.

Jos haluat siirtyä Loomion ylläpitämiltä palvelimilta [omalle palvelimellesi](https://github.com/loomio/loomio), voit käyttää tätä toimintoa.

Jos ylläpidät omaa Loomio-palvelinta etkä enää halua jatkaa sen ylläpitoa, Loomio tarjoaa ylläpidettyä palvelua Yhdysvalloissa, EU:ssa ja Australiassa. Jos haluat siirtää ryhmäsi jollekin näistä palvelimista, [ota meihin yhteyttä](/contact).

[Ota meihin yhteyttä](/contact), jos haluat siirtää Loomio-ryhmäsi Loomion maailmanlaajuisesta loomio.com-palvelusta johonkin alueellisista palveluistamme: loomio.eu palvelee Eurooppaa ja loomio.nz Australiaa ja Uutta-Seelantia.

<!-- translation-section: export-data -->

## Vie tiedot

Avaa ryhmän pudotusvalikko napsauttamalla kolmea pistettä ja valitse **Vie ryhmätiedot**.

![Vie ryhmätiedot -toiminto Oatmilk Cooperative -ryhmän valikossa](group_export_group_data.png)

<!-- translation-section: export-group-data-as-csv -->

### Vie ryhmän tiedot CSV-muodossa

*Kun haluat käsitellä ryhmän tietoja taulukkolaskentaohjelmassa, kuten MS Excelissä tai Google Sheetsissä.*

Loomio valmistelee CSV-tiedoston taustalla ja lähettää sinulle latauslinkin sähköpostitse, kun tiedosto on valmis. Linkki on käytettävissä viikon ajan.

<!-- translation-section: export-group-data-as-html -->

### Vie ryhmän tiedot HTML-muodossa

*Kun haluat tallentaa tiedot arkistointia varten.*

Loomio valmistelee HTML-tiedoston taustalla ja lähettää sinulle latauslinkin sähköpostitse, kun tiedosto on valmis. Linkki on käytettävissä viikon ajan.

<!-- translation-section: export-group-data-as-json -->

### Vie ryhmän tiedot JSON-muodossa

*Kun haluat siirtää ryhmäsi tiedot itse ylläpitämääsi Loomio-asennukseen.*

Sinun on oltava ryhmän ylläpitäjä, jotta voit viedä sen tiedot. JSON-vienti sisältää:

- Ryhmän, sen jäsenet ja jäsenyyspyynnöt
- Mukana olevien ryhmien ketjut, kommentit, reaktiot, tunnisteet, mallit, ilmoitukset ja niihin liittyvät tietueet
- Kyselyt, vaihtoehdot, äänet ja johtopäätökset; anonyymi kysely sisällytetään vasta sen sulkeuduttua
- Alaryhmät, joihin kuulut
- Avoimet ja suljetut alaryhmät, kun viet niiden pääryhmän tiedot pääryhmän ylläpitäjänä, vaikka et kuuluisi kyseisiin alaryhmiin
- Viittaukset mukana olevaan sisältöön liitettyihin tiedostoihin ja kuviin

JSON-vienti ei sisällä:

- Salaisia alaryhmiä, joihin et kuulu, eikä niiden jäsenyyksiä tai sisältöä
- Poistamista odottavia alaryhmiä
- Anonyymejä kyselyjä, joita ei ole suljettu
- Suoria ketjuja ja kyselyjä, jotka eivät kuulu ryhmään

Saat pian sähköpostin, jossa on linkki JSON-tiedoston lataamiseen.

<!-- translation-section: print-thread-to-pdf -->

## Tulosta ketju PDF-tiedostoksi

Saatat tarvita ketjusta kopion tallennettavaksi erilliseen tiedostoarkistoon.

Ketjun **Tulosta**-toiminto säilyttää kaikki kommentit, kyselyt, äänet ja johtopäätökset sekä ketjun muotoilun.

Napsauta ketjun kolmen pisteen valikkoa (⋯) ja valitse **Tulosta**. Loomio luo HTML-sivun, jonka voit tulostaa tai tallentaa PDF-tiedostoksi selaimesi tulostustoiminnolla.

Voit kopioida sivun ja liittää sen tekstinkäsittelyohjelmaan, tiedostoon tai tietovarastoon.

![Tulosta-toiminto palautettavia pulloja koskevassa keskustelussa](discussion_print_discussion.png#width-90)

<!-- translation-section: import-your-group-data-on-another-loomio-server -->

## Tuo ryhmäsi tiedot toiselle Loomio-palvelimelle

Ohjeet oman Loomio-palvelimen käyttöönottoon löydät osoitteesta: https://github.com/loomio/loomio

Jos ylläpidät omaa Loomio-asennusta ja haluat tuoda viemäsi tiedot:

Kopioi .json-tiedosto kontti-instanssin `import`-kansioon:

`scp your-group-data.json username@some-domain.org:loomio-deploy/import`

Avaa käynnissä olevan sovelluksen Rails-konsoli:

`docker exec -ti loomio-app rails console`

Kutsu palvelua:

`GroupExportService.import('/import/your-group-data.json')`
