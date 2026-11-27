---
title: Kyselymallit
source_revision: 3f3249b79d74c9f47d03ba2e119fd499ef49aef7
source_file: docs/help/en/user_manual/polls/poll_templates/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-28'
sections:
  introduction: 6faf3959a24d633a
  who-can-manage-templates: 2f0ab3bdaf9d093a
  create-a-poll-template: 0fafc6275b6c9153
  template-title-subtitle-and-help: 5a3f6c78e32fb066
  voting-method: 3ad5838dfcb67da0
  example-title-details-and-tags: 0f0d84a8b9b6ecb2
  response-options: e6ef2fb08eb66840
  duration-and-settings: 9b3c78d3c0d4986a
  manage-the-template-list: a58617ec50baf468
  save-a-poll-as-a-template: 36dc7b5d410d0eea
  start-a-new-template: 4f14910d88b22de8
  configure-the-template: 5fdb36299dd771b8
  edit-a-default-template: 6f1e7050d20ed373
generated:
  introduction: 41ae9c6a8628d5a1
  who-can-manage-templates: ac0f1499dcd3fdb7
  create-a-poll-template: 78bc97e104c5da3e
  template-title-subtitle-and-help: 3ec0fb67dd959f51
  voting-method: f9b84b65f73eceb3
  example-title-details-and-tags: ea5a7b3f71daa65b
  response-options: 3aa1869a062fa648
  duration-and-settings: 41b51cbecf6d7e8f
  manage-the-template-list: 1e42bb70431a29bd
  save-a-poll-as-a-template: 06f4be9e88c10c14
  start-a-new-template: 5e58489e7152e692
  configure-the-template: 9dc3620d6201d95e
  edit-a-default-template: 4c63b99976fc0d15
title_source: 114cca246e357304
title_generated: 22a10edb0e6d9b26
needs_review:
  introduction: use "vaihtoehto" instead of "asetukset" for "option"
---

<!-- translation-section: introduction -->

# Kyselymallit

Kyselymallit ovat uudelleenkäytettäviä lähtökohtia, jotka näytetään, kun valitset **Aloita äänestys** tai **Uusi kysely**. Malli yhdistää äänestystavan valmiisiin ohjeisiin, vastausvaihtoehtoihin ja asetuksiin.

Tämän sivun ohjeilla voit määrittää, mitkä mallit ovat ryhmän käytettävissä, tai luoda mallin omaa prosessiasi varten. Jos haluat valita mallin tiettyyn äänestykseen, katso [Ehdotukset](../proposals/) tai [Kyselyt](../proposal_types/). Jos haluat ohjata koko päätöksentekoprosessia, katso [Päätösten tekeminen](/guides/making-decisions/).

Kun aloitat äänestyksen, valitse **Ehdotus**- tai **Kysely**-välilehti ja valitse jokin ryhmän käytettävissä olevista malleista.

Malli täyttää johdannon, esimerkkisisällön, vaihtoehdot ja asetukset valmiiksi. Tarkista ja muokkaa ne päätökseesi sopiviksi ennen äänestyksen aloittamista. Uuden äänestyksen muokkaaminen ei muuta mallia.

<!-- translation-section: create-a-poll-template -->

## Luo kyselymalli

<!-- translation-section: save-a-poll-as-a-template -->

### Tallenna mallina

Jos haluat käyttää olemassa olevaa ehdotusta tai kyselyä uudelleen, avaa sen toimintovalikko ja valitse **Tallenna mallina**.

![Ehdotus, jonka toimintovalikko on auki ja Tallenna mallina on korostettu](save_as_template.png)

Äänestyksen päivämääriä, äänestäjiä, ääniä, tuloksia ja kyselyn johtopäätöstä ei tallenneta malliin.

<!-- translation-section: start-a-new-template -->

### Aloita uusi malli

Avaa malliluettelo ja valitse **Uusi malli**. Aloita esimerkistä tai tyhjästä mallista ja valitse sitten ryhmä, joka käyttää sitä.

![](proposal_template_setting.png)

<!-- translation-section: edit-a-default-template -->

### Muokkaa oletusmallia

Jos haluat mukauttaa oletusmallia, kuten **Suostumus**, avaa sen toimintovalikko ja valitse **Muokkaa mallia**. Tämä toiminto on ryhmän ylläpitäjien käytettävissä. Tallentaminen luo ryhmällesi oman mallin ja piilottaa oletusversion ryhmän malliluettelosta.

![Suostumus-oletusmalli, jonka Muokkaa mallia -toiminto on näkyvissä](edit_default_template.png)

<!-- translation-section: configure-the-template -->

## Mallin asetukset

Anna mallille nimi ja alaotsikko, jotka kuvaavat, milloin sitä kannattaa käyttää. Muokkaa muita kenttiä niin, että malli on valmis uudelleenkäyttöön, ja valitse sitten **Tallenna mallipohja**. Malli näkyy tämän jälkeen, kun käyttäjät aloittavat uuden ehdotuksen tai kyselyn.

[![Toimintaperiaatteiden muuttamiseen tarkoitetun suostumusprosessin koko mallilomake](poll_template_new.png)](poll_template_new.png)

