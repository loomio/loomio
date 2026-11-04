---
title: STV-vaalit
source_revision: 924e704b41670a012a16528cf88edf90f8d6b572
source_file: docs/en/user_manual/polls/stv/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: 6c43a75f60922bb6
  when-to-use-stv: e37de389c27f7d87
  creating-an-stv-election: 2d475191d922803f
  number-of-seats: 9463d911f230eea0
  counting-method: b7ff2dce779d15c1
  quota-type: f9ab31d93916bf24
  how-voting-works: bace7c735dbb39f1
  how-counting-works: 794084f981b2cf3f
  understanding-results: 8442813a9c097112
  method-and-quota: 90113296c3d59816
  elected-candidates: 7ac0bae756fa5608
  round-by-round-details: c0ccc83e51dcaa1a
  exporting-ballots: 582555dd13633bf0
  share-an-outcome: 6a02aed173b368b9
generated:
  introduction: 68b8b8feb6549c78
  when-to-use-stv: 59b07f03d2112224
  creating-an-stv-election: bb9f4fddb6f11622
  number-of-seats: 57a64a8a633bd658
  counting-method: f2ce1d1650138002
  quota-type: 203478e87fa93d24
  how-voting-works: 2599ede84ef7f5b6
  how-counting-works: 68feaac7e24776ca
  understanding-results: 8de9cde353ad71d3
  method-and-quota: 67344bd4b5a1542e
  elected-candidates: b1c501489ee425e1
  round-by-round-details: 697065e385581a07
  exporting-ballots: d226f324af38bbd6
  share-an-outcome: 89428b23fffa8b24
title_source: cd3e1a4cdc2456a6
title_generated: 5db74b13bec93710
---

<!-- translation-section: introduction -->

# STV-vaalit

**Siirtoäänivaali (STV)** on suhteellista edustusta tuottava äänestystapa, jolla valitaan useita voittajia ehdokkaiden joukosta. Se varmistaa, että valitut ehdokkaat edustavat suhteellisesti äänestäjien erilaisia näkemyksiä.

<!-- translation-section: when-to-use-stv -->

## Milloin STV-vaaleja kannattaa käyttää

Käytä STV-vaaleja, kun haluat:

- Valita **toimikunnan, hallituksen tai edustajajoukon** ehdokkaiden joukosta
- Varmistaa **suhteellisen edustuksen**, jossa vähemmistöryhmät voivat saada paikkoja kannatuksensa suhteessa
- Järjestää vaalit, joissa äänestäjät asettavat ehdokkaat mieltymysjärjestykseen

>[!NOTE]
>STV **ei** ole sama kuin Loomion [Järjestys-kysely](/en/user_manual/polls/rank/), joka käyttää yksinkertaisempaa pisteisiin perustuvaa järjestystä yhden parhaan vaihtoehdon valitsemiseen. STV-vaaleissa valitaan useita voittajia siirtämällä ääniä ja pudottamalla ehdokkaita eri kierroksilla.

<!-- translation-section: creating-an-stv-election -->

## STV-vaalien luominen

Kun aloitat kyselyn, valitse kyselytyypiksi **STV-vaalit** ja lisää sitten ehdokkaat kyselyn vaihtoehdoiksi. Voit mukauttaa kyselyä määrittämällä **paikkojen määrän**, **laskentamenetelmän** ja **kiintiötyypin**.

Tässä esimerkissä Oatmilk Cooperative valitsee kolme henkilöä valvomaan palautettavien pakkausten kokeilua. Lomakkeessa kuvataan tehtävä, luetellaan viisi ehdokasta ja käytetään skotlantilaista STV-menetelmää sekä Droopin kiintiötä.

![](form.png)

<!-- translation-section: number-of-seats -->

### Paikkojen määrä

Kuinka monta voittajaa valitaan. Määrän on oltava pienempi kuin ehdokkaiden määrä.

<!-- translation-section: counting-method -->

### Laskentamenetelmä

Äänten laskemiseen on käytettävissä kaksi menetelmää:

Skotlantilainen STV
  : Suositeltu. Painotettu kattava Gregoryn menetelmä (Weighted Inclusive Gregory Method, WIGM), jota on käytetty Skotlannin paikallisvaaleissa vuodesta 2007. Säännöt ovat täsmälliset ja selkeät. Sopii parhaiten useimmille organisaatioille.
  
Meekin STV
  : Tarkempi menetelmä, jossa äänten laskeminen vaatii tietokoneen. Kun ehdokas on valittu, Meekin menetelmä siirtää jatkuvasti sen osan kustakin äänestä, jota ehdokas ei tarvitse, äänestäjän seuraaville mieltymyksille. Tämä koskee myös ääniä, jotka siirtyvät ehdokkaalle myöhemmin laskennassa. Kun ehdokas putoaa, äänet lasketaan uudelleen kuin hän ei olisi koskaan ollut ehdolla. Ääniä menee hukkaan vähemmän kuin skotlantilaisessa STV-menetelmässä, mutta laskentaa ei voi tarkistaa käsin.

