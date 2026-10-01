---
sections:
  introduction: 301b7440aa148d0b
  set-members-vote-weights: 47b8d7c9222794d8
  use-weighted-voting-in-a-poll: d8af319ed1e38e4d
  results: 3cd10f104ced0ed5
generated:
  introduction: 17d84b939a710992
  set-members-vote-weights: 5a9d21e17b8b592a
  use-weighted-voting-in-a-poll: 5bf3382a236219c5
  results: b3ffea904b8be5fb
title: Painotettu äänestys
title_source: 0b971991dfcacbab
title_generated: 6c6d53a110e6e406
source_revision: 9c60c42fc739483fa23f15d9f34a1e9245518092
source_file: docs/en/user_manual/polls/weighted_voting/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
---

<!-- translation-section: introduction -->

# Painotettu äänestys

Painotetussa äänestyksessä jotkin äänet vaikuttavat tulokseen enemmän kuin toiset. Jokaisella äänestäjällä on äänipainotus. Esimerkiksi:

- Asuinyhteisö antaa jokaiselle kiinteistölle yhden äänen. Kolmea kiinteistöä edustavan jäsenen äänipainotus on `3`.
- Osuuskunnan hallitus tekee päätöksen, mutta työntekijät osallistuvat keskusteluun. Hallituksen jäsenten äänipainotus on `1`. Työntekijöiden äänipainotus on `0`, joten heidän äänensä tallennetaan, mutta ne eivät muuta tulosta.
- Yritys antaa osakkeenomistajille ääniä heidän omistusosuutensa mukaan. Henkilön, joka omistaa 12,5 % osakkeista, äänipainotus on `12.5`.

<!-- translation-section: set-members-vote-weights -->

## Aseta jäsenten äänipainotukset

Ryhmän ylläpitäjä voi avata ryhmän **Jäsenet**-sivun ja valita **Muokkaa äänimääriä**. Anna äänipainotukset ja valitse **Tallenna äänipainotukset**. Äänipainotus voi olla `0` tai suurempi, ja siinä voi olla enintään kolme desimaalia. Etsi henkilöä nimellä tai sähköpostiosoitteella. Jos haluat antaa kaikille jäsenille saman äänipainotuksen, valitse **Aseta kaikki äänipainotukset**.

![Ryhmän jäsenten äänipainotukset](member-weights.png)

Jäsenen äänipainotus kopioidaan jokaiseen kyselyyn, johon hänet lisätään. Äänipainotuksen muuttaminen myöhemmin ei muuta kyselyjä, joihin se on jo kopioitu.

<!-- translation-section: use-weighted-voting-in-a-poll -->

## Käytä painotettua äänestystä kyselyssä

Valitse kyselyn lisäasetuksista **Käytä painotettua äänestystä**. Voit ottaa sen käyttöön tai poistaa sen käytöstä äänestyksen avauduttua. Käytöstä poistaminen asettaa kyselyn kaikki äänipainotukset arvoon `1`, ja kyseisessä kyselyssä muuttamasi äänipainotukset menetetään.

Jos ryhmäsi käyttää painotettua äänestystä vakiintuneessa prosessissa, valitse [kyselymallissa](/en/user_manual/polls/poll_templates) **Käytä painotettua äänestystä**. Tästä mallista aloitetut kyselyt käyttävät painotettua äänestystä.

![Käytä painotettua äänestystä -asetus kyselyssä](poll-setting.png)

Painotettu äänestys toimii seuraavissa kyselytyypeissä: [Ehdotus](/en/user_manual/polls/proposals), [Valita](/en/user_manual/polls/choose), [Pisteet](/en/user_manual/polls/score), [Kohdista](/en/user_manual/polls/allocate) ja [Sijoitus](/en/user_manual/polls/rank).

Et voi käyttää painotettua äänestystä ja [anonyymiä äänestystä](/en/user_manual/polls/anonymous_voting) samassa kyselyssä.

Jos haluat muuttaa yhden äänestäjän äänipainotusta, valitse **Hallitse äänestäjiä** ja sitten hänen nimensä vieressä oleva äänipainotus. Jos haluat muuttaa kaikkien äänipainotuksia, valitse **Aseta kaikki äänipainotukset**. Voit kopioida kunkin jäsenen äänipainotuksen ryhmästä tai antaa kaikille saman arvon. Äänestäjät, jotka eivät ole ryhmän jäseniä, saavat äänipainotuksen `1`.

![Hallitse äänestäjiä -painike kyselyssä](poll-manage-voters.png)

![Kyselyn äänestäjät ja heidän yksilölliset äänipainotuksensa](poll-voter-weights.png)

<!-- translation-section: results -->

## Tulokset

Tuloksissa tavalliset ja painotetut kokonaismäärät näkyvät rinnakkain:

- Ehdotus- ja Valita-kyselyissä näkyvät **Äänet** ja **Painotetut äänet**.
- Pisteet-, Kohdista- ja Sijoitus-kyselyissä näkyvät **Pisteet** ja **Painotetut pisteet**.

Kaavio näyttää painotetun tuloksen. Valitse sarakkeen otsikko, jos haluat näyttää kaaviossa kyseisen sarakkeen tiedot. Äänioikeutettujen määrä ja päätösvaltaisuus lasketaan henkilöiden määrän perusteella, ei äänipainotusten. Jokainen, joka voi nähdä äänet, voi nähdä myös kunkin äänestäjän äänipainotuksen.

![Ehdotuksen tulos, jossa näkyvät äänet ja painotetut äänet](weighted-proposal-result.png)
