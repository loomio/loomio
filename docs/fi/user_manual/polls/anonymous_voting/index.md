---
title: Anonyymi äänestys
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/polls/anonymous_voting/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-30'
sections:
  introduction: d5c276b2785919c3
  how-anonymous-voting-protects-voters: f2be8477636489af
  while-voting-is-open: dda23e517269b9cf
  votes-cannot-be-changed: 1e317297688ba902
  why-anonymous-votes-do-not-have-reasons: 39c1a8362550ae40
  results-and-exports: eb2429afd442dad2
  participation-verification: cdaa1f5c3ca1e179
  reminders: 0afad473c90f2f03
  what-coordinators-and-administrators-can-see: 51460c8a6b663aba
  limits-of-anonymous-voting: 912141560342d073
  questions: 60cc6f1a0163ec5d
  can-a-coordinator-see-how-i-voted: 3dd2c9e6d06debda
  can-i-see-my-vote-after-submitting-it: c558e29729aed45f
  can-i-change-or-withdraw-my-vote: dd1a385fa8d225a5
  will-i-receive-an-email-confirming-my-vote: 8616fc9a0b9809ac
  does-a-public-poll-reveal-more-information: 2ba76a1748304f96
  is-anonymous-voting-suitable-for-every-election: d1b723178449c0da
generated:
  introduction: dd4008767d30016c
  how-anonymous-voting-protects-voters: 14d278fdae1fdf54
  while-voting-is-open: e3f5d679ec303197
  votes-cannot-be-changed: 212b04057186489a
  why-anonymous-votes-do-not-have-reasons: df019880d417fca5
  results-and-exports: 334146e763886ffa
  participation-verification: f8375a6e9273ed12
  reminders: d4b65900a4588662
  what-coordinators-and-administrators-can-see: 5707eae840b612b9
  limits-of-anonymous-voting: c848ddc98f282f8b
  questions: b868ae945415823c
  can-a-coordinator-see-how-i-voted: ca9f2872664d21fd
  can-i-see-my-vote-after-submitting-it: 28bae68efbab0a09
  can-i-change-or-withdraw-my-vote: 1015d6f64d08786a
  will-i-receive-an-email-confirming-my-vote: f11e5da90800ca28
  does-a-public-poll-reveal-more-information: 071a1bcb66e5fb23
  is-anonymous-voting-suitable-for-every-election: 8474d5bc9841430f
title_source: 1bc4567506ad4d51
title_generated: 5c4eec1fb34c2a8c
---

<!-- translation-section: introduction -->

# Anonyymi äänestys

Anonyymissä äänestyksessä tieto siitä, kuka on äänestänyt, säilytetään erillään annetuista äänistä. Kyselyn koordinaattorit näkevät, ketkä olivat äänioikeutettuja. Kun vähintään kolme henkilöä on äänestänyt, he voivat myös tarkistaa, ketkä osallistuivat. Sovelluksen käyttäjät eivät voi yhdistää annettua ääntä sen antajaan.

Tällä sivulla kerrotaan, miten anonyymi äänestys suojaa äänestäjiä, mitä tietoja säilytetään ja missä suojan rajat kulkevat.

<!-- translation-section: how-anonymous-voting-protects-voters -->

## Miten anonyymi äänestys suojaa äänestäjiä

Anonyymissä kyselyssä säilytetään kahta erillistä tietojoukkoa:

| Osallistumistiedot | Annetut äänet |
| --- | --- |
| Ketkä ovat äänioikeutettuja | Valitut vaihtoehdot tai annetut pisteet |
| Ketkä kutsuttiin ja kuka heidät kutsui | Kysely, johon ääni kuuluu |
| Onko kukin äänioikeutettu äänestänyt | Ei nimeä eikä käyttäjätiliä |
| Ei valittuja vaihtoehtoja eikä annettuja pisteitä | Ei yhteyttä osallistumistietoihin |

Näillä tiedoilla ei ole yhteistä tunnistetta, jonka avulla ne voisi yhdistää. Annettuihin ääniin ei myöskään tallenneta tarkkaa lähetysaikaa, kutsutietoja, kirjallisia perusteluja, liitteitä tai muita tietoja, jotka voisivat auttaa tunnistamaan äänestäjän.

Tiedot pidetään erillään jo ääntä tallennettaessa. Suoja ei perustu pelkästään siihen, että nimet piilotetaan käyttöliittymässä.

<!-- translation-section: while-voting-is-open -->

## Äänestyksen ollessa käynnissä

Tulokset pysyvät piilossa kaikilta, kunnes kysely sulkeutuu. Tämä koskee myös kyselyn koordinaattoreita, ryhmän ylläpitäjiä ja sovellusta käyttäviä palvelun ylläpitäjiä.

