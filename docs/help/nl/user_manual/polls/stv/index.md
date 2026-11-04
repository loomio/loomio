---
title: STV-verkiezingen
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
  introduction: 4af9f5ad46589ab3
  when-to-use-stv: 32f567a427cde35e
  creating-an-stv-election: f2d92d868e05bd7e
  number-of-seats: bcb68b4e855c69c3
  counting-method: 95b91f35ba21184c
  quota-type: e36f1f002f39dbc3
  how-voting-works: 04c8dc3b00cefc15
  how-counting-works: b8a183eaea637e71
  understanding-results: 865f6bf72f31a40d
  method-and-quota: ed493e2b8b34dea7
  elected-candidates: '096ecc43996eb93b'
  round-by-round-details: 7345b7559b885044
  exporting-ballots: 110c9ead88cd2893
  share-an-outcome: 15d37559d2ae21f8
title_source: cd3e1a4cdc2456a6
title_generated: 9791a584c9d8c54a
needs_review:
  elected-candidates: use "zetel" instead of "plaats" for "seat"
---

<!-- translation-section: introduction -->

# STV-verkiezingen

**Single Transferable Vote (STV)** is een stemmethode voor evenredige vertegenwoordiging waarmee meerdere winnaars uit een groep kandidaten worden gekozen. De methode zorgt ervoor dat gekozen kandidaten de verscheidenheid aan opvattingen onder kiezers evenredig vertegenwoordigen.

<!-- translation-section: when-to-use-stv -->

## Wanneer gebruik je STV

Gebruik een STV-verkiezing wanneer je:

- Een **commissie, bestuur of delegatie** wilt kiezen uit een groep voorgedragen kandidaten
- **Evenredige vertegenwoordiging** wilt waarborgen, waarbij minderheden zetels kunnen winnen in verhouding tot hun steun
- Verkiezingen wilt houden waarbij kiezers kandidaten op volgorde van voorkeur rangschikken

>[!NOTE]
>STV is **niet** hetzelfde als Loomio's [rangschikpeiling](/en/user_manual/polls/rank/), die een eenvoudigere rangschikking op basis van scores gebruikt om één beste optie te kiezen. STV ondersteunt verkiezingen met meerdere winnaars, waarbij stemmen worden overgedragen en kandidaten in opeenvolgende rondes afvallen.

<!-- translation-section: creating-an-stv-election -->

## Een STV-verkiezing aanmaken

Selecteer bij het starten van een peiling **STV-verkiezing** als peilingtype en voeg vervolgens de kandidaten toe als opties van de peiling. Je kunt de peiling aanpassen door het **aantal zetels**, de **telmethode** en het **type quotum** in te stellen.

In dit voorbeeld kiest Oatmilk Cooperative drie mensen om toezicht te houden op een proef met retourneerbare verpakkingen. Het formulier beschrijft de rol, vermeldt vijf kandidaten en gebruikt Scottish STV met het Droop-quotum.

![](form.png)

<!-- translation-section: number-of-seats -->

### Aantal zetels

Het aantal winnaars dat gekozen moet worden. Dit moet kleiner zijn dan het aantal kandidaten.

<!-- translation-section: counting-method -->

### Telmethode

Er zijn twee methoden beschikbaar om de stemmen te tellen:

Scottish STV
  : Aanbevolen. De Weighted Inclusive Gregory Method (WIGM), die sinds 2007 bij Schotse lokale verkiezingen wordt gebruikt. Duidelijk vastgelegde, eenvoudige regels. Geschikt voor de meeste organisaties.
  
Meek STV
  : Een nauwkeurigere methode waarbij alleen een computer de telling kan uitvoeren. Wanneer een kandidaat wordt gekozen, blijft Meek het deel van elke stem dat die kandidaat niet nodig heeft doorgeven aan de volgende voorkeuren van de kiezer. Dit geldt ook voor stemmen die de kandidaat later tijdens de telling bereiken. Wanneer een kandidaat afvalt, worden de stemmen opnieuw geteld alsof die kandidaat nooit had meegedaan. Er gaan minder stemmen verloren dan bij Scottish STV, maar de telling kan niet met de hand worden gecontroleerd.

