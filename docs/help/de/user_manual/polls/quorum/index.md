---
title: Quorum
source_revision: c6076258c3438c0dd6dc8fbf1fc0b0df47c0aeb5
source_file: docs/en/user_manual/polls/quorum/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: 0bf465006210877b
  example-scenario: 6596ad44e1c046b4
generated:
  introduction: 7e0690ca41581746
  example-scenario: 050c81396fce43af
title_source: 18ed8b6c5ab90343
title_generated: 18ed8b6c5ab90343
needs_review:
  example-scenario: use "Entscheidung" instead of "Abstimmung" for "decision"; use "Stimme" instead of "Abstimmung" for "vote"
---

<!-- translation-section: introduction -->

# Quorum

Ein Quorum ist der Mindestprozentsatz der stimmberechtigten Abstimmenden, die teilnehmen müssen, damit eine Abstimmung gültig ist. Nutze es, wenn dein Entscheidungsverfahren eine bestimmte Beteiligung erfordert.

Öffne beim Erstellen einer Abstimmung **Weitere Einstellungen** und gib unter **Teilnahmequorum** den erforderlichen Prozentsatz ein. Lass das Feld leer, wenn kein Quorum erforderlich ist.

![Die Quorum-Einstellung mit einem Teilnahmequorum von 60 Prozent](./quorum-section.png)

Du kannst auch in einer [Abstimmungsvorlage](/en/user_manual/polls/poll_templates/) ein Quorum festlegen, damit Abstimmungen aus dieser Vorlage es standardmäßig verwenden.

<!-- translation-section: example-scenario -->

## Beispielszenario

Die Oatmilk Cooperative diskutiert einen sechswöchigen Test mit Mehrwegflaschen. Die Diskussion ist an dem Punkt angelangt, an dem die Genossenschaft das Budget für den Test genehmigen muss.

Jamie wählt **Jetzt abstimmen**, wählt die Vorschlagsvorlage **Konsent** aus und füllt Titel, Details, Optionen, Dauer und Einstellungen für Abstimmende aus.

![Titel, Details, Optionen, Dauer und Einstellungen für Abstimmende des Vorschlags](proposal-options.png)

Jamie beschränkt die Stimmabgabe auf die fünf Personen, die für das Budget des Tests verantwortlich sind.

Die Genossenschaft verlangt für wichtige Entscheidungen eine Beteiligung von 60 Prozent. Deshalb trägt Jamie **60** in das Feld für das Teilnahmequorum ein und startet den Vorschlag.

Bevor jemand abstimmt, zeigt die Ergebnisanzeige, dass das Quorum noch nicht erreicht ist.

![Noch keine Stimmen abgegeben und das Quorum von 60 Prozent noch nicht erreicht](pie-chart-0.png)

Jamie stimmt zu und Samira widerspricht. Das Diagramm wird aktualisiert, aber zwei von fünf stimmberechtigten Personen entsprechen nur einer Beteiligung von 40 Prozent. Das Quorum ist daher noch nicht erreicht.

![Zwei von fünf Stimmen abgegeben und das Quorum noch nicht erreicht](pie-chart-40.png)

Alex stimmt ebenfalls zu. Drei von fünf stimmberechtigten Personen haben teilgenommen. Damit ist das Quorum von 60 Prozent erreicht. Die Anforderung wird nun mit einem grünen Häkchen angezeigt. Jamie kann die Abstimmung vorzeitig beenden oder auf die übrigen Abstimmenden warten.

![Drei von fünf Stimmen abgegeben und das Quorum von 60 Prozent erreicht](pie-chart-60.png)
