---
title: STV-Wahlen
source_revision: c6076258c3438c0dd6dc8fbf1fc0b0df47c0aeb5
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
  introduction: 61a1095de89ba748
  when-to-use-stv: '08ec5f91f20d3515'
  creating-an-stv-election: 4514bca6a7efa547
  number-of-seats: cd3c94e20e907cd4
  counting-method: 93e9aa71254df7f2
  quota-type: a5a5b014c6061989
  how-voting-works: 364b279c21f10a85
  how-counting-works: 2276fea0469e04ce
  understanding-results: 2704a3492756e0ae
  method-and-quota: 5fd11096fe63313e
  elected-candidates: 1f60b374dbc6d9bd
  round-by-round-details: f6ede0a3c0b682a0
  exporting-ballots: 422a14ecb67f3754
  share-an-outcome: 2965e0166adfb19e
title_source: cd3e1a4cdc2456a6
title_generated: d3db61f29b5753db
needs_review:
  when-to-use-stv: use "Stimme" instead of "Abstimmung" for "vote"
---

<!-- translation-section: introduction -->

# STV-Wahlen

**Single Transferable Vote (STV)** ist eine Abstimmungsart für die Verhältniswahl, bei der mehrere Personen aus einem Kreis von Kandidierenden gewählt werden. Sie sorgt dafür, dass die gewählten Personen die Vielfalt der Ansichten unter den Abstimmenden proportional repräsentieren.

<!-- translation-section: when-to-use-stv -->

## Wann du STV verwenden solltest

Verwende eine STV-Wahl, wenn du:

- einen **Ausschuss, einen Vorstand oder eine Gruppe von Delegierten** aus vorgeschlagenen Personen wählen möchtest
- eine **proportionale Vertretung** sicherstellen möchtest, bei der Minderheiten Sitze entsprechend ihrer Unterstützung gewinnen können
- Wahlen durchführen möchtest, bei denen Abstimmende die Kandidierenden nach ihrer Präferenz ordnen

>[!NOTE]
>STV ist **nicht** dasselbe wie Loomios [Abstimmung zum Ordnen](/en/user_manual/polls/rank/), die eine einfachere, punktebasierte Rangfolge verwendet, um eine einzelne beste Option auszuwählen. STV ermöglicht Wahlen mit mehreren zu wählenden Personen, bei denen Stimmen übertragen und Kandidierende in mehreren Runden ausgeschlossen werden.

<!-- translation-section: creating-an-stv-election -->

## Eine STV-Wahl erstellen

Wähle beim Starten einer Abstimmung **STV-Wahl** als Abstimmungstyp und füge die Kandidierenden als Optionen hinzu. Du kannst die Abstimmung anpassen, indem du die **Anzahl der Sitze**, die **Auszählungsmethode** und den **Quotentyp** festlegst.

In diesem Beispiel wählt Oatmilk Cooperative drei Personen, die ihren Versuch mit Mehrwegverpackungen betreuen sollen. Das Formular beschreibt die Aufgabe, listet fünf Kandidierende auf und verwendet Scottish STV mit der Droop-Quote.

![](form.png)

<!-- translation-section: number-of-seats -->

### Anzahl der Sitze

Wie viele Personen gewählt werden sollen. Die Anzahl muss kleiner sein als die Anzahl der Kandidierenden.

<!-- translation-section: counting-method -->

### Auszählungsmethode

Es gibt zwei Methoden zur Auszählung der Stimmen:

Scottish STV
  : Empfohlen. Die Weighted Inclusive Gregory Method (WIGM), die seit 2007 bei schottischen Kommunalwahlen verwendet wird. Klar definierte, einfache Regeln. Für die meisten Organisationen am besten geeignet.
  
Meek STV
  : Eine genauere Methode, deren Auszählung nur ein Computer durchführen kann. Wenn eine kandidierende Person gewählt wird, gibt Meek den nicht benötigten Anteil jeder Stimme weiterhin an die nachfolgenden Präferenzen der abstimmenden Person weiter. Das gilt auch für Stimmen, die die gewählte Person erst später in der Auszählung erreichen. Wenn eine kandidierende Person ausscheidet, werden die Stimmen erneut ausgezählt, als hätte diese Person nie kandidiert. Weniger Stimmen bleiben ungenutzt als bei Scottish STV, aber die Auszählung lässt sich nicht von Hand überprüfen.

<!-- translation-section: quota-type -->

### Quotentyp

Die Quote ist die Mindestanzahl an Stimmen, die eine kandidierende Person benötigt, um einen Sitz zu gewinnen. Es gibt zwei Möglichkeiten:

