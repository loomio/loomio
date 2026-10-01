---
title: STV-verkiezingen
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
  introduction: 5f085f92dcdf253d
  when-to-use-stv: fe716c0aadaa4c79
  creating-an-stv-election: 37c0f3b71ee25d18
  number-of-seats: 45d29a98400766a9
  counting-method: 563024f65f8089b0
  quota-type: 3ee8bc58deb29c05
  how-voting-works: bfb620ab5f810dd9
  how-counting-works: 1b42fae723e9f594
  understanding-results: 9d149dcb12b5c306
  method-and-quota: 3a0c2ba42d9254d2
  elected-candidates: ba25c1bb9e9ab984
  round-by-round-details: d5ef4286c903b0b5
  exporting-ballots: dd9796b3c169ad82
  share-an-outcome: 3188f531185500eb
title_source: cd3e1a4cdc2456a6
title_generated: 9791a584c9d8c54a
---

<!-- translation-section: introduction -->

# STV-verkiezingen

**Single Transferable Vote (STV)** is een methode voor evenredige vertegenwoordiging waarmee meerdere kandidaten worden gekozen. De gekozen kandidaten vertegenwoordigen zo de verschillende opvattingen van de kiezers in verhouding tot hun steun.

<!-- translation-section: when-to-use-stv -->

## Wanneer gebruik je STV?

Gebruik een STV-verkiezing als je:

- Uit een groep genomineerden een **commissie, bestuur of groep afgevaardigden** wilt kiezen
- **Evenredige vertegenwoordiging** wilt, zodat minderheidsgroepen zetels kunnen winnen in verhouding tot hun steun
- Een verkiezing wilt houden waarin kiezers kandidaten op volgorde van voorkeur zetten

>[!NOTE]
>STV is **niet** hetzelfde als Loomio's [rangschikkingspeiling](/en/user_manual/polls/rank/). Die gebruikt een eenvoudiger puntensysteem om één beste optie te kiezen. STV kiest meerdere winnaars door stemmen over te dragen en kandidaten in telrondes uit te schakelen.

<!-- translation-section: creating-an-stv-election -->

## Een STV-verkiezing maken

Selecteer **STV-verkiezing** als peilingtype wanneer je een peiling start. Voeg daarna de kandidaten toe als opties. Je kunt de verkiezing instellen met het **aantal te vullen zetels**, de **telmethode** en het **quotatype**.

In dit voorbeeld kiest Oatmilk Cooperative drie mensen die toezicht houden op een proef met herbruikbare verpakkingen. Het formulier legt de rol uit, toont vijf kandidaten en gebruikt Scottish STV met het Droop-quotum.

![](form.png)

<!-- translation-section: number-of-seats -->

### Aantal te vullen zetels

Het aantal kandidaten dat gekozen moet worden. Dit moet kleiner zijn dan het aantal kandidaten.

<!-- translation-section: counting-method -->

### Telmethode

Er zijn twee methoden om de stemmen te tellen:

Scottish STV
  : Aanbevolen. De Weighted Inclusive Gregory Method (WIGM), die sinds 2007 wordt gebruikt bij Schotse lokale verkiezingen. De regels zijn duidelijk en eenvoudig. Geschikt voor de meeste organisaties.
  
Meek STV
  : Een nauwkeurigere methode waarbij alleen een computer de stemmen kan tellen. Als een kandidaat wordt gekozen, blijft Meek het deel van elke stem dat die kandidaat niet nodig heeft overdragen aan de volgende voorkeuren van de kiezer. Dit geldt ook voor stemmen die de kandidaat later in de telling ontvangt. Als een kandidaat wordt uitgeschakeld, worden de stemmen opnieuw geteld alsof die kandidaat nooit had meegedaan. Er gaan minder stemmen verloren dan bij Scottish STV, maar de telling kan niet met de hand worden gecontroleerd.

<!-- translation-section: quota-type -->

### Quotatype

Het quotum is het minimumaantal stemmen dat een kandidaat nodig heeft om een zetel te winnen. Je kunt kiezen uit:

