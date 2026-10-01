---
title: Ääniosuusvaatimukset
source_revision: 9c60c42fc739483fa23f15d9f34a1e9245518092
source_file: docs/en/user_manual/polls/vote_share_requirements/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: 57d7127721bebf93
  eligible-voters-and-votes-cast: 930bbc475f734396
  different-vote-share-requirements: cfdfd13a0a6a8b38
  detailed-example: 395dbccb0e6427fc
generated:
  introduction: c6375836afa2867f
  eligible-voters-and-votes-cast: 00f56fe9161667e6
  different-vote-share-requirements: da851b255793bf5e
  detailed-example: '0428d2fc493422a4'
title_source: a654891ca817844e
title_generated: 49e9c181193d6bed
---

<!-- translation-section: introduction -->

# Ääniosuusvaatimukset

Aseta vaihtoehdolle ääniosuusvaatimus, kun ehdotuksen hyväksyminen edellyttää tiettyä kannatusprosenttia tai sitä, että vastustus jää tietyn prosenttiosuuden alle.

Voit yhdistää ääniosuusvaatimuksen [päätösvaltaisuusvaatimukseen](/en/user_manual/polls/quorum/), jolloin ehdotuksen hyväksyminen edellyttää sekä riittävää osallistumista että tiettyä äänten jakautumista.

Valitse ehdotuslomakkeessa vaihtoehdon vieressä oleva muokkauskuvake.

![Samaa mieltä -vaihtoehdon vieressä oleva muokkauskuvake](edit-highlight-on-option.png)

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

Vaihtoehdon vaatimukseksi asetetaan usein **Enintään 0%**. Se tarkoittaa, ettei ehdotusta voida hyväksyä, jos joku valitsee kyseisen vaihtoehdon. Käytä tätä vaatimusta **Lohko**-vaihtoehdossa, jotta yksikin estävä ääni estää ehdotuksen hyväksymisen.

Voit lisätä vaatimukset myös [kyselymalliin](/en/user_manual/polls/poll_templates/), jolloin mallista luodut uudet ehdotukset käyttävät niitä oletusarvoisesti.

<!-- translation-section: detailed-example -->

## Yksityiskohtainen esimerkki

Oatmilk-osuuskunta päättää, toteuttaako se kuuden viikon palautuspullokokeilun. Viidellä henkilöllä on äänioikeus.

Osuuskunnan prosessi edellyttää, että vähintään 75 prosenttia äänestäjäoikeutetuista kannattaa ehdotusta. Jamie muokkaa ehdotuksen **Samaa mieltä** -vaihtoehtoa, ottaa sen ääniosuusvaatimuksen käyttöön ja asettaa vaatimukseksi **Vähintään 75% äänestäjäoikeutetuista**.

![Samaa mieltä -vaihtoehto, jota vähintään 75 prosentin äänestäjäoikeutetuista on kannatettava](./agree-vote-option.png)

Jamie asettaa myös 60 prosentin päätösvaltaisuusvaatimuksen. Jamie ja Samira äänestävät ehdotuksen puolesta. Kaikki annetut äänet kannattavat ehdotusta, mutta ne edustavat vain 40 prosenttia äänestäjäoikeutetuista. Kumpikaan vaatimus ei siis täyty.

![Kaksi viidestä henkilöstä on äänestänyt ehdotuksen puolesta, eikä kumpikaan vaatimus täyty](./first-vote-breakdown.png)

Sen jälkeen Alex ja Morgan äänestävät ehdotuksen puolesta ja Taylor sitä vastaan. Kaikki viisi ovat nyt äänestäneet, joten päätösvaltaisuusvaatimus täyttyy. Neljä viidestä äänestäjäoikeutetusta kannattaa ehdotusta. Kannatus on 80 prosenttia, mikä ylittää 75 prosentin ääniosuusvaatimuksen. Molempien vaatimusten kohdalla näkyy vihreä valintamerkki.

![Kaikki viisi henkilöä ovat äänestäneet, ja molemmat vaatimukset täyttyvät](./final-vote-breakdown.png)