Droop
  : Empfohlen. Die Standardquote für STV-Wahlen, die in Irland, Australien und Schottland verwendet wird. Sie ist die kleinste Quote, die höchstens so viele Kandidierende erreichen können, wie Sitze zu vergeben sind. Eine Gruppe von Abstimmenden, die ihre eigenen Kandidierenden an erster Stelle einordnet, gewinnt mindestens so viele Sitze, wie ihre Stimmen vollständige Quoten ergeben. Sie wird so berechnet:
\\[ floor(\frac{votes}{(seats + 1)}) + 1 \\]

Hare
  : Eine größere Quote. Gruppen mit vielen Stimmen benötigen für jeden gewonnenen Sitz mehr davon, sodass kleinere Gruppen eher die letzten Sitze gewinnen können. Sie wird so berechnet:
    \\[ \frac{votes}{seats}\\]

In beiden Formeln ist *votes* die Anzahl der Stimmzettel, auf denen mindestens eine kandidierende Person eingeordnet ist.

Meek STV berechnet die Quote ohne Rundung, bei Droop als votes ÷ (seats + 1). Die Quote wird in jeder Runde anhand der Stimmen neu berechnet, die noch auf Kandidierende entfallen. Eine kandidierende Person muss die Quote überschreiten, um gewählt zu werden.
  
  >[!TIP]
  > Die Droop-Quote ergibt immer eine kleinere Stimmenzahl als die Hare-Quote. Bei einer Wahl mit 100 Stimmen und vier Sitzen wäre die Droop-Quote beispielsweise 21 und die Hare-Quote 25.

<!-- translation-section: how-voting-works -->

## So funktioniert die Stimmabgabe

In diesem Beispiel wählt Oatmilk Cooperative drei Personen, die den Versuch mit Mehrwegverpackungen betreuen sollen. Abstimmende ziehen die Kandidierenden über die Linie und ordnen sie nach ihrer Präferenz:

![](stv-vote-in-progress.png)

- **Ordnen 1** = bevorzugte kandidierende Person
- **Ordnen 2** = zweite Wahl
- Ordne so viele Kandidierende, wie du möchtest

Abstimmende müssen mindestens eine kandidierende Person einordnen, aber nicht alle. Nicht eingeordnete Kandidierende erhalten keinen Anteil der Stimme dieser abstimmenden Person.

<!-- translation-section: how-counting-works -->

## So funktioniert die Auszählung
Die Auszählung läuft wie folgt ab:

1. Eine **Quote** wird berechnet (die Mindestanzahl an Stimmen, die nötig ist, um einen Sitz zu gewinnen).
2. **Erste Präferenzen** werden für alle Kandidierenden gezählt.
3. Jede kandidierende Person, die die Quote erreicht, ist **gewählt**. Ihre überschüssigen Stimmen (oberhalb der Quote) werden mit einem anteiligen Wert an die nächsten Präferenzen der Abstimmenden **übertragen**, beginnend mit dem größten Überschuss. Stimmen werden nur an Kandidierende übertragen, die noch in der Auszählung sind.
4. Wenn kein Überschuss mehr übertragen werden kann, **scheidet die kandidierende Person mit den wenigsten Stimmen aus**. Ihre Stimmen werden mit ihrem vollen Wert an die nächsten Präferenzen der Abstimmenden übertragen.
5. Wenn die Anzahl der verbleibenden Kandidierenden der Anzahl der noch zu besetzenden Sitze entspricht, sind sie alle gewählt, auch wenn sie die Quote nicht erreicht haben.
6. Andernfalls wird die Auszählung ab Schritt 3 wiederholt, bis alle Sitze besetzt sind.

Durch den anteiligen Wert werden nur die Stimmen weitergegeben, die eine gewählte Person nicht benötigt. Wenn die Quote beispielsweise 26 beträgt und eine kandidierende Person 40 Stimmen hat, beträgt ihr Überschuss 14. Jeder ihrer 40 Stimmzettel wird an die nächste Präferenz weitergegeben und zählt dort mit einem Wert von 14 ÷ 40 = 0,35 einer Stimme.

Bei Scottish STV wird der Wert jeder übertragenen Stimme auf fünf Nachkommastellen abgerundet, wie bei schottischen Kommunalwahlen.

Wenn zwei oder mehr Kandidierende die wenigsten Stimmen haben, scheidet die Person aus, die in der letzten vorherigen Runde mit unterschiedlichen Stimmenzahlen weniger Stimmen hatte.

