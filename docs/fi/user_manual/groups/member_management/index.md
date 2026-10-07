---
title: Jäsenten hallinta
source_revision: cd2e1e63e611688362e80009f50b8ed25025ba8b
source_file: docs/en/user_manual/groups/member_management/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-07'
sections:
  introduction: f216b18771a2c2a9
  administering-your-group: 27aed40959adef57
  managing-subgroups: 76b2fd61123a8a8a
  removing-members: f00aea52bfcd3547
  leaving-group: 02f69c9806d6beda
  set-title: 835b25d246477b4a
  member-email-addresses: cae570f30b671275
generated:
  introduction: 1714c46f36d1ffae
  administering-your-group: 2898d425c2e6d61f
  managing-subgroups: ee727f5ab3064a13
  removing-members: d06a6537a9918925
  leaving-group: 788c378592fc7540
  set-title: 45528c476e0cb3a5
  member-email-addresses: bafe12114e7c7745
title_source: 23ac3a7fe9ee72a2
title_generated: 016c04a55abe893a
---

<!-- translation-section: introduction -->

# Jäsenten hallinta

Jos olet ylläpitäjä, voit hallita jäseniä ryhmäsi sivun **Jäsenet**-välilehdellä.

Napsauta ryhmän jäsenen oikealla puolella olevia kolmea pistettä (**⋮**), niin voit asettaa hänelle otsikon, nimetä hänet ylläpitäjäksi tai edustajaksi tai poistaa hänet ryhmästä.

![Jäsenen toimintovalikko Oatmilk Cooperativen jäsensivulla](member_management.png)

<!-- translation-section: administering-your-group -->

## Ryhmäsi ylläpito
Loomio-ryhmässä on vain kaksi käyttäjätyyppiä: **jäsen** ja **ylläpitäjä**.

Ylläpitäjät hoitavat ryhmäsi hallinnollisia tehtäviä, kuten jäsenten lisäämistä ja poistamista, jäsenten käyttöoikeuksien hallintaa, ryhmän yksityisyysasetusten määrittämistä ja tilausten hallintaa. Lisäksi ylläpitäjät voivat nähdä jäsenten sähköpostiosoitteet ja viedä ryhmän tiedot.

Uuden Loomio-ryhmän luonut henkilö nimetään oletuksena ylläpitäjäksi. Suosittelemme nimeämään ainakin yhden muun ryhmäsi luotetun henkilön ylläpitäjäksi, jotta joku voi aina hoitaa ryhmäsi ylläpitoa. Ryhmässäsi voi olla niin monta ylläpitäjää kuin haluat.

Voit nimetä jäsenen **ylläpitäjäksi** siirtymällä Jäsenet-välilehdelle, etsimällä jäsenen ja napsauttamalla hänen nimensä vieressä olevia kolmea pistettä (**⋮**). Valitse **Nimeä ylläpitäjäksi**. Hänen nimensä viereen ilmestyy `Admin`-tunniste.

![Nimeä ylläpitäjäksi -toiminto jäsenen valikossa](member_make_admin.png)

<!-- translation-section: managing-subgroups -->

## Alaryhmien hallinta
Pääryhmän ylläpitäjät voivat liittyä sen avoimiin, suljettuihin ja **Näkyy pääryhmälle** -alaryhmiin ja nimetä sitten itsensä alaryhmien ylläpitäjiksi.

Valitse alaryhmän sivulta **Liittyä ryhmään**.

![Liittyä ryhmään -painike Oatmilk Cooperativen suljetussa alaryhmässä](member_join_subgroup.png)

Kun olet liittynyt alaryhmään, voit myös nimetä itsesi sen ylläpitäjäksi samalla tavalla kuin nimeäisit kenet tahansa ylläpitäjäksi.

>[!Note]
>Nämä oikeudet eivät koske [**salaisia** alaryhmiä](/en/user_manual/groups/subgroups/?highlight=secret#permissions).

<!-- translation-section: removing-members -->

## Jäsenten poistaminen
Kun napsautat **Poista ryhmästä**, sinua pyydetään vahvistamaan poistaminen. Poistamisen jälkeen käyttäjä ei enää pääse ryhmän sivuille, ketjuihin, kyselyihin tai ehdotuksiin. Hän ei enää saa sähköposteja tai ilmoituksia ryhmän toiminnasta. Käyttäjän kommentit ja äänet säilyvät kuitenkin ennallaan.

![Poista ryhmästä -toiminto jäsenen valikossa](member_remove.png)

Voit halutessasi lisätä poistetut jäsenet myöhemmin takaisin ryhmään.

<!-- translation-section: leaving-group -->

## Ryhmästä poistuminen
Voit poistua ryhmästä siirtymällä ryhmän sivulle, avaamalla kolmen pisteen valikon ja napsauttamalla **Poistu ryhmästä**.

![Poistu ryhmästä -toiminto Oatmilk Cooperativen asetusvalikossa](member_leave_group.png)

<!-- translation-section: set-title -->

## Aseta otsikko
Jäsenet-välilehdellä voit kertoa roolisi ryhmässä tai nimeä edustamasi organisaation käyttämällä **otsikko**-kenttää. Sinä tai ryhmän ylläpitäjä voitte muuttaa otsikkoasi valitsemalla **Aseta otsikko** nimesi vieressä olevasta kolmen pisteen valikosta.

![Aseta otsikko -toiminto jäsenen valikossa](member_set_title.png)

Sinulla voi olla eri otsikko eri alaryhmissä.

<!-- translation-section: member-email-addresses -->

## Jäsenten sähköpostiosoitteet

Vain ylläpitäjät voivat nähdä ryhmän jäsenten sähköpostiosoitteet. Tämä on joskus tarpeen ryhmän jäsenistön tarkistamiseksi.

Näet jäsenten sähköpostiosoitteet lataamalla CSV-tiedoston [tietojen viennin](/en/user_manual/groups/data_export/) avulla ja avaamalla sen Excelissä tai Google Sheetsissä.

Ryhmän tietojen vientitiedosto näyttää jokaisen alaryhmän kaikki henkilöt ja heidän sähköpostiosoitteensa.

Voit myös hakea jäseniä sähköpostiosoitteen perusteella Jäsenet-välilehdellä. Jos haluat poistaa jonkun ryhmästä, voit etsiä hänet sähköpostiosoitteen avulla ja poistaa hänet.
