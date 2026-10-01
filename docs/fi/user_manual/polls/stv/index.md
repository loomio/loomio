---
title: STV-vaalit
source_revision: cf8da02f691349beecf6ac6444971fad130d4ddd
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
  introduction: 569d21ad446c2872
  when-to-use-stv: 1caf09fbbb8fe453
  creating-an-stv-election: f01dc501105b5238
  number-of-seats: 8d89a096d3ab638c
  counting-method: 5f40bce25f95850c
  quota-type: 5851d86a48e80121
  how-voting-works: 0d977600aad6c011
  how-counting-works: 16585abd0d2e6e23
  understanding-results: c3a407cdefa4c7dd
  method-and-quota: 8d63ccc6a847fcf8
  elected-candidates: 48577fca647fb798
  round-by-round-details: ccecb10c6e7ed304
  exporting-ballots: 96ebf656aa7c85d4
  share-an-outcome: dc08d971a6e91fdd
title_source: cd3e1a4cdc2456a6
title_generated: 5db74b13bec93710
---

<!-- translation-section: introduction -->

# STV-vaalit

**Siirtoäänivaali (STV)** on suhteellinen vaalitapa, jolla valitaan useita ehdokkaita. Sen avulla valitut ehdokkaat edustavat äänestäjien erilaisia näkemyksiä suhteellisesti.

<!-- translation-section: when-to-use-stv -->

## Milloin käyttää STV-vaaleja

Käytä STV-vaaleja, kun haluat:

- Valita ehdokkaiden joukosta **toimikunnan, hallituksen tai edustajaryhmän**
- Varmistaa **suhteellisen edustuksen**, jossa myös vähemmistöt voivat saada kannatustaan vastaavan määrän paikkoja
- Järjestää vaalit, joissa äänestäjät asettavat ehdokkaat mieluisuusjärjestykseen

>[!NOTE]
>STV **eroaa** Loomion [järjestyskyselystä](/en/user_manual/polls/rank/), jossa vaihtoehdot pisteytetään yhden parhaan vaihtoehdon valitsemiseksi. STV-vaaleissa valitaan useita ehdokkaita siirtämällä ääniä ja pudottamalla ehdokkaita laskentakierroksilla.

<!-- translation-section: creating-an-stv-election -->

## STV-vaalien luominen

Kun aloitat kyselyn, valitse kyselyn tyypiksi **STV-vaalit** ja lisää ehdokkaat vaihtoehdoiksi. Voit määrittää **täytettävien paikkojen määrän**, **laskentamenetelmän** ja **kiintiötyypin**.

Tässä esimerkissä Oatmilk Cooperative valitsee kolme henkilöä valvomaan palautettavien pakkausten kokeilua. Lomakkeessa kuvataan tehtävä, luetellaan viisi ehdokasta ja käytetään Scottish STV -laskentamenetelmää sekä Droop-kiintiötä.

![](form.png)

<!-- translation-section: number-of-seats -->

### Täytettävien paikkojen määrä

Valittavien henkilöiden määrä. Sen on oltava pienempi kuin ehdokkaiden määrä.

<!-- translation-section: counting-method -->

### Laskentamenetelmä

Äänten laskentaan on kaksi menetelmää:

Scottish STV
  : Suositeltu. Weighted Inclusive Gregory Method (WIGM) -menetelmää on käytetty Skotlannin paikallisvaaleissa vuodesta 2007. Sen säännöt ovat selkeät ja tarkasti määritellyt. Se sopii useimmille organisaatioille.
  
Meek STV
  : Tarkempi menetelmä, jossa äänten laskeminen vaatii tietokoneen. Kun ehdokas valitaan, Meek siirtää kustakin äänestä sen osan, jota ehdokas ei tarvitse, äänestäjän seuraaville ehdokkaille. Tämä koskee myös ääniä, jotka siirtyvät valitulle ehdokkaalle myöhemmin laskennan aikana. Kun ehdokas putoaa, äänet lasketaan uudelleen ikään kuin hän ei olisi ollut mukana vaalissa. Ääniä menee hukkaan vähemmän kuin Scottish STV -menetelmässä, mutta laskentaa ei voi tarkistaa käsin.

<!-- translation-section: quota-type -->

### Kiintiötyyppi

Kiintiö on äänimäärä, jonka ehdokas vähintään tarvitsee tullakseen valituksi. Vaihtoehtoja on kaksi:

Droop
  : Suositeltu. STV-vaalien vakiokiintiö, jota käytetään Irlannissa, Australiassa ja Skotlannissa. Se on pienin kiintiö, jonka voi saavuttaa enintään yhtä moni ehdokas kuin paikkoja on täytettävänä. Äänestäjäryhmä, joka asettaa omat ehdokkaansa ensimmäisiksi, saa vähintään yhtä monta paikkaa kuin sen äänimäärään sisältyy täysiä kiintiöitä. Kiintiö lasketaan näin:
\\[ floor(\frac{votes}{(seats + 1)}) + 1 \\]

Hare
  : Suurempi kiintiö. Paljon ääniä saaneet ryhmät käyttävät enemmän ääniä kuhunkin saamaansa paikkaan, joten pienemmät ryhmät saavat todennäköisemmin viimeiset paikat. Kiintiö lasketaan näin:
    \\[ \frac{votes}{seats}\\]

Molemmissa kaavoissa *votes* tarkoittaa niiden äänestyslippujen määrää, joissa on asetettu vähintään yksi ehdokas mieluisuusjärjestykseen.

Meek STV laskee kiintiön pyöristämättä. Droop-kiintiön kaava on votes ÷ (seats + 1). Kiintiö lasketaan uudelleen joka kierroksella ehdokkailla yhä olevien äänten perusteella, ja ehdokkaan on ylitettävä kiintiö tullakseen valituksi.
  
  >[!TIP]
  > Droop-kiintiö on aina pienempi kuin Hare-kiintiö. Esimerkiksi vaalissa, jossa on 100 ääntä ja neljä paikkaa, Droop-kiintiö on 21 ääntä ja Hare-kiintiö 25 ääntä.

<!-- translation-section: how-voting-works -->

## Näin äänestäminen toimii

Tässä esimerkissä Oatmilk Cooperative valitsee kolme henkilöä valvomaan uudelleenkäytettävien pakkausten kokeilua. Äänestäjät vetävät ehdokkaat viivan yläpuolelle ja asettavat heidät mieluisuusjärjestykseen:

![](stv-vote-in-progress.png)

- **Sija 1** = mieluisin ehdokas
- **Sija 2** = toiseksi mieluisin ehdokas
- Jatka ehdokkaiden järjestämistä niin pitkälle kuin haluat

Äänestäjän on asetettava vähintään yksi ehdokas mieluisuusjärjestykseen, mutta kaikkia ehdokkaita ei tarvitse järjestää. Äänestäjän ääni ei siirry ehdokkaille, joita hän ei ole järjestänyt.

<!-- translation-section: how-counting-works -->

## Näin ääntenlaskenta toimii
Äänet lasketaan seuraavasti:

1. Lasketaan **kiintiö** eli vähimmäisäänimäärä, jolla ehdokas saa paikan.
2. Lasketaan kunkin ehdokkaan **Ensimmäiset mieltymykset**.
3. Jokainen kiintiön saavuttanut ehdokas **valitaan**. Kiintiön ylittävät äänet **siirretään** murto-osaisina äänestäjien seuraaville ehdokkaille, suurin ylijäämä ensin. Äänet siirtyvät vain ehdokkaille, jotka ovat yhä mukana laskennassa.
4. Jos siirrettävää ylijäämää ei enää ole, **vähiten ääniä saanut ehdokas putoaa**. Hänen äänensä siirtyvät täysimääräisinä äänestäjien seuraaville ehdokkaille.
5. Kun jäljellä olevia ehdokkaita on yhtä monta kuin täyttämättömiä paikkoja, heidät kaikki valitaan, vaikka he eivät olisi saavuttaneet kiintiötä.
6. Muussa tapauksessa laskentaa jatketaan kohdasta 3, kunnes kaikki paikat on täytetty.

Murto-osainen siirto jakaa eteenpäin vain ne äänet, joita valittu ehdokas ei tarvitse. Jos esimerkiksi kiintiö on 26 ja ehdokkaalla on 40 ääntä, hänen ylijäämänsä on 14. Jokainen hänen 40 äänestyslipustaan siirtyy seuraavalle ehdokkaalle arvolla 14 ÷ 40 = 0.35 ääntä.

Scottish STV -menetelmässä kunkin siirretyn äänen arvo pyöristetään alaspäin viiden desimaalin tarkkuuteen, kuten Skotlannin paikallisvaaleissa.

Jos kahdella tai useammalla ehdokkaalla on yhtä vähän ääniä, pudotetaan se, jolla oli vähemmän ääniä viimeisimmällä aiemmalla kierroksella, jolla heidän äänimääränsä erosivat.

>[!TIP]
>Äänestyslippu lasketaan mukaan vain niin kauan kuin siinä on mukana laskennassa oleva ehdokas. Kun yhtään tällaista ehdokasta ei ole jäljellä, äänestyslippu on "loppuun käytetty", eikä sitä enää lasketa mukaan.