<!-- translation-section: quota-type -->

### Kiintiötyyppi

Kiintiö on vähimmäisäänimäärä, jonka ehdokas tarvitsee saadakseen paikan. Vaihtoehdot ovat:

Droop
  : Suositeltu. STV-vaalien tavallinen kiintiö, jota käytetään Irlannissa, Australiassa ja Skotlannissa. Se on pienin kiintiö, jonka voi saavuttaa enintään yhtä moni ehdokas kuin paikkoja on. Äänestäjäjoukko, joka asettaa omat ehdokkaansa ensimmäisiksi, saa vähintään yhtä monta paikkaa kuin sen äänimäärään sisältyy kokonaisia kiintiöitä. Se lasketaan näin:
\\[ floor(\frac{votes}{(seats + 1)}) + 1 \\]

Hare
  : Suurempi kiintiö. Suuren äänimäärän saaneet joukot käyttävät enemmän ääniään kuhunkin saamaansa paikkaan, joten pienemmät joukot saavat todennäköisemmin viimeiset paikat. Se lasketaan näin:
    \\[ \frac{votes}{seats}\\]

Molemmissa kaavoissa *votes* tarkoittaa niiden äänestyslippujen määrää, joissa vähintään yksi ehdokas on asetettu mieltymysjärjestykseen.

Meekin STV laskee kiintiön ilman pyöristystä. Droopin kiintiön kaava on votes ÷ (seats + 1). Menetelmä laskee kiintiön uudelleen jokaisella kierroksella ehdokkailla yhä olevien äänten perusteella, ja ehdokkaan on ylitettävä kiintiö tullakseen valituksi.
  
  >[!TIP]
  > Droopin kiintiö on aina äänimäärältään pienempi kuin Haren kiintiö. Esimerkiksi vaaleissa, joissa on 100 ääntä ja neljä paikkaa, Droopin kiintiö olisi 21 ja Haren kiintiö 25.

<!-- translation-section: how-voting-works -->

## Miten äänestäminen toimii

Tässä esimerkissä Oatmilk Cooperative valitsee kolme henkilöä valvomaan uudelleenkäytettävien pakkausten kokeilua. Äänestäjät vetävät ehdokkaat viivan yläpuolelle ja asettavat heidät mieltymysjärjestykseen:

![](stv-vote-in-progress.png)

- **Järjestys 1** = mieluisin ehdokas
- **Järjestys 2** = toiseksi mieluisin ehdokas
- Jatka asettamalla järjestykseen niin monta ehdokasta kuin haluat

Äänestäjien on asetettava järjestykseen vähintään yksi ehdokas, mutta kaikkia ehdokkaita ei tarvitse järjestää. Järjestämättä jätetyt ehdokkaat eivät saa lainkaan kyseisen äänestäjän tukea.

<!-- translation-section: how-counting-works -->

## Miten äänten laskenta toimii
Äänet lasketaan seuraavasti:

1. Lasketaan **kiintiö** eli paikan saamiseen tarvittava vähimmäisäänimäärä.
2. Lasketaan kunkin ehdokkaan **Ensimmäiset mieltymykset**.
3. Jokainen kiintiön saavuttanut ehdokas on **valittu**. Hänen ylijäämä-äänensä eli kiintiön ylittävä osuus **siirretään** äänestäjien seuraaville mieltymyksille murto-osan arvoisina, suurin ylijäämä ensin. Äänet siirtyvät vain ehdokkaille, jotka ovat yhä mukana laskennassa.
4. Jos siirrettävää ylijäämää ei ole jäljellä, **vähiten ääniä saanut ehdokas putoaa**. Hänen äänensä siirtyvät äänestäjien seuraaville mieltymyksille täysimääräisinä.
5. Kun jäljellä olevia ehdokkaita on yhtä monta kuin jäljellä olevia paikkoja, heidät kaikki valitaan, vaikka he eivät olisi saavuttaneet kiintiötä.
6. Muussa tapauksessa laskenta jatkuu kohdasta 3, kunnes kaikki paikat on täytetty.

Murto-osan arvoisina jaetaan vain ne äänet, joita voittaja ei tarvitse. Jos esimerkiksi kiintiö on 26 ja ehdokkaalla on 40 ääntä, hänen ylijäämänsä on 14. Jokainen hänen 40 äänestyslipustaan siirtyy seuraavalle mieltymykselle arvolla 14 ÷ 40 = 0,35 ääntä.

Skotlantilaisessa STV-menetelmässä jokaisen siirretyn äänen arvo pyöristetään alaspäin viiden desimaalin tarkkuuteen, kuten Skotlannin paikallisvaaleissa.

Jos kahdella tai useammalla ehdokkaalla on vähiten ääniä, heistä putoaa se, jolla oli vähemmän ääniä viimeisimmällä aiemmalla kierroksella, jolla heidän äänimääränsä erosivat.

