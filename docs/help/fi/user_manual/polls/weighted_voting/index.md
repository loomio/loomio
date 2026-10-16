---
sections:
  introduction: d1b37bf68148b2a5
  set-members-vote-weights: 47b8d7c9222794d8
  use-weighted-voting-in-a-poll: d8af319ed1e38e4d
  results: 3cd10f104ced0ed5
generated:
  introduction: 5761643177197fe2
  set-members-vote-weights: d73e7c452d65b411
  use-weighted-voting-in-a-poll: 637ff70246df8700
  results: 601a64a242a42b2a
title: Painotettu äänestys
title_source: 0b971991dfcacbab
title_generated: 6c6d53a110e6e406
source_revision: 3f73d4a156d9ffd3137ff085cc6ab58fbc4de46b
source_file: docs/en/user_manual/polls/weighted_voting/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-06'
needs_review:
  results: use "Pisteytys" instead of "pisteet" for "Score"
---

<!-- translation-section: introduction -->

# Painotettu äänestys

Painotetussa äänestyksessä jotkin äänet vaikuttavat tulokseen enemmän kuin toiset. Jokaisella äänestäjällä on äänipaino. Esimerkiksi:

- Asuinyhteisö antaa jokaiselle kiinteistölle yhden äänen. Kolmea kiinteistöä edustavan jäsenen äänipaino on `3`.
- Työosuuskunta myöntää äänioikeuden, kun jäsenyys on kestänyt määrätyn ajan. Uudempien jäsenten äänipaino on `0`, joten he voivat osallistua keskusteluun ja tutustua äänestämiseen ilman, että heidän äänensä vaikuttavat tulokseen.
- Yritys antaa osakkeenomistajille ääniä heidän omistusosuutensa mukaan. Henkilön, joka omistaa 12,5 % osakkeista, äänipaino on `12.5`.

<!-- translation-section: set-members-vote-weights -->

## Aseta jäsenten äänipainot

Ryhmän ylläpitäjä voi avata ryhmän **Jäsenet**-sivun ja valita **Muokkaa äänimääriä**. Syötä äänipainot ja valitse **Tallenna äänipainotukset**. Äänipainot voivat olla `0` tai suurempia, ja niissä voi olla enintään kolme desimaalia. Etsi henkilöä nimellä tai sähköpostiosoitteella. Jos haluat antaa jokaiselle jäsenelle saman äänipainon, valitse **Aseta kaikki äänipainotukset**.

![Ryhmän jäsenten äänipainot](member-weights.png)

Jäsenen äänipaino kopioidaan jokaiseen kyselyyn, johon hänet lisätään. Äänipainon muuttaminen myöhemmin ei muuta kyselyitä, joihin se on jo kopioitu.

<!-- translation-section: use-weighted-voting-in-a-poll -->

## Käytä painotettua äänestystä kyselyssä

Valitse kyselyn lisäasetuksista **Käytä painotettua äänestystä**. Voit ottaa sen käyttöön tai poistaa sen käytöstä äänestyksen alettua. Kun poistat sen käytöstä, kyselyn kaikkien äänipainojen arvoksi asetetaan `1`, ja kaikki kyseiseen kyselyyn tekemäsi äänipainojen muutokset menetetään.

Jos ryhmäsi käyttää painotettua äänestystä vakiintuneessa prosessissa, valitse [kyselymallissa](/en/user_manual/polls/poll_templates) **Käytä painotettua äänestystä**. Tästä mallista aloitetut kyselyt käyttävät painotettua äänestystä.

![Kyselyn Käytä painotettua äänestystä -asetus](poll-setting.png)

Painotettu äänestys toimii seuraavissa kyselytyypeissä: [Ehdotus](/en/user_manual/polls/proposals), [Valinta](/en/user_manual/polls/choose), [Pisteytys](/en/user_manual/polls/score), [Pistejako](/en/user_manual/polls/allocate) ja [Järjestys](/en/user_manual/polls/rank).

Et voi käyttää painotettua äänestystä ja [anonyymiä äänestystä](/en/user_manual/polls/anonymous_voting) samassa kyselyssä.

Jos haluat muuttaa yhden äänestäjän äänipainoa, valitse **Hallitse äänestäjiä** ja valitse sitten hänen nimensä vieressä oleva äänipaino. Jos haluat muuttaa kaikkien äänipainoja, valitse **Aseta kaikki äänipainotukset**. Voit kopioida kunkin jäsenen äänipainon ryhmästä tai antaa kaikille saman arvon. Äänestäjät, jotka eivät ole ryhmän jäseniä, saavat äänipainon `1`.

![Kyselyn Hallitse äänestäjiä -painike](poll-manage-voters.png)

![Kyselyn äänestäjät ja heidän yksilölliset äänipainonsa](poll-voter-weights.png)

<!-- translation-section: results -->

## Tulokset

Tuloksissa näkyvät painottamattomat ja painotetut kokonaismäärät rinnakkain:

- Ehdotus- ja Valinta-kyselyissä näkyvät **Äänet** ja **Painotetut äänet**.
- Pisteytys-, Pistejako- ja Järjestys-kyselyissä näkyvät **Pisteet** ja **Painotetut pisteet**.

Kaavio näyttää painotetun tuloksen. Valitse sarakkeen otsikko, jos haluat näyttää kyseisen sarakkeen kaaviossa. Äänioikeutettujen määrä ja päätösvaltaisuus lasketaan henkilöiden, ei äänipainojen perusteella. Jokainen, joka näkee äänet, näkee myös kunkin äänestäjän äänipainon.

![Ehdotuksen tulos, jossa näkyvät äänet ja painotetut äänet](weighted-proposal-result.png)
