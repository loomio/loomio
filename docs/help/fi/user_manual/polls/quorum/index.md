---
title: Päätösvaltaisuus
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/polls/quorum/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
sections:
  introduction: 885a154beca10592
  example-scenario: 2c4be2012a2bcba4
generated:
  introduction: 070ff0769ebd2fc7
  example-scenario: e2515254c74174c6
title_source: 18ed8b6c5ab90343
title_generated: 231a357976471e5a
---

<!-- translation-section: introduction -->

# Päätösvaltaisuus

Päätösvaltaisuus tarkoittaa sitä vähimmäisprosenttia äänioikeutetuista äänestäjistä, jonka on osallistuttava, jotta kysely voidaan hyväksyä. Käytä sitä, kun päätöksentekoprosessisi edellyttää tiettyä osallistumistasoa.

Kun käytät [painotettua äänestystä](/en/user_manual/polls/weighted_voting), päätösvaltaisuus lasketaan äänipainojen perusteella. Esimerkiksi Jamien äänipaino on `2`, Samiran `1` ja Alexin `1`. Jos vain Jamie äänestää, osallistuneiden osuus on puolet äänioikeutettujen yhteenlasketusta äänipainosta. Jos myös Samira äänestää, osallistuminen nousee 75 prosenttiin, jolloin 60 prosentin päätösvaltaisuus saavutetaan.

Kun luot kyselyn, avaa **Lisää asetuksia** ja syötä vaadittu prosenttiosuus kenttään **Päätösvaltaisuus**. Jätä kenttä tyhjäksi, jos päätösvaltaisuutta ei edellytetä.

![Päätösvaltaisuusasetus, jossa vaadittu osallistuminen on 60 prosenttia](./quorum-section.png)

Voit asettaa päätösvaltaisuuden myös [kyselymallissa](/en/user_manual/polls/poll_templates/), jolloin mallista luodut kyselyt käyttävät sitä oletuksena.

Jos kysely sulkeutuu ilman, että päätösvaltaisuus saavutetaan, Loomio näyttää, ettei päätösvaltaisuutta saavutettu. Kysely ei automaattisesti jatku tai peruunnu. Ketjun ylläpitäjä voi avata kyselyn uudelleen (jos se on sallittua) tai jakaa johtopäätöksen, jossa kerrotaan, mitä tapahtuu seuraavaksi.

<!-- translation-section: example-scenario -->

## Esimerkkitilanne

Oatmilk Cooperative keskustelee kuuden viikon kokeilusta, jossa käytetään palautettavia pulloja, ja sen on hyväksyttävä kokeilun budjetti.

Jamie valitsee **Aloita äänestys**, valitsee ehdotusmallin ja täyttää otsikon, tiedot, vaihtoehdot, keston ja äänestäjäasetukset.

![Ehdotuksen otsikko, tiedot, vaihtoehdot, kesto ja äänestäjäasetukset](proposal-options.png)

Jamie rajaa äänestyksen viiteen kokeilun budjetista vastaavaan henkilöön. Koska osuuskunta edellyttää merkittävissä päätöksissä 60 prosentin osallistumista, Jamie syöttää kenttään **Päätösvaltaisuus** arvon **60** ja käynnistää ehdotuksen.

Ennen kuin kukaan äänestää, tulospaneeli näyttää, ettei päätösvaltaisuutta ole saavutettu.

![Yhtään ääntä ei ole annettu, eikä 60 prosentin päätösvaltaisuutta ole vielä saavutettu](pie-chart-0.png)

Jamie valitsee Samaa mieltä ja Samira valitsee Eri mieltä. Kaavio päivittyy, mutta kaksi viidestä äänioikeutetusta äänestäjästä tarkoittaa vain 40 prosentin osallistumista, joten päätösvaltaisuutta ei vieläkään ole saavutettu.

![Kaksi viidestä äänestä on annettu, eikä päätösvaltaisuutta ole vielä saavutettu](pie-chart-40.png)

Alex valitsee sitten Samaa mieltä. Kolme viidestä äänioikeutetusta äänestäjästä on osallistunut, joten 60 prosentin päätösvaltaisuus on saavutettu. Vaatimuksen kohdalla näkyy nyt vihreä valintamerkki. Jamie voi sulkea kyselyn etuajassa tai odottaa muiden äänestäjien ääniä.

![Kolme viidestä äänestä on annettu, ja 60 prosentin päätösvaltaisuus on saavutettu](pie-chart-60.png)