<!-- translation-section: quota-type -->

### Type quotum

Het quotum is het minimale aantal stemmen dat een kandidaat nodig heeft om een zetel te winnen. Je kunt kiezen uit:

Droop
  : Aanbevolen. Het standaardquotum voor STV-verkiezingen, gebruikt in Ierland, Australië en Schotland. Het is het kleinste quotum dat niet door meer kandidaten kan worden bereikt dan er zetels zijn. Een groep kiezers die de eigen kandidaten bovenaan zet, wint minstens zoveel zetels als het aantal quota dat hun stemmen samen vormen. Het wordt als volgt berekend:
\\[ floor(\frac{votes}{(seats + 1)}) + 1 \\]

Hare
  : Een groter quotum. Groepen met veel stemmen gebruiken meer stemmen voor elke zetel die ze winnen, waardoor kleinere groepen meer kans hebben om de laatste zetels te winnen. Het wordt als volgt berekend:
    \\[ \frac{votes}{seats}\\]

In beide formules is *votes* het aantal stembiljetten waarop minstens één kandidaat is gerangschikt.

Meek STV berekent het quotum zonder afronding, voor Droop als votes ÷ (seats + 1). Het quotum wordt elke ronde opnieuw berekend op basis van de stemmen die nog bij kandidaten liggen. Een kandidaat moet het quotum overschrijden om gekozen te worden.
  
  >[!TIP]
  > Droop levert altijd een kleiner aantal stemmen op dan Hare. Bij een verkiezing met 100 stemmen en vier zetels is het Droop-quotum bijvoorbeeld 21 en het Hare-quotum 25.

<!-- translation-section: how-voting-works -->

## Hoe stemmen werkt

In dit voorbeeld kiest Oatmilk Cooperative drie mensen om toezicht te houden op de proef met herbruikbare verpakkingen. Kiezers slepen kandidaten boven de lijn en rangschikken ze op volgorde van voorkeur:

![](stv-vote-in-progress.png)

- **Rangschikken 1** = kandidaat met de hoogste voorkeur
- **Rangschikken 2** = tweede keuze
- Rangschik zoveel kandidaten als je wilt

Kiezers moeten minstens één kandidaat rangschikken, maar hoeven niet elke kandidaat te rangschikken. Kandidaten die een kiezer niet rangschikt, ontvangen geen steun van die kiezer.

<!-- translation-section: how-counting-works -->

## Hoe de telling werkt
De telling verloopt als volgt:

1. Er wordt een **quotum** berekend (het minimale aantal stemmen dat nodig is om een zetel te winnen).
2. De **Eerste voorkeuren** worden voor elke kandidaat geteld.
3. Elke kandidaat die het quotum bereikt, is **gekozen**. De overtollige stemmen (boven het quotum) worden met een gedeeltelijke waarde **overgedragen** aan de volgende voorkeuren van de kiezers, beginnend met het grootste overschot. Stemmen worden alleen overgedragen aan kandidaten die nog in de telling zitten.
4. Als er geen overschot meer is om over te dragen, is de kandidaat met de **minste stemmen afgevallen**. De stemmen van die kandidaat worden met hun volledige waarde overgedragen aan de volgende voorkeuren van de kiezers.
5. Wanneer het aantal overgebleven kandidaten gelijk is aan het aantal resterende zetels, worden ze allemaal gekozen, ook als ze het quotum niet hebben bereikt.
6. Anders wordt de telling vanaf stap 3 herhaald totdat alle zetels zijn ingevuld.

Door de gedeeltelijke waarde worden alleen de stemmen verdeeld die een winnaar niet nodig heeft. Als het quotum bijvoorbeeld 26 is en een kandidaat 40 stemmen heeft, is het overschot 14. Elk van de 40 stembiljetten wordt overgedragen aan de volgende voorkeur met een waarde van 14 ÷ 40 = 0,35 stem.

Bij Scottish STV wordt de waarde van elke overgedragen stem naar beneden afgerond op vijf decimalen, zoals bij Schotse gemeenteraadsverkiezingen.

Als twee of meer kandidaten de minste stemmen hebben, valt de kandidaat af die in de meest recente eerdere ronde minder stemmen had.