>[!TIP]
>Ein Stimmzettel zählt nur, solange darauf eine kandidierende Person eingeordnet ist, die noch in der Auszählung ist. Wenn keine mehr übrig ist, ist der Stimmzettel „erschöpft“ und zählt nicht mehr.

<!-- translation-section: understanding-results -->

## Das Ergebnis verstehen

Nachdem die Abstimmung beendet ist, wird das Ergebnis in mehreren Abschnitten angezeigt. Bei dieser Wahl besetzen Samira Patel, Alex Morgan und Morgan Price die drei Ausschusssitze:

![](stv-results-summary.png)

<!-- translation-section: method-and-quota -->

### Methode und Quote

Oben siehst du die Auszählungsmethode (Scottish STV oder Meek STV) und den Quotentyp (Droop oder Hare) sowie die Quote: die Anzahl an Stimmen, die eine kandidierende Person benötigte, um einen Sitz zu gewinnen.

<!-- translation-section: elected-candidates -->

### Gewählte Personen

Eine Übersichtstabelle der gewählten Personen mit fünf Spalten:

| Spalte | Bedeutung |
|--------|---------|
| **Kandidat** | Der Name der gewählten Person |
| **Runde gewählt** | Die Auszählungsrunde, in der die Person die Quote erreicht und einen Sitz gewonnen hat. Runde 1 bedeutet, dass sie allein durch erste Präferenzen gewonnen hat; in späteren Runden benötigte sie übertragene Stimmen von ausgeschiedenen Kandidierenden oder aus Überschüssen. |
| **Erste Präferenzen** | Wie viele Abstimmende diese Person als erste Wahl eingeordnet haben. Das zeigt ihre direkte Unterstützung vor jeder Stimmenübertragung. |
| **Endergebnis** | Die Stimmenzahl der Person zum Zeitpunkt ihrer Wahl. Durch Stimmenübertragungen ist sie oft höher als die Anzahl ihrer ersten Präferenzen. |
| **Überschuss** | Um wie viel das Endergebnis der Person die Quote überschritten hat (Endergebnis minus Quote). Ein größerer Überschuss bedeutet mehr Unterstützung über die für die Wahl benötigte Stimmenzahl hinaus. Bei Scottish STV wird dieser Überschuss an die nächsten Präferenzen der Abstimmenden weitergegeben. |

Manchmal lässt sich ein Gleichstand auch anhand früherer Runden nicht auflösen. Wenn der Gleichstand keinen Einfluss darauf hat, wer gewählt wird, läuft die Auszählung weiter. Andernfalls endet sie in dieser Runde. Kandidierende, die unabhängig von der Auflösung des Gleichstands gewinnen, werden als gewählt angezeigt. Kandidierende, die je nach Auflösung des Gleichstands gewinnen oder verlieren könnten, werden in einer separaten Tabelle angezeigt. Loomio zeigt ihren Gleichstand an, statt eine Person zufällig auszuwählen.

<!-- translation-section: round-by-round-details -->

### Details zu jeder Runde

Klappe **Details zu jeder Runde** auf, um Stimmenübertragungen und das Ausscheiden von Kandidierenden zu sehen. Jede Zeile steht für eine kandidierende Person und jede Spalte für eine Auszählungsrunde. Jede Zahl gibt die Stimmen an, die die Person zu Beginn dieser Runde hatte:

![](stv-results.png)

Die grüne Markierung zeigt, wann eine kandidierende Person gewählt wurde, die rote, wann sie ausgeschieden ist, und die orange, wann ein Gleichstand vorlag.

<!-- translation-section: share-an-outcome -->

## Ein Fazit teilen

Teile ein Fazit, wenn die Wahl beendet ist. Nenne die gewählten Personen und gib an, wann ihre Amtszeit beginnt. Unter [Ein Fazit teilen](/en/user_manual/polls/intro_to_decisions#5-share-an-outcome) erfährst du, wie Fazits funktionieren.

![Ein Fazit, das die gewählten Ausschussmitglieder nennt](outcome.png)

<!-- translation-section: exporting-ballots -->

## Stimmzettel exportieren

Nachdem die Wahl beendet ist, können Personen, die das Ergebnis sehen dürfen, die Stimmzettel im BLT-Format für eine unabhängige Nachzählung oder Prüfung exportieren. Der Export enthält die Rangfolgen der Kandidierenden und fasst identische Rangfolgen in einer einzigen Zeile mit der Anzahl der Stimmzettel zusammen. Bei anonymen Wahlen enthält er keine Identitäten der Abstimmenden, Stimmzettelkennungen, Abgabezeitpunkte oder Angaben zur Reihenfolge der Abgabe.
