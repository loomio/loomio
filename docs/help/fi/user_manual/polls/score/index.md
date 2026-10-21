---
title: Pisteytys
source_revision: 924e704b41670a012a16528cf88edf90f8d6b572
source_file: docs/en/user_manual/polls/score/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: 7881bcdd5aad5df4
  when-to-use-score: 0ef92ec0bb907a3f
  example-score-possible-trial-locations: 3c9438177a822198
  set-up-the-poll: 29b0296533594cd6
  vote: 1113501e9e6736b7
  read-the-results: 3e996e9bcc830d1d
  share-an-outcome: 243aaac17e645331
generated:
  introduction: 785fff131238c0b3
  when-to-use-score: c896dd7329d13faf
  example-score-possible-trial-locations: 111b53c35da0b187
  set-up-the-poll: 634779c9afe18fbd
  vote: 07b42e393a741975
  read-the-results: 0c9543c0a6f0b213
  share-an-outcome: 82c25677ac77a1d8
title_source: 38e5a46cbc5ad328
title_generated: 204f0c0fae94e97b
needs_review:
  read-the-results: use "Pisteytys" instead of "pisteet" for "Score"
---

<!-- translation-section: introduction -->

# Pisteytys

Pisteytys mittaa, miten osallistujat arvioivat kutakin vaihtoehtoa yhteisellä numeroasteikolla. Valinnasta poiketen siinä pyydetään arvioimaan jokainen vaihtoehto, joten tulokset kertovat sekä osallistujien mieltymyksistä että niiden voimakkuudesta.

<!-- translation-section: when-to-use-score -->

## Milloin käyttää pisteytystä

Käytä pisteytystä, kun jokaista vaihtoehtoa voidaan arvioida erikseen saman kysymyksen perusteella. Se sopii hyvin:

- projektin eri osien valmiuden arviointiin;
- useiden periaatteiden tärkeyden arviointiin;
- mahdollisten kokousaiheiden kiinnostavuuden mittaamiseen;
- avustushakemusten arviointiin yhteisen kriteerin perusteella; tai
- useiden ehdotusten soveltuvuuden vertailuun.

Määrittele, mitä asteikon alin ja ylin arvo tarkoittavat. Ilman yhteistä määritelmää sama luku voi tarkoittaa eri äänestäjille eri asioita. Käytä [Valintaa](/en/user_manual/polls/choose/), kun tarvitset vain valintoja, tai [Pistejakoa](/en/user_manual/polls/allocate/), kun osallistujien on tehtävä kompromisseja rajallisen pistebudjetin puitteissa.

<!-- translation-section: example-score-possible-trial-locations -->

## Esimerkki: pisteytä mahdolliset kokeilupaikat

Oatmilk-osuuskunta valitsee paikkoja palautuspullojen kokeilua varten. Se pyytää jäseniä pisteyttämään neljä paikkaa asteikolla 0 (**sopimaton**) – 10 (**ihanteellinen**) ja ottamaan huomioon asiakkaiden pääsyn paikalle, henkilöstön resurssit, varastoinnin ja pullojen noutokuljetukset.

<!-- translation-section: set-up-the-poll -->

## Luo kysely

Esitä yksi kysymys, joka soveltuu samalla tavalla jokaiseen vaihtoehtoon. Lisää arvioitavat kohteet, määritä **Minimipistemäärä** ja **Maksimipistemäärä** ja selitä asteikon ääriarvot lisätiedoissa. Vaihtoehtojen kuvauksilla voit täsmentää, mitä kunkin kohteen arviointi kattaa.

![](form.png)

Valitse asteikko, jota osallistujat voivat käyttää johdonmukaisesti. Asteikko 0–5 on nopea käyttää, ja asteikko 0–10 mahdollistaa tarkemmat erot. Suurempi tarkkuus ei välttämättä tuota parempaa tietoa, joten käytä suppeinta kysymykseen sopivaa asteikkoa.

Anonyymi äänestys ja vaihtoehtojen näyttäminen satunnaisessa järjestyksessä voivat olla hyödyllisiä, kun haluat vähentää muiden ihmisten tai vaihtoehtojen järjestyksen vaikutusta vastauksiin.

<!-- translation-section: vote -->

## Äänestä

Osallistujat pisteyttävät jokaisen vaihtoehdon liukusäätimellä. Tässä esimerkissä äänestäjä antaa päärautatieaseman kahvilalle 8 pistettä, joenrantatorille 6 pistettä, yliopiston ravintola-alueelle 7 pistettä ja sataman toimistoille 5 pistettä.

![](voting.png)

Perustelu kertoo, miten äänestäjä käytti asteikkoa. Tämä auttaa ryhmää erottamaan puuttuvista tiedoista johtuvan matalan pistemäärän vaihtoehtoon liittyvästä huolesta johtuvasta matalasta pistemäärästä.

<!-- translation-section: read-the-results -->

## Lue tulokset

Tulokset näyttävät jokaisesta vaihtoehdosta:

- **Pisteet**: kaikkien pistemäärien summan;
- **Tarkoittaa**: keskimääräisen pistemäärän; ja
- **Äänestäjät**: kuinka moni antoi vaihtoehdolle pistemäärän.

![](results.png)

Tässä esimerkissä **Central Station -kahvilalla** on korkein keskiarvo, 7,5. **Harbourin toimistoilla** on matalin keskiarvo, 5,25, kun taas Riversiden torin ja yliopiston ravintola-alueen keskiarvo on kummallakin 7. Neljä viidestä kutsutusta on äänestänyt, joten ryhmä näkee myös, että yksi vastaus vielä puuttuu.

Vertaa keskiarvoja vain, kun vaihtoehdoilla on suunnilleen yhtä monta äänestäjää. Lue äänten perustelut ennen kuin pidät pientä eroa merkittävänä.

<!-- translation-section: share-an-outcome -->

## Jaa johtopäätös

Kun kysely sulkeutuu, jaa johtopäätös. Kerro, mihin toimiin pistemäärien perusteella ryhdytään ja miten mahdolliset tasatilanteet ratkaistaan. Lue johtopäätösten käytöstä kohdasta [Jaa johtopäätös](/en/user_manual/polls/intro_to_decisions#5-share-an-outcome).

![Johtopäätös, jossa valitaan korkeimman keskimääräisen pistemäärän saanut paikka](outcome.png)
