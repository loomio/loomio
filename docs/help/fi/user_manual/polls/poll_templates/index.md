---
title: Kyselymallit
source_revision: 924e704b41670a012a16528cf88edf90f8d6b572
source_file: docs/en/user_manual/polls/poll_templates/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: f11182d62d99dbcc
  voting-methods-and-templates: 24be471686aa2dfd
  use-a-template: 8b19cdf141c41c9b
  who-can-manage-templates: 60218ef791438e19
  create-a-poll-template: c20dd8c57c3deab0
  template-title-subtitle-and-help: 3ad53a8b118aabd3
  voting-method: 761137852812fea8
  example-title-details-and-tags: 9dbbd0510d2d6cc1
  response-options: 727afbf0dcea6069
  duration-and-settings: a364411a3bebb3ae
  save-and-test-the-template: 8c48386c69ea309a
  manage-the-template-list: 0c124d7958c3f80a
generated:
  introduction: ade44dc7a1a25bb9
  voting-methods-and-templates: 0d648f6bcdbbe08a
  use-a-template: 73f1e351005db729
  who-can-manage-templates: b676755b1c4c5cec
  create-a-poll-template: a77e0716a6ec47bb
  template-title-subtitle-and-help: 5b0558b1207f0685
  voting-method: fc44758e336ceebb
  example-title-details-and-tags: f279060ec84ef2ab
  response-options: 328e97027f9e1c75
  duration-and-settings: 9010fc5abb2793df
  save-and-test-the-template: 944a8d02e329fcfb
  manage-the-template-list: 568e84f5d38cd527
title_source: 114cca246e357304
title_generated: 22a10edb0e6d9b26
needs_review:
  use-a-template: use "vaihtoehto" instead of "asetukset" for "option"
---

<!-- translation-section: introduction -->

# Kyselymallit

Kyselymallit ovat uudelleenkäytettäviä lähtökohtia, jotka näytetään, kun valitset **Aloita äänestys** tai **Uusi kysely**. Malli yhdistää äänestystavan valmiisiin ohjeisiin, vastausvaihtoehtoihin ja asetuksiin.

Tämän sivun ohjeilla voit määrittää, mitkä mallit ovat ryhmän käytettävissä, tai luoda mallin omaa prosessiasi varten. Jos haluat valita mallin tiettyyn äänestykseen, katso [Ehdotukset](../proposals/) tai [Kyselyt](../proposal_types/). Jos haluat ohjata koko päätöksentekoprosessia, katso [Päätösten tekeminen](/en/guides/making_decisions/).

<!-- translation-section: voting-methods-and-templates -->

## Äänestystavat ja mallit

Äänestystapa määrittää, miten osallistujat vastaavat ja miten Loomio laskee tuloksen. Äänestystapoja ovat esimerkiksi Ehdotus, Valinta, Pisteytys, Pistejako, Järjestys, Aikakysely ja STV.

Kyselymalli käyttää jotakin näistä äänestystavoista ja lisää siihen uudelleenkäytettävät oletusarvot. Esimerkiksi Tunnustelu, Neuvonanto, Suostumus ja Konsensus ovat eri malleja, jotka perustuvat Ehdotus-äänestystapaan. Niiden ohjeet ja vastausvaihtoehdot eroavat toisistaan, vaikka Loomio käsittelee niiden äänet samalla tavalla.

<!-- translation-section: use-a-template -->

## Käytä mallia

Kun aloitat äänestyksen, valitse **Ehdotus**- tai **Kysely**-välilehti ja valitse jokin ryhmän käytettävissä olevista malleista.

![](proposal_templates_list.png)

Malli sisältää johdannon, esimerkkisisällön, vaihtoehdot ja asetukset. Tarkista ja muokkaa niitä kyseiseen päätökseen sopiviksi ennen äänestyksen aloittamista. Uuden äänestyksen muokkaaminen ei muuta uudelleenkäytettävää mallia.

<!-- translation-section: who-can-manage-templates -->

## Kuka voi hallita malleja

Ryhmän ylläpitäjät voivat luoda ja hallita kaikkia ryhmänsä kyselymalleja. He voivat ottaa käyttöön asetuksen **Jäsenet voivat luoda malleja** kohdassa **Ryhmäasetukset** → **Käyttöoikeudet**. Kun asetus on käytössä, jäsenet voivat luoda malleja ja hallita itse luomiaan malleja.

<!-- translation-section: create-a-poll-template -->

## Luo kyselymalli

Avaa malliluettelo ja valitse **Uusi malli**. Aloita esimerkistä tai tyhjästä mallista ja valitse sitten ryhmä, joka käyttää sitä.

![](proposal_template_setting.png)

