# Localization instructions

## i18n / Localization

- **Change an English application string only together with every translation.** Retranslate the key in every locale in the same change, or create a new key and reference it instead. User-manual translations follow the deferred workflow in [user_manual.md](user_manual.md).
- **`config/locales/glossary.yml` defines Loomio's terms and each locale's style.** Every key term has its Loomio meaning and one preferred translation per locale, and every locale has its register. Both translators send it to the model. Choose terms by correct Loomio meaning first, then a length close to the English, then the words people know from popular apps (WhatsApp for poll, Slack for thread). Thread and discussion stay distinct: a thread holds a discussion or a poll. Outcome uses the word for "conclusion". How much existing text a better term changes is no reason to keep a worse one. Fix a wrong term in the glossary, then apply it.
- **Translate and check with the glossary.** `rake loomio:translate_strings` translates missing app strings with codex. `rake loomio:check_glossary` lists strings that break the glossary in `tmp/glossary/<locale>.csv`, and `rake loomio:apply_glossary` revises them (`MISSING=1` also revises strings missing a preferred term; `LOCALES=fr,de` limits locales). `bundle exec ruby docs/help/check_glossary.rb` checks the manual.
- **Name keys after their values,** so templates are easy to read.
- **Write English UI copy plainly and calmly.** No exclamation marks on success messages; say what happened. Omit the final full stop on single-sentence UI strings. Choose words whose meaning survives translation.
