---
title: Stimmenanteilsanforderungen
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/polls/vote_share_requirements/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
sections:
  introduction: cbaf41b11886d669
  eligible-voters-and-votes-cast: 1eace7b24593e671
  different-vote-share-requirements: 0707fe507dfba2b9
  detailed-example: bd9380153211ad27
generated:
  introduction: 4b8429547ed45a4e
  eligible-voters-and-votes-cast: 1a3c191783ed2969
  different-vote-share-requirements: c538f5f81f95e83f
  detailed-example: cf1fb3aac04bcf51
title_source: a654891ca817844e
title_generated: 35ba3ce6df488414
---

<!-- translation-section: introduction -->

# Stimmenanteilsanforderungen

Lege für eine Option eine Stimmenanteilsanforderung fest, wenn ein Vorschlag einen Mindestprozentsatz an Zustimmung erhalten oder unter einem Höchstprozentsatz an Widerspruch bleiben muss, um angenommen zu werden.

Du kannst Stimmenanteilsanforderungen mit einem [Quorum](/en/user_manual/polls/quorum/) kombinieren, um sowohl eine ausreichende Beteiligung als auch eine bestimmte Verteilung der Stimmen vorauszusetzen.

Wähle im Vorschlagsformular das Bearbeitungssymbol neben einer Option.

![Das Bearbeitungssymbol neben der Option Zustimmung](edit-highlight-on-option.png)

<!-- translation-section: eligible-voters-and-votes-cast -->

## Wahlberechtigte und abgegebene Stimmen

Der Prozentsatz kann sich entweder auf **Abgegebene Stimmen** oder auf **Wahlberechtigte** beziehen.

![Auswahl, ob sich eine Stimmenanteilsanforderung auf abgegebene Stimmen oder Wahlberechtigte bezieht](./eligible-vs-cast.png)

**Wahlberechtigte** bezeichnet alle Personen, die über den Vorschlag abstimmen können. **Abgegebene Stimmen** bezeichnet nur die Stimmen, die bereits abgegeben wurden.

Eine Anforderung von 75 Prozent Zustimmung der Wahlberechtigten ist nur erfüllt, wenn mindestens 75 Prozent aller Wahlberechtigten für diese Option stimmen.

Eine Anforderung von 60 Prozent Zustimmung der abgegebenen Stimmen ist erfüllt, wenn 60 Prozent der abgegebenen Stimmen die Option unterstützen, unabhängig von der Gesamtbeteiligung. Füge ein Quorum hinzu, wenn dein Verfahren auch eine Mindestbeteiligung voraussetzt.

Bei der [gewichteten Abstimmung](/en/user_manual/polls/weighted_voting) verwenden beide Bezugsgrößen Stimmgewichte. **Abgegebenes Stimmgewicht** setzt die Summe der Stimmgewichte für die Option ins Verhältnis zum gesamten abgegebenen Stimmgewicht. **Stimmgewicht der Stimmberechtigten** setzt das Stimmgewicht der Abstimmenden, die die Option wählen, ins Verhältnis zum Stimmgewicht aller Wahlberechtigten, einschließlich der Personen, die noch nicht abgestimmt haben. Beispielsweise kann eine Person mit 70 von insgesamt 100 wahlberechtigten Stimmgewichtseinheiten eine Anforderung von 60 Prozent Zustimmung auf Basis des wahlberechtigten Stimmgewichts erfüllen.

<!-- translation-section: different-vote-share-requirements -->

## Unterschiedliche Stimmenanteilsanforderungen

Ein Vorschlag kann Anforderungen für mehrere Optionen haben. Zum Beispiel:

- Zustimmung muss mindestens 75 Prozent der Wahlberechtigten erreichen.
- Enthaltung darf höchstens 30 Prozent der abgegebenen Stimmen ausmachen.
- Veto darf höchstens 0 Prozent der abgegebenen Stimmen ausmachen.

Eine Option auf **Höchstens 0%** zu setzen, ist eine gängige Vorgehensweise. Das bedeutet, dass der Vorschlag nicht angenommen werden kann, wenn jemand diese Option auswählt. Verwende diese Einstellung für **Veto**, damit ein einziges Veto den Vorschlag stoppt.

Bei gewichteter Abstimmung überschreitet nur ein Veto mit einem positiven Stimmgewicht eine Anforderung von 0 Prozent. Ein Veto mit dem Stimmgewicht `0` fügt dem Ergebnis kein Stimmgewicht hinzu.

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
