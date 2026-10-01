---
title: STV-Wahlen
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
  introduction: 71f852bf07e2d1a6
  when-to-use-stv: 76bfcdfc1f879cbc
  creating-an-stv-election: c678e56351e8a0f9
  number-of-seats: ac7e68024679ec33
  counting-method: ee49594782d95648
  quota-type: c1283dfba5ec42e8
  how-voting-works: 20d5da3f60ee5720
  how-counting-works: 10f4173cd7f222c9
  understanding-results: 82ce1b65596abaaf
  method-and-quota: 0b1f3303768e8ace
  elected-candidates: a8022595e944f4fb
  round-by-round-details: f28a96eab2be537a
  exporting-ballots: 5c500dd566fa1299
  share-an-outcome: eabe596c9fc3d3af
title_source: cd3e1a4cdc2456a6
title_generated: d3db61f29b5753db
---

<!-- translation-section: introduction -->

# STV-Wahlen

**Single Transferable Vote (STV)** ist ein Verhältniswahlverfahren, bei dem mehrere Personen aus einer Gruppe von Kandidaten gewählt werden. Die gewählten Personen vertreten die unterschiedlichen Ansichten der Abstimmenden entsprechend ihrem Stimmenanteil.

<!-- translation-section: when-to-use-stv -->

## Wann du STV verwenden kannst

Verwende eine STV-Wahl, wenn du:

- einen **Ausschuss, Vorstand oder eine Delegation** aus mehreren vorgeschlagenen Personen wählen möchtest
- eine **verhältnismäßige Vertretung** erreichen möchtest, bei der auch kleinere Gruppen Sitze entsprechend ihrer Unterstützung gewinnen können
- eine Wahl durchführen möchtest, bei der die Abstimmenden Kandidaten nach ihrer Präferenz ordnen

>[!NOTE]
>STV ist **nicht** dasselbe wie Loomios [Rangfolge-Umfrage](/en/user_manual/polls/rank/). Bei dieser einfacheren Umfrage werden Optionen mit Punkten bewertet, um eine beste Option zu bestimmen. Bei STV werden mehrere Personen durch die Übertragung von Stimmen und das Ausscheiden von Kandidaten gewählt.

<!-- translation-section: creating-an-stv-election -->

## Eine STV-Wahl erstellen

Wähle beim Erstellen einer Umfrage **STV-Wahl** als Umfragetyp und füge die Kandidaten als Umfrageoptionen hinzu. Du kannst die **Anzahl der zu besetzenden Plätze**, die **Zählmethode** und den **Quotentyp** festlegen.

In diesem Beispiel wählt die Oatmilk Cooperative drei Personen, die ihren Versuch mit Mehrwegverpackungen begleiten. Das Formular beschreibt die Aufgabe, nennt fünf Kandidaten und verwendet Scottish STV mit der Droop-Quote.

![](form.png)

<!-- translation-section: number-of-seats -->

### Anzahl der zu besetzenden Plätze

Die Anzahl der Personen, die gewählt werden sollen. Sie muss kleiner sein als die Anzahl der Kandidaten.

<!-- translation-section: counting-method -->

### Zählmethode

Für die Auszählung stehen zwei Methoden zur Verfügung:

Scottish STV
  : Empfohlen. Diese Methode verwendet die Weighted Inclusive Gregory Method (WIGM), die seit 2007 bei schottischen Kommunalwahlen eingesetzt wird. Die Regeln sind klar definiert und einfach anzuwenden. Sie eignet sich für die meisten Organisationen.
  
Meek STV
  : Eine genauere Methode, deren Auszählung nur ein Computer durchführen kann. Wenn ein Kandidat gewählt wird, überträgt Meek weiterhin den nicht benötigten Anteil jeder Stimme auf die nachfolgenden Präferenzen der Abstimmenden. Das gilt auch für Stimmen, die den Kandidaten erst später in der Auszählung erreichen. Wenn ein Kandidat ausscheidet, werden die Stimmen neu ausgezählt, als hätte diese Person nie kandidiert. Weniger Stimmen bleiben ungenutzt als bei Scottish STV, aber die Auszählung lässt sich nicht von Hand überprüfen.

<!-- translation-section: quota-type -->

### Quotentyp

Die Quote ist die Mindestzahl an Stimmen, die ein Kandidat für einen Sitz braucht. Es gibt zwei Arten:

Droop
  : Empfohlen. Die Standardquote für STV-Wahlen, die in Irland, Australien und Schottland verwendet wird. Sie ist die kleinste Quote, die höchstens so viele Kandidaten erreichen können, wie Sitze verfügbar sind. Eine Gruppe von Abstimmenden, die ihre eigenen Kandidaten auf die ersten Ränge setzt, gewinnt mindestens so viele Sitze, wie ihr Stimmenanteil ganze Quoten umfasst. Sie wird so berechnet:
\\[ floor(\frac{votes}{(seats + 1)}) + 1 \\]

Hare
  : Eine größere Quote. Gruppen mit vielen Stimmen benötigen mehr davon für jeden gewonnenen Sitz. Dadurch gewinnen kleinere Gruppen eher die letzten Sitze. Sie wird so berechnet:
    \\[ \frac{votes}{seats}\\]

In beiden Formeln ist *votes* die Anzahl der Stimmzettel, auf denen mindestens ein Kandidat eingeordnet ist.

Meek STV berechnet die Quote ohne Rundung, für Droop als votes ÷ (seats + 1). Die Quote wird in jeder Runde anhand der Stimmen neu berechnet, die noch auf Kandidaten entfallen. Ein Kandidat muss sie überschreiten, um gewählt zu werden.
  
  >[!TIP]
  > Die Droop-Quote ist immer niedriger als die Hare-Quote. Bei einer Wahl mit 100 Stimmen und vier Sitzen beträgt die Droop-Quote zum Beispiel 21 und die Hare-Quote 25.

<!-- translation-section: how-voting-works -->

## So funktioniert die Stimmabgabe

In diesem Beispiel wählt die Oatmilk Cooperative drei Personen, die ihren Versuch mit Mehrwegverpackungen begleiten. Die Abstimmenden ziehen Kandidaten über die Linie und ordnen sie nach ihrer Präferenz:

![](stv-vote-in-progress.png)

- **Rang 1** = bevorzugter Kandidat
- **Rang 2** = zweite Wahl
- Ordne so viele weitere Kandidaten, wie du möchtest

Die Abstimmenden müssen mindestens einen Kandidaten in eine Rangfolge bringen, aber nicht alle Kandidaten. Kandidaten ohne Rang erhalten keine Unterstützung von dieser Person.

<!-- translation-section: how-counting-works -->

## So funktioniert die Auszählung
Die Stimmen werden wie folgt ausgezählt:

1. Die **Quote** wird berechnet (die Mindestzahl an Stimmen für einen Sitz).
2. Für jeden Kandidaten werden **Erste Präferenzen** gezählt.
3. Jeder Kandidat, der die Quote erreicht, ist **gewählt**. Seine überschüssigen Stimmen (über der Quote) werden anteilig auf die nächsten Präferenzen der Abstimmenden **übertragen**, beginnend mit dem größten Überschuss. Stimmen werden nur auf Kandidaten übertragen, die noch in der Auszählung sind.
4. Ist kein Überschuss mehr zu übertragen, **scheidet der Kandidat mit den wenigsten Stimmen aus**. Seine Stimmen werden mit vollem Wert auf die nächsten Präferenzen der Abstimmenden übertragen.
5. Entspricht die Zahl der verbleibenden Kandidaten der Zahl der noch zu besetzenden Sitze, sind sie alle gewählt, auch wenn sie die Quote nicht erreicht haben.
6. Andernfalls wird die Auszählung ab Schritt 3 wiederholt, bis alle Sitze besetzt sind.

Durch die anteilige Übertragung werden nur die Stimmen weitergegeben, die eine gewählte Person nicht benötigt. Beträgt die Quote zum Beispiel 26 und ein Kandidat hat 40 Stimmen, ist sein Überschuss 14. Jeder seiner 40 Stimmzettel wird auf die nächste Präferenz übertragen und zählt dort mit einem Wert von 14 ÷ 40 = 0,35 einer Stimme.

Bei Scottish STV wird der Wert jeder übertragenen Stimme auf fünf Nachkommastellen abgerundet, wie bei schottischen Kommunalwahlen.

Haben zwei oder mehr Kandidaten die wenigsten Stimmen, scheidet derjenige aus, der in der letzten früheren Runde mit unterschiedlichem Stimmenstand weniger Stimmen hatte.

>[!TIP]
>Ein Stimmzettel zählt nur, solange darauf ein Kandidat eingeordnet ist, der noch in der Auszählung ist. Bleibt keiner mehr übrig, ist der Stimmzettel „erschöpft“ und zählt nicht mehr.

