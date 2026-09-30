---
title: Pisteytys
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/polls/score/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-29'
sections:
  introduction: 7881bcdd5aad5df4
  when-to-use-score: 0ef92ec0bb907a3f
  example-score-possible-trial-locations: 3c9438177a822198
  set-up-the-poll: 29b0296533594cd6
  vote: 1113501e9e6736b7
  read-the-results: f773aa25f47c325b
generated:
  introduction: 75e5412423e51b50
  when-to-use-score: 2e699bfbf9f8f55a
  example-score-possible-trial-locations: 9c495407e5041276
  set-up-the-poll: 40622886f3bf045f
  vote: aff239a480d9d9ca
  read-the-results: eaa29e93edddf5a9
title_source: 38e5a46cbc5ad328
title_generated: 204f0c0fae94e97b
---

<!-- translation-section: introduction -->

# Pisteytys

Pisteytyksessä osallistujat arvioivat jokaisen vaihtoehdon samalla numeroasteikolla. Jokainen vastaa kaikkiin vaihtoehtoihin. Tuloksista näet, mitä osallistujat pitävät parempana ja kuinka vahvasti.

<!-- translation-section: when-to-use-score -->

## Milloin käyttää pisteytystä

Käytä pisteytystä, kun jokaisen vaihtoehdon voi arvioida erikseen saman kysymyksen perusteella. Se sopii esimerkiksi:

- projektin eri osien valmiuden arviointiin;
- useiden periaatteiden tärkeyden arviointiin;
- mahdollisten kokousaiheiden kiinnostavuuden mittaamiseen;
- apurahahakemusten arviointiin samalla perusteella; tai
- useiden ehdotusten soveltuvuuden vertailuun.

Määrittele, mitä asteikon pienin ja suurin arvo tarkoittavat. Ilman yhteistä määritelmää sama luku voi tarkoittaa eri äänestäjille eri asioita. Käytä [Valintaa](/en/user_manual/polls/choose/), jos tarvitset vain valinnat, tai [Pisteiden jakoa](/en/user_manual/polls/allocate/), jos osallistujien on jaettava rajallinen pistemäärä vaihtoehtojen kesken.

<!-- translation-section: example-score-possible-trial-locations -->

## Esimerkki: kokeilupaikkojen pisteyttäminen

Oatmilk Cooperative valitsee paikkoja palautettavien pullojen kokeiluun. Se pyytää jäseniä pisteyttämään neljä paikkaa asteikolla 0 (**sopimaton**) – 10 (**ihanteellinen**). Arvioinnissa huomioidaan asiakkaiden pääsy paikalle, henkilöstön kapasiteetti, varastointi ja pullojen keräyskuljetukset.

<!-- translation-section: set-up-the-poll -->

## Luo kysely

Esitä yksi kysymys, joka koskee kaikkia vaihtoehtoja samalla tavalla. Lisää arvioitavat kohteet, aseta **Minimipistemäärä** ja **Maksimipistemäärä** ja selitä asteikon ääripäät lisätiedoissa. Voit täsmentää kunkin kohteen arvioinnin laajuutta vaihtoehtojen kuvauksissa.

![](form.png)

Valitse asteikko, jota osallistujat voivat käyttää johdonmukaisesti. Asteikko 0–5 on nopea käyttää, kun taas asteikko 0–10 mahdollistaa tarkemmat erot. Tarkempi asteikko ei välttämättä tuota parempaa tietoa, joten valitse kysymykseen sopiva mahdollisimman lyhyt asteikko.

Anonyymi äänestys ja vaihtoehtojen näyttäminen satunnaisessa järjestyksessä voivat vähentää muiden ihmisten ja vaihtoehtojen järjestyksen vaikutusta vastauksiin.

<!-- translation-section: vote -->

## Äänestä

Osallistujat pisteyttävät jokaisen vaihtoehdon liukusäätimellä. Tässä esimerkissä äänestäjä antaa Central Station cafelle 8 pistettä, Riverside marketille 6, University food courtille 7 ja Harbour officesille 5.

![](voting.png)

Äänestyksen perustelu kertoo, miten äänestäjä käytti asteikkoa. Se auttaa ryhmää erottamaan, johtuuko pieni pistemäärä tiedon puutteesta vai varsinaisesta huolesta.

<!-- translation-section: read-the-results -->

## Lue tuloksia

Tuloksissa näkyy jokaiselle vaihtoehdolle:

- **Pisteet**: kaikkien annettujen pisteiden summa;
- **Tarkoittaa**: pisteiden keskiarvo; ja
- **Äänestäjät**: kuinka moni pisteytti vaihtoehdon.

![](results.png)

Tässä esimerkissä **Central Station cafen** keskiarvo on korkein, 7,5. **Harbour officesin** keskiarvo on matalin, 5,25. Riverside marketin ja University food courtin keskiarvo on kummankin 7. Kutsutuista viidestä henkilöstä neljä on äänestänyt, joten ryhmä näkee myös, että yksi vastaus puuttuu.

Vertaa keskiarvoja vain silloin, kun vaihtoehdoilla on suunnilleen yhtä monta äänestäjää. Lue äänestysten perustelut ennen kuin pidät pientä eroa merkityksellisenä. Julkaise lopuksi päätelmä, jossa kerrot, mihin toimiin pisteiden perusteella ryhdytään.
