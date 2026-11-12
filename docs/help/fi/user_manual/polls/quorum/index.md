---
title: Päätösvaltaisuus
source_revision: 82853c73875ee63265d588fc0dae6eafffa81b41
source_file: docs/help/en/user_manual/polls/quorum/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-12'
sections:
  introduction: dbfdebe6e23060db
  example-scenario: d247e0866095c321
  overview-and-examples: 9097cf14e7f9bd68
generated:
  introduction: d33bd535ffd2646e
  example-scenario: 7ee0a7a527876382
  overview-and-examples: d822002cb24d572c
title_source: 18ed8b6c5ab90343
title_generated: 231a357976471e5a
---

<!-- translation-section: introduction -->

# Päätösvaltaisuus

Päätösvaltaisuus tarkoittaa sitä vähimmäisprosenttia äänioikeutetuista äänestäjistä, jonka on osallistuttava, jotta kysely olisi pätevä. Käytä sitä, kun päätöksentekoprosessisi edellyttää tiettyä osallistumistasoa.

Kun käytät [painotettua äänestystä](/en/user_manual/polls/weighted_voting), päätösvaltaisuus lasketaan äänipainojen perusteella. Esimerkiksi Jamien äänipaino on `2`, Samiran `1` ja Alexin `1`. Jos vain Jamie äänestää, osallistuneiden osuus on puolet äänioikeutettujen yhteenlasketusta äänipainosta. Jos myös Samira äänestää, osallistuminen nousee 75 prosenttiin, jolloin 60 prosentin päätösvaltaisuus saavutetaan.

Kun luot kyselyn, avaa **Lisää asetuksia**. Syötä vaadittu prosenttiosuus kenttään **Päätösvaltaisuus**. Jätä kenttä tyhjäksi, jos päätösvaltaisuutta ei edellytetä.

![Päätösvaltaisuusasetus, jossa vaadittu osallistuminen on 60 prosenttia](./quorum-section.png)

Voit asettaa päätösvaltaisuuden myös [kyselymallissa](/en/user_manual/polls/poll_templates/), jolloin mallista luodut kyselyt käyttävät sitä oletuksena.

<!-- translation-section: example-scenario -->

## Esimerkkitilanne

Oatmilk Cooperative keskustelee kuuden viikon kokeilusta, jossa käytetään palautettavia pulloja. Keskustelu on edennyt siihen vaiheeseen, että osuuskunnan on hyväksyttävä kokeilun budjetti.

Jamie valitsee **Aloita äänestys**, valitsee **Suostumus**-ehdotusmallin ja täyttää otsikon, tiedot, vaihtoehdot, keston ja äänestäjäasetukset.

![Ehdotuksen otsikko, tiedot, vaihtoehdot, kesto ja äänestäjäasetukset](proposal-options.png)

Jamie rajaa äänestyksen viiteen kokeilun budjetista vastaavaan henkilöön.

Osuuskunta edellyttää merkittävissä päätöksissä 60 prosentin osallistumista, joten Jamie syöttää kenttään **Päätösvaltaisuus** arvon **60** ja käynnistää ehdotuksen.

Ennen kuin kukaan äänestää, tulospaneeli näyttää, ettei päätösvaltaisuutta ole saavutettu.

![Yhtään ääntä ei ole annettu, eikä 60 prosentin päätösvaltaisuutta ole vielä saavutettu](pie-chart-0.png)

Jamie valitsee Samaa mieltä ja Samira valitsee Eri mieltä. Kaavio päivittyy, mutta kaksi viidestä äänioikeutetusta äänestäjästä tarkoittaa vain 40 prosentin osallistumista, joten päätösvaltaisuutta ei vieläkään ole saavutettu.

![Kaksi viidestä äänestä on annettu, eikä päätösvaltaisuutta ole vielä saavutettu](pie-chart-40.png)

Alex valitsee sitten Samaa mieltä. Kolme viidestä äänioikeutetusta äänestäjästä on osallistunut, joten 60 prosentin päätösvaltaisuus on saavutettu. Vaatimuksen kohdalla näkyy nyt vihreä valintamerkki. Jamie voi sulkea kyselyn etuajassa tai odottaa muiden äänestäjien ääniä.

![Kolme viidestä äänestä on annettu, ja 60 prosentin päätösvaltaisuus on saavutettu](pie-chart-60.png)

<!-- translation-section: overview-and-examples -->

## Yleiskatsaus ja esimerkkejä

Katso yleiskatsaus ja esimerkkejä sivulta [Päätösvaltaisuus Loomiossa](https://www.loomio.com/features/quorum/).
