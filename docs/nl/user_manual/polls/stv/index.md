---
title: STV-verkiezingen
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
  introduction: 5f085f92dcdf253d
  when-to-use-stv: fe716c0aadaa4c79
  creating-an-stv-election: 37c0f3b71ee25d18
  number-of-seats: 45d29a98400766a9
  counting-method: 75bf3273e03ec703
  quota-type: d209d1df37cf22f2
  how-voting-works: 41d1bccb6e48f5d6
  how-counting-works: c2bde2e48b1bfc8e
  understanding-results: 9d149dcb12b5c306
  method-and-quota: 3a0c2ba42d9254d2
  elected-candidates: caf4e186f3a6eeeb
  round-by-round-details: 3e5fcbf63af1ff7f
  exporting-ballots: dd9796b3c169ad82
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

Scottish STV : Aanbevolen. De Weighted Inclusive Gregory Method (WIGM), die sinds 2007 wordt gebruikt bij Schotse lokale verkiezingen. De regels zijn duidelijk en eenvoudig. Geschikt voor de meeste organisaties.

Meek STV : Een wiskundig nauwkeurigere methode die de telling herhaalt. Als een kandidaat wordt uitgeschakeld, worden de stemmen opnieuw geteld alsof die kandidaat nooit had meegedaan.

<!-- translation-section: quota-type -->

### Quotatype

Het quotum is het minimumaantal stemmen dat een kandidaat nodig heeft om een zetel te winnen. Je kunt kiezen uit:

Droop : Aanbevolen. Het gebruikelijke quotatype voor de meeste STV-verkiezingen. Het wordt gebruikt in Ierland, Australië en Schotland. Droop garandeert dat een coalitie met een meerderheid van de stemmen ook een meerderheid van de zetels krijgt. Het wordt zo berekend: \\[ floor(\frac{votes}{(seats + 1)}) + 1 \\]

Hare
  : Een hoger minimum, dat kleinere groepen evenrediger vertegenwoordigt.
    DSA-afdelingen geven de voorkeur aan Hare om de vertegenwoordiging van minderheden te beschermen.
   Het wordt zo berekend:
    \\[ \frac{votes}{seats}\\]

>[!TIP]
  > Het Droop-quotum is altijd lager dan het Hare-quotum. Bij een verkiezing met 100 stemmen en vier zetels is het Droop-quotum bijvoorbeeld 21 en het Hare-quotum 25.

<!-- translation-section: how-voting-works -->

## Hoe stemmen werkt

In dit voorbeeld kiest Oatmilk Cooperative drie mensen die toezicht houden op de proef met herbruikbare verpakkingen. Kiezers slepen kandidaten boven de lijn en zetten hen op volgorde van voorkeur:

![](stv-vote-in-progress.png)

- **Rang 1** = kandidaat met de hoogste voorkeur
- **Rang 2** = tweede keuze
- Rangschik zoveel kandidaten als je wilt

Kiezers hoeven niet elke kandidaat te rangschikken. Kandidaten zonder rang krijgen geen steun van die kiezer.

<!-- translation-section: how-counting-works -->

## Hoe het tellen werkt
De stemmen worden als volgt geteld:

1. Er wordt een **quotum** berekend: het minimumaantal stemmen dat nodig is om een zetel te winnen.
2. De **Eerste voorkeuren** worden voor elke kandidaat geteld.
3. Als een kandidaat het quotum haalt, wordt die **gekozen**. Het overschot aan stemmen boven het quotum wordt voor een deel van de waarde **overgedragen** aan de volgende voorkeuren van de kiezers.
4. Als geen kandidaat het quotum haalt, wordt de kandidaat met de **minste stemmen uitgeschakeld**. De stemmen van die kandidaat worden voor hun volledige waarde overgedragen aan de volgende voorkeuren van de kiezers.
5. Dit proces wordt herhaald totdat alle zetels zijn gevuld.

>[!TIP]
>Als een kiezer geen overgebleven kandidaten heeft gerangschikt, is het stembiljet 'uitgeput' en telt die stem niet meer mee. Daarom is het meestal beter om meer kandidaten te rangschikken.

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

Als de telling eindigt in een gelijkspel waarbij het uitschakelen van een van de overgebleven kandidaten de uitslag zou veranderen, worden die kandidaten in een aparte tabel getoond. Er wordt dan niet willekeurig een winnaar gekozen.

<!-- translation-section: round-by-round-details -->

### Details per ronde

Klap **Details per ronde** uit om te zien hoe stemmen zijn overgedragen en kandidaten zijn uitgeschakeld. Elke rij toont een kandidaat en elke kolom een telronde:

![](stv-results.png)

Groen geeft aan wanneer een kandidaat werd gekozen, rood wanneer een kandidaat werd uitgeschakeld en oranje wanneer kandidaten gelijk eindigden.

<!-- translation-section: exporting-ballots -->

## Stembiljetten exporteren

Na het sluiten van de verkiezing kunnen mensen die de uitslag mogen bekijken de stembiljetten exporteren in BLT-formaat voor een onafhankelijke hertelling of controle. De export bevat de rangschikkingen van kandidaten en voegt identieke rangschikkingen samen op één rij met het aantal stembiljetten. Bij anonieme verkiezingen bevat de export geen identiteit van kiezers, stembiljet-ID's, tijdstippen van indiening of volgorde van indiening.
