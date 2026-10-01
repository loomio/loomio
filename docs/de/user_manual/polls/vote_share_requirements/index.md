---
title: Stimmenanteilsanforderungen
source_revision: c6076258c3438c0dd6dc8fbf1fc0b0df47c0aeb5
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
  introduction: 7cf89a31e178a57c
  eligible-voters-and-votes-cast: 54fd4de6f9962379
  different-vote-share-requirements: b20042d1d363ec3f
  detailed-example: cf1fb3aac04bcf51
title_source: a654891ca817844e
title_generated: 35ba3ce6df488414
---

<!-- translation-section: introduction -->

# Stimmenanteilsanforderungen

Lege für eine Option eine Stimmenanteilsanforderung fest, wenn ein Vorschlag einen bestimmten Prozentsatz an Zustimmung erhalten oder unter einem bestimmten Prozentsatz an Widerspruch bleiben muss, um angenommen zu werden.

Stimmenanteilsanforderungen können mit einem [Quorum](/en/user_manual/polls/quorum/) kombiniert werden, um sowohl eine ausreichende Beteiligung als auch eine bestimmte Verteilung der Stimmen vorauszusetzen.

Wähle im Vorschlagsformular das Bearbeitungssymbol neben einer Option.

![Das Bearbeitungssymbol neben der Option Zustimmung](edit-highlight-on-option.png)

<!-- translation-section: eligible-voters-and-votes-cast -->

## Wahlberechtigte und abgegebene Stimmen

Der Prozentsatz kann sich entweder auf **Abgegebene Stimmen** oder auf **Wahlberechtigte** beziehen.

![Auswahl, ob sich eine Stimmenanteilsanforderung auf abgegebene Stimmen oder Wahlberechtigte bezieht](./eligible-vs-cast.png)

**Wahlberechtigte** bezeichnet alle Personen, die über den Vorschlag abstimmen können. **Abgegebene Stimmen** bezeichnet nur die Stimmen, die bereits abgegeben wurden.

Eine Anforderung von 75 Prozent Zustimmung der Wahlberechtigten ist nur erfüllt, wenn mindestens 75 Prozent aller Wahlberechtigten für diese Option stimmen.

Eine Anforderung von 60 Prozent Zustimmung der abgegebenen Stimmen ist erfüllt, wenn 60 Prozent der abgegebenen Stimmen die Option unterstützen, unabhängig von der Gesamtbeteiligung. Füge ein Quorum hinzu, wenn dein Verfahren auch eine Mindestbeteiligung voraussetzt.

<!-- translation-section: different-vote-share-requirements -->

## Unterschiedliche Stimmenanteilsanforderungen

Ein Vorschlag kann Anforderungen für mehrere Optionen haben. Zum Beispiel:

- Zustimmung muss mindestens 75 Prozent der Wahlberechtigten erreichen
- Enthaltung darf höchstens 30 Prozent der abgegebenen Stimmen ausmachen
- Veto darf höchstens 0 Prozent der abgegebenen Stimmen ausmachen

Eine Option auf **Höchstens 0%** zu setzen, ist eine gängige Vorgehensweise. Das bedeutet, dass der Vorschlag nicht angenommen werden kann, wenn jemand diese Option auswählt. Verwende diese Einstellung für **Veto**, damit ein einziges Veto den Vorschlag stoppt.

Du kannst auch einer [Abstimmungsvorlage](/en/user_manual/polls/poll_templates/) Anforderungen hinzufügen, damit neue Vorschläge aus dieser Vorlage sie standardmäßig verwenden.

<!-- translation-section: detailed-example -->

## Ausführliches Beispiel

Die Genossenschaft Oatmilk Cooperative entscheidet, ob sie Mehrwegflaschen sechs Wochen lang erproben soll. Fünf Personen sind wahlberechtigt.

Das Verfahren der Genossenschaft setzt voraus, dass mindestens 75 Prozent der Wahlberechtigten zustimmen. Jamie bearbeitet die Option **Zustimmung** des Vorschlags, aktiviert die Stimmenanteilsanforderung und setzt sie auf **Mindestens 75% der Wahlberechtigten**.

![Die Option Zustimmung mit einer Anforderung von mindestens 75 Prozent der Wahlberechtigten](./agree-vote-option.png)

Jamie legt außerdem ein Quorum von 60 Prozent fest. Jamie und Samira stimmen zu. Alle abgegebenen Stimmen unterstützen den Vorschlag, stammen aber von nur 40 Prozent der Wahlberechtigten. Daher ist keine der beiden Anforderungen erfüllt.

![Zwei von fünf Personen haben zugestimmt und keine der beiden Anforderungen ist erfüllt](./first-vote-breakdown.png)

Anschließend stimmen Alex und Morgan zu, während Taylor widerspricht. Alle fünf Personen haben abgestimmt, womit das Quorum erreicht ist, und vier von fünf Wahlberechtigten stimmen zu. Die Zustimmung von 80 Prozent übersteigt die Stimmenanteilsanforderung von 75 Prozent, sodass beide Anforderungen mit grünen Häkchen angezeigt werden.

![Alle fünf Personen haben abgestimmt und beide Anforderungen sind erfüllt](./final-vote-breakdown.png)
