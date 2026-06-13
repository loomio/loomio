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
| client.*.yml   | `poll_stv_form.method_meek`, `poll_stv_results.method_meek` | Local adjectives/names like `Nöyrä STV`, `Szelíd STV`, `Πράος STV`, `Мик СВТ` | `Meek STV` | Meek is a named STV counting method, not the adjective "mild/meek" and not to be localized |
| client.*.yml   | `poll_stv_form.quota_droop`, `poll_stv_results.quota_droop` | Local words for droop/drop/sag like `Pudotuskiintiö`, `Leesési kvóta`, `下垂` | `Droop quota`, `Droop` | Droop is a named election quota, not a verb/adjective |
| client.*.yml   | `poll_stv_form.quota_hare`, `poll_stv_results.quota_hare` | Local words for the animal hare/rabbit like `cuota de liebre`, `Hasenquote`, `野兔` | `Hare quota`, `Hare` | Hare is a named election quota, not the animal in ordinary prose |
| client.*.yml   | `poll_stv_results.round` | Local verbs for "round/rounding" and translated placeholders like `Στρογγυλοποίηση %{αριθμός}` | `Round %{number}` or locale equivalent preserving `%{number}` | Round is an election counting round; interpolation names must not be translated |
| client.*.yml   | `poll_stv_results.tied` | Local words for necktie/bind like `Cravate`, `Gravata`, `领带`, `Binden` | `Tie` or locale equivalent for equal result | Tie means equal votes/result, not clothing or fastening |
| client.*.yml   | `poll_common_votes_panel.cast`, `poll_common_votes_panel.uncast` | Movie/casting/throwing/foundry senses like `Elenco`, `Gießen`, `Casting`, `投掷` | Vote-status wording such as `Cast` / `Uncast` or locale equivalent | In poll results, cast means a vote has been submitted, not thrown, moulded, or assigned to a cast |
| client.*.yml   | `thread_arrangement_form.threaded`, `discussion_last_seen_by.thread_engagement` | Physical screw/thread senses like `Gewinde`, `Enroscado`, `螺纹`, `Angrenarea filetului` | UI conversation-thread wording such as `Threaded` / `Thread engagement` or locale equivalent | Thread refers to discussion threading, not screw threads or fibres |
| server.*.yml   | `poll_templates.stv.process_introduction`, `poll_templates.stv.details` | Translated STV proper names and election terms like `manso`, `douce`, `scozzese o moderato`, `hareng/liebre`, and "occupied seats" | Preserved `Scottish`, `Meek`, `Droop`, `Hare`; corrected eliminated-vote and seats-to-fill wording | STV method/quota names are proper nouns; election seats are filled/available, not already occupied |
| server.*.yml   | `unauthorized.add_guests.all` | Added `%{subject}` to translations even though English source has no placeholder | Removed `%{subject}` and translated as adding guests generally | Interpolation placeholders must exactly match the source; Google sometimes invents context variables from nearby strings |
| client.*.yml   | `notifications.email_subject.poll_created` | Dropped `%{poll_type}` and used generic "Vote" labels | Restored `%{poll_type}: %{title}` | Email subject needs the dynamic poll type, not a hard-coded generic label |
| client.zh_CN.yml | Multiple HTML/interpolation keys | Full-width percent signs or translated placeholder words like `％{标题}` / literal `作者` | Restored placeholders such as `%{title}`, `%{author}`, `%{username}` | Placeholder names and `%{...}` syntax must never be translated or converted to full-width characters |
| client.*.yml   | `strand_nav.return`, `thread_arrangement_form.items`, `thread_arrangement_form.thread_settings`, `poll_common_settings.*`, `poll_common_details_meta.*` | UI labels translated in wrong senses like "Return"→yield, "items"→goods/articles, "thread"→subprocess/screw-thread, "opened"→inaugurated | Corrected to navigation, discussion-thread, poll-setting, and poll-time meanings | Short UI labels need surrounding UI context; Google often picks a plausible but wrong dictionary sense |
| server.*.yml   | `group.error.handle_must_be_url_friendly` | Character range `(a-z)` collapsed to `(az)` or `(a)` | Preserve `(a-z)` | ASCII character ranges are literal validation guidance, not prose to translate |
| client.it.yml, server.it.yml | Multiple direct-address UI and template strings | Formal/plural `Si prega`, `Vi preghiamo`, `vostro/vostra`, and mixed replacements like `Vi prego` | Informal singular Italian `tu` register with direct imperatives like `inserisci`, `accetta`, `rispondi`, `contattaci` | Italian direct-address UI should be consistent and concise; Google introduced formal/plural politeness forms and bad mixed conjugations |

