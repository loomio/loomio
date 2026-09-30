---
title: Stimmenanteilsanforderungen
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/polls/vote_share_requirements/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-29'
sections:
  introduction: c97281f29d615dea
  eligible-voters-and-votes-cast: 930bbc475f734396
  different-vote-share-requirements: 0d25794ec996d42c
  detailed-example: dc765c43a22a28a1
generated:
  introduction: 17688b427315fbda
  eligible-voters-and-votes-cast: a67bc2831a58dc5a
  different-vote-share-requirements: b46a33ad7354cd7a
  detailed-example: ae7b435739e034a5
title_source: a654891ca817844e
title_generated: 35ba3ce6df488414
---

<!-- translation-section: introduction -->

# Stimmenanteilsanforderungen

Lege für eine Option eine Stimmenanteilsanforderung fest, wenn ein Vorschlag nur mit einem bestimmten Anteil an Zustimmung oder höchstens einem bestimmten Anteil an Ablehnung angenommen werden soll.

Du kannst Stimmenanteilsanforderungen mit einem [Quorum](/en/user_manual/polls/quorum/) kombinieren. So muss sowohl die Beteiligung als auch die Verteilung der Stimmen die jeweiligen Anforderungen erfüllen.

Wähle beim Erstellen eines Vorschlags das Bearbeitungssymbol neben einer Option.

![Das Bearbeitungssymbol neben der Option Zustimmung](edit-highlight-on-option.png)

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

Du kannst Anforderungen auch zu einer [Abstimmungsvorlage](/en/user_manual/polls/poll_templates/) hinzufügen. Neue Vorschläge, die aus der Vorlage erstellt werden, übernehmen sie dann standardmäßig.

<!-- translation-section: detailed-example -->

## Ausführliches Beispiel

Die Oatmilk Cooperative entscheidet, ob sie das Budget für einen sechswöchigen Test mit Mehrwegflaschen genehmigt. Fünf Personen sind wahlberechtigt.

Jamie verwendet die Vorschlagsvorlage **Zustimmung**, bearbeitet die Option Zustimmung und aktiviert ihre Stimmenanteilsanforderung.

Das Verfahren der Kooperative verlangt, dass mindestens 75 Prozent der Wahlberechtigten den Vorschlag unterstützen. Jamie legt die Anforderung auf **Mindestens 75 % der Wahlberechtigten** fest.

![Die Option Zustimmung erfordert mindestens 75 Prozent der Wahlberechtigten](./consent-vote-option.png)

Jamie legt außerdem ein Quorum von 60 Prozent fest. Jamie und Samira stimmen zu. Alle abgegebenen Stimmen unterstützen den Vorschlag. Die beiden Stimmen entsprechen aber nur 40 Prozent der Wahlberechtigten. Daher ist keine der beiden Anforderungen erfüllt.

![Zwei von fünf Personen haben zugestimmt und keine der beiden Anforderungen ist erfüllt](./first-vote-breakdown.png)

Alex und Morgan stimmen ebenfalls zu, Taylor stimmt dagegen. Alle fünf Personen haben abgestimmt. Damit ist das Quorum erreicht, und vier von fünf Wahlberechtigten stimmen zu. Die Zustimmung von 80 Prozent übersteigt die geforderten 75 Prozent. Beide Anforderungen werden daher mit einem grünen Häkchen angezeigt.

![Alle fünf Personen haben abgestimmt und beide Anforderungen sind erfüllt](./final-vote-breakdown.png)
