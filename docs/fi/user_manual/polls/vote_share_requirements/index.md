---
title: Ääniosuusvaatimukset
source_revision: 924e704b41670a012a16528cf88edf90f8d6b572
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
  introduction: c10b52e202ae3194
  eligible-voters-and-votes-cast: 21bd5da2dbae05e0
  different-vote-share-requirements: 355553d529308add
  detailed-example: c8bf82311c2e1fb4
title_source: a654891ca817844e
title_generated: 49e9c181193d6bed
---

<!-- translation-section: introduction -->

# Ääniosuusvaatimukset

Aseta vaihtoehdolle ääniosuusvaatimus, kun ehdotuksen hyväksyminen edellyttää tiettyä kannatusprosenttia tai sitä, että vastustus jää tietyn prosenttiosuuden alle.

Ääniosuusvaatimukset voi yhdistää [päätösvaltaisuuteen](/en/user_manual/polls/quorum/), jolloin vaaditaan sekä riittävää osallistumista että tiettyä äänten jakaumaa.

Valitse ehdotuslomakkeessa vaihtoehdon vieressä oleva muokkauskuvake.

![Muokkauskuvake Samaa mieltä -vaihtoehdon vieressä](edit-highlight-on-option.png)

<!-- translation-section: eligible-voters-and-votes-cast -->

## Äänestäjäoikeutetut ja annetut äänet

Prosenttiosuus voi perustua joko **Annettuihin ääniin** tai **Äänestäjäoikeutettuihin**.

![Valinta, perustuuko ääniosuusvaatimus annettuihin ääniin vai äänestäjäoikeutettuihin](./eligible-vs-cast.png)

**Äänestäjäoikeutetut** tarkoittaa kaikkia, jotka voivat äänestää ehdotuksessa. **Annetut äänet** tarkoittaa vain jo annettuja ääniä.

Vaatimus, jonka mukaan 75 prosentin äänestäjäoikeutetuista on oltava samaa mieltä, voi täyttyä vain, kun vähintään 75 prosenttia kaikista äänestäjäoikeutetuista äänestää kyseistä vaihtoehtoa.

Vaatimus, jonka mukaan 60 prosentin annetuista äänistä on tuettava vaihtoehtoa, voi täyttyä osallistumisasteesta riippumatta. Lisää päätösvaltaisuusvaatimus, jos toimintatapasi edellyttää myös tiettyä vähimmäisosallistumista.

<!-- translation-section: different-vote-share-requirements -->

## Erilaiset ääniosuusvaatimukset

Ehdotuksessa voi olla vaatimuksia usealle vaihtoehdolle. Esimerkiksi:

- Samaa mieltä on oltava vähintään 75 prosenttia äänestäjäoikeutetuista
- Tyhjiä ääniä saa olla enintään 30 prosenttia annetuista äänistä
- Vetoääniä saa olla enintään 0 prosenttia annetuista äänistä

Vaihtoehdon asettaminen arvoon **Enintään 0 %** on yleinen käytäntö. Se tarkoittaa, ettei ehdotusta voi hyväksyä, jos yksikin henkilö valitsee kyseisen vaihtoehdon. Käytä tätä **Veto**-vaihtoehdossa, jotta yksikin veto estää ehdotuksen hyväksymisen.

Voit lisätä vaatimuksia myös [kyselymalliin](/en/user_manual/polls/poll_templates/), jolloin mallista luodut uudet ehdotukset käyttävät niitä oletusarvoisesti.

<!-- translation-section: detailed-example -->

## Yksityiskohtainen esimerkki

Oatmilk-osuuskunta päättää, kokeileeko se palautettavia pulloja kuuden viikon ajan. Viidellä henkilöllä on äänestysoikeus.

Osuuskunnan toimintatapa edellyttää, että vähintään 75 prosenttia äänestäjäoikeutetuista on samaa mieltä. Jamie muokkaa ehdotuksen **Samaa mieltä** -vaihtoehtoa, ottaa sen ääniosuusvaatimuksen käyttöön ja asettaa sen arvoon **Vähintään 75 % äänestäjäoikeutetuista**.

![Samaa mieltä -vaihtoehto, joka edellyttää vähintään 75 prosentin kannatusta äänestäjäoikeutetuilta](./agree-vote-option.png)

Jamie asettaa myös 60 prosentin päätösvaltaisuusvaatimuksen. Jamie ja Samira äänestävät Samaa mieltä -vaihtoehtoa. Kaikki annetut äänet tukevat ehdotusta, mutta ne edustavat vain 40 prosenttia äänestäjäoikeutetuista, joten kumpikaan vaatimus ei täyty.

![Kaksi viidestä henkilöstä on äänestänyt Samaa mieltä -vaihtoehtoa, eikä kumpikaan vaatimus täyty](./first-vote-breakdown.png)

Seuraavaksi Alex ja Morgan äänestävät Samaa mieltä -vaihtoehtoa ja Taylor Eri mieltä -vaihtoehtoa. Kaikki viisi henkilöä ovat äänestäneet, joten päätösvaltaisuusvaatimus täyttyy, ja neljä viidestä äänestäjäoikeutetusta on samaa mieltä. 80 prosentin kannatus ylittää 75 prosentin ääniosuusvaatimuksen, joten kummankin vaatimuksen kohdalla näkyy vihreä valintamerkki.

![Kaikki viisi henkilöä ovat äänestäneet, ja molemmat vaatimukset täyttyvät](./final-vote-breakdown.png)