## 2026-05-21 — lock_thread_modal body changed to explanation

- **file:** `config/locales/client.en.yml`
- **key:** `lock_thread_modal.body`
- **before:** Lock threads to remove them from the list of open threads and prevent people from commenting.
- **after:** Lock threads to prevent people from commenting or making further changes
- **why it was wrong:** The original text claimed locking "removes threads from the list of open threads," which is no longer true — the default discussions panel now shows all threads (both locked and unlocked). The new text accurately describes what locking does: prevents further comments and changes.

## 2026-05-22 — lock/unlock thread translation pass

| File | Key | Before | After | Why it was wrong |
|------|-----|--------|-------|------------------|
| `config/locales/client.de.yml` | `action_dock.lock_thread` | `Gewinde sichern` | `Thread sperren` | Took "thread" as a screw/mechanical thread instead of a discussion thread. |
| `config/locales/client.es.yml` | `action_dock.lock_thread` | `Hilo de bloqueo` | `Bloquear hilo` | Noun phrase, not the imperative UI action. |
| `config/locales/client.fr.yml` | `action_dock.lock_thread` | `Filetage de verrouillage` | `Verrouiller la discussion` | Took "thread" as a screw/mechanical thread. |
| `config/locales/client.it.yml` | `action_dock.lock_thread` | `Filettatura di bloccaggio` | `Blocca discussione` | Took "thread" as a screw/mechanical thread. |
| `config/locales/client.nl_NL.yml` | `action_dock.lock_thread` | `Borgdraad` | `Discussie vergrendelen` | Took "thread" as safety wire/mechanical thread, not a discussion. |
| `config/locales/client.pt_BR.yml` | `action_dock.lock_thread` | `Rosca de travamento` | `Bloquear tópico` | Took "thread" as screw thread. |
| `config/locales/client.tr.yml` | `action_dock.lock_thread` | `Kilitleme vidası` | `Konuyu kilitle` | Took "thread" as screw. |
| `config/locales/client.zh_CN.yml` | `action_dock.lock_thread` | `锁螺纹` | `锁定主题` | Took "thread" as screw thread. |
| `config/locales/client.zh_TW.yml` | `action_dock.lock_thread` | `鎖螺紋` | `鎖定主題` | Took "thread" as screw thread. |
| `config/locales/client.fr.yml`, `client.pt_BR.yml`, `client.ru.yml`, `client.tr.yml` | notification/thread item lock keys | Translated placeholders like `%{acteur}`, `%{ator}`, `%{автор}`, `%{yazar}` | Restored `%{actor}` / `%{author}` | Interpolation placeholder names must never be translated. |
| `config/locales/client.he.yml` | `action_dock.unlock_thread`, `discussion.locked.unlocked` | Repeated the lock wording | `ביטול נעילת שרשור`, `נעילת השרשור בוטלה` | Unlock status/action was translated as lock. |
| `config/locales/client.fr.yml`, `client.hu.yml`, `client.it.yml`, `client.pl.yml`, `client.ru.yml` | locked discussion labels | Closed/shut wording such as `Fermé`, `Bezárt`, `Chiuso`, `Zamknięty`, `Закрытые обсуждения` | Lock-state wording such as `Verrouillé`, `Zárolva`, `Bloccate`, `Zablokowane`, `Заблокированные обсуждения` | Locking a thread is distinct from closing a poll/discussion; these labels should not drift back to "closed". |

