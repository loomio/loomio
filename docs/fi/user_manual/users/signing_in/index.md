---
title: Kirjautuminen
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/users/signing_in/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-30'
sections:
  introduction: 9aa03b133cc213ce
  sign-in-with-a-passkey: c685bd268243f8f5
  sign-in-with-email-and-password: 20db7df775a273d8
  get-a-sign-in-code: 50bf073c798941bc
  create-an-account: 9ac55c48d388b8a9
  sign-in-with-google: 1e8bfdcee244d0bd
  other-loomio-sites: 123e31828ab49002
  sign-out: 96c8936d1a7aef07
generated:
  introduction: 43078fe89df953a1
  sign-in-with-a-passkey: bc67e8ff42399f9b
  sign-in-with-email-and-password: ddd4b9af2deaa0c7
  get-a-sign-in-code: d6f28088b9a69a1a
  create-an-account: b54144229cacd8b7
  sign-in-with-google: 32b12b9c6ba42340
  other-loomio-sites: 3dd65df9ef952a41
  sign-out: 14811d65fc452b9c
title_source: 824a1d703ce676bb
title_generated: d368933632e1d251
---

<!-- translation-section: introduction -->

# Kirjautuminen

Loomio.comissa voit kirjautua sisään passkeyllä, sähköpostiosoitteella ja salasanalla, sähköpostitse lähetettävällä kirjautumiskoodilla tai Google-tilillä. Valitse sinulle sopivin käytettävissä oleva tapa.

![Loomion kirjautumislomake, jossa voi käyttää passkeytä, sähköpostiosoitetta ja salasanaa tai sähköpostitse lähetettävää koodia](sign_in_email.png)

<!-- translation-section: sign-in-with-a-passkey -->

## Kirjaudu sisään passkeyllä

Valitse **Käytä salasanaa**. Selain tai laite näyttää käytettävissä olevat Loomion passkeyt ja pyytää avaamaan valitsemasi passkeyn tavalliseen tapaan näytön lukituksella, sormenjäljellä, kasvojentunnistuksella, PIN-koodilla tai turva-avaimella. Sähköpostiosoitetta ei tarvitse antaa ensin.

Voit lisätä, nimetä ja poistaa passkeytä profiilissasi. Turvallisuussyistä Loomio voi pyytää sinua kirjautumaan uudelleen sisään ennen niiden muuttamista. Anna kullekin passkeylle tunnistettava nimi, kuten ”Työkannettava” tai ”Puhelin”. Passkey on sidottu siihen Loomio-sivustoon, jolla se luotiin. Laitteesi tai salasananhallintasi voi synkronoida sen.

<!-- translation-section: sign-in-with-email-and-password -->

## Kirjaudu sisään sähköpostiosoitteella ja salasanalla

Anna sähköpostiosoitteesi ja salasanasi ja valitse sitten **Kirjaudu sisään**. Tilien yksityisyyden suojaamiseksi Loomio näyttää saman virheilmoituksen riippumatta siitä, estääkö sähköpostiosoite vai salasana kirjautumisen.

Jos et ole lisännyt passkeytä, Loomio ehdottaa sen lisäämistä sen jälkeen, kun olet kirjautunut sisään salasanalla. Voit ohittaa ehdotuksen, ja Loomio muistaa valintasi.

Jos sinulla ei ole salasanaa tai et muista sitä, valitse sen sijaan **Lähetä minulle koodi**.

<!-- translation-section: get-a-sign-in-code -->

## Hanki kirjautumiskoodi

Valitse **Lähetä minulle koodi**, anna sähköpostiosoitteesi ja lähetä lomake. Loomio näyttää saman vahvistuksen riippumatta siitä, kuuluuko osoite johonkin tiliin. Näin muut eivät voi selvittää lomakkeen avulla, kuka käyttää Loomiota.

Jos osoite kuuluu tiliisi, Loomio lähettää kuusinumeroisen koodin. Palaa kirjautumislomakkeeseen, anna koodi ja valitse **Kirjaudu sisään**. Kirjautumiskoodit vanhenevat tavallisesti 24 tunnin kuluttua, eikä niitä voi käyttää uudelleen. Jos viesti ei saavu, tarkista roskapostikansiosi ja varmista, että annoit tiliisi liitetyn sähköpostiosoitteen.

![Loomion lomake kuusinumeroisen kirjautumiskoodin antamiseen](sign_in_code.png)

Aina kun kirjaudut sisään koodilla, Loomio ehdottaa salasanan asettamista tai vaihtamista. Jos selaimesi tukee passkeytä, voit myös lisätä sellaisen, vaikka olisit jo lisännyt passkeyn toisella laitteella. Passkeyllä voit kirjautua nopeasti sisään laitteesi sormenjäljellä, kasvojentunnistuksella tai näytön lukituksella. Voit ohittaa ehdotuksen ja jatkaa sähköpostitse lähetettävien koodien käyttöä.

<!-- translation-section: create-an-account -->

## Luo tili

Valitse **Luo tili** ja vahvista sähköpostiosoitteesi ohjeiden mukaan.

Yksityisyytesi suojaamiseksi käytä samaa sähköpostiosoitetta, johon sait ryhmäkutsun. Jos sinulla on tilejä usealla sähköpostiosoitteella, voit [yhdistää tilisi](/en/user_manual/users/merge_accounts).

<!-- translation-section: sign-in-with-google -->

## Kirjaudu sisään Google-tilillä

Valitse **Kirjaudu sisään Google-tilillä** ja tunnistaudu Google-tililläsi. Jos olemassa olevalla Loomio-tilillä on sama sähköpostiosoite, Loomio liittää Google-tunnuksesi siihen tiliin.

<!-- translation-section: other-loomio-sites -->

## Muut Loomio-sivustot

Omaa Loomio-sivustoaan ylläpitävät organisaatiot voivat määrittää eri kirjautumistapoja. Sivusto voi tarjota rinnakkain salasanoja, sähköpostitse lähetettäviä koodeja, passkeytä, Google-kirjautumista, SAML-kirjautumista tai muuta OAuth-palveluntarjoajaa.

Joillakin sivustoilla tarvitset kutsun ennen tilin luomista. Näillä sivustoilla **Luo tili** näkyy vain, kun avaat kutsulinkin.

Yksityisellä sivustolla, jolla käytetään vain kertakirjautumista (SSO), näkyy ainoastaan organisaation kirjautumisvaihtoehto. Sivusto ei tarjoa Loomion hallinnoimia salasanoja, sähköpostitse lähetettäviä kirjautumiskoodeja, tilin luomista suoraan Loomiossa eikä Loomion hallinnoimia passkeytä. Jos organisaatio käyttää passkeytä, sen tunnistuspalvelu pyytää niitä kertakirjautumisen aikana.

<!-- translation-section: sign-out -->

## Kirjaudu ulos

Avaa sivupalkki, valitse nimesi ja sitten **Kirjaudu ulos**. Jos käytät yhteiskäyttöistä tietokonetta, kirjaudu lopuksi ulos sen sijaan, että sulkisit vain selaimen välilehden.