>[!TIP]
>Een stembiljet telt alleen mee zolang er een kandidaat op is gerangschikt die nog in de telling zit. Als er geen meer over zijn, is het stembiljet "uitgeput" en telt het niet meer mee.

<!-- translation-section: understanding-results -->

## Het resultaat begrijpen

Nadat de peiling is gesloten, wordt het resultaat in verschillende onderdelen weergegeven. Bij deze verkiezing nemen Samira Patel, Alex Morgan en Morgan Price de drie commissiezetels in:

![](stv-results-summary.png)

<!-- translation-section: method-and-quota -->

### Methode en quotum

Bovenaan zie je de telmethode (Scottish STV of Meek STV) en het type quotum (Droop of Hare), samen met het quotum: het aantal stemmen dat een kandidaat nodig had om een zetel te winnen.

<!-- translation-section: elected-candidates -->

### Gekozen kandidaten

Een overzichtstabel van de winnaars met vijf kolommen:

| Kolom | Betekenis |
|--------|---------|
| **Kandidaat** | De naam van de gekozen kandidaat |
| **Ronde gekozen** | De telronde waarin de kandidaat het quotum bereikte en een zetel won. Ronde 1 betekent dat de kandidaat alleen op basis van eerste voorkeuren won; in latere rondes waren overgedragen stemmen nodig van afgevallen kandidaten of kandidaten met een overschot. |
| **Eerste voorkeuren** | Hoeveel kiezers deze kandidaat als eerste keuze rangschikten. Dit toont de directe steun voor een kandidaat voordat er stemmen worden overgedragen. |
| **Eindstand** | Het aantal stemmen van de kandidaat op het moment dat die werd gekozen. Door de overdracht van stemmen is dit vaak hoger dan het aantal eerste voorkeuren. |
| **Overschot** | Hoeveel de eindstand van de kandidaat boven het quotum lag (eindstand min quotum). Een groter overschot betekent meer steun bovenop wat nodig was om te winnen. Bij Scottish STV wordt dit overschot herverdeeld over de volgende voorkeuren van de kiezers. |

Soms kunnen eerdere rondes een gelijke stand niet doorbreken. Als de gelijke stand geen invloed heeft op wie wordt gekozen, gaat de telling verder. Als dat wel zo is, stopt de telling bij die ronde. Kandidaten die winnen ongeacht hoe de gelijke stand wordt doorbroken, worden als gekozen weergegeven. Kandidaten die afhankelijk van de gelijke stand kunnen winnen of verliezen, worden in een aparte tabel weergegeven. Loomio toont hen met een gelijke stand in plaats van willekeurig één kandidaat te kiezen.

<!-- translation-section: round-by-round-details -->

### Details per ronde

Klap **Details per ronde** open om overdrachten van stemmen en afgevallen kandidaten te bekijken. Elke rij is een kandidaat en elke kolom is een telronde. Elk getal geeft het aantal stemmen aan dat de kandidaat aan het begin van die ronde had:

![](stv-results.png)

De groene markering laat zien wanneer een kandidaat werd gekozen, rood wanneer de kandidaat afviel en oranje wanneer er een gelijke stand was.

<!-- translation-section: share-an-outcome -->

## Een conclusie delen

Deel een conclusie wanneer de verkiezing sluit. Noem de gekozen personen en geef aan wanneer hun rol begint. Zie [Een conclusie delen](/en/user_manual/polls/intro_to_decisions#5-share-an-outcome) voor uitleg over hoe conclusies werken.

![Een conclusie met de namen van de gekozen commissieleden](outcome.png)

<!-- translation-section: exporting-ballots -->

## Stembiljetten exporteren

Nadat de verkiezing is gesloten, kunnen mensen die het resultaat kunnen bekijken de stembiljetten in BLT-formaat exporteren voor een onafhankelijke hertelling of controle. De export bevat de voorkeursvolgorde van kandidaten en voegt identieke voorkeursvolgordes samen tot één rij met het aantal stembiljetten. Bij anonieme verkiezingen bevat de export geen identiteiten van kiezers, identificatiecodes van stembiljetten, tijdstippen van indienen of volgorde van indienen.
