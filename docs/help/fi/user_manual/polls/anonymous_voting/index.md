---
title: Anonyymi äänestys
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/polls/anonymous_voting/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
sections:
  introduction: ffcecd2f4297c47d
  how-anonymous-voting-protects-voters: 3b757a1b4a7bda96
  while-voting-is-open: aafc698ee8108194
  votes-cannot-be-changed: 3a99e6c3f48e10ee
  why-anonymous-votes-do-not-have-reasons: 4027d6c1fbf4d29c
  results-and-exports: 5c10ab43a5f890b4
  participation-verification: e77ece0fc0d6cd73
  reminders: f711a180ae7c948f
  what-coordinators-and-administrators-can-see: d873cd48677fc324
  limits-of-anonymous-voting: 9ab54b74a4716e19
  questions: 60cc6f1a0163ec5d
  can-a-coordinator-see-how-i-voted: bfa1baf48f41cdd1
  can-i-see-my-vote-after-submitting-it: 435010e0c2ecf488
  can-i-change-or-withdraw-my-vote: 676d5401bf4d73cc
  will-i-receive-an-email-confirming-my-vote: 9660f10e8ffb9f9c
  does-a-public-poll-reveal-more-information: '087defb00bb8b99f'
  is-anonymous-voting-suitable-for-every-election: 9fae56c0661f0ec9
generated:
  introduction: 7c77ce5b6535a4d2
  how-anonymous-voting-protects-voters: 3f8c5c16eec1a684
  while-voting-is-open: 1c5ad89087147fe0
  votes-cannot-be-changed: 32a49fe0086b6011
  why-anonymous-votes-do-not-have-reasons: 5e2ed14b4b27af28
  results-and-exports: 4bc36258351da14b
  participation-verification: 4ab83dc057d21173
  reminders: 7e521bf7769ab340
  what-coordinators-and-administrators-can-see: c25b19d34d40fd42
  limits-of-anonymous-voting: fe4df8405b87a0b7
  questions: b868ae945415823c
  can-a-coordinator-see-how-i-voted: 38ea72bc1a684724
  can-i-see-my-vote-after-submitting-it: 45705ac2bdb901ff
  can-i-change-or-withdraw-my-vote: 4734c3b98e90dabc
  will-i-receive-an-email-confirming-my-vote: c25fa426261ba4cc
  does-a-public-poll-reveal-more-information: 7862431a049c36a5
  is-anonymous-voting-suitable-for-every-election: a18346d2f39f5865
title_source: 1bc4567506ad4d51
title_generated: 5c4eec1fb34c2a8c
---

<!-- translation-section: introduction -->

# Anonyymi äänestys

Anonyymi äänestys, jota kutsutaan myös sokkoäänestykseksi, pitää tiedon äänestäneistä erillään itse äänistä. Kyselyn sulkeuduttua kaikki, jotka näkevät tulokset, näkevät myös osallistujat, mutta kukaan Loomion käyttäjä ei voi yhdistää ääntä sen antaneeseen henkilöön.

Tällä sivulla kerrotaan, miten anonyymi äänestys toimii, mitä tietoja säilytetään ja mitkä ovat suojan rajat.

<!-- translation-section: how-anonymous-voting-protects-voters -->

## Miten anonyymi äänestys suojaa äänestäjiä

Anonyymi kysely säilyttää kaksi erillistä tietojoukkoa:

| Osallistumistiedot | Annetut äänet |
| --- | --- |
| Kenellä on äänioikeus | Valitut vaihtoehdot tai pisteet |
| Kuka kutsuttiin ja kuka hänet kutsui | Kysely, johon ääni kuuluu |
| Onko kukin äänioikeutettu henkilö äänestänyt | Ei nimeä eikä käyttäjätiliä |
| Ei valittuja vaihtoehtoja eikä pisteitä | Ei yhteyttä osallistumistietoihin |

Näillä tiedoilla ei ole yhteistä tunnistetta, joka yhdistäisi ne. Annettuihin ääniin ei myöskään tallenneta lähetysaikoja, kutsutietoja, äänten perusteluja, liitteitä eikä muita metatietoja, joista äänestäjän voisi tunnistaa.

Tiedot pidetään erillään jo ääntä tallennettaessa. Suoja ei perustu pelkästään nimien piilottamiseen käyttöliittymässä.

<!-- translation-section: while-voting-is-open -->

## Kun äänestys on avoinna

Tulokset pysyvät piilossa kaikilta, kunnes kysely sulkeutuu. Tämä koskee myös ketjun ylläpitäjiä, ryhmän ylläpitäjiä ja Loomio-asennuksen ylläpitäjiä.