Itsenäisissä kyselyissä **Vain ylläpitäjät voivat lisätä liitteitä** sallii uusien tiedostojen ja tekstin sekaan lisättävien kuvien lisäämisen vain ketjun ja ryhmän ylläpitäjille. Rajoitus koskee myös kyselyvastauksia ja niihin annettuja vastauksia. Olemassa olevassa ketjussa olevat kyselyt noudattavat kyseisen ketjun liiteasetusta. Mallin muuttaminen vaikuttaa vain tuleviin kyselyihin.

<!-- translation-section: template-title-subtitle-and-help -->

### Mallin otsikko, alaotsikko ja ohjeet

Kerro otsikossa ja alaotsikossa, milloin malli kannattaa valita. Lisää prosessin ohjeet, päätöksentekosäännöt ja linkit lisämateriaaleihin kohtaan **Mallipohjan ohjeet**.

<!-- translation-section: voting-method -->

### Äänestystapa

Valitse, mitä osallistujien pitää ilmaista ja miten tulos lasketaan:

- **Ehdotus**: vastaa väittämään ennalta määritetyillä kannoilla;
- **Valita**: valitse yksi tai useampi vaihtoehto;
- **Pisteytys**: arvioi jokainen vaihtoehto asteikolla;
- **Pistejako**: jaa rajallinen määrä pisteitä;
- **Järjestys**: aseta vaihtoehdot mieluisuusjärjestykseen;
- **Aikakysely**: ilmoita, mitkä ajat sopivat sinulle; ja
- **STV**: aseta ehdokkaat mieluisuusjärjestykseen suhteellisessa vaalissa, jossa valitaan useita henkilöitä.

Äänestystavan vaihtaminen muuttaa mallin käytettävissä olevia kenttiä ja tuloksen laskentaa.

<!-- translation-section: example-title-details-and-tags -->

### Esimerkkiotsikko, kuvaus ja tunnisteet

Käytä esimerkkiotsikossa ja kuvauksessa ohjaavia kysymyksiä tai ohjeita, kun jokainen äänestys tarvitsee erilaisen sisällön. Lisää oletusarvoisia luokittelutunnisteita vain, jos ne sopivat mallin jokaiseen käyttökertaan.

<!-- translation-section: response-options -->

### Vastausvaihtoehdot

Äänestystavat, kuten Ehdotus ja Valinta, antavat sinun määrittää vastausvaihtoehdot. Napsauta vaihtoehdon vieressä olevaa kynäkuvaketta muokataksesi seuraavia tietoja:

- **Vaihtoehdon nimi**: vastauksen lyhyt nimi;
- **Kuvake**: vaihtoehdon visuaalinen merkki;
- **Merkitys**: mitä vaihtoehdon valitseminen viestii; ja
- **Syykehote**: kysymys, joka näytetään, kun joku perustelee äänensä.

![](poll_type_edit_option.png)

Määritä vaihtoehdot niin, että osallistujat ymmärtävät niiden erot arvailematta. Merkitysten tulee vastata ryhmäsi käytössä olevia päätöksentekosääntöjä.

<!-- translation-section: duration-and-settings -->

### Kesto ja asetukset

Aseta oletuskesto, joka sopii mallin useimpiin käyttötarkoituksiin. Laatija voi muuttaa yksittäisen äänestyksen päättymisaikaa.

Muilla oletusasetuksilla määritetään tulosten näkyvyys, anonyymi äänestys, [painotettu äänestys](../weighted_voting/), äänen perusteluvaatimukset, muistutukset, päätösvaltaisuus ja äänestystapakohtainen toiminta. Katso lisätietoja sivulta [Ehdotusten ja kyselyjen asetukset](../settings/).

<!-- translation-section: manage-the-template-list -->

## Mallien hallinta

Mallin vieressä olevasta toimintovalikosta voit valita seuraavat toiminnot:

- **Muokkaa**: muokkaa mallin uudelleenkäytettävää sisältöä ja oletusarvoja;
- **Liikkua**: siirrä malli toiseen kohtaan luettelossa;
- **Piilottaa**: piilota malli äänestyksiä aloittavilta käyttäjiltä; tai
- **Poistaa**: poista itse luotu malli, jota ei enää tarvita.

![Ryhmän malliluettelo, jossa toimintaperiaatteiden muuttamiseen tarkoitetun suostumusprosessin toimintovalikko on auki](template_manage.png)

Valitse **Näytä piilotetut mallit**, kun haluat tarkastella tai palauttaa piilotettuja malleja. Voit piilottaa oletusmalleja tai muokata niitä ryhmällesi sopiviksi, mutta et voi poistaa niitä.

Mallin muuttaminen ei muuta ehdotuksia tai kyselyjä, jotka on jo aloitettu sen pohjalta.

<!-- translation-section: who-can-manage-templates -->

### Kuka voi hallita malleja

Ryhmän ylläpitäjät voivat luoda ja hallita kaikkia ryhmänsä kyselymalleja. He voivat ottaa käyttöön asetuksen **Jäsenet voivat luoda malleja** kohdassa **Ryhmäasetukset** → **Käyttöoikeudet**. Kun asetus on käytössä, jäsenet voivat luoda malleja ja hallita itse luomiaan malleja.
