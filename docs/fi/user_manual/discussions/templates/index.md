---
title: Keskustelumallit
source_revision: 924e704b41670a012a16528cf88edf90f8d6b572
source_file: docs/en/user_manual/discussions/templates/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: 9b2b30212a057b4b
  how-templates-are-used: 7d5681170fe9911e
  choose-who-is-notified-by-default: e9fe4c939442f514
  template-settings: 2e71090b3d149213
  example-bottle-trial-review: 20009020c0b68fdf
  create-a-template: 223eee427ebb52bb
  manage-the-template-list: 9a4957687be2b34d
  share-templates-between-groups: 2bff30bad2a0eb4a
  let-members-create-templates: 0cfd990ff48a1a09
  templates-for-non-members: ebaf610bf85e81a9
  related: 6f4cc2ccf8e709d3
generated:
  introduction: 0c48855c6c3912a5
  how-templates-are-used: 3de0f58a904f29b9
  choose-who-is-notified-by-default: ef2847c229cf399a
  template-settings: '0029f64c59958918'
  example-bottle-trial-review: 3c29e1e27a3f725d
  create-a-template: 808f176c2d832720
  manage-the-template-list: 4d0ccf20ab05a299
  share-templates-between-groups: d44cb1020d7fe668
  let-members-create-templates: 201e1bba154cdd78
  templates-for-non-members: 63b9924e5d724e7e
  related: a8de70276572a9a7
title_source: 5ac608aa42806d13
title_generated: 00fbd778c84da62b
needs_review:
  choose-who-is-notified-by-default: use "vaihtoehto" instead of "asetus" for "option"
---

<!-- translation-section: introduction -->

# Keskustelumallit

Keskustelumallit auttavat ryhmääsi aloittamaan keskustelut samalla tavalla joka kerta. Malli voi sisältää otsikon, kontekstin, tunnisteita ja ohjeita keskustelun aloittajalle. Se määrittää myös oletukset, kuten ilmoitetaanko koko ryhmälle ja mitä kyselyjä ehdotetaan.

Jokainen uusi keskustelu ryhmässä aloitetaan mallista. Kun joku valitsee **Aloita keskustelu**, Loomio näyttää ryhmän mallit. Myös **Tyhjä malli** on malli, joten ryhmäsi voi muuttaa senkin oletuksia.

Mallit sopivat ryhmäsi toistuviin prosesseihin, kuten projektien arviointiin, neuvojen pyytämiseen, kokousten valmisteluun, rahoituspäätöksiin tai asiakirjojen hyväksymiseen. Keskustelun aloittaja voi silti muokata kaikkea ennen keskustelun aloittamista.

<!-- translation-section: how-templates-are-used -->

## Näin malleja käytetään

1. Jäsen valitsee ryhmän sivulta **Aloita keskustelu**.
2. Loomio näyttää ryhmän näkyvät mallit. Jokaisesta näkyy otsikko ja alaotsikko.
3. Jäsen valitsee mallin. Loomio avaa uuden keskustelun lomakkeen, joka on täytetty mallin pohjalta.
4. Mallin ohjeet näkyvät lomakkeen yläosassa.
5. Jäsen muokkaa otsikkoa, kontekstia, tunnisteita ja kutsulistaa ja valitsee sitten **Aloita keskustelu**.

![](list.png)

Mallin muuttaminen vaikuttaa vain muutoksen jälkeen aloitettuihin keskusteluihin. Mallista aiemmin aloitettujen keskustelujen sisältö ja asetukset säilyvät ennallaan.

<!-- translation-section: choose-who-is-notified-by-default -->

## Valitse, kenelle ilmoitetaan oletuksena

**Kutsu**-asetus määrittää, kenet uuden keskustelun lomake kutsuu oletuksena. Siinä on kaksi vaihtoehtoa:

- **Kaikki ryhmässä**: ryhmä näkyy keskustelulomakkeen **Kutsu**-kentässä, ja jokainen jäsen saa ilmoituksen, kun keskustelu alkaa.
- **Ei mitään**: **Kutsu**-kenttä on aluksi tyhjä. Kukaan ei saa ilmoitusta, ellei keskustelun aloittaja lisää ihmisiä.

