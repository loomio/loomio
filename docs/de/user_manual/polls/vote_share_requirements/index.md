---
title: Stimmenanteilsanforderungen
source_revision: 71554be8e61a76613b0707b8262302c22299a5d0
source_file: docs/en/user_manual/polls/vote_share_requirements/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: 57d7127721bebf93
  eligible-voters-and-votes-cast: 930bbc475f734396
  different-vote-share-requirements: cfdfd13a0a6a8b38
  detailed-example: 395dbccb0e6427fc
generated:
  introduction: c68238ff779bf8e0
  eligible-voters-and-votes-cast: a67bc2831a58dc5a
  different-vote-share-requirements: fcb5e43da889857c
  detailed-example: 980db2c7a338c626
title_source: a654891ca817844e
title_generated: 35ba3ce6df488414
---

<!-- translation-section: introduction -->

# Stimmenanteilsanforderungen

Lege für eine Option eine Stimmenanteilsanforderung fest, wenn ein Vorschlag nur mit einem bestimmten Anteil an Zustimmung oder höchstens einem bestimmten Anteil an Ablehnung angenommen werden soll.

Du kannst Stimmenanteilsanforderungen mit einem [Quorum](/en/user_manual/polls/quorum/) kombinieren. So muss sowohl die Beteiligung als auch die Verteilung der Stimmen die jeweiligen Anforderungen erfüllen.

Wähle im Vorschlagsformular das Bearbeitungssymbol neben einer Option.

![Das Bearbeitungssymbol neben der Option Dafür](edit-highlight-on-option.png)

<!-- translation-section: eligible-voters-and-votes-cast -->

## Wahlberechtigte und abgegebene Stimmen

Der Prozentsatz kann sich auf **Abgegebene Stimmen** oder **Wahlberechtigte** beziehen.

![Auswahl, ob sich die Stimmenanteilsanforderung auf abgegebene Stimmen oder Wahlberechtigte bezieht](./eligible-vs-cast.png)

**Wahlberechtigte** sind alle Personen, die über den Vorschlag abstimmen können. **Abgegebene Stimmen** sind nur die Stimmen, die tatsächlich eingereicht wurden.

Wenn mindestens 75 Prozent der Wahlberechtigten zustimmen müssen, kann der Vorschlag nur angenommen werden, wenn mindestens 75 Prozent aller Wahlberechtigten für diese Option stimmen.

Wenn mindestens 60 Prozent der abgegebenen Stimmen zustimmen müssen, kann der Vorschlag angenommen werden, sobald 60 Prozent der eingereichten Stimmen diese Option unterstützen. Die gesamte Wahlbeteiligung spielt dabei keine Rolle. Lege zusätzlich ein Quorum fest, wenn dein Verfahren eine Mindestbeteiligung verlangt.

<!-- translation-section: different-vote-share-requirements -->

## Verschiedene Stimmenanteilsanforderungen

Ein Vorschlag kann Anforderungen für mehrere Optionen haben. Zum Beispiel:

- Dafür: mindestens 75 Prozent der Wahlberechtigten
- Enthaltung: höchstens 30 Prozent der abgegebenen Stimmen
- Veto: höchstens 0 Prozent der abgegebenen Stimmen

Eine Option auf **Nicht mehr als 0 %** zu setzen, ist eine übliche Vorgehensweise. Das bedeutet, dass der Vorschlag nicht angenommen werden kann, wenn jemand diese Option wählt. Verwende diese Einstellung für **Veto**, damit ein einzelnes Veto den Vorschlag stoppt.

Du kannst Anforderungen auch zu einer [Abstimmungsvorlage](/en/user_manual/polls/poll_templates/) hinzufügen. Neue Vorschläge, die aus der Vorlage erstellt werden, übernehmen sie dann standardmäßig.

<!-- translation-section: detailed-example -->

## Ausführliches Beispiel

Die Oatmilk Cooperative entscheidet, ob sie einen sechswöchigen Test mit Mehrwegflaschen durchführt. Fünf Personen sind wahlberechtigt.

Das Verfahren der Kooperative verlangt, dass mindestens 75 Prozent der Wahlberechtigten zustimmen. Jamie bearbeitet die Option **Dafür** des Vorschlags, aktiviert ihre Stimmenanteilsanforderung und legt sie auf **Mindestens 75 % der Wahlberechtigten** fest.

![Die Option Dafür erfordert die Zustimmung von mindestens 75 Prozent der Wahlberechtigten](./agree-vote-option.png)

Jamie legt außerdem ein Quorum von 60 Prozent fest. Jamie und Samira stimmen zu. Alle abgegebenen Stimmen unterstützen den Vorschlag. Die beiden Stimmen entsprechen aber nur 40 Prozent der Wahlberechtigten. Daher ist keine der beiden Anforderungen erfüllt.

![Zwei von fünf Personen haben zugestimmt und keine der beiden Anforderungen ist erfüllt](./first-vote-breakdown.png)

Alex und Morgan stimmen ebenfalls zu, Taylor stimmt dagegen. Alle fünf Personen haben abgestimmt. Damit ist das Quorum erreicht, und vier von fünf Wahlberechtigten stimmen zu. Die Zustimmung von 80 Prozent übersteigt die geforderten 75 Prozent. Beide Anforderungen werden daher mit einem grünen Häkchen angezeigt.

![Alle fünf Personen haben abgestimmt und beide Anforderungen sind erfüllt](./final-vote-breakdown.png)
