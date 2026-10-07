---
title: Alaryhmät
source_revision: cd2e1e63e611688362e80009f50b8ed25025ba8b
source_file: docs/en/user_manual/groups/subgroups/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-07'
sections:
  introduction: 63e6e23d24e80919
  add-a-subgroup: 0bc0e5f99eb074c3
  subgroup-settings: 737225cc4bebe7e8
  privacy: 5bdd92ce200f197a
  permissions: ee02991523f1ebe4
  find-subgroups: 5e6fc5a5122c1417
  invite-to-a-subgroup: 0af670e1e9b32a5e
  simultaneously-invite-people-to-subgroups-and-parent-group: 1991604900321cd7
  administer-a-subgroup: 58fa95833f79dd01
  delete-a-subgroup: 2c6e76ec78386443
generated:
  introduction: 751f6b5395cbd1f7
  add-a-subgroup: 62a6338ca49e4894
  subgroup-settings: eb275d9b7dad3776
  privacy: 89d17a25396b71fd
  permissions: 4af16f6e379b37d5
  find-subgroups: fb8a0662cdff75b5
  invite-to-a-subgroup: aa0041c6a3913691
  simultaneously-invite-people-to-subgroups-and-parent-group: cad30b323bd6e7d9
  administer-a-subgroup: f8d9fc86d743f211
  delete-a-subgroup: 93cdc7731d9d4c71
title_source: 9f81e728f70cae3e
title_generated: 1df663e60675db34
---

<!-- translation-section: introduction -->

# Alaryhmät

Alaryhmät auttavat sinua järjestämään viestinnän ja jäsenet niin, että oikeat ihmiset voivat työskennellä yhdessä.

Organisaatiolla voi olla esimerkiksi seuraavat alaryhmät:
- hallitus
- tiimi tai projektin työryhmä
- tiettyyn aiheeseen keskittyvä ryhmä (esimerkiksi strategia tai oppiminen)

Alaryhmät toimivat samalla tavalla kuin ryhmät, mutta ne sijaitsevat pääryhmäsi sisällä. Useimmat ominaisuudet ja asetukset ovat samat kuin pääryhmässä. Henkilö voi myös olla alaryhmäsi, kuten hallituksen, jäsen kuulumatta pääryhmääsi.

<!-- translation-section: add-a-subgroup -->

## Lisää alaryhmä

>[!Note]
>Oikeus lisätä uusia alaryhmiä määritetään ryhmän [käyttöoikeusasetuksissa](/en/user_manual/groups/settings/permissions). Oletusarvoisesti vain ylläpitäjät voivat aloittaa uusia alaryhmiä.

Lisää alaryhmä siirtymällä pääryhmäsi sivulle ja napsauttamalla sivupalkista **Uusi alaryhmä**.  

![Uusi alaryhmä -painike Oatmilk Cooperative -ryhmän sivupalkissa](subgroups-sidebar.png)

Napsauta **Uusi alaryhmä** -painiketta, anna alaryhmälle nimi ja valitse yksityisyysasetus. Napsauta sitten **Aloita alaryhmä**.

![Packaging Working Group -alaryhmän luomislomake](subgroups_new.png)

Kun olet valmis, [kutsu ihmisiä](/en/user_manual/groups/inviting_people/) alaryhmään.

Voit muokata alaryhmän [ryhmäasetuksia](/en/user_manual/groups/settings/) napsauttamalla alaryhmän sivulla olevaa rataskuvaketta.

![Ryhmän asetusten muokkaaminen Packaging Working Group -alaryhmässä](subgroups_edit_group_settings.png)

<!-- translation-section: subgroup-settings -->

## Alaryhmän asetukset

<!-- translation-section: privacy -->

### Yksityisyys

Valitse erikseen, kuka voi löytää alaryhmän ja miten siihen liitytään:

| Yksityisyys | Kuka voi löytää alaryhmän | Kuka voi lukea sen ketjuja |
| --- | --- | --- |
| **Avoin** | Kuka tahansa | Kuka tahansa |
| **Suljettu** | Kuka tahansa | Alaryhmän jäsenet ja kutsutut vieraat |
| **Näkyy pääryhmälle** | Pääryhmän jäsenet ja alaryhmän jäsenet | Alaryhmän jäsenet ja kutsutut vieraat |
| **Salainen** | Kutsutut alaryhmän jäsenet | Alaryhmän jäsenet ja kutsutut vieraat |

Jos haluat pääryhmän jäsenten voivan liittyä itse, valitse **Näkyy pääryhmälle** ja sitten **Ryhmän [pääryhmä] jäsenet voivat liittyä ilman hyväksyntää** kohdasta **Miten ihmiset liittyvät?** alaryhmää luodessasi tai kohdasta **Muokkaa ryhmän asetuksia → Yksityisyys**. Pääryhmän ulkopuoliset ihmiset tarvitsevat kutsun. Jäsenet voivat poistua alaryhmästä ja liittyä siihen uudelleen niin kauan kuin he kuuluvat sen pääryhmään.

