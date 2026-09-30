---
title: Valitse
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/polls/choose/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-29'
sections:
  introduction: f9d6a5bfb7445de0
  when-to-use-choose: f8a798497cac5a43
  example-set-a-planning-meeting-agenda: 32a94a916dbf84e5
  set-up-the-poll: a16095b63c57e0c9
  vote: d170451131c544cf
  read-the-results: 84521c82aed8dd29
generated:
  introduction: f9757fd804c50607
  when-to-use-choose: 471c45ff628740b4
  example-set-a-planning-meeting-agenda: 0052a937ce1225af
  set-up-the-poll: b6f2ee29fe96a210
  vote: 645dc7712ea8bc00
  read-the-results: 246c0d17e0010630
title_source: c7f937836f5d82d5
title_generated: 92978709da089a2a
---

<!-- translation-section: introduction -->

# Valitse

Valitse on yksinkertainen kysely, jolla löydät suosituimman vaihtoehdon tai kokoat lyhyen listan. Osallistujat valitsevat yhden tai useamman vaihtoehdon asettamiesi rajojen mukaan. Tätä äänestystapaa kutsutaan monivalinnaksi.

<!-- translation-section: when-to-use-choose -->

## Milloin Valitse sopii käyttöön

Käytä Valitse-kyselyä, kun vaihtoehdot ovat erillisiä ja haluat laskea, kuinka moni valitsee kunkin niistä. Se sopii esimerkiksi seuraaviin tilanteisiin:

- yhden kokouspaikan valitseminen lyhyeltä listalta;
- enintään kolmen aiheen valitseminen esityslistalle;
- jatkoon etenevän suunnitelman valitseminen; tai
- sen selvittäminen, mitä palveluja jäsenet aikovat käyttää.

Valitse-kysely tallentaa valinnat, mutta ei sitä, kuinka vahvasti osallistuja kannattaa vaihtoehtoja tai missä järjestyksessä hän niitä suosii. Käytä [Pisteet](/en/user_manual/polls/score/)-kyselyä, kun haluat mitata kunkin vaihtoehdon kannatuksen voimakkuutta, [Kohdista](/en/user_manual/polls/allocate/)-kyselyä, kun käytettävissä on rajallinen budjetti, tai [Sijoitus](/en/user_manual/polls/rank/)-kyselyä, kun vaihtoehtojen järjestyksellä on merkitystä.

<!-- translation-section: example-set-a-planning-meeting-agenda -->

## Esimerkki: suunnittelukokouksen esityslista

Oatmilk-osuuskunnan pitää päättää, mitkä palautuspullojen kokeilun osa-alueet tarvitsevat eniten aikaa seuraavassa suunnittelukokouksessa. Kyselyssä jokaista pyydetään valitsemaan enintään kaksi aihetta. Kyselyn tiedoissa kerrotaan, miten tulosta käytetään. Jokaisesta vaihtoehdosta annetaan riittävästi tietoa, jotta se erottuu muista.

<!-- translation-section: set-up-the-poll -->

## Määritä kysely

Kirjoita kyselyn otsikoksi täsmällinen kysymys. Kerro **Tiedot**-kohdassa, mitä osallistujien tulee ottaa huomioon ja mitä tuloksen perusteella tehdään. Lisää kaikki tarjolla olevat vaihtoehdot ja aseta sitten **Vähimmäisvalinnat** ja **Maksimi valinnanvaraa**.

![](form.png)

Aseta molemmiksi rajoiksi 1, jos osallistujan on valittava täsmälleen yksi vaihtoehto. Aseta suurempi enimmäismäärä, jos haluat koota lyhyen listan. Älä salli niin montaa valintaa, että osallistujat voivat valita lähes kaikki vaihtoehdot. Silloin tulos on vähemmän hyödyllinen.

Voit lisätä vaihtoehdolle tarkennuksen tai lisäselityksen sen vieressä olevasta kynäkuvakkeesta. Tämä auttaa, jos vaihtoehdon lyhyen nimen voi ymmärtää eri tavoin.

![](edit_option.png)

**Lisää asetuksia** -kohdassa **Näytä vaihtoehdot satunnaisessa järjestyksessä** voi vähentää sitä vaikutusta, että sama vaihtoehto näytetään aina ensimmäisenä.

![](random_order.png)

<!-- translation-section: vote -->

## Äänestä

Äänestyslomake kertoo osallistujille, kuinka monta vaihtoehtoa he voivat valita. Tässä esimerkissä äänestäjä valitsee **Kahviloiden pullojen noutoaikataulun** ja **Pesuprosessin**. Hän perustelee valintansa suhteessa kokeiluun.

![](voting.png)

Perustelu voi kertoa, miksi vaihtoehto on tärkeä ja mitä työtä osallistujat odottavat siihen kuuluvan. Jos perustelut ovat päätöksen kannalta tärkeitä, määritä äänestyksen perusteluja koskeva asetus ennen kyselyn aloittamista.

<!-- translation-section: read-the-results -->

## Lue tulokset

Tuloksista näet kunkin vaihtoehdon osuuden kaikista valinnoista, sen valinneiden äänestäjien määrän sekä sen, ketkä eivät ole äänestäneet. Koska jokainen sai valita kaksi vaihtoehtoa, prosentit kuvaavat valintojen osuutta eivätkä ihmisten osuutta.

![](results.png)

Tässä esimerkissä **Kahviloiden pullojen noutoaikataulu** on saanut kolme valintaa. **Pesuprosessi** ja **Palautusasteen raportointi** ovat kumpikin saaneet kaksi. Tuloksen perusteella kahviloiden pullojen noudolle kannattaa varata eniten aikaa esityslistalla. Järjestäjän on silti päätettävä, miten jäljelle jäävä aika jaetaan tasatuloksen saaneiden aiheiden kesken.

Kun kysely sulkeutuu, julkaise **Tulokset**, jossa kerrot, mitä ryhmä tekee kyselyn tuloksen perusteella.

![](outcome.png)