Mallilomakkeessa määritetään ohjeet ja oletusarvot, jotka käyttäjät saavat aloittaessaan äänestyksen.

![](poll_template_new.png)

<!-- translation-section: template-title-subtitle-and-help -->

### Mallin otsikko, alaotsikko ja ohjeet

- **Mallipohjan otsikko** on malliluettelossa näkyvä lyhyt nimi.
- **Mallipohjan alaotsikko** kertoo yhdellä lauseella, milloin mallia kannattaa käyttää.
- **Mallipohjan ohjeet** näkyvät tietopaneelissa, kun joku käyttää mallia. Kerro mallin tarkoitus ja säännöt, jotka osallistujien tulee tuntea, ja lisää linkit asiaankuuluviin toimintaperiaatteisiin tai oppaisiin.

![](template_WAAP_intro.png)

Käytä selkeitä ja täsmällisiä nimiä, jotka erottavat mallin ryhmän muista malleista.

<!-- translation-section: voting-method -->

### Äänestystapa

Valitse, mitä osallistujien pitää ilmaista ja miten tulos lasketaan.

![](poll_type_voting_method.png)

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

Lisää esimerkkisisältöä, joka auttaa laatijaa muotoilemaan äänestyksen. Nämä arvot kopioidaan uuteen ehdotukseen tai kyselyyn, ja niitä voi muokata ennen sen alkamista.

![](template_WAAP_details.png)

Käytä ohjaavia kysymyksiä tai ohjeita valmiin sisällön sijaan, jos otsikon tai kuvauksen täytyy olla erilainen jokaisella käyttökerralla. Lisää oletusarvoisia luokittelutunnisteita vain, jos ne sopivat mallin jokaiseen käyttökertaan.

<!-- translation-section: response-options -->

### Vastausvaihtoehdot

Äänestystavat, kuten Ehdotus ja Valinta, antavat sinun määrittää vastausvaihtoehdot. Napsauta vaihtoehdon vieressä olevaa kynäkuvaketta muokataksesi seuraavia tietoja:

- **Vaihtoehdon nimi**: vastauksen lyhyt nimi;
- **Kuvake**: vaihtoehdon visuaalinen merkki;
- **Merkitys**: mitä vaihtoehdon valitseminen viestii; ja
- **Syykehote**: kysymys, joka näytetään, kun joku perustelee vastauksensa.

![](poll_type_edit_option.png)

Määritä vaihtoehdot niin, että osallistujat ymmärtävät niiden erot arvailematta. Merkitysten tulee vastata ryhmäsi käytössä olevia päätöksentekosääntöjä.

<!-- translation-section: duration-and-settings -->

### Kesto ja asetukset

Aseta oletuskesto, joka sopii mallin useimpiin käyttötarkoituksiin. Laatija voi muuttaa yksittäisen äänestyksen päättymisaikaa.

![](poll_type_duration.png)

Muilla oletusasetuksilla voi määrittää tulosten näkyvyyden, anonyymin äänestyksen, [painotetun äänestyksen](../weighted_voting/), äänen perusteluvaatimukset, muistutukset, päätösvaltaisuuden ja äänestystapakohtaisen toiminnan. Katso niiden vaikutukset sivulta [Ehdotusten ja kyselyjen asetukset](../settings/).

<!-- translation-section: save-and-test-the-template -->

### Tallenna ja testaa malli

Kun olet tallentanut mallin, luo siitä äänestysluonnos. Tarkista, että johdanto, ohjaavat kysymykset ja ohjeet, vaihtoehdot ja oletusarvot ovat ymmärrettäviä myös henkilölle, joka ei luonut mallia. Luonnoksen luominen auttaa myös varmistamaan, että valittu äänestystapa tuottaa ryhmän odottaman tuloksen.

<!-- translation-section: manage-the-template-list -->

## Hallitse malliluetteloa

Mallin vieressä olevasta toimintovalikosta voit valita seuraavat toiminnot:

- **Muokkaa**: muokkaa mallin uudelleenkäytettävää sisältöä ja oletusarvoja;
- **Liikkua**: siirrä malli toiseen kohtaan luettelossa;
- **Piilottaa**: piilota malli äänestyksiä aloittavilta käyttäjiltä; tai
- **Poistaa**: poista itse luotu malli, jota ei enää tarvita.

![](template_manage.png)

Valitse **Näytä piilotetut mallit**, kun haluat tarkastella tai palauttaa piilotettuja malleja. Oletusmallit voi piilottaa tai muokata ryhmälle sopiviksi, mutta niitä ei voi poistaa.

![](template_manage_settings.png)

Mallin muuttaminen ei muuta ehdotuksia tai kyselyjä, jotka on jo aloitettu sen pohjalta.