Kun joku äänestää:

- hänen antamansa ääni tallennetaan ilman hänen nimeään tai osallistumistietojaan;
- hänen osallistumistietoihinsa merkitään, että hän on äänestänyt;
- äänestä ei luoda tapahtumaa, ilmoitusta, sähköpostia, kommenttia eikä toimintamerkintää;
- hänen valinnoistaan ei palauteta kopiota lähettämisen jälkeen; ja
- näytöllä vahvistetaan vain, että hänen äänensä on tallennettu.

Osallistumistietoihin ei tallenneta tarkkaa äänestysaikaa, eikä annettuja ääniä järjestetä lähetysajan mukaan.

<!-- translation-section: votes-cannot-be-changed -->

## Ääniä ei voi muuttaa

Jokainen äänioikeutettu henkilö voi äänestää kerran. Annettua anonyymiä ääntä ei voi tarkastella, muuttaa, perua eikä korvata. Myöskään ylläpitäjä ei voi tehdä näin.

Jos henkilö voisi hakea oman äänensä tai korvata sen, henkilön ja äänen välillä pitäisi olla yhteys. Anonyymissä äänestyksessä tätä yhteyttä ei tarkoituksella luoda.

Tarkista valintasi huolellisesti ennen lähettämistä.

<!-- translation-section: why-anonymous-votes-do-not-have-reasons -->

## Miksi anonyymeillä äänillä ei ole perusteluja

Anonyymeihin ääniin ei voi liittää äänen perustelua eikä liitettä. Perustelut voivat sisältää nimiä, henkilökohtaisia tietoja, kirjoitustyylin piirteitä tai mainintoja, joista äänestäjän voi tunnistaa. Ne voivat myös helpottaa yksittäisten äänten erottamista tuloksista.

Osallistujat voivat silti keskustella kyselystä sen ketjussa. Nämä kommentit ovat tavallisia, nimellä julkaistuja puheenvuoroja, eikä niitä liitetä anonyymiin ääneen.

<!-- translation-section: results-and-exports -->

## Tulokset ja viennit

Kyselyn sulkeuduttua Loomio laskee tulokset osallistumistiedoista erillään olevista äänistä ja näyttää kyseisen kyselytyypin yhteistulokset.

Loomio ei julkaise äänten tunnisteita, lähetysjärjestystä eikä lähetysaikoja. Kyselyn vientitiedostot sisältävät vain yhteistulokset yksittäisten äänten rivien sijaan. Ainoa poikkeus ovat suljetut STV-vaalit, jotka voi viedä BLT-muodossa uudelleenlaskentaa varten. BLT-vienti sisältää ehdokkaiden paremmuusjärjestykset ilman äänestäjien henkilöllisyyksiä tai äänten metatietoja. Äänet ryhmitellään, kun useassa äänessä on sama järjestys.

Anonyymiä kyselyä ei voi avata uudelleen sen sulkeuduttua.

<!-- translation-section: participation-verification -->

## Ketkä osallistuivat

Anonyymin kyselyn sulkeuduttua kaikki, jotka näkevät sen tulokset, näkevät myös osallistujat. Kukaan ei näe tätä tietoa äänestyksen ollessa avoinna.

Valitse **Näytä äänet**, niin näet luettelon. Siinä näkyy aina, kenellä oli äänioikeus. Luettelo ei koskaan näytä, miten tai milloin kukaan äänesti. Kunkin henkilön kohdalla näkyy, onko hän äänestänyt, vain jos riittävän moni osallistui: vähintään kyselyn päätösvaltaisuuteen vaadittava määrä, jos se on määritetty, ja muussa tapauksessa vähintään puolet äänioikeutetuista. Ääniä on kuitenkin aina oltava vähintään kolme.

Ryhmän jäsenet ja kyselyn äänestäjät näkevät myös, milloin kukin henkilö liittyi ryhmään ja kuka hänet kutsui. Ryhmän ylläpitäjät näkevät lisäksi sähköpostiosoitteet, jotta he voivat erottaa samannimiset henkilöt toisistaan.

Koska kaikki tulokset näkevät henkilöt näkevät myös, ketkä äänestivät, yksipuolinen tulos voi paljastaa, miten ihmiset äänestivät. Jos esimerkiksi jokainen ääni on Samaa mieltä, kaikki äänestäneet olivat samaa mieltä.

Ylläpitäjät voivat lisätä äänioikeutettuja henkilöitä äänestyksen ollessa avoinna myös sen jälkeen, kun muut ovat jo äänestäneet. Anonyymistä kyselystä ei voi poistaa siihen jo lisättyjä äänestäjiä.