Droop
  : Aanbevolen. Het gebruikelijke quotum voor STV-verkiezingen, dat wordt gebruikt in Ierland, Australië en Schotland. Het is het kleinste quotum dat niet door meer kandidaten kan worden gehaald dan er zetels zijn. Een groep kiezers die de eigen kandidaten als eerste rangschikt, wint minstens zoveel zetels als het aantal quota waarover die groep beschikt. Het wordt zo berekend:
\\[ floor(\frac{votes}{(seats + 1)}) + 1 \\]

Hare
  : Een hoger quotum. Groepen met veel stemmen gebruiken meer stemmen voor elke zetel die ze winnen, waardoor kleinere groepen meer kans hebben om de laatste zetels te winnen. Het wordt zo berekend:
    \\[ \frac{votes}{seats}\\]

In beide formules is *votes* het aantal stembiljetten waarop minstens één kandidaat is gerangschikt.

Meek STV berekent het quotum zonder afronding, voor Droop als votes ÷ (seats + 1). Het quotum wordt elke ronde opnieuw berekend op basis van de stemmen die kandidaten nog hebben. Een kandidaat moet meer stemmen dan het quotum hebben om gekozen te worden.
  
  >[!TIP]
  > Het Droop-quotum is altijd lager dan het Hare-quotum. Bij een verkiezing met 100 stemmen en vier zetels is het Droop-quotum bijvoorbeeld 21 en het Hare-quotum 25.

<!-- translation-section: how-voting-works -->

## Hoe stemmen werkt

In dit voorbeeld kiest Oatmilk Cooperative drie mensen die toezicht houden op de proef met herbruikbare verpakkingen. Kiezers slepen kandidaten boven de lijn en zetten hen op volgorde van voorkeur:

![](stv-vote-in-progress.png)

- **Rang 1** = kandidaat met de hoogste voorkeur
- **Rang 2** = tweede keuze
- Rangschik zoveel kandidaten als je wilt

Kiezers moeten minstens één kandidaat rangschikken, maar hoeven niet elke kandidaat te rangschikken. Kandidaten zonder rang krijgen geen steun van die kiezer.

<!-- translation-section: how-counting-works -->

## Hoe het tellen werkt
De stemmen worden als volgt geteld:

1. Er wordt een **quotum** berekend (het minimumaantal stemmen dat nodig is om een zetel te winnen).
2. De **Eerste voorkeuren** worden voor elke kandidaat geteld.
3. Elke kandidaat die het quotum haalt, wordt **gekozen**. Het overschot aan stemmen boven het quotum wordt voor een deel van de waarde **overgedragen** aan de volgende voorkeuren van de kiezers, te beginnen met het grootste overschot. Stemmen worden alleen overgedragen aan kandidaten die nog in de telling zitten.
4. Als er geen overschot meer is om over te dragen, wordt de kandidaat met de **minste stemmen uitgeschakeld**. De stemmen van die kandidaat worden voor hun volledige waarde overgedragen aan de volgende voorkeuren van de kiezers.
5. Als het aantal overgebleven kandidaten gelijk is aan het aantal nog te vullen zetels, worden ze allemaal gekozen, ook als ze het quotum niet hebben gehaald.
6. Anders wordt de telling vanaf stap 3 herhaald totdat alle zetels zijn gevuld.

Door slechts een deel van de waarde over te dragen, worden alleen de stemmen verdeeld die een winnaar niet nodig heeft. Als het quotum bijvoorbeeld 26 is en een kandidaat 40 stemmen heeft, is het overschot 14. Elk van de 40 stembiljetten wordt overgedragen aan de volgende voorkeur met een waarde van 14 ÷ 40 = 0,35 stem.

Bij Scottish STV wordt de waarde van elke overgedragen stem naar beneden afgerond op vijf decimalen, net als bij Schotse gemeenteraadsverkiezingen.

Als twee of meer kandidaten de minste stemmen hebben, wordt de kandidaat uitgeschakeld die in de meest recente eerdere ronde minder stemmen had.