>[!TIP]
>Äänestyslippu lasketaan mukaan vain niin kauan kuin siinä on asetettu mieltymysjärjestykseen ehdokas, joka on yhä mukana laskennassa. Kun yhtään tällaista ehdokasta ei ole jäljellä, äänestyslippu on "loppuun käytetty", eikä sitä enää lasketa mukaan.

<!-- translation-section: understanding-results -->

## Tulosten tulkitseminen

Kyselyn sulkeuduttua tulokset näkyvät useassa osiossa. Näissä vaaleissa Samira Patel, Alex Morgan ja Morgan Price saavat toimikunnan kolme paikkaa:

![](stv-results-summary.png)

<!-- translation-section: method-and-quota -->

### Menetelmä ja kiintiö

Yläosassa näet laskentamenetelmän (skotlantilainen STV tai Meekin STV), kiintiötyypin (Droop tai Hare) sekä kiintiön eli äänimäärän, jonka ehdokas tarvitsi saadakseen paikan.

<!-- translation-section: elected-candidates -->

### Valitut ehdokkaat

Voittajien yhteenvetotaulukossa on viisi saraketta:

| Sarake | Merkitys |
|--------|---------|
| **Ehdokas** | Valitun ehdokkaan nimi |
| **Kierros valittu** | Millä laskentakierroksella ehdokas saavutti kiintiön ja sai paikan. Kierros 1 tarkoittaa, että hän tuli valituksi pelkillä ensimmäisillä mieltymyksillä. Myöhemmillä kierroksilla hän tarvitsi pudonneilta ehdokkailta tai valittujen ehdokkaiden ylijäämästä siirrettyjä ääniä. |
| **Ensimmäiset mieltymykset** | Kuinka moni äänestäjä asetti tämän ehdokkaan ensimmäiseksi. Tämä näyttää ehdokkaan suoran kannatuksen ennen äänten siirtoja. |
| **Loppusumma** | Ehdokkaan äänimäärä sillä hetkellä, kun hän tuli valituksi. Äänten siirtojen vuoksi se on usein suurempi kuin ensimmäisten mieltymysten määrä. |
| **Ylijäämä** | Kuinka paljon ehdokkaan loppusumma ylitti kiintiön (loppusumma miinus kiintiö). Suurempi ylijäämä tarkoittaa vahvempaa kannatusta yli valintaan tarvittavan määrän. Skotlantilaisessa STV-menetelmässä tämä ylijäämä jaetaan äänestäjien seuraaville mieltymyksille. |

Aiemmat kierrokset eivät aina ratkaise tasatilannetta. Jos tasatilanne ei vaikuta siihen, ketkä valitaan, laskenta jatkuu. Jos se vaikuttaa valintaan, laskenta pysähtyy kyseiselle kierrokselle. Ehdokkaat, jotka tulevat valituiksi riippumatta siitä, miten tasatilanne ratkaistaan, näytetään valittuina. Ehdokkaat, jotka voivat tulla valituiksi tai jäädä valitsematta tasatilanteen ratkaisusta riippuen, näytetään erillisessä taulukossa. Loomio näyttää heidät tasatilanteessa sen sijaan, että valitsisi yhden sattumanvaraisesti.

<!-- translation-section: round-by-round-details -->

### Kierros kierrokselta yksityiskohdat

Avaa **Kierros kierrokselta yksityiskohdat**, niin näet äänten siirrot ja ehdokkaiden putoamiset. Kukin rivi vastaa ehdokasta ja kukin sarake laskentakierrosta. Jokainen luku kertoo ehdokkaan äänimäärän kyseisen kierroksen alussa:

![](stv-results.png)

Vihreä korostus näyttää, milloin ehdokas tuli valituksi, punainen näyttää, milloin hän putosi, ja oranssi näyttää, milloin hän oli tasatilanteessa.

<!-- translation-section: share-an-outcome -->

## Jaa johtopäätös

Kun vaalit suljetaan, jaa johtopäätös. Nimeä valitut henkilöt ja kerro, milloin heidän tehtävänsä alkaa. Lue johtopäätösten käytöstä kohdasta [Jaa johtopäätös](/en/user_manual/polls/intro_to_decisions#5-share-an-outcome).

![Johtopäätös, jossa nimetään toimikuntaan valitut jäsenet](outcome.png)

<!-- translation-section: exporting-ballots -->

## Äänestyslippujen vienti

Kun vaalit on suljettu, tulokset näkevät henkilöt voivat viedä äänestysliput BLT-muodossa riippumatonta uudelleenlaskentaa tai tarkastusta varten. Vienti sisältää ehdokkaiden suosituimmuusjärjestykset ja yhdistää samat järjestykset yhdeksi riviksi, jolla ilmoitetaan äänestyslippujen määrä. Anonyymeissä vaaleissa vienti ei sisällä äänestäjien henkilöllisyyksiä, äänestyslippujen tunnisteita, lähetysaikoja tai lähetysjärjestystä.
