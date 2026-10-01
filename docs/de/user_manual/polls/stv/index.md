---
title: STV-Wahlen
source_revision: 71554be8e61a76613b0707b8262302c22299a5d0
source_file: docs/en/user_manual/polls/stv/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
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
  share-an-outcome: 6a02aed173b368b9
generated:
  introduction: 71f852bf07e2d1a6
  when-to-use-stv: 76bfcdfc1f879cbc
  creating-an-stv-election: c678e56351e8a0f9
  number-of-seats: ac7e68024679ec33
  counting-method: b4f256f3701f4b7c
  quota-type: 7207c678a327adae
  how-voting-works: bc622554966fa560
  how-counting-works: b64e33415e309e89
  understanding-results: 82ce1b65596abaaf
  method-and-quota: 0b1f3303768e8ace
  elected-candidates: 8f56c890d529a3e5
  round-by-round-details: c71f016de66c38b4
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

Scottish STV : Empfohlen. Diese Methode verwendet das Weighted Inclusive Gregory Method (WIGM), das seit 2007 bei schottischen Kommunalwahlen eingesetzt wird. Die Regeln sind klar definiert und einfach anzuwenden. Sie eignet sich für die meisten Organisationen.

Meek STV : Eine mathematisch genauere Methode mit wiederholter Berechnung. Wenn ein Kandidat ausscheidet, werden die Stimmen neu ausgezählt, als hätte diese Person nie kandidiert.

<!-- translation-section: quota-type -->

### Quotentyp

Die Quote ist die Mindestzahl an Stimmen, die ein Kandidat für einen Sitz braucht. Es gibt zwei Arten:

Droop : Empfohlen. Die Droop-Quote ist bei den meisten STV-Wahlen üblich und wird in Irland, Australien und Schottland verwendet. Sie stellt sicher, dass eine Koalition mit der Mehrheit der Stimmen auch die Mehrheit der Sitze erhält. Sie wird so berechnet: \\[ floor(\frac{votes}{(seats + 1)}) + 1 \\]

Hare
  : Eine höhere Mindestzahl an Stimmen, die kleinere Gruppen stärker berücksichtigt.
    DSA-Ortsgruppen bevorzugen Hare, um die Vertretung von Minderheiten zu schützen.
   Sie wird so berechnet:
    \\[ \frac{votes}{seats}\\]

>[!TIP]
  > Die Droop-Quote ist immer niedriger als die Hare-Quote. Bei einer Wahl mit 100 Stimmen und vier Sitzen beträgt die Droop-Quote zum Beispiel 21 und die Hare-Quote 25.

<!-- translation-section: how-voting-works -->

## So funktioniert die Stimmabgabe

In diesem Beispiel wählt die Oatmilk Cooperative drei Personen, die ihren Versuch mit Mehrwegverpackungen begleiten. Die Abstimmenden ziehen Kandidaten über die Linie und ordnen sie nach ihrer Präferenz:

![](stv-vote-in-progress.png)

- **Rang 1** = bevorzugter Kandidat
- **Rang 2** = zweite Wahl
- Ordne so viele weitere Kandidaten, wie du möchtest

Die Abstimmenden müssen nicht alle Kandidaten in eine Rangfolge bringen. Kandidaten ohne Rang erhalten keine Unterstützung von dieser Person.

<!-- translation-section: how-counting-works -->

## So funktioniert die Auszählung
Die Stimmen werden wie folgt ausgezählt:

1. Die **Quote** wird berechnet (die Mindestzahl an Stimmen für einen Sitz).
2. Für jeden Kandidaten werden die **Erste Präferenzen** gezählt.
3. Erreicht ein Kandidat die Quote, ist er **gewählt**. Seine überschüssigen Stimmen (über der Quote) werden anteilig auf die nächsten Präferenzen der Wähler **übertragen**.
4. Erreicht kein Kandidat die Quote, **scheidet der Kandidat mit den wenigsten Stimmen aus**. Seine Stimmen werden mit vollem Wert auf die nächsten Präferenzen der Wähler übertragen.
5. Das wiederholt sich, bis alle Sitze besetzt sind.

>[!TIP]
>Wenn eine abstimmende Person keinen der verbleibenden Kandidaten eingeordnet hat, ist ihr Stimmzettel „erschöpft“ und die Stimme kann nicht weiter übertragen werden. Deshalb ist es meist sinnvoll, mehr Kandidaten einzuordnen.

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
| **Runde gewählt** | Die Auszählungsrunde, in der der Kandidat die Quote erreicht und einen Sitz gewonnen hat. Runde 1 bedeutet, dass die Ersten Präferenzen allein ausgereicht haben. In späteren Runden waren übertragene Stimmen von ausgeschiedenen oder bereits gewählten Kandidaten nötig. |
| **Erste Präferenzen** | Wie viele Abstimmende diesen Kandidaten auf Rang 1 gesetzt haben. Das zeigt seine direkte Unterstützung vor der Übertragung von Stimmen. |
| **Endergebnis** | Der Stimmenstand des Kandidaten zum Zeitpunkt seiner Wahl. Durch übertragene Stimmen liegt er oft über der Zahl seiner Ersten Präferenzen. |
| **Überschuss** | Der Betrag, um den der Stimmenstand des Kandidaten die Quote überschritten hat (Stimmenstand minus Quote). Ein größerer Überschuss zeigt mehr Unterstützung, als für die Wahl nötig war. Bei Scottish STV wird dieser Überschuss auf die nächsten Präferenzen der Abstimmenden verteilt. |

Führt die Auszählung zu einem Gleichstand, bei dem das Ausscheiden eines der verbleibenden Kandidaten das Ergebnis verändern würde, werden diese Kandidaten in einer eigenen Tabelle angezeigt. Es wird kein Gewinner willkürlich bestimmt.

<!-- translation-section: round-by-round-details -->

### Details zu jeder Runde

Klappe **Details zu jeder Runde** auf, um die Übertragung von Stimmen und das Ausscheiden von Kandidaten zu sehen. Jede Zeile steht für einen Kandidaten und jede Spalte für eine Auszählungsrunde:

![](stv-results.png)

Grün zeigt, wann ein Kandidat gewählt wurde, Rot zeigt sein Ausscheiden und Orange einen Gleichstand.

<!-- translation-section: share-an-outcome -->

## Teile ein Fazit

Teile nach Abschluss der Wahl ein Fazit. Nenne die gewählten Personen und gib an, wann sie ihre Aufgaben übernehmen. Unter [Teile ein Fazit](/en/user_manual/polls/intro_to_decisions#5-share-an-outcome) erfährst du, wie Fazits funktionieren.

![Ein Fazit, das die gewählten Ausschussmitglieder nennt](outcome.png)

<!-- translation-section: exporting-ballots -->

## Stimmzettel exportieren

Nach dem Schließen der Wahl können Personen, die die Ergebnisse sehen dürfen, die Stimmzettel im BLT-Format für eine unabhängige Nachzählung oder Prüfung exportieren. Der Export enthält die Rangfolgen der Kandidaten. Identische Rangfolgen werden in einer Zeile mit der Anzahl der entsprechenden Stimmzettel zusammengefasst. Bei anonymen Wahlen enthält der Export keine Angaben zur Identität der Abstimmenden, keine Stimmzettelkennungen, keine Abgabezeiten und keine Reihenfolge der Abgabe.
