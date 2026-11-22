---
title: Pisteytys
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/polls/score/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
sections:
  introduction: 2d2ee7470b7af3e9
  when-to-use-score: c77f6021d2718aee
  example-score-possible-trial-locations: 3c9438177a822198
  set-up-the-poll: 7f31a87784ef45a1
  vote: 7d71803e67a4da5f
  read-the-results: 6c6967f4469924b0
  share-an-outcome: 37bfe6ea8e84da54
generated:
  introduction: 491555391984bb69
  when-to-use-score: a3e6f041f0d3c782
  example-score-possible-trial-locations: 111b53c35da0b187
  set-up-the-poll: 3fb92d07b2693af1
  vote: 1e78283356e7b7ae
  read-the-results: 2993a5ef62d25651
  share-an-outcome: 82c25677ac77a1d8
title_source: 38e5a46cbc5ad328
title_generated: 204f0c0fae94e97b
---

<!-- translation-section: introduction -->

# Pisteytys

Pisteytys mittaa, miten osallistujat arvioivat kutakin vaihtoehtoa yhteisellä numeroasteikolla. Valinnasta poiketen siinä pyydetään arvioimaan jokainen vaihtoehto, mikä kertoo sekä osallistujien mieltymyksistä että niiden voimakkuudesta.

<!-- translation-section: when-to-use-score -->

## Milloin käyttää pisteytystä

Käytä pisteytystä, kun jokaista vaihtoehtoa voidaan arvioida erikseen saman kysymyksen perusteella. Se sopii hyvin:

- projektin eri osien valmiuden arviointiin;
- useiden periaatteiden tärkeyden arviointiin;
- mahdollisten kokousaiheiden kiinnostavuuden mittaamiseen;
- avustushakemusten arviointiin yhteisen kriteerin perusteella; tai
- useiden ehdotusten soveltuvuuden vertailuun.

Määrittele, mitä asteikon alin ja ylin arvo tarkoittavat, jotta kaikki tulkitsevat luvut samalla tavalla. Käytä [Valintaa](/en/user_manual/polls/choose/), kun tarvitset vain valintoja, tai [Pistejakoa](/en/user_manual/polls/allocate/), kun osallistujien on tehtävä kompromisseja rajallisen pistebudjetin puitteissa.

<!-- translation-section: example-score-possible-trial-locations -->

## Esimerkki: pisteytä mahdolliset kokeilupaikat

Oatmilk-osuuskunta valitsee paikkoja palautuspullojen kokeilua varten. Se pyytää jäseniä pisteyttämään neljä paikkaa asteikolla 0 (**sopimaton**) – 10 (**ihanteellinen**) ja ottamaan huomioon asiakkaiden pääsyn paikalle, henkilöstön resurssit, varastoinnin ja pullojen noutokuljetukset.

<!-- translation-section: set-up-the-poll -->

## Luo kysely

Esitä yksi kysymys, joka soveltuu samalla tavalla jokaiseen vaihtoehtoon. Lisää arvioitavat kohteet, määritä **Minimipistemäärä** ja **Maksimipistemäärä** ja selitä asteikon ääriarvot lisätiedoissa. Voit lisätä vaihtoehdolle kuvauksen täsmentääksesi, mitä kunkin kohteen arviointi kattaa.

![](form.png)

Valitse asteikko, jota osallistujat voivat käyttää johdonmukaisesti. Asteikko 0–5 on nopea käyttää, ja asteikko 0–10 mahdollistaa tarkemmat erot. Käytä suppeinta kysymykseesi sopivaa asteikkoa — laajempi asteikko ei aina tuota parempia tuloksia.

Voit käyttää anonyymiä äänestystä tai näyttää vaihtoehdot satunnaisessa järjestyksessä vähentääksesi muiden osallistujien ja vaihtoehtojen järjestyksen vaikutusta vastauksiin.

<!-- translation-section: vote -->

## Äänestä

Osallistujat pisteyttävät jokaisen vaihtoehdon liukusäätimellä. Tässä esimerkissä äänestäjä antaa päärautatieaseman kahvilalle 8 pistettä, joenrantatorille 6 pistettä, yliopiston ravintola-alueelle 7 pistettä ja sataman toimistoille 5 pistettä.

![](voting.png)

Äänen perustelu kertoo, miten äänestäjä käytti asteikkoa. Tämä auttaa ryhmää arvioimaan, johtuuko matala pistemäärä todellisesta huolesta vai puuttuvista tiedoista.

<!-- translation-section: read-the-results -->

## Lue tulokset

Tulokset näyttävät jokaisesta vaihtoehdosta:

- **Pisteet**: kaikkien pistemäärien summan;
- **Tarkoittaa**: keskimääräisen pistemäärän; ja
- **Äänestäjät**: kuinka moni antoi vaihtoehdolle pistemäärän.

![](results.png)

Tässä esimerkissä **päärautatieaseman kahvilalla** on korkein keskiarvo, 7,5. **Sataman toimistoilla** on matalin keskiarvo, 5,25, kun taas joenrantatorin ja yliopiston ravintola-alueen keskiarvo on kummallakin 7. Neljä viidestä kutsutusta on äänestänyt, joten yksi vastaus vielä puuttuu.

Vertaa keskiarvoja vain, kun vaihtoehdoilla on suunnilleen yhtä monta äänestäjää. Lue äänten perustelut ennen kuin pidät pientä eroa merkittävänä.

<!-- translation-section: share-an-outcome -->

## Jaa johtopäätös

Kun kysely sulkeutuu, jaa johtopäätös. Kerro, mihin toimiin pistemäärien perusteella ryhdytään ja miten mahdolliset tasatilanteet ratkaistaan. Lue johtopäätösten käytöstä kohdasta [Jaa johtopäätös](/en/user_manual/polls/intro_to_decisions#5-share-an-outcome).

![Johtopäätös, jossa valitaan korkeimman keskimääräisen pistemäärän saanut paikka](outcome.png)