>[!TIP]
>Een stembiljet telt alleen mee zolang er een kandidaat op is gerangschikt die nog in de telling zit. Als er geen meer over zijn, is het stembiljet 'uitgeput' en telt het niet meer mee.

<!-- translation-section: understanding-results -->

## De uitslag begrijpen

Na het sluiten van de peiling wordt de uitslag in verschillende onderdelen getoond. In deze verkiezing vullen Samira Patel, Alex Morgan en Morgan Price de drie zetels in de commissie:

![](stv-results-summary.png)

<!-- translation-section: method-and-quota -->

### Methode en quotum

Bovenaan zie je de telmethode (Scottish STV of Meek STV), het quotatype (Droop of Hare) en het quotum: het aantal stemmen dat een kandidaat nodig had om een zetel te winnen.

<!-- translation-section: elected-candidates -->

### Gekozen kandidaten

Een overzichtstabel van de winnaars met vijf kolommen:

| Kolom | Betekenis |
|--------|---------|
| **Kandidaat** | De naam van de gekozen kandidaat |
| **Ronde gekozen** | De telronde waarin de kandidaat het quotum haalde en een zetel won. Ronde 1 betekent dat de kandidaat alleen met eerste voorkeuren won. In latere rondes waren ook overgedragen stemmen van uitgeschakelde kandidaten of uit een overschot nodig. |
| **Eerste voorkeuren** | Het aantal kiezers dat deze kandidaat als eerste keuze rangschikte. Dit toont de directe steun vóór de overdracht van stemmen. |
| **Eindstand** | Het aantal stemmen van de kandidaat op het moment van verkiezing. Door overgedragen stemmen is dit vaak hoger dan het aantal eerste voorkeuren. |
| **Overschot** | Het aantal stemmen waarmee de eindstand van de kandidaat het quotum overschreed (eindstand min quotum). Een groter overschot betekent meer steun dan nodig was om te winnen. Bij Scottish STV wordt dit overschot verdeeld over de volgende voorkeuren van de kiezers. |

Soms kunnen eerdere rondes een gelijkspel niet doorbreken. Als het gelijkspel niet bepaalt wie er wordt gekozen, gaat de telling verder. Als dat wel zo is, stopt de telling in die ronde. Kandidaten die winnen ongeacht hoe het gelijkspel wordt doorbroken, worden als gekozen getoond. Kandidaten die afhankelijk van het gelijkspel kunnen winnen of verliezen, worden in een aparte tabel getoond. Loomio toont hen als gelijk geëindigd in plaats van willekeurig één kandidaat te kiezen.

<!-- translation-section: round-by-round-details -->

### Details per ronde

Klap **Details per ronde** uit om te zien hoe stemmen zijn overgedragen en kandidaten zijn uitgeschakeld. Elke rij toont een kandidaat en elke kolom een telronde. Elk getal geeft het aantal stemmen aan dat de kandidaat aan het begin van die ronde had:

![](stv-results.png)

Groen geeft aan wanneer een kandidaat werd gekozen, rood wanneer een kandidaat werd uitgeschakeld en oranje wanneer kandidaten gelijk eindigden.

<!-- translation-section: share-an-outcome -->

## Deel een conclusie

Deel een conclusie zodra de verkiezing sluit. Noem de gekozen personen en geef aan wanneer hun rol begint. Lees [Deel een conclusie](/en/user_manual/polls/intro_to_decisions#5-share-an-outcome) voor uitleg over hoe conclusies werken.

![Een conclusie met de namen van de gekozen commissieleden](outcome.png)

<!-- translation-section: exporting-ballots -->

## Stembiljetten exporteren

Na het sluiten van de verkiezing kunnen mensen die de uitslag mogen bekijken de stembiljetten exporteren in BLT-formaat voor een onafhankelijke hertelling of controle. De export bevat de rangschikkingen van kandidaten en voegt identieke rangschikkingen samen op één rij met het aantal stembiljetten. Bij anonieme verkiezingen bevat de export geen identiteit van kiezers, stembiljet-ID's, tijdstippen van indiening of volgorde van indiening.