Kun joku äänestää:

- annettu ääni tallennetaan ilman äänestäjän nimeä tai yhteyttä hänen osallistumistietoihinsa;
- osallistumistietoihin merkitään, että hän on äänestänyt;
- äänestä ei luoda tapahtumaa, ilmoitusta, sähköpostia, kommenttia eikä merkintää toimintalokiin;
- hänen valinnoistaan ei palauteta kopiota lähettämisen jälkeen; ja
- käyttöliittymä vahvistaa vain, että ääni tallennettiin.

Osallistumistietoihin ei tallenneta tarkkaa äänestysaikaa. Annettuja ääniä ei järjestetä lähetysajan mukaan.

<!-- translation-section: votes-cannot-be-changed -->

## Annettua ääntä ei voi muuttaa

Jokainen äänioikeutettu voi äänestää kerran. Annettua anonyymiä ääntä ei voi tarkastella, muuttaa, perua eikä korvata. Tämä koskee myös koordinaattoreita ja ylläpitäjiä.

Jotta henkilö voisi hakea tai korvata äänensä, hänen ja äänen välillä pitäisi säilyttää pysyvä yhteys. Anonyymissä äänestyksessä tällaista yhteyttä ei luoda.

Tarkista valintasi huolellisesti ennen äänen lähettämistä.

<!-- translation-section: why-anonymous-votes-do-not-have-reasons -->

## Miksi anonyymeihin ääniin ei voi lisätä perusteluja

Uuteen anonyymiin ääneen ei voi lisätä kirjallista perustelua tai liitettä. Perustelu voi sisältää nimiä, henkilötietoja, tunnistettavan kirjoitustyylin, mainintoja tai muita tietoja, joista äänestäjän voi tunnistaa. Perustelut voisivat myös helpottaa yksittäisten äänten erottamista yhteistuloksesta.

Osallistujat voivat edelleen keskustella kyselystä sen keskusteluketjussa, jos keskustelu on käytettävissä. Nämä kommentit ovat tavallisia, kirjoittajan nimellä näkyviä keskusteluviestejä. Niitä ei liitetä anonyymiin ääneen.

<!-- translation-section: results-and-exports -->

## Tulokset ja viennit

Kun kysely sulkeutuu, tulokset lasketaan erillään tallennetuista äänistä. Ne näytetään kokonaismäärinä ja muina kyselytyypin tukemina yhteistuloksina.

Sovellus ei julkaise äänten tunnisteita, lähetysjärjestystä eikä lähetysaikoja. Kyselyn vientitiedostot sisältävät yhteistulokset, eivät erillistä riviä jokaisesta anonyymistä äänestä. Suljetusta STV-vaalista voi kuitenkin viedä BLT-tiedoston. Se sisältää vaalin uudelleenlaskentaan tarvittavat ehdokkaiden paremmuusjärjestykset. Saman järjestyksen sisältävät äänestysliput ryhmitellään. Tiedosto ei sisällä äänestäjien henkilöllisyyksiä eikä äänestyslippujen metatietoja.

Anonyymiä kyselyä ei voi avata uudelleen sen sulkeuduttua.

<!-- translation-section: participation-verification -->

## Osallistumisen tarkistaminen

Kyselyn koordinaattorit voivat tarkastella nimettyjä osallistumistietoja. Niistä näkyy aina, ketkä olivat äänioikeutettuja. Kun vähintään kolme henkilöä on äänestänyt, tiedoista näkyy myös, onko kukin henkilö äänestänyt. Niistä ei koskaan näy, miten kukaan äänesti. Jos kysely sulkeutuu alle kolmen annetun äänen jälkeen, tieto osallistumisesta pysyy piilossa.

Muut osallistujat eivät voi tarkastella nimettyjä osallistumistietoja. Oikeus nähdä kyselyn tulokset ei anna oikeutta nähdä osallistumistietoja.

Koordinaattorit voivat lisätä äänioikeutettuja äänestyksen ollessa käynnissä, myös sen jälkeen kun muut ovat äänestäneet. Jo äänestäneitä henkilöitä ei voi poistaa anonyymistä kyselystä.

<!-- translation-section: reminders -->

## Muistutukset

Jos anonyymi kysely kestää vähintään 24 tuntia, äänioikeutetut, jotka eivät ole äänestäneet, saavat yhden automaattisen muistutuksen viimeisen 24 tunnin aikana.

Muistutuksen saajat valitaan vain osallistumistietojen perusteella. Annettuja ääniä ei tarkastella eikä niihin luoda yhteyttä. Jos määräaika muuttuu, tunneittain tehtävä muistutustarkistus käyttää senhetkistä määräaikaa. Kyselylle ei ylläpidetä erillistä ajastettua muistutusta.

