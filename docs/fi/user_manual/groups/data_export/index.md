---
title: Tietojen vienti
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
  introduction: a95c5925f9d3976d
  export-data: 8ff98619fcf5c879
  export-group-data-as-csv: 40290737323c78c2
  export-group-data-as-html: 30f5b8d532bc9aa3
  export-group-data-as-json: d16eb25a62886f86
  print-thread-to-pdf: 4e81a48daddf80f3
  import-your-group-data-on-another-loomio-server: 1b2e08fbb45f5fcd
title_source: 29049648f87b87f5
title_generated: b1e3420f6c63b367
---

<!-- translation-section: introduction -->

# Ryhmän tietojen varmuuskopiointi tai vienti

Ryhmän tietojen vientitoiminnolla voit:

- Ladata jäsentiedot sisältävän tiedoston ryhmän jäsenyyksien tarkistamista varten.
- Ladata ryhmäsi sisällön, mukaan lukien keskustelujen ja kyselyjen tekstit, arkistointia tai analysointia varten.
- Avata kyselyjen tulokset taulukkolaskentaohjelmassa tai käsitellä niitä ohjelmointikielellä.
- [Tulostaa keskustelun tai kyselyn tai tallentaa sen PDF-tiedostona arkistointia varten.](#print-thread-to-pdf)
- Siirtää ryhmäsi, mukaan lukien kaikki käyttäjät, keskustelut, kyselyt ja tiedostot, toiselle Loomio-palvelimelle.

Jos haluat joskus siirtyä Loomion ylläpitämiltä palvelimilta [omalle palvelimellesi](https://github.com/loomio/loomio), voit käyttää tätä toimintoa.

Jos ylläpidät omaa Loomio-palvelinta mutta haluat siirtyä ylläpidettyyn palveluun, Loomio tarjoaa palvelimia Yhdysvalloissa, EU:ssa ja Australiassa. Jos haluat siirtää ryhmäsi jollekin näistä palvelimista, [ota meihin yhteyttä](/contact).

[Ota meihin yhteyttä](/contact), jos haluat siirtää Loomio-ryhmäsi loomio.comin maailmanlaajuisesta palvelusta johonkin alueellisista palveluistamme: Euroopassa loomio.eu tai Australiassa ja Uudessa-Seelannissa loomio.nz.

<!-- translation-section: export-data -->

## Vie tiedot

Avaa ryhmän valikko napsauttamalla kolmea pistettä ja valitse **Vie ryhmätiedot**.

![Vie ryhmätiedot -toiminto Oatmilk Cooperativen valikossa](group_export_group_data.png)

<!-- translation-section: export-group-data-as-csv -->

### Vie ryhmätiedot CSV-muodossa

*Kun haluat käsitellä ryhmän tietoja taulukkolaskentaohjelmassa, kuten MS Excelissä tai Google Sheetsissä.*

Loomio valmistelee CSV-tiedoston taustalla ja lähettää sinulle latauslinkin sähköpostitse, kun tiedosto on valmis. Linkki on käytettävissä viikon ajan.

<!-- translation-section: export-group-data-as-html -->

### Vie ryhmätiedot HTML-muodossa

*Kun haluat tallentaa tiedot arkistointia varten.*

Loomio valmistelee HTML-tiedoston taustalla ja lähettää sinulle latauslinkin sähköpostitse, kun tiedosto on valmis. Linkki on käytettävissä viikon ajan.

<!-- translation-section: export-group-data-as-json -->

### Vie ryhmätiedot JSON-muodossa

*Kun haluat siirtää ryhmäsi tiedot itse ylläpitämällesi Loomio-palvelimelle.*

Sinun on oltava ryhmän ylläpitäjä, jotta voit viedä sen tiedot. JSON-vienti sisältää:

- Ryhmän, sen jäsenet ja liittymispyynnöt
- Mukaan sisältyvien ryhmien keskustelut, kommentit, reaktiot, tunnisteet, mallipohjat, ilmoitukset ja niihin liittyvät tiedot
- Kyselyt, vastausvaihtoehdot, äänet ja johtopäätökset; nimetön kysely sisältyy vientiin vasta sen sulkeuduttua
- Alaryhmät, joihin kuulut
- Avoimet ja suljetut alaryhmät, kun viet emoryhmän tiedot sen ylläpitäjänä, vaikka et kuuluisi näihin alaryhmiin
- Viittaukset mukaan sisältyvään sisältöön liitettyihin tiedostoihin ja kuviin

JSON-vienti ei sisällä:

- Salaisia alaryhmiä, joihin et kuulu, eikä niiden jäsenyyksiä tai sisältöä
- Poistoa odottavia alaryhmiä
- Nimettömiä kyselyjä, jotka eivät ole sulkeutuneet
- Suoria keskusteluja ja kyselyjä, jotka eivät kuulu ryhmään

Saat pian sähköpostin, jossa on linkki JSON-tiedoston lataamiseen.

<!-- translation-section: print-thread-to-pdf -->

## Tulosta keskustelu PDF-tiedostoksi

Voit tallentaa keskustelusta kopion erilliseen tiedostoarkistoon.

**Tulosta**-toiminto säilyttää kaikki kommentit, kyselyt, äänet ja johtopäätökset sekä keskustelun muotoilun.

Napsauta keskusteluvalikon kolmea pistettä (⋯) ja valitse **Tulosta**. Loomio luo HTML-sivun, jonka voit tulostaa tai tallentaa PDF-tiedostona selaimesi tulostustoiminnolla.

Voit kopioida sivun ja liittää sen tekstinkäsittelyohjelmaan, tiedostoon tai tietovarastoon.

![Tulosta-toiminto palautuspulloja käsittelevässä keskustelussa](discussion_print_discussion.png#width-90)

<!-- translation-section: import-your-group-data-on-another-loomio-server -->

## Tuo ryhmäsi tiedot toiselle Loomio-palvelimelle

Ohjeet oman Loomio-palvelimen käyttöönottoon löydät osoitteesta https://github.com/loomio/loomio

Jos ylläpidät omaa Loomio-palvelinta ja haluat tuoda viemäsi tiedot:

Kopioi .json-tiedosto kontti-instanssin `import`-kansioon:

`scp your-group-data.json username@some-domain.org:loomio-deploy/import`

Avaa käynnissä olevan palvelun Rails-konsoli:

`docker exec -ti loomio-app rails console`

Kutsu palvelua:

`GroupExportService.import('/import/your-group-data.json')`