![Alaryhmän yksityisyysasetukset, joissa alaryhmä näkyy pääryhmälle ja liittyminen onnistuu ilman hyväksyntää](subgroups_privacy_settings.png)

Liittyminen tekee ihmisestä tavallisen alaryhmän jäsenen. Se ei tee hänestä ylläpitäjää eikä muuta olemassa olevien ketjujen yksityisyyttä.

Myös julkiset alaryhmät voivat sallia välittömän liittymisen. Kuka tahansa voi liittyä, kun tämä vaihtoehto on valittu. Kun pääryhmä on yksityinen, alaryhmän käytettävissä olevat yksityisyysasetukset ovat **Näkyy pääryhmälle** ja **Salainen**.

Alaryhmä, jonka yksityisyysasetus on **Näkyy pääryhmälle**, pysyy yksityisenä, kun sen pääryhmä muuttuu julkiseksi. Pääryhmän muuttaminen yksityiseksi rajoittaa sen julkisten alaryhmien näkyvyyden pääryhmän jäsenille ja tekee niiden ketjuista yksityisiä. Salaiset alaryhmät säilyvät ennallaan.

[Lue lisää ryhmän yksityisyydestä](/en/user_manual/groups/settings/privacy).

<!-- translation-section: permissions -->

### Käyttöoikeudet

Alaryhmät toimivat itsenäisesti pääryhmästä. Jos esimerkiksi alaryhmän yksityisyysasetus on **Salainen**, vain kutsutut jäsenet voivat löytää alaryhmän, nähdä sen jäsenet ja lukea ketjuja.

Alaryhmät, joiden yksityisyysasetus on **Suljettu** tai **Näkyy pääryhmälle**, voivat sallia pääryhmän jäsenten lukea yksityisiä ketjuja ennen liittymistä. Ota käyttöön **Ryhmän [pääryhmä] jäsenet voivat nähdä yksityiset ketjut** kohdassa **Käyttöoikeudet**. Nämä lukijat eivät saa äänioikeutta eivätkä alaryhmän jäsenyyttä.

![Asetus, joka antaa pääryhmän jäsenille oikeuden nähdä alaryhmän yksityiset ketjut](subgroups_private_threads_settings.png)

<!-- translation-section: find-subgroups -->

## Etsi alaryhmiä

Avaa sivupalkin valikko ja napsauta ryhmäsi nimeä nähdäksesi sen alaryhmät.

![Oatmilk Cooperative -ryhmän alaryhmät sivupalkissa](subgroups_find_subgroups.png)

<!-- translation-section: invite-to-a-subgroup -->

## Kutsu alaryhmään

Kutsu ihmisiä alaryhmään samalla tavalla kuin ryhmään. Jos he kuuluvat jo pääryhmään tai saman organisaation toiseen alaryhmään, johon sinäkin kuulut, voit kirjoittaa heidän nimensä tai valita kyseisen ryhmän vastaanottajiksi. Valitse vastaanottajaryhmän tunniste, jotta se avautuu yksittäisten ihmisten luetteloksi. Poista sitten ihmiset, joita et halua kutsua.

<!-- translation-section: simultaneously-invite-people-to-subgroups-and-parent-group -->

### Kutsu ihmisiä alaryhmiin ja pääryhmään samalla kertaa

Kun käytät pääryhmäsi **Jäsenet**-välilehden **Kutsu ihmisiä** -painiketta, voit kutsua ihmisiä useisiin alaryhmiin samalla kertaa. Valitse niiden alaryhmien valintaruudut, joihin haluat heidän liittyvän heti.

![Pääryhmän ja alaryhmän valitseminen kutsulomakkeessa](group_invite_email_subgroups.png)

<!-- translation-section: administer-a-subgroup -->

## Hallinnoi alaryhmää

Alaryhmillä voi olla omat ylläpitäjänsä, jotka voivat olla eri henkilöitä kuin pääryhmän ylläpitäjät.

Pääryhmän ylläpitäjä voi kuitenkin antaa itselleen ylläpitäjän oikeudet missä tahansa alaryhmässä. Näin pääryhmän ylläpitäjät voivat hallinnoida alaryhmiä tarvittaessa.

Siirry Alaryhmät-välilehdelle, etsi alaryhmä ja napsauta **Liittyä ryhmään**.

![Liittyä ryhmään -painike suljetussa alaryhmässä](member_join_subgroup.png)

Kun pääryhmän ylläpitäjä on liittynyt alaryhmän jäseneksi, hän voi antaa itselleen alaryhmän ylläpitäjän oikeudet.

![Ylläpitäjän oikeuksien antaminen pääryhmän ylläpitäjälle](member_make_admin.png)

<!-- translation-section: delete-a-subgroup -->

## Poista alaryhmä

Ylläpitäjät voivat poistaa alaryhmän samalla tavalla kuin ryhmän. Kun poistat alaryhmän, varmista, ettet poista pääryhmää.

Lue, [miten ryhmiä poistetaan](/en/user_manual/groups/deleting_your_group/).
