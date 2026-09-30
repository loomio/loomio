---
title: Jäsenten hallinta
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/groups/member_management/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-30'
sections:
  introduction: f216b18771a2c2a9
  administering-your-group: 27aed40959adef57
  managing-subgroups: ee977899fa34caab
  removing-members: f00aea52bfcd3547
  leaving-group: 02f69c9806d6beda
  set-title: 835b25d246477b4a
  member-email-addresses: cae570f30b671275
generated:
  introduction: 6ae58dabda3d6e81
  administering-your-group: 6c84758f9b3bef39
  managing-subgroups: af135cc6ee0a367b
  removing-members: 8f3cf2c2a12424a3
  leaving-group: b1d292d296538e28
  set-title: f8873fd6c47160d1
  member-email-addresses: 64cf083fa11cc868
title_source: 23ac3a7fe9ee72a2
title_generated: 016c04a55abe893a
---

<!-- translation-section: introduction -->

# Jäsenten hallinta

Jos olet ryhmän ylläpitäjä, voit hallita jäseniä ryhmäsivun **Jäsenet**-välilehdellä.

Napsauta ryhmän jäsenen oikealla puolella olevaa kolmen pisteen valikkoa (**⋮**). Voit asettaa jäsenelle otsikon, nimetä hänet ylläpitäjäksi tai edustajaksi tai poistaa hänet ryhmästä.

![Jäsenen toimintovalikko Oatmilk Cooperativen jäsensivulla](member_management.png)

<!-- translation-section: administering-your-group -->

## Ryhmän hallinnointi
Loomio-ryhmässä on vain kahdenlaisia käyttäjiä: **jäseniä** ja **ylläpitäjiä**.

Ylläpitäjät lisäävät ja poistavat jäseniä, hallitsevat jäsenten käyttöoikeuksia, määrittävät ryhmän yksityisyysasetukset ja hallitsevat tilaussopimuksia. Lisäksi he näkevät jäsenten sähköpostiosoitteet ja voivat viedä ryhmän tiedot.

Uuden Loomio-ryhmän luojasta tulee oletusarvoisesti ylläpitäjä. Suosittelemme nimeämään ylläpitäjäksi vähintään yhden muun luotettavan ryhmän jäsenen, jotta joku voi aina hallinnoida ryhmää. Ylläpitäjien määrää ei ole rajoitettu.

Voit tehdä jäsenestä **ylläpitäjän** siirtymällä Jäsenet-välilehdelle ja napsauttamalla hänen nimensä vieressä olevaa kolmen pisteen valikkoa (**⋮**). Valitse **Nimeä ylläpitäjäksi**. Hänen nimensä viereen ilmestyy `Admin`-merkintä.

![Nimeä ylläpitäjäksi -toiminto jäsenen valikossa](member_make_admin.png)

<!-- translation-section: managing-subgroups -->

## Alaryhmien hallinta
Jos olet pääryhmän eli organisaation ylläpitäjä, sinulla on lisäoikeuksia __suljettuihin__ alaryhmiin.

Voit liittyä mihin tahansa suljettuun alaryhmään napsauttamalla kyseisen alaryhmän sivun vasemmassa reunassa, välilehtien alapuolella, olevaa ”Liity ryhmään” -painiketta.

![Liity ryhmään -painike Oatmilk Cooperativen suljetussa alaryhmässä](member_join_subgroup.png)

Kun olet liittynyt alaryhmään, voit nimetä itsesi sen ylläpitäjäksi samalla tavalla kuin nimeäisit kenet tahansa muun.

>[!Note]
>Nämä oikeudet eivät koske [**salaisia** alaryhmiä](/en/user_manual/groups/subgroups/?highlight=secret#permissions).

<!-- translation-section: removing-members -->

## Jäsenten poistaminen
Kun napsautat **Poista ryhmästä**, sinua pyydetään vahvistamaan poisto. Poistettu käyttäjä ei enää pääse ryhmän sivuille, keskusteluketjuihin, kyselyihin tai ehdotuksiin. Hän ei myöskään saa ryhmän toiminnasta sähköpostiviestejä tai ilmoituksia. Hänen kirjoittamansa kommentit ja antamansa äänet säilyvät ennallaan.

![Poista ryhmästä -toiminto jäsenen valikossa](member_remove.png)

Voit halutessasi lisätä poistetun jäsenen takaisin ryhmään myöhemmin.

<!-- translation-section: leaving-group -->

## Ryhmästä poistuminen
Poistu ryhmästä siirtymällä ryhmäsivulle, avaamalla kolmen pisteen valikko ja valitsemalla **Poistu ryhmästä**.

![Poistu ryhmästä -toiminto Oatmilk Cooperativen asetusvalikossa](member_leave_group.png)

<!-- translation-section: set-title -->

## Aseta otsikko
**Jäsenet**-välilehdellä voit kertoa roolistasi ryhmässä tai ilmoittaa edustamasi organisaation käyttämällä **otsikko**-kenttää. Sinä tai ryhmän ylläpitäjä voitte muuttaa otsikkoasi valitsemalla nimesi vieressä olevasta kolmen pisteen valikosta **Aseta otsikko**.

![Aseta otsikko -toiminto jäsenen valikossa](member_set_title.png)

Sinulla voi olla eri otsikko eri alaryhmissä.

<!-- translation-section: member-email-addresses -->

## Jäsenten sähköpostiosoitteet

Vain ylläpitäjät näkevät ryhmän jäsenten sähköpostiosoitteet. Niitä voidaan tarvita ryhmän jäsenyyksien tarkistamiseen.

Näet jäsenten sähköpostiosoitteet lataamalla CSV-tiedoston [tietojen viennillä](/en/user_manual/groups/data_export/) ja avaamalla sen Excelissä tai Google Sheetsissä.

Viety ryhmätiedosto sisältää kaikkien alaryhmien jäsenet ja heidän sähköpostiosoitteensa.

Voit myös hakea jäseniä sähköpostiosoitteen perusteella Jäsenet-välilehdellä. Jos haluat poistaa jonkun ryhmästä, voit etsiä hänet sähköpostiosoitteella.