Automaattista muistutusta ei lähetetä, jos kyselyn koko äänestysaika on alle 24 tuntia.

<!-- translation-section: what-coordinators-and-administrators-can-see -->

## Mitä koordinaattorit ja ylläpitäjät voivat nähdä

Kyselyn koordinaattori, ryhmän ylläpitäjä tai palvelun ylläpitäjä voi roolinsa mukaan nähdä sovelluksessa:

- kyselyn ja sen äänioikeutetut;
- onko kukin äänioikeutettu äänestänyt, jos hänen roolinsa antaa siihen oikeuden ja vähintään kolme henkilöä on äänestänyt; ja
- yhteistulokset kyselyn sulkeuduttua.

Sovelluksen toiminnoilla he eivät voi nähdä:

- mitkä valinnat kuuluvat tietylle henkilölle;
- yksittäisiä ääniä tai äänestysmalleja;
- milloin tietty ääni lähetettiin; tai
- annettuun ääneen liittyvää perustelua, liitettä, tapahtumaa tai ilmoitusta.

<!-- translation-section: limits-of-anonymous-voting -->

## Anonyymin äänestyksen rajat

Nämä suojaukset estävät sovelluksen käyttäjiä yhdistämästä annettua ääntä sen antajaan. Ne eivät tarjoa kryptografista suojaa järjestelmän ylläpitäjältä, joka voi tarkastella tietokantaa, varmuuskopioita, palvelinlokeja, prosessimuistia, verkkoliikennettä tai sovelluksen muokattua versiota.

Myös tulos voi paljastaa tietoja. Jos äänioikeutettuja on vähän, tulos on yksimielinen tai valintojen yhdistelmä on erottuva, henkilön valintoja voi olla helpompi päätellä. Sama koskee kyselyn ulkopuolella jaettuja tietoja. Äänestäjä voi myös itse kertoa, miten äänesti, kyselyn ulkopuolisessa keskustelussa.

Harkitse äänestäjien määrää ja päätöksen arkaluonteisuutta, kun arvioit, sopiiko sovelluksen tarjoama anonyymi äänestäminen tilanteeseen.

<!-- translation-section: questions -->

## Kysymyksiä

<!-- translation-section: can-a-coordinator-see-how-i-voted -->

### Voiko koordinaattori nähdä, miten äänestin?

Ei. Kun vähintään kolme henkilöä on äänestänyt, koordinaattori voi tarkistaa, oletko äänestänyt. Hän ei kuitenkaan voi yhdistää sinua antamaasi ääneen sovelluksen kautta. Jos ääniä on vähemmän kuin kolme, tieto osallistumisestasi pysyy piilossa.

<!-- translation-section: can-i-see-my-vote-after-submitting-it -->

### Voinko nähdä ääneni lähettämisen jälkeen?

Et. Sovellus vahvistaa, että äänesi tallennettiin, ja poistaa sitten valintasi äänestysnäkymästä. Sovellus ei voi hakea ääntäsi luomatta yhteyttä, jonka anonyymi äänestäminen on tarkoitettu välttämään.

<!-- translation-section: can-i-change-or-withdraw-my-vote -->

### Voinko muuttaa ääntäni tai perua sen?

Et. Sovelluksella ei ole yhteyttä, jonka avulla se voisi tunnistaa muutettavan tai poistettavan äänen.

<!-- translation-section: will-i-receive-an-email-confirming-my-vote -->

### Saanko sähköpostivahvistuksen äänestämisestäni?

Et. Äänestäminen näyttää vain vahvistuksen näytöllä ja päivittää osallistumistietosi. Se ei lähetä vahvistussähköpostia eikä luo ilmoitusta tai tapahtumaa.

<!-- translation-section: does-a-public-poll-reveal-more-information -->

### Paljastaako julkinen äänestys enemmän tietoa?

Julkisen äänestyksen ja sen koottujen tulosten katselu voi olla mahdollista äänestyksen päätyttyä. Nimetyt osallistumistiedot ja yksittäiset anonyymit äänet eivät tule näkyviin.

<!-- translation-section: is-anonymous-voting-suitable-for-every-election -->

### Sopiiko anonyymi äänestäminen kaikkiin vaaleihin?

Ei. Se erottaa äänestäjien henkilöllisyydet äänistä sovelluksessa. Jos päätös edellyttää suojaa järjestelmän ylläpitäjiä vastaan tai itsenäisesti todennettavaa kryptografista vaalia, tarvitset näihin vaatimuksiin suunnitellun järjestelmän.
