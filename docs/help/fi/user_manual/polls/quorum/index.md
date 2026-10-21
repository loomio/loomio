---
title: Päätösvaltaisuus
source_revision: 924e704b41670a012a16528cf88edf90f8d6b572
source_file: docs/en/user_manual/polls/quorum/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: 0bf465006210877b
  example-scenario: 6596ad44e1c046b4
generated:
  introduction: 5b17c6e06ac6746a
  example-scenario: 5d1b5b99f55849a2
title_source: 18ed8b6c5ab90343
title_generated: 231a357976471e5a
---

<!-- translation-section: introduction -->

# Päätösvaltaisuus

Päätösvaltaisuus tarkoittaa sitä vähimmäisprosenttia äänioikeutetuista äänestäjistä, jonka on osallistuttava, jotta kysely olisi pätevä. Käytä sitä, kun päätöksentekoprosessisi edellyttää tiettyä osallistumistasoa.

Kun luot kyselyn, avaa **Lisää asetuksia** ja syötä vaadittu prosenttiosuus kenttään **Osallistumispäätösvaltaisuus**. Jätä kenttä tyhjäksi, jos päätösvaltaisuutta ei edellytetä.

![Päätösvaltaisuusasetus, jossa osallistumispäätösvaltaisuus on 60 prosenttia](./quorum-section.png)

Voit asettaa päätösvaltaisuuden myös [kyselymallissa](/en/user_manual/polls/poll_templates/), jolloin mallista luodut kyselyt käyttävät sitä oletuksena.

<!-- translation-section: example-scenario -->

## Esimerkkitilanne

Oatmilk Cooperative keskustelee kuuden viikon kokeilusta, jossa käytetään palautettavia pulloja. Keskustelu on edennyt siihen vaiheeseen, että osuuskunnan on hyväksyttävä kokeilun budjetti.

Jamie valitsee **Aloita äänestys**, valitsee **Suostumus**-ehdotusmallin ja täyttää otsikon, tiedot, vaihtoehdot, keston ja äänestäjäasetukset.

![Ehdotuksen otsikko, tiedot, vaihtoehdot, kesto ja äänestäjäasetukset](proposal-options.png)

Jamie rajaa äänestyksen viiteen kokeilun budjetista vastaavaan henkilöön.

Osuuskunta edellyttää merkittävissä päätöksissä 60 prosentin osallistumista, joten Jamie syöttää osallistumispäätösvaltaisuuden kenttään **60** ja käynnistää ehdotuksen.

Ennen kuin kukaan äänestää, tulospaneeli näyttää, ettei päätösvaltaisuutta ole saavutettu.

![Yhtään ääntä ei ole annettu, eikä 60 prosentin päätösvaltaisuutta ole vielä saavutettu](pie-chart-0.png)

Jamie on samaa mieltä ja Samira on eri mieltä. Kaavio päivittyy, mutta kaksi viidestä äänioikeutetusta äänestäjästä tarkoittaa vain 40 prosentin osallistumista, joten päätösvaltaisuutta ei vieläkään ole saavutettu.

![Kaksi viidestä äänestä on annettu, eikä päätösvaltaisuutta ole vielä saavutettu](pie-chart-40.png)

Alex on myös samaa mieltä. Kolme viidestä äänioikeutetusta äänestäjästä on osallistunut, joten 60 prosentin päätösvaltaisuus on saavutettu. Vaatimuksen kohdalla näkyy nyt vihreä valintamerkki. Jamie voi sulkea kyselyn etuajassa tai odottaa muiden äänestäjien ääniä.

![Kolme viidestä äänestä on annettu, ja 60 prosentin päätösvaltaisuus on saavutettu](pie-chart-60.png)