Loomion valmiissa malleissa, myös **Tyhjä malli** -mallissa, on valittuna **Kaikki ryhmässä**. Jos ryhmäsi ei halua kaikkien jäsenten saavan ilmoitusta jokaisesta uudesta keskustelusta, muokkaa ryhmäsi käyttämiä malleja ja valitse **Kutsu**-asetuksen arvoksi **Ei mitään**.

![](use.png)

Keskustelun aloittaja voi aina muuttaa kutsulistaa ennen keskustelun aloittamista. Hän voi poistaa ryhmän, jolloin kukaan ei saa ilmoitusta, tai lisätä sen sijaan tiettyjä ihmisiä. Tämä asetus vaikuttaa vain ilmoituksiin. Ryhmän jäsenet voivat edelleen löytää ja lukea keskustelun ryhmässä riippumatta siitä, kumman vaihtoehdon valitset.

Ryhmä lisätään kutsulistaan vain, jos keskustelun aloittajalla on oikeus ilmoittaa koko ryhmälle. Ylläpitäjät voivat aina tehdä näin. Jäsenet voivat tehdä näin, kun **Jäsenet voivat ilmoittaa kaikille ryhmän jäsenille** on käytössä ryhmän käyttöoikeuksissa.

<!-- translation-section: template-settings -->

## Mallin asetukset

Ryhmän ylläpitäjät voivat muokata mallia malliluettelossa sen vieressä olevasta toimintovalikosta. Lomakkeessa on seuraavat asetukset:

![](form.png)

