---
title: Valitse
source_revision: 924e704b41670a012a16528cf88edf90f8d6b572
source_file: docs/en/user_manual/polls/choose/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: f9d6a5bfb7445de0
  when-to-use-choose: f8a798497cac5a43
  example-set-a-planning-meeting-agenda: 32a94a916dbf84e5
  set-up-the-poll: a16095b63c57e0c9
  vote: d170451131c544cf
  read-the-results: e675d12da1a4ba8a
  share-an-outcome: f6afc1713b921265
generated:
  introduction: 470395125efd4b9e
  when-to-use-choose: 908a8bde5b540cee
  example-set-a-planning-meeting-agenda: ad0db79663f8feaf
  set-up-the-poll: accd1abb7f5a5eaf
  vote: '0448b12d4ec940fc'
  read-the-results: 44b91df51d19b5e3
  share-an-outcome: 07c48004c7ef0120
title_source: c7f937836f5d82d5
title_generated: 92978709da089a2a
needs_review:
  vote: use "vaihtoehto" instead of "asetus" for "option"
---

<!-- translation-section: introduction -->

# Valinta

Valinta on yksinkertainen kysely suosituimman vaihtoehdon löytämiseen tai vaihtoehtojen karsimiseen. Osallistujat valitsevat yhden tai useamman vaihtoehdon asettamiesi rajojen mukaan. Tämä äänestystapa tunnetaan yleisesti monivalintana.

<!-- translation-section: when-to-use-choose -->

## Milloin käyttää Valintaa

Käytä Valintaa, kun vaihtoehdot eroavat selvästi toisistaan ja haluat laskea, kuinka moni valitsee kunkin vaihtoehdon. Se sopii hyvin seuraaviin tilanteisiin:

- yhden tapahtumapaikan valitsemiseen esivalituista vaihtoehdoista;
- enintään kolmen aiheen valitsemiseen esityslistalle;
- sen päättämiseen, mikä suunnitelma etenee seuraavalle kierrokselle; tai
- sen selvittämiseen, mitä palveluja jäsenet aikovat käyttää.

Valinta tallentaa valinnat, mutta ei henkilön mieltymysten voimakkuutta tai järjestystä. Käytä [Pisteytystä](/en/user_manual/polls/score/), kun haluat mitata, kuinka vahvasti ihmiset kannattavat kutakin vaihtoehtoa, [Pistejakoa](/en/user_manual/polls/allocate/), kun käytettävissä on rajallinen budjetti, tai [Järjestystä](/en/user_manual/polls/rank/), kun mieltymysten järjestyksellä on merkitystä.

<!-- translation-section: example-set-a-planning-meeting-agenda -->

## Esimerkki: laadi suunnittelukokouksen esityslista

Oatmilk-osuuskunnan on päätettävä, mitkä palautettavien pullojen kokeilun osa-alueet tarvitsevat eniten aikaa seuraavassa suunnittelukokouksessa. Kyselyssä jokaista pyydetään valitsemaan enintään kaksi aihetta. Kyselyn tiedoissa kerrotaan, miten tuloksia käytetään, ja jokaisesta vaihtoehdosta annetaan riittävästi tietoa, jotta sen voi erottaa muista.

<!-- translation-section: set-up-the-poll -->

## Määritä kysely

Anna kyselyn otsikoksi täsmällinen kysymys. Kerro **Tiedot**-kohdassa, mitä osallistujien tulisi ottaa huomioon ja miten tuloksia käytetään. Lisää kaikki tarjolla olevat vaihtoehdot ja määritä sitten **Vähimmäisvalinnat** ja **Maksimi valinnanvaraa**.

![](form.png)

Aseta molemmiksi rajoiksi 1, kun osallistujien on valittava täsmälleen yksi vaihtoehto. Aseta suurempi enimmäismäärä, kun haluat karsia vaihtoehtoja. Vältä sallimasta niin montaa valintaa, että osallistujat voivat valita lähes kaikki vaihtoehdot, sillä silloin tuloksista on vähemmän hyötyä.

Napsauta vaihtoehdon vieressä olevaa kynäkuvaketta ja lisää selitys vaihtoehdon merkityksestä tai muita lisätietoja. Tästä on hyötyä, jos vaihtoehdon lyhyen nimen voi tulkita eri tavoin.

![](edit_option.png)

**Lisää asetuksia** -kohdan **Näytä vaihtoehdot satunnaisessa järjestyksessä** voi vähentää vaikutusta, joka syntyy, kun sama vaihtoehto näytetään aina ensimmäisenä.

![](random_order.png)

<!-- translation-section: vote -->

## Äänestä

Äänestyslomake kertoo osallistujille, kuinka monta vaihtoehtoa he voivat valita. Tässä esimerkissä äänestäjä valitsee **Kahviloiden noutoaikataulu** ja **Pesun työnkulku** ja antaa sitten perustelun, joka yhdistää nämä valinnat kokeiluun.

![](voting.png)

Perustelu voi kertoa, miksi vaihtoehto on tärkeä ja mitä työtä osallistujat odottavat sen kattavan. Jos perustelut ovat tärkeitä päätöksen kannalta, määritä äänen perustelua koskeva asetus ennen kyselyn aloittamista.

<!-- translation-section: read-the-results -->

## Lue tulokset

Tulokset näyttävät kunkin vaihtoehdon osuuden kaikista valinnoista, sen valinneiden äänestäjien määrän sekä sen, ketkä eivät ole äänestäneet. Koska jokainen saattoi valita kaksi vaihtoehtoa, prosenttiosuudet kuvaavat valintojen osuuksia eivätkä ihmisten osuuksia.

![](results.png)

Tässä esimerkissä **Kahviloiden noutoaikataulu** on valittu kolme kertaa. **Pesun työnkulku** ja **Palautusasteen raportointi** on kumpikin valittu kaksi kertaa. Tulokset puoltavat sitä, että kahviloiden noutoihin varataan eniten aikaa esityslistalla, mutta järjestäjän on vielä päätettävä, miten jäljelle jäävä aika jaetaan tasatilanteeseen päätyneiden aiheiden kesken.

<!-- translation-section: share-an-outcome -->

## Jaa johtopäätös

Kun kysely sulkeutuu, jaa johtopäätös. Kerro, miten ryhmä käyttää tuloksia ja miten mahdolliset tasatilanteet ratkaistaan. Lue [Jaa johtopäätös](/en/user_manual/polls/intro_to_decisions#5-share-an-outcome) saadaksesi tietoa johtopäätösten käytöstä.

![Johtopäätös, jossa kahviloiden noutoihin varataan eniten kokousaikaa](outcome.png)
