---
title: Kirjautuminen
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/users/signing_in/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
sections:
  introduction: 15eb32ac962bc715
  sign-in-with-a-passkey: 12038dab660af30d
  sign-in-with-email-and-password: 4918f19e6c5c0e8e
  get-a-sign-in-code: 2857b8b8be3a9bee
  create-an-account: 9ac55c48d388b8a9
  sign-in-with-google: 22b4cd3763d09a34
  other-loomio-sites: 37ad63f50883c4b4
  sign-out: b4ab119ac81aad77
generated:
  introduction: 92ba641c336f6816
  sign-in-with-a-passkey: f35264370aff4947
  sign-in-with-email-and-password: 4067ca61b5bba88b
  get-a-sign-in-code: 679e68d4f4cd7676
  create-an-account: 38bbe6ce8fd43930
  sign-in-with-google: f2be9c3604c670fe
  other-loomio-sites: cf3d0d5ca9e7ae81
  sign-out: dc28b5330210e2e5
title_source: 824a1d703ce676bb
title_generated: d368933632e1d251
---

<!-- translation-section: introduction -->

# Kirjautuminen

Loomio.comissa voit kirjautua sisään pääsyavaimella, sähköpostiosoitteella ja salasanalla, sähköpostitse lähetetyllä kirjautumiskoodilla tai Google-tilillä. Valitse sinulle sopivin tapa.

![Loomion kirjautumislomake, jossa voit käyttää pääsyavainta, sähköpostiosoitetta ja salasanaa tai sähköpostitse lähetettyä koodia](sign_in_email.png)

<!-- translation-section: sign-in-with-a-passkey -->

## Kirjaudu sisään pääsyavaimella

Valitse **Käytä salasanaa** — sinun ei tarvitse ensin syöttää sähköpostiosoitetta. Selaimesi tai laitteesi näyttää käytettävissäsi olevat Loomion pääsyavaimet ja pyytää sinua avaamaan yhden niistä näytön lukituksella, sormenjäljellä, kasvojentunnistuksella, tunnusluvulla tai turva-avaimella.

Voit lisätä, nimetä ja poistaa pääsyavaimia profiilissasi. Turvallisuussyistä Loomio saattaa pyytää sinua kirjautumaan uudelleen sisään ennen niiden muuttamista. Anna jokaiselle pääsyavaimelle selkeä nimi, kuten ”Työkannettava” tai ”Puhelin”. Pääsyavaimet on sidottu siihen Loomio-sivustoon, jolla loit ne, ja ne voivat synkronoitua laitteiden välillä laitteesi tai salasananhallintasi kautta.

<!-- translation-section: sign-in-with-email-and-password -->

## Kirjaudu sisään sähköpostiosoitteella ja salasanalla

Syötä sähköpostiosoitteesi ja salasanasi ja valitse **Kirjaudu sisään**. Yksityisyyden suojaamiseksi Loomio näyttää saman virheilmoituksen riippumatta siitä, onko sähköpostiosoite vai salasana väärä.

Jos et ole vielä lisännyt pääsyavainta, Loomio ehdottaa sen lisäämistä kirjauduttuasi sisään. Voit hylätä ehdotuksen, ja Loomio muistaa valintasi.

Jos sinulla ei ole salasanaa tai et muista sitä, valitse sen sijaan **Lähetä minulle koodi**.

<!-- translation-section: get-a-sign-in-code -->

## Hanki kirjautumiskoodi

Valitse **Lähetä minulle koodi**, syötä sähköpostiosoitteesi ja lähetä lomake. Yksityisyyden suojaamiseksi Loomio näyttää saman vahvistuksen riippumatta siitä, kuuluuko osoite jollekin tilille.

Jos osoite kuuluu tilillesi, Loomio lähettää sinulle sähköpostitse kuusinumeroisen koodin. Palaa kirjautumislomakkeeseen, syötä koodi ja valitse **Kirjaudu sisään**. Koodit vanhenevat 24 tunnin kuluttua, ja niitä voi käyttää vain kerran. Jos sähköposti ei saavu, tarkista roskapostikansiosi ja varmista, että syötit tiliisi liitetyn osoitteen.

![Loomion lomake kuusinumeroisen kirjautumiskoodin syöttämiseen](sign_in_code.png)

Kun olet kirjautunut sisään koodilla, Loomio ehdottaa salasanan asettamista tai vaihtamista tai pääsyavaimen lisäämistä, jos selaimesi tukee pääsyavaimia. Voit ohittaa ehdotuksen ja jatkaa sähköpostitse lähetettyjen koodien käyttöä.

<!-- translation-section: create-an-account -->

## Luo tili

Valitse **Luo tili** ja vahvista sähköpostiosoitteesi ohjeiden mukaan.

Yksityisyytesi suojaamiseksi käytä samaa sähköpostiosoitetta, johon sait ryhmän kutsun. Jos sinulla on tilejä useammalla osoitteella, voit [yhdistää tilisi](/en/user_manual/users/merge_accounts).

<!-- translation-section: sign-in-with-google -->

## Kirjaudu sisään Google-tilillä

Valitse **Kirjaudu sisään Google-tilillä** ja kirjaudu sisään Google-tililläsi. Jos olemassa oleva Loomio-tili käyttää samaa sähköpostiosoitetta, Loomio liittää Google-tilisi siihen. Muussa tapauksessa Loomio luo sinulle uuden tilin.

<!-- translation-section: other-loomio-sites -->

## Muut Loomio-sivustot

Omaa Loomio-sivustoaan ylläpitävät organisaatiot voivat määrittää erilaisia kirjautumistapoja. Sivusto voi tarjota rinnakkain salasanoja, sähköpostitse lähetettyjä koodeja, pääsyavaimia, Googlea, SAML:ää tai muuta OAuth-palveluntarjoajaa.

Joillakin sivustoilla tarvitset kutsun ennen kuin voit luoda tilin. Näillä sivustoilla **Luo tili** näkyy vain, kun avaat kutsulinkin.

Jotkin yksityiset sivustot edellyttävät kirjautumista organisaatiosi kertakirjautumisjärjestelmän (SSO) kautta. Nämä sivustot eivät tarjoa Loomion salasanoja, sähköpostitse lähetettyjä koodeja tai pääsyavaimia eivätkä anna sinun luoda erillistä Loomio-tiliä. Jos organisaatiosi käyttää pääsyavaimia, käytät niitä organisaatiosi kirjautumisnäkymässä.

<!-- translation-section: sign-out -->

## Kirjaudu ulos

Avaa sivupalkki, valitse nimesi ja valitse sitten **Kirjaudu ulos**. Kun käytät yhteistä tietokonetta, kirjaudu aina ulos lopetettuasi käytön. Pelkkä selaimen välilehden sulkeminen ei riitä.

Uloskirjautuminen päättää kyseisen selaimen istunnon välittömästi. Loomio säilyttää istunnon IP-osoitteen, selaimen tiedot sekä istunnon alkamis- ja päättymisajat tietoturvaselvityksiä varten oletusarvoisesti 60 päivän ajan (yksityisten sivustojen ylläpitäjät voivat muuttaa tätä säilytysaikaa). Tilisi poistaminen pysyvästi poistaa myös nämä istuntotiedot.