- **Mallipohjan otsikko**: malliluettelossa näkyvä lyhyt nimi.
- **Mallipohjan alaotsikko**: yhden rivin kuvaus siitä, milloin mallia kannattaa käyttää.
- **Mallipohjan ohjeet**: uuden keskustelun lomakkeen yläosassa näkyvät ohjeet. Kuvaa niissä prosessi ja lisää linkkejä tarvittavaan aineistoon. Ohjeet eivät ole osa keskustelua.
- **Ryhmä**: aloitetaanko mallista keskustelu ryhmässä vai suora keskustelu. Suora keskustelu näkyy vain siihen kutsutuille ihmisille.
- **Oletusotsikko**: jokaiseen uuteen keskusteluun valmiiksi täytetty otsikko. Aloittaja voi muokata sitä.
- **Esimerkki otsikosta**: tyhjässä otsikkokentässä näkyvä esimerkki. Käytä sitä, kun oletusotsikko ei sopisi jokaiseen keskusteluun.
- **Tunnisteet**: jokaiseen uuteen keskusteluun lisättävät tunnisteet. Aloittaja voi poistaa ne.
- **Konteksti**: keskustelun aloitusteksti. Ohjaa kirjoittamista otsikoilla, kysymyksillä tai linkeillä.
- **Kutsu**: kutsutaanko kaikki ryhmän jäsenet oletuksena. Katso [Valitse, kenelle ilmoitetaan oletuksena](#choose-who-is-notified-by-default).
- **Kyselymallit**: tähän prosessiin ehdotettavat kyselyt. Ne näkyvät uuden keskustelun lomakkeessa. Ne näkyvät myös ensimmäisinä, kun joku aloittaa kyselyn keskustelussa. Ne eivät ala automaattisesti.
- **Salli samanaikaiset kyselyt**: voiko keskustelussa olla avoinna useampi kuin yksi kysely kerrallaan.
- **Kommentin pituusrajoitus**: valinnainen kommenttien enimmäispituus.

Käytä oletusotsikkoa vain, jos se pysyy paikkansapitävänä. Muussa tapauksessa kirjoita esimerkki otsikosta, joka ohjaa aloittajaa nimeämään kyseisen arvioinnin, ajanjakson, asiakirjan tai päätöksen.

<!-- translation-section: example-bottle-trial-review -->

## Esimerkki: pullokokeilun arviointi

Oatmilk Cooperative arvioi palautettavien pullojen kokeiluaan jokaisen kierroksen jälkeen. Sen mallin nimi on ”Pullokokeilun arviointi”, ja mallissa on oletusotsikko. Malli lisää tunnisteen ”Pullokokeilu”. Sen konteksti pyytää jäseniä lukemaan viikkoraportin ja tarkastelemaan palautusasteita, pesutietoja, kahviloiden palautetta ja kuljetuskustannuksia. Se suosittelee ensin tunnustelua ja sen jälkeen Suostumus-kyselyä.

Tämä toimii mallina, koska tarkoitus ja arvioinnin pohjana oleva aineisto pysyvät samoina jokaisella kierroksella. Vain havainnot ja päätökset muuttuvat.

<!-- translation-section: create-a-template -->

## Luo malli

Ryhmän ylläpitäjät voivat valita malliluettelosta **Uusi malli**. Valitse esimerkki Loomion galleriasta tai aloita tyhjästä mallista, muokkaa sitä tarpeisiisi ja tallenna se.

Voit hakea galleriasta tai suodattaa sitä. Esimerkki lisätään ryhmääsi vasta, kun tallennat sen.

<!-- translation-section: manage-the-template-list -->

## Hallitse malliluetteloa

Kun ryhmä luodaan, Loomio lisää joukon ryhmän tyyppiin sopivia malleja. Aluksi näkyvissä ovat vain **Tyhjä malli** ja **Harjoituskeskustelu**. Muut ovat piilotettuina, ja ylläpitäjät voivat tuoda ne näkyviin.

Ryhmän ylläpitäjät voivat mallin vieressä olevasta toimintovalikosta:

- muokata sen sisältöä ja asetuksia;
- piilottaa sen malliluettelosta;
- tuoda sen näkyviin **Piilotetut mallit** -luettelosta;
- muuttaa näkyvien mallien järjestystä;
- viedä sen JSON-tiedostona; tai
- poistaa sen.

Piilotettu malli säilyy myöhempää käyttöä varten. Mallin poistaminen ei poista siitä aloitettuja keskusteluja.

<!-- translation-section: share-templates-between-groups -->

## Jaa malleja ryhmien välillä

Valitse mallin toimintovalikosta **Vie JSON-tiedosto**, niin voit ladata mallin tiedostona. Voit käyttää sitä toisessa ryhmässä valitsemalla **Uusi malli** ja sitten **Tuo JSON-tiedosto**. Lomake avautuu tuodulla sisällöllä, jotta voit tarkistaa sen ennen tallentamista.

Linkit mukautettuihin kyselymalleihin eivät sisälly tiedostoon. Vie ja tuo nämä kyselymallit erikseen.

<!-- translation-section: let-members-create-templates -->

## Anna jäsenten luoda malleja

Oletuksena vain ryhmän ylläpitäjät voivat luoda ja muokata malleja. Ylläpitäjä voi ottaa käyttöön asetuksen **Jäsenet voivat luoda malleja** kohdassa **Ryhmäasetukset** → **Käyttöoikeudet**.

Kun asetus on käytössä, jäsenet voivat luoda keskustelu- ja kyselymalleja sekä muokata luomiaan malleja. Ylläpitäjät voivat muokata kaikkia ryhmän malleja. Jäsenen malli näkyy ryhmän malliluettelossa heti tallentamisen jälkeen, joten sovi nimeämis- ja tarkistuskäytännöistä ennen tämän käyttöoikeuden käyttöönottoa.

<!-- translation-section: templates-for-non-members -->

## Mallit muille kuin jäsenille

Jos **Muutkin kuin jäsenet voivat aloittaa keskusteluja** on käytössä, ryhmän ulkopuoliset ihmiset valitsevat samasta malliluettelosta. Heidän keskustelulomakkeensa ei koskaan kutsu ryhmää oletuksena. Katso [Kerää yksityisiä ehdotuksia](/en/user_manual/discussions/private_submissions).

<!-- translation-section: related -->

## Aiheeseen liittyvää

- [Kyselymallit](/en/user_manual/polls/poll_templates)
