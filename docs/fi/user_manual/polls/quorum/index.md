---
title: Päätösvaltaisuus
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/polls/quorum/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-29'
sections:
  introduction: 0bf465006210877b
  example-scenario: 6596ad44e1c046b4
generated:
  introduction: 3f21e30e9c9f9b42
  example-scenario: f29f0657c388685a
title_source: 18ed8b6c5ab90343
title_generated: 231a357976471e5a
---

<!-- translation-section: introduction -->

# Päätösvaltaisuus

Päätösvaltaisuuden saavuttamiseksi äänestykseen on osallistuttava vähintään tietyn prosenttiosuuden äänioikeutetuista. Voit käyttää osallistumisrajaa, kun päätöksentekotapanne edellyttää tiettyä osallistumistasoa.

Kun luot kyselyn, avaa **Lisää asetuksia** ja syötä vaadittu prosenttiosuus kohtaan **Osallistumispäätösvaltaisuus**. Jätä kenttä tyhjäksi, jos osallistumisrajaa ei tarvita.

![Päätösvaltaisuuden asetus, jossa osallistumisraja on 60 prosenttia](./quorum-section.png)

Voit asettaa osallistumisrajan myös [kyselymalliin](/en/user_manual/polls/poll_templates/). Silloin mallista luodut kyselyt käyttävät sitä oletusarvoisesti.

<!-- translation-section: example-scenario -->

## Esimerkkitilanne

Oatmilk-osuuskunta keskustelee kuuden viikon kokeilusta, jossa käytetään palautettavia pulloja. Keskustelu on edennyt vaiheeseen, jossa osuuskunnan on hyväksyttävä kokeilun budjetti.

Jamie valitsee **Aloita äänestys**, valitsee **Suostumus**-ehdotusmallin ja täyttää otsikon, kuvauksen, vaihtoehdot, keston ja äänestäjien asetukset.

![Ehdotuksen otsikko, kuvaus, vaihtoehdot, kesto ja äänestäjien asetukset](proposal-options.png)

Jamie rajaa äänestyksen viiteen henkilöön, jotka vastaavat kokeilun budjetista.

Osuuskunta edellyttää merkittävissä päätöksissä 60 prosentin osallistumista. Siksi Jamie syöttää osallistumispäätösvaltaisuuden kenttään **60** ja aloittaa ehdotuksen.

Ennen ensimmäistä ääntä tulospaneeli näyttää, ettei osallistumisrajaa ole saavutettu.

![Yhtään ääntä ei ole annettu eikä 60 prosentin osallistumisrajaa ole saavutettu](pie-chart-0.png)

Jamie kannattaa ehdotusta ja Samira vastustaa sitä. Kaavio päivittyy, mutta kaksi viidestä äänioikeutetusta tarkoittaa vain 40 prosentin osallistumista. Osallistumisrajaa ei siis ole vielä saavutettu.

![Kaksi viidestä äänestä on annettu eikä osallistumisrajaa ole vielä saavutettu](pie-chart-40.png)

Sitten Alex kannattaa ehdotusta. Kolme viidestä äänioikeutetusta on osallistunut, joten 60 prosentin osallistumisraja täyttyy. Vaatimuksen kohdalla näkyy nyt vihreä valintamerkki. Jamie voi sulkea kyselyn etuajassa tai odottaa jäljellä olevia äänestäjiä.

![Kolme viidestä äänestä on annettu ja 60 prosentin osallistumisraja on saavutettu](pie-chart-60.png)