<!-- translation-section: understanding-results -->

## Ergebnisse verstehen

Nach dem Schließen der Umfrage werden die Ergebnisse in mehreren Abschnitten angezeigt. Bei dieser Wahl erhalten Samira Patel, Alex Morgan und Morgan Price die drei Ausschusssitze:

![](stv-results-summary.png)

<!-- translation-section: method-and-quota -->

### Methode und Quote

Oben siehst du die Zählmethode (Scottish STV oder Meek STV), den Quotentyp (Droop oder Hare) und die Quote – also die Zahl der Stimmen, die ein Kandidat für einen Sitz brauchte.

<!-- translation-section: elected-candidates -->

### Gewählte Kandidaten

Eine Übersichtstabelle der gewählten Personen mit fünf Spalten:

| Spalte | Bedeutung |
|--------|---------|
| **Kandidat** | Der Name des gewählten Kandidaten |
| **Runde gewählt** | Die Auszählungsrunde, in der der Kandidat die Quote erreicht und einen Sitz gewonnen hat. Runde 1 bedeutet, dass die Ersten Präferenzen allein ausgereicht haben. In späteren Runden waren übertragene Stimmen von ausgeschiedenen Kandidaten oder Überschüsse bereits gewählter Kandidaten nötig. |
| **Erste Präferenzen** | Wie viele Abstimmende diesen Kandidaten auf Rang 1 gesetzt haben. Das zeigt seine direkte Unterstützung vor der Übertragung von Stimmen. |
| **Endergebnis** | Der Stimmenstand des Kandidaten zum Zeitpunkt seiner Wahl. Durch übertragene Stimmen liegt er oft über der Zahl seiner Ersten Präferenzen. |
| **Überschuss** | Der Betrag, um den das Endergebnis des Kandidaten die Quote überschritten hat (Endergebnis minus Quote). Ein größerer Überschuss zeigt mehr Unterstützung, als für die Wahl nötig war. Bei Scottish STV wird dieser Überschuss auf die nächsten Präferenzen der Abstimmenden verteilt. |

Manchmal lässt sich ein Gleichstand auch anhand früherer Runden nicht auflösen. Wenn der Gleichstand keinen Einfluss darauf hat, wer gewählt wird, geht die Auszählung weiter. Andernfalls endet sie in dieser Runde. Kandidaten, die unabhängig von der Auflösung des Gleichstands gewinnen, werden als gewählt angezeigt. Kandidaten, die je nach Auflösung gewinnen oder verlieren könnten, werden in einer eigenen Tabelle angezeigt. Loomio zeigt sie mit Gleichstand an, statt einen von ihnen zufällig auszuwählen.

<!-- translation-section: round-by-round-details -->

### Details zu jeder Runde

Klappe **Details zu jeder Runde** auf, um die Übertragung von Stimmen und das Ausscheiden von Kandidaten zu sehen. Jede Zeile steht für einen Kandidaten und jede Spalte für eine Auszählungsrunde. Jede Zahl zeigt den Stimmenstand des Kandidaten zu Beginn dieser Runde:

![](stv-results.png)

Grün zeigt, wann ein Kandidat gewählt wurde, Rot zeigt sein Ausscheiden und Orange einen Gleichstand.

<!-- translation-section: share-an-outcome -->

## Teile ein Fazit

Teile nach Abschluss der Wahl ein Fazit. Nenne die gewählten Personen und gib an, wann sie ihre Aufgaben übernehmen. Unter [Teile ein Fazit](/en/user_manual/polls/intro_to_decisions#5-share-an-outcome) erfährst du, wie Fazits funktionieren.

![Ein Fazit, das die gewählten Ausschussmitglieder nennt](outcome.png)

<!-- translation-section: exporting-ballots -->

## Stimmzettel exportieren

Nach dem Schließen der Wahl können Personen, die die Ergebnisse sehen dürfen, die Stimmzettel im BLT-Format für eine unabhängige Nachzählung oder Prüfung exportieren. Der Export enthält die Rangfolgen der Kandidaten. Identische Rangfolgen werden in einer Zeile mit der Anzahl der entsprechenden Stimmzettel zusammengefasst. Bei anonymen Wahlen enthält der Export keine Angaben zur Identität der Abstimmenden, keine Stimmzettelkennungen, keine Abgabezeiten und keine Reihenfolge der Abgabe.