<!-- translation-section: understanding-results -->

## Tulosten tarkastelu

Kyselyn sulkeuduttua tulokset näkyvät useassa osiossa. Tässä vaalissa Samira Patel, Alex Morgan ja Morgan Price saavat toimikunnan kolme paikkaa:

![](stv-results-summary.png)

<!-- translation-section: method-and-quota -->

### Menetelmä ja kiintiö

Ylhäällä näet laskentamenetelmän (Scottish STV tai Meek STV), kiintiötyypin (Droop tai Hare) ja kiintiön eli äänimäärän, jonka ehdokas tarvitsi tullakseen valituksi.

<!-- translation-section: elected-candidates -->

### Valitut ehdokkaat

Valitut ehdokkaat esitetään viisi saraketta sisältävässä yhteenvetotaulukossa:

| Sarake | Merkitys |
|--------|---------|
| **Ehdokas** | Valitun ehdokkaan nimi |
| **Kierros valittu** | Laskentakierros, jolla ehdokas saavutti kiintiön ja sai paikan. Kierros 1 tarkoittaa, että ehdokas valittiin pelkillä ensimmäisillä mieltymyksillä. Myöhemmillä kierroksilla valittu tarvitsi pudonneilta ehdokkailta tai muiden ehdokkaiden ylijäämästä siirtyneitä ääniä. |
| **Ensimmäiset mieltymykset** | Kuinka moni äänestäjä asetti ehdokkaan ensimmäiseksi. Luku kertoo ehdokkaan suoran kannatuksen ennen äänten siirtoja. |
| **Loppusumma** | Ehdokkaan äänimäärä valintahetkellä. Äänten siirtojen vuoksi se on usein suurempi kuin ensimmäisten mieltymysten määrä. |
| **Ylijäämä** | Kuinka paljon ehdokkaan loppusumma ylitti kiintiön (loppusumma miinus kiintiö). Suurempi ylijäämä kertoo vahvemmasta kannatuksesta kuin valintaan tarvittiin. Scottish STV -menetelmässä ylijäämä jaetaan äänestäjien seuraaville ehdokkaille. |

Joskus tasatilannetta ei voida ratkaista aiempien kierrosten perusteella. Jos tasatilanteen ratkaisu ei vaikuta siihen, ketkä valitaan, laskenta jatkuu. Jos se vaikuttaa, laskenta pysähtyy kyseiselle kierrokselle. Ehdokkaat, jotka tulevat valituiksi riippumatta tasatilanteen ratkaisusta, näytetään valittuina. Ehdokkaat, jotka voivat tulla valituiksi tai pudota tasatilanteen ratkaisusta riippuen, näytetään erillisessä taulukossa. Loomio näyttää heidät tasatilanteessa sen sijaan, että valitsisi jonkun satunnaisesti.

<!-- translation-section: round-by-round-details -->

### Kierros kierrokselta yksityiskohdat

Avaa **Kierros kierrokselta yksityiskohdat**, niin näet äänten siirrot ja ehdokkaiden putoamiset. Kukin rivi kuvaa ehdokasta ja kukin sarake laskentakierrosta. Kukin luku kertoo ehdokkaan äänimäärän kyseisen kierroksen alussa:

![](stv-results.png)

Vihreä korostus näyttää, milloin ehdokas valittiin, punainen näyttää putoamisen ja oranssi tasatilanteen.

<!-- translation-section: share-an-outcome -->

## Jaa johtopäätös

Kun vaalit päättyvät, jaa johtopäätös. Nimeä valitut henkilöt ja kerro, milloin heidän tehtävänsä alkaa. Lue johtopäätösten käytöstä kohdasta [Jaa johtopäätös](/en/user_manual/polls/intro_to_decisions#5-share-an-outcome).

![Johtopäätös, jossa nimetään valitut toimikunnan jäsenet](outcome.png)

<!-- translation-section: exporting-ballots -->

## Äänestyslippujen vienti

Vaalin sulkeuduttua tuloksia tarkastelemaan oikeutetut voivat viedä äänestysliput BLT-muodossa riippumatonta uudelleenlaskentaa tai tarkastusta varten. Vienti sisältää ehdokkaiden järjestykset ja yhdistää samanlaiset järjestykset yhdelle riville sekä ilmoittaa äänestyslippujen määrän. Nimettömissä vaaleissa vienti ei sisällä äänestäjien henkilöllisyyksiä, äänestyslippujen tunnisteita, lähetysaikoja eikä lähetysjärjestystä.
