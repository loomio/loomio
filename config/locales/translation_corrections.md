# Corrected translations

A log of hand-corrections to non-English locale files where
`bin/rake loomio:translate_strings` (Google Translate) produced a wrong
sense, not just a typo — Google has very little UI context, so short
ambiguous labels often come back wrong. Scan this before merging a
retranslation PR: if the same English key reappears with a suspicious
change, check it against the patterns below.

## Patterns

- **Polysemous short labels.** A one- or two-word English string gets
  translated in the wrong sense because the translator can't see that
  it's a UI verb/imperative. "Pin" → pinboard-noun instead of verb;
  "Close" → "closing" adjective instead of imperative; "Block" → city
  block instead of obstruct; "Post" → mail instead of publish.
- **Siblings drift apart.** Paired actions (subscribe/unsubscribe,
  pin/unpin, open/close) get translated in isolation, one passes, then
  the other gets a different structure (plural vs singular, verb vs
  noun) — they read inconsistently in the UI. Check symmetry when one
  half of a pair changes.
- **"aufheben", "auflösen", etc.** German words that can mean
  "cancel/annul" *or* "lift/remove". Translator picks the wrong sense
  for UI remove-actions.

## Loomio glossary overrides

Terms with a Loomio-specific meaning Google can't infer from the string alone.
Force these mappings when retranslating (established in commits 38a9808ce1
and 7cc8e45029).

### `outcome` ≠ the local word for "result"

In Loomio, **outcome** is the author's closing statement on a poll.
**Result** is the vote tally. Many languages use the same word for both, so
Google collapses them and the distinction disappears in the UI. Use the
locale's word for *conclusion* / *decision* for `outcome`, and keep the
locale's word for *result* only for vote tallies.

| Locale | Use for `outcome` | Google's default (wrong) |
|--------|-------------------|---------------------------|
| fr     | `conclusion`      | `résultat`                |
| pt-BR  | `conclusão`       | `resultado`               |
| da     | `konklusion`      | `resultat`                |
| sv     | `slutsats`        | `resultat`                |
| nl-NL  | `conclusie`       | `resultaat`               |
| it     | `conclusione`     | `risultato`               |
| ro     | `concluzie`       | `rezultat`                |
| uk     | `висновок`        | `результат`               |
| he     | `מסקנה`           | `תוצאה`                   |
| ja     | `結論`            | `結果`                    |
| zh-TW  | `結論`            | `結果`                    |
| hu     | `következtetés`   | `eredmény`                |
| tr     | `karar`           | `sonuç`                   |

Applies to every noun use — `outcomes`, `outcome_announced`, `outcome_created`,
`outcome_updated`, `outcome_review_due`, `post_outcome`, etc. Similar locales
not yet reviewed should probably get the same treatment.

### `post` (verb) ≠ postal/temporal "post"

As a verb in strings like "Post outcome" / "posted", Google often picks the
postal or temporal sense (`poster`/`posté` in fr, `Pós-` prefix in pt-BR,
literal `après` / "after" in fr). Use the locale's verb for **publish** /
**share** (`publier`/`publié`, `publicar`, `publiceren`, …). Affected ~17
languages in the Nov 2025 pass.

## Corrections

| File           | Key                                | Was                                             | Now                               | Why it was wrong                                       |
|----------------|------------------------------------|-------------------------------------------------|-----------------------------------|--------------------------------------------------------|
| client.de.yml  | `group_page_actions.subscribe`     | `Benachrichtigung aktivieren` (singular)        | `Benachrichtigungen aktivieren`   | Sibling `unsubscribe` already plural — pair inconsistent |
| client.de.yml  | `context_panel.pin_discussion`     | `Diskussion über die Pinnwand` ("about the pinboard") | `Diskussion anpinnen`       | Took "pin" as pinboard noun instead of verb            |
| client.de.yml  | `context_panel.unpin_discussion`   | `Diskussion aufheben` ("cancel the discussion") | `Diskussion abpinnen`             | "aufheben" = cancel, wrong sense of "un-pin"           |
| client.de.yml  | `context_panel.close_discussion`   | `Schließende Diskussion` ("closing discussion", adjective) | `Diskussion schließen` | Adjectival present participle instead of imperative verb |