<!-- translation-section: reminders -->

## Muistutukset

Jos anonyymi kysely kestää vähintään 24 tuntia, äänioikeutetut henkilöt, jotka eivät ole äänestäneet, saavat yhden automaattisen muistutuksen viimeisten 24 tunnin aikana.

Loomio valitsee vastaanottajat pelkkien osallistumistietojen perusteella tarkastelematta annettuja ääniä.

Kyselyt, joiden äänestysaika on alle 24 tuntia, eivät lähetä tätä automaattista muistutusta.

<!-- translation-section: what-coordinators-and-administrators-can-see -->

## Mitä ylläpitäjät voivat nähdä

Ketjun ylläpitäjä, ryhmän ylläpitäjä tai Loomio-asennuksen ylläpitäjä voi sovelluksessa nähdä:

- kyselyn ja sen äänioikeutetut henkilöt;
- onko kukin äänioikeutettu henkilö äänestänyt (jos ylläpitäjän rooli sallii tiedon katselun ja riittävän moni on äänestänyt); ja
- yhteistulokset kyselyn sulkeuduttua.

He eivät voi sovelluksen avulla nähdä:

- mitkä valinnat kuuluvat tietylle henkilölle;
- yksittäisiä ääniä tai äänestyskäyttäytymisen malleja;
- milloin ääni annettiin; tai
- ääneen liittyvää perustelua, liitettä, tapahtumaa tai ilmoitusta.

<!-- translation-section: limits-of-anonymous-voting -->

## Anonyymin äänestyksen rajat

Anonyymi äänestys estää Loomion käyttäjiä yhdistämästä ääntä äänestäjään. Se ei tarjoa kryptografista suojaa palvelimen ylläpidosta vastaavaa henkilöä vastaan, jos hän voi tarkastella tietokantaa, varmuuskopioita, palvelinlokeja, prosessin muistia, verkkoliikennettä tai muokattua koodia.

Myös itse tulokset voivat antaa vihjeitä. Pieni ryhmä, yksimielinen tulos, erottuva valintojen yhdistelmä tai kyselyn ulkopuolella jaetut kommentit voivat helpottaa henkilön äänen päättelemistä.

Ota huomioon ryhmän koko ja päätöksen arkaluonteisuus ennen kuin luotat sovellustason anonyymiin äänestykseen.

<!-- translation-section: questions -->

## Kysymyksiä

<!-- translation-section: can-a-coordinator-see-how-i-voted -->

### Voiko kukaan nähdä, miten äänestin?

Ei. Kukaan Loomion käyttäjä ei voi yhdistää sinua ääneesi. Kun riittävän moni on äänestänyt, kaikki tulokset näkevät henkilöt näkevät, osallistuitko. Ennen tämän rajan saavuttamista myös tieto siitä, oletko äänestänyt, pysyy piilossa.

<!-- translation-section: can-i-see-my-vote-after-submitting-it -->

### Voinko nähdä ääneni sen lähettämisen jälkeen?

Et. Loomio vahvistaa, että äänesi on tallennettu, ja poistaa valintasi näytöltä. Se ei voi hakea ääntäsi luomatta yhteyttä, jota anonyymissä äänestyksessä vältetään.

<!-- translation-section: can-i-change-or-withdraw-my-vote -->

### Voinko muuttaa tai perua ääneni?

Et. Koska sinun ja äänesi välillä ei ole yhteyttä, Loomio ei voi tunnistaa, mitä ääntä pitäisi muuttaa tai poistaa.

<!-- translation-section: will-i-receive-an-email-confirming-my-vote -->

### Saanko sähköpostivahvistuksen äänestäni?

Et. Äänestäminen näyttää vain vahvistuksen näytöllä ja päivittää osallistumistietosi. Se ei lähetä sähköpostia eikä luo ilmoitusta tai toimintamerkintää.

<!-- translation-section: does-a-public-poll-reveal-more-information -->

### Paljastaako julkinen kysely enemmän tietoja?

Kun julkinen kysely suljetaan, kuka tahansa voi nähdä sen tulokset ja osallistujat. Yksittäisiä ääniä tai jäsenyyden ja kutsujen tietoja ei voi nähdä.

<!-- translation-section: is-anonymous-voting-suitable-for-every-election -->

### Sopiiko anonyymi äänestys kaikkiin vaaleihin?

Ei. Se pitää äänestäjät ja äänet erillään sovelluksen tasolla. Vaalit, jotka edellyttävät suojaa palvelimen ylläpitäjiltä tai riippumatonta kryptografista todentamista, tarvitsevat järjestelmän, joka on suunniteltu näitä vaatimuksia varten.
