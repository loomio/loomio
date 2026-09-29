---
title: Ääniosuusvaatimukset
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/polls/vote_share_requirements/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-29'
sections:
  introduction: c97281f29d615dea
  eligible-voters-and-votes-cast: 930bbc475f734396
  different-vote-share-requirements: 0d25794ec996d42c
  detailed-example: dc765c43a22a28a1
generated:
  introduction: c351b35c63754224
  eligible-voters-and-votes-cast: 00f56fe9161667e6
  different-vote-share-requirements: 02ec31cece988956
  detailed-example: c8a6041306a71bbf
title_source: a654891ca817844e
title_generated: 49e9c181193d6bed
---

<!-- translation-section: introduction -->

# Ääniosuusvaatimukset

Aseta vaihtoehdolle ääniosuusvaatimus, kun ehdotuksen hyväksyminen edellyttää tiettyä kannatusprosenttia tai sitä, että vastustus jää tietyn prosenttiosuuden alle.

Voit yhdistää ääniosuusvaatimuksen [päätösvaltaisuusvaatimukseen](/en/user_manual/polls/quorum/), jolloin ehdotuksen hyväksyminen edellyttää sekä riittävää osallistumista että tiettyä äänten jakautumista.

Kun luot ehdotusta, valitse vaihtoehdon vieressä oleva muokkauskuvake.

![Suostumus-vaihtoehdon vieressä oleva muokkauskuvake](edit-highlight-on-option.png)

<!-- translation-section: eligible-voters-and-votes-cast -->

## Äänestäjäoikeutetut ja annetut äänet

Prosenttiosuuden perusteeksi voit valita joko **Annetut äänet** tai **Äänestäjäoikeutetut**.

![Valinta, lasketaanko ääniosuusvaatimus annetuista äänistä vai äänestäjäoikeutetuista](./eligible-vs-cast.png)

**Äänestäjäoikeutetut** tarkoittaa kaikkia, jotka voivat äänestää ehdotuksessa. **Annetut äänet** tarkoittaa vain lähetettyjä ääniä.

Jos vaatimus on 75 prosenttia äänestäjäoikeutetuista, ehdotus voidaan hyväksyä vain, kun vähintään 75 prosenttia kaikista äänestäjäoikeutetuista äänestää kyseisen vaihtoehdon puolesta.

Jos vaatimus on 60 prosenttia annetuista äänistä, ehdotus voidaan hyväksyä, kun 60 prosenttia lähetetyistä äänistä kannattaa vaihtoehtoa, vaikka kaikki äänestäjäoikeutetut eivät äänestäisi. Lisää päätösvaltaisuusvaatimus, jos prosessisi edellyttää myös osallistumisen vähimmäistasoa.

<!-- translation-section: different-vote-share-requirements -->

## Useita ääniosuusvaatimuksia

Voit asettaa vaatimuksia ehdotuksen useammalle vaihtoehdolle. Esimerkiksi:

- Kannatuksen on oltava vähintään 75 prosenttia äänestäjäoikeutetuista
- Äänestämisestä pidättäytyvien osuus saa olla enintään 30 prosenttia annetuista äänistä
- Ehdotuksen estävien äänten osuus saa olla enintään 0 prosenttia annetuista äänistä

Voit lisätä vaatimukset myös [kyselymalliin](/en/user_manual/polls/poll_templates/), jolloin mallista luodut uudet ehdotukset käyttävät niitä oletusarvoisesti.

<!-- translation-section: detailed-example -->

## Yksityiskohtainen esimerkki

Oatmilk-osuuskunta päättää, hyväksyykö se kuuden viikon palautuspullokokeilun budjetin. Viidellä henkilöllä on äänioikeus.

Jamie käyttää **Suostumus**-ehdotusmallia, muokkaa Suostumus-vaihtoehtoa ja ottaa sen ääniosuusvaatimuksen käyttöön.

Osuuskunnan prosessi edellyttää, että vähintään 75 prosenttia äänestäjäoikeutetuista kannattaa ehdotusta. Jamie asettaa vaatimukseksi **Vähintään 75% Äänestäjäoikeutetut**.

![Suostumus-vaihtoehto, jota on kannatettava vähintään 75 prosentin äänestäjäoikeutetuista](./consent-vote-option.png)

Jamie asettaa myös 60 prosentin päätösvaltaisuusvaatimuksen. Jamie ja Samira äänestävät ehdotuksen puolesta. Kaikki annetut äänet kannattavat ehdotusta, mutta ne edustavat vain 40 prosenttia äänestäjäoikeutetuista. Kumpikaan vaatimus ei siis täyty.

![Kaksi viidestä henkilöstä on äänestänyt ehdotuksen puolesta, eikä kumpikaan vaatimus täyty](./first-vote-breakdown.png)

Sen jälkeen Alex ja Morgan äänestävät ehdotuksen puolesta ja Taylor sitä vastaan. Kaikki viisi ovat nyt äänestäneet, joten päätösvaltaisuusvaatimus täyttyy. Neljä viidestä äänestäjäoikeutetusta kannattaa ehdotusta. Kannatus on 80 prosenttia, mikä ylittää 75 prosentin ääniosuusvaatimuksen. Molempien vaatimusten kohdalla näkyy vihreä valintamerkki.

![Kaikki viisi henkilöä ovat äänestäneet, ja molemmat vaatimukset täyttyvät](./final-vote-breakdown.png)
