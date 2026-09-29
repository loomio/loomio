---
title: STV-vaalit
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/polls/stv/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-29'
sections:
  introduction: 6c43a75f60922bb6
  when-to-use-stv: e37de389c27f7d87
  creating-an-stv-election: 2d475191d922803f
  number-of-seats: 9463d911f230eea0
  counting-method: 31e83bb5bc08829c
  quota-type: 12d5c4b5fe2abb1d
  how-voting-works: b9a7df3cedbe4d50
  how-counting-works: 50ba0a7800bc5667
  understanding-results: 8442813a9c097112
  method-and-quota: 90113296c3d59816
  elected-candidates: a6c3dbb5548c7d41
  round-by-round-details: e4a8789dae29d49e
  exporting-ballots: 582555dd13633bf0
generated:
  introduction: 569d21ad446c2872
  when-to-use-stv: 1caf09fbbb8fe453
  creating-an-stv-election: f01dc501105b5238
  number-of-seats: 8d89a096d3ab638c
  counting-method: '2887716527685194'
  quota-type: 86c40eab86e26313
  how-voting-works: 252e51703e6006d2
  how-counting-works: c131c8689681c977
  understanding-results: c3a407cdefa4c7dd
  method-and-quota: 8d63ccc6a847fcf8
  elected-candidates: 3860ddfb4e0145a3
  round-by-round-details: 377f90356d24577d
  exporting-ballots: 96ebf656aa7c85d4
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

Scottish STV : Suositeltu. Weighted Inclusive Gregory Method (WIGM) -menetelmää on käytetty Skotlannin paikallisvaaleissa vuodesta 2007. Sen säännöt ovat selkeät ja tarkasti määritellyt. Se sopii useimmille organisaatioille.

Meek STV : Matemaattisesti tarkempi, toistuvaan laskentaan perustuva menetelmä. Kun ehdokas putoaa, äänet lasketaan uudelleen ikään kuin hän ei olisi ollut mukana vaalissa.

<!-- translation-section: quota-type -->

### Kiintiötyyppi

Kiintiö on äänimäärä, jonka ehdokas vähintään tarvitsee tullakseen valituksi. Vaihtoehtoja on kaksi:

Droop : Suositeltu. Droop on useimpien STV-vaalien vakiokiintiö, ja sitä käytetään Irlannissa, Australiassa ja Skotlannissa. Se takaa, että enemmistön muodostava ryhmittymä saa enemmistön paikoista. Kiintiö lasketaan näin: \\[ floor(\frac{votes}{(seats + 1)}) + 1 \\]

Hare
  : Korkeampi vähimmäisraja, joka antaa pienemmille ryhmittymille suhteellisemman edustuksen.
    DSA:n paikallisosastot suosivat Hare-kiintiötä vähemmistöjen edustuksen turvaamiseksi.
   Kiintiö lasketaan näin:
    \\[ \frac{votes}{seats}\\]

>[!TIP]
  > Droop-kiintiö on aina pienempi kuin Hare-kiintiö. Esimerkiksi vaalissa, jossa on 100 ääntä ja neljä paikkaa, Droop-kiintiö on 21 ääntä ja Hare-kiintiö 25 ääntä.

<!-- translation-section: how-voting-works -->

## Näin äänestäminen toimii

Tässä esimerkissä Oatmilk Cooperative valitsee kolme henkilöä valvomaan uudelleenkäytettävien pakkausten kokeilua. Äänestäjät vetävät ehdokkaat viivan yläpuolelle ja asettavat heidät mieluisuusjärjestykseen:

![](stv-vote-in-progress.png)

- **Sija 1** = mieluisin ehdokas
- **Sija 2** = toiseksi mieluisin ehdokas
- Jatka ehdokkaiden järjestämistä niin pitkälle kuin haluat

Kaikkia ehdokkaita ei tarvitse järjestää. Äänestäjän ääni ei siirry ehdokkaille, joita hän ei ole järjestänyt.

<!-- translation-section: how-counting-works -->

## Näin ääntenlaskenta toimii
Äänet lasketaan seuraavasti:

1. Lasketaan **kiintiö** eli vähimmäisäänimäärä, jolla ehdokas saa paikan.
2. Lasketaan kunkin ehdokkaan **Ensimmäiset mieltymykset**.
3. Jos ehdokas saavuttaa kiintiön, hänet **valitaan**. Kiintiön ylittävät äänet **siirretään** murto-osaisina äänestäjien seuraaville ehdokkaille.
4. Jos kukaan ei saavuta kiintiötä, **vähiten ääniä saanut ehdokas putoaa**. Hänen äänensä siirtyvät täysimääräisinä äänestäjien seuraaville ehdokkaille.
5. Tätä jatketaan, kunnes kaikki paikat on täytetty.

>[!TIP]
>Jos äänestäjän järjestämistä ehdokkaista ei ole enää ketään mukana, hänen äänestyslippunsa ääntä ei voida enää siirtää. Siksi useamman ehdokkaan järjestäminen kannattaa yleensä.

<!-- translation-section: understanding-results -->

## Tulosten tarkastelu

Kyselyn sulkeuduttua tulokset näkyvät useassa osiossa. Tässä vaalissa Samira Patel, Alex Morgan ja Morgan Price saavat toimikunnan kolme paikkaa:

![](stv-results-summary.png)

<!-- translation-section: method-and-quota -->

### Menetelmä ja kiintiö

Ylhäällä näet laskentamenetelmän (Scottish STV tai Meek STV), kiintiötyypin (Droop tai Hare) ja kiintiön eli äänimäärän, jonka ehdokas tarvitsi tullakseen valituksi.

<!-- translation-section: elected-candidates -->

### Valitut ehdokkaat

Valitut ehdokkaat esitetään viis saraketta sisältävässä yhteenvetotaulukossa:

| Sarake | Merkitys |
|--------|---------|
| **Ehdokas** | Valitun ehdokkaan nimi |
| **Kierros valittu** | Laskentakierros, jolla ehdokas saavutti kiintiön ja sai paikan. Kierros 1 tarkoittaa, että ehdokas valittiin pelkillä ensimmäisillä mieltymyksillä. Myöhemmillä kierroksilla valittu tarvitsi pudonneilta ehdokkailta tai muiden ehdokkaiden ylijäämästä siirtyneitä ääniä. |
| **Ensimmäiset mieltymykset** | Kuinka moni äänestäjä asetti ehdokkaan ensimmäiseksi. Luku kertoo ehdokkaan suoran kannatuksen ennen äänten siirtoja. |
| **Loppusumma** | Ehdokkaan äänimäärä valintahetkellä. Äänten siirtojen vuoksi se on usein suurempi kuin ensimmäisten mieltymysten määrä. |
| **Ylijäämä** | Kuinka paljon ehdokkaan loppusumma ylitti kiintiön (loppusumma miinus kiintiö). Suurempi ylijäämä kertoo vahvemmasta kannatuksesta kuin valintaan tarvittiin. Scottish STV -menetelmässä ylijäämä jaetaan äänestäjien seuraaville ehdokkaille. |

Jos laskennassa syntyy tasatilanne, jossa kenen tahansa jäljellä olevan ehdokkaan pudottaminen muuttaisi tulosta, ehdokkaat näytetään erillisessä taulukossa. Voittajaa ei valita mielivaltaisesti.

<!-- translation-section: round-by-round-details -->

### Kierros kierrokselta yksityiskohdat

Avaa **Kierros kierrokselta yksityiskohdat**, niin näet äänten siirrot ja ehdokkaiden putoamiset. Kukin rivi kuvaa ehdokasta ja kukin sarake laskentakierrosta:

![](stv-results.png)

Vihreä korostus näyttää, milloin ehdokas valittiin, punainen näyttää putoamisen ja oranssi tasatilanteen.

<!-- translation-section: exporting-ballots -->

## Äänestyslippujen vienti

Vaalin sulkeuduttua tuloksia tarkastelemaan oikeutetut voivat viedä äänestysliput BLT-muodossa riippumatonta uudelleenlaskentaa tai tarkastusta varten. Vienti sisältää ehdokkaiden järjestykset ja yhdistää samanlaiset järjestykset yhdelle riville sekä ilmoittaa äänestyslippujen määrän. Nimettömissä vaaleissa vienti ei sisällä äänestäjien henkilöllisyyksiä, äänestyslippujen tunnisteita, lähetysaikoja eikä lähetysjärjestystä.
