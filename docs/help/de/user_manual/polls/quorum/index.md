---
title: Quorum
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/polls/quorum/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
sections:
  introduction: 885a154beca10592
  example-scenario: 2c4be2012a2bcba4
generated:
  introduction: e503073f27c13e5c
  example-scenario: cc0defbb0decd280
title_source: 18ed8b6c5ab90343
title_generated: 18ed8b6c5ab90343
---

<!-- translation-section: introduction -->

# Quorum

Ein Quorum ist der Mindestprozentsatz der stimmberechtigten Abstimmenden, die teilnehmen müssen, damit eine Abstimmung gültig ist. Nutze es, wenn dein Entscheidungsverfahren eine Mindestbeteiligung erfordert.

Bei einer [gewichteten Abstimmung](/en/user_manual/polls/weighted_voting) berücksichtigt das Quorum die Stimmgewichte. Zum Beispiel hat Jamie das Stimmgewicht `2`, Samira das Stimmgewicht `1` und Alex das Stimmgewicht `1`. Wenn nur Jamie abstimmt, ist die Hälfte des stimmberechtigten Stimmgewichts vertreten. Wenn auch Samira abstimmt, erreicht die Beteiligung 75 Prozent und erfüllt damit ein Quorum von 60 Prozent.

Öffne beim Erstellen einer Abstimmung **Weitere Einstellungen** und gib unter **Quorum** den erforderlichen Prozentsatz ein. Lass das Feld leer, wenn kein Quorum erforderlich ist.

![Die Quorum-Einstellung mit einem Teilnahmequorum von 60 Prozent](./quorum-section.png)

Du kannst auch in einer [Abstimmungsvorlage](/en/user_manual/polls/poll_templates/) ein Quorum festlegen, damit Abstimmungen aus dieser Vorlage es standardmäßig verwenden.

Wenn eine Abstimmung endet, ohne das Quorum zu erreichen, zeigt Loomio an, dass das Quorum nicht erfüllt wurde. Die Abstimmung wird weder automatisch verlängert noch abgebrochen. Ein Thread-Admin kann die Abstimmung wieder öffnen, sofern dies erlaubt ist, oder ein Fazit teilen, das die nächsten Schritte erklärt.

<!-- translation-section: example-scenario -->

## Beispielszenario

Die Oatmilk Cooperative diskutiert einen sechswöchigen Test mit Mehrwegflaschen und muss das Budget für den Test genehmigen.

Jamie wählt **Jetzt abstimmen**, wählt eine Vorschlagsvorlage aus und füllt Titel, Details, Optionen, Dauer und Einstellungen für Abstimmende aus.

![Titel, Details, Optionen, Dauer und Einstellungen für Abstimmende des Vorschlags](proposal-options.png)

Jamie beschränkt die Stimmabgabe auf die fünf Personen, die für das Budget des Tests verantwortlich sind. Da die Genossenschaft für wichtige Entscheidungen eine Beteiligung von 60 Prozent verlangt, trägt Jamie unter **Quorum** den Wert **60** ein und startet den Vorschlag.

Bevor jemand abstimmt, zeigt die Ergebnisanzeige, dass das Quorum noch nicht erreicht ist.

![Noch keine Stimmen abgegeben und das Quorum von 60 Prozent noch nicht erreicht](pie-chart-0.png)

Jamie stimmt zu und Samira widerspricht. Das Diagramm wird aktualisiert, aber zwei von fünf stimmberechtigten Abstimmenden entsprechen nur einer Beteiligung von 40 Prozent. Das Quorum ist daher noch nicht erreicht.

![Zwei von fünf Stimmen abgegeben und das Quorum noch nicht erreicht](pie-chart-40.png)

Alex stimmt ebenfalls zu. Drei von fünf stimmberechtigten Abstimmenden haben teilgenommen. Damit ist das Quorum von 60 Prozent erreicht. Die Anforderung wird nun mit einem grünen Häkchen angezeigt. Jamie kann die Abstimmung vorzeitig beenden oder auf die übrigen Abstimmenden warten.

![Drei von fünf Stimmen abgegeben und das Quorum von 60 Prozent erreicht](pie-chart-60.png)
