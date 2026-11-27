---
title: Tietojen vienti
source_revision: 6e7aad6a91a50e55dca43a20edcc88d445ee4185
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
  introduction: abd57986e9b2be9d
  export-data: e9b4c93060667fed
  export-group-data-as-csv: c9b3afa454491ee1
  export-group-data-as-html: a75b68b4b5117345
  export-group-data-as-json: a0e7a0a58d1314cd
  print-thread-to-pdf: 5e59a906833be96a
  import-your-group-data-on-another-loomio-server: 10048b848153b1b8
title_source: 29049648f87b87f5
title_generated: b1e3420f6c63b367
---

<!-- translation-section: introduction -->

# Ryhmän tietojen varmuuskopiointi tai vienti

Ryhmän tietojen vientitoiminnolla voit:

- Ladata jäsentiedot ryhmän jäsenyyksien tarkistamista varten.
- Arkistoida tai analysoida ryhmäsi ketjuja, kommentteja ja kyselyjä.
- Avata kyselyjen tulokset taulukkolaskentaohjelmassa tai käsitellä niitä komentosarjalla.
- [Tulostaa ketjun tai kyselyn tai tallentaa sen PDF-tiedostona arkistoosi.](#print-thread-to-pdf)
- Siirtää ryhmäsi käyttäjineen, ketjuineen, kyselyineen ja tiedostoineen toiselle Loomio-palvelimelle.

Voit käyttää tätä toimintoa siirtyäksesi Loomion ylläpitämästä palvelusta [itse ylläpitämällesi palvelimelle](https://github.com/loomio/loomio). Jos ylläpidät omaa palvelinta ja haluat siirtyä Loomion ylläpitämään palveluun Yhdysvalloissa, EU:ssa tai Australiassa, [ota meihin yhteyttä](/contact).

[Ota meihin yhteyttä](/contact), jos haluat siirtää ryhmän loomio.com-palvelusta alueelliseen palveluun (loomio.eu Euroopassa tai loomio.nz Australiassa ja Uudessa-Seelannissa).

<!-- translation-section: export-data -->

## Vie tiedot

Vain ryhmän ylläpitäjä voi viedä ryhmän tiedot. Avaa ryhmän sivulla **asetukset** ja valitse **Vie ryhmätiedot**.

![Vie ryhmätiedot -toiminto Oatmilk Cooperative -ryhmän asetussivulla](group_export_group_data.png)

Loomio valmistelee viennin taustalla ja lähettää sinulle latauslinkin sähköpostitse, kun vienti on valmis. Linkki on käytettävissä viikon ajan.

<!-- translation-section: export-group-data-as-csv -->

### Vie ryhmän tiedot CSV-muodossa

Käytä CSV-muotoa tarkastellaksesi ryhmän tietoja, kuten jäsenten tietoja ja toimintaa, taulukkolaskentaohjelmassa, kuten Microsoft Excelissä tai Google Sheetsissä.

<!-- translation-section: export-group-data-as-html -->

### Vie ryhmän tiedot HTML-muodossa

Käytä HTML-muotoa tallentaaksesi luettavan kopion ryhmäsi keskusteluista ja kyselyistä arkistointia varten.

<!-- translation-section: export-group-data-as-json -->

### Vie ryhmän tiedot JSON-muodossa

Käytä JSON-muotoa siirtääksesi ryhmäsi tiedot itse ylläpitämällesi Loomio-palvelimelle.

JSON-vienti sisältää:

- Ryhmän, sen jäsenet ja jäsenyyspyynnöt
- Mukana olevien ryhmien ketjut, kommentit, reaktiot, tunnisteet, mallit, ilmoitukset ja niihin liittyvät tietueet
- Kyselyt, vaihtoehdot, äänet ja johtopäätökset; anonyymi kysely sisällytetään vasta sen sulkeuduttua
- Alaryhmät, joihin kuulut
- Avoimet, suljetut ja pääryhmälle näkyvät alaryhmät, kun viet niiden pääryhmän tiedot pääryhmän ylläpitäjänä, vaikka et kuuluisi kyseisiin alaryhmiin
- Viittaukset mukana olevaan sisältöön liitettyihin tiedostoihin ja kuviin

JSON-vienti ei sisällä:

- Salaisia alaryhmiä, joihin et kuulu, eikä niiden jäsenyyksiä tai sisältöä
- Poistamista odottavia alaryhmiä
- Anonyymejä kyselyjä, joita ei ole suljettu
- Suoria ketjuja ja kyselyjä, jotka eivät kuulu ryhmään

<!-- translation-section: print-thread-to-pdf -->

## Tulosta ketju PDF-tiedostoksi

Jos haluat tallentaa yksittäisen ketjun arkistoosi, avaa sen toimintovalikko ja valitse **Tulosta**. Loomio luo HTML-sivun, joka sisältää ketjun kommentit, kyselyt, äänet, johtopäätökset ja muotoilun. Tulosta sivu tai tallenna se PDF-tiedostoksi selaimesi tulostustoiminnolla tai kopioi sisältö toiseen asiakirjaan.

![Tulosta-toiminto palautettavia pulloja koskevassa keskustelussa](discussion_print_discussion.png#width-90)

<!-- translation-section: import-your-group-data-on-another-loomio-server -->

## Tuo ryhmäsi tiedot toiselle Loomio-palvelimelle

Tämä osio on tarkoitettu itse ylläpidetyn Loomio-palvelimen ylläpitäjille. Käyttöönotto-ohjeet löydät [Loomion koodivarastosta](https://github.com/loomio/loomio).

1. Kopioi `.json`-tiedosto kontin `import`-kansioon:

```sh
scp your-group-data.json username@some-domain.org:loomio-deploy/import
```

2. Avaa Rails-konsoli käynnissä olevassa kontissa:

```sh
docker exec -ti loomio-app rails console
```

3. Suorita tuontipalvelu:

```ruby
GroupExportService.import('/import/your-group-data.json')
```
