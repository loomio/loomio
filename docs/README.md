# Repository documentation

- [Help site](help/README.md): published user manual, guides, API reference, policies, translations, assets, and the site builder
- [Agent instructions](AGENTS.md): entry point for the task-specific instructions in `agents/`
- [System documentation](system/): internal architecture and design notes
- [Release notes](release_notes/): dated release notes

Build the English help site with:

```bash
DOCS_LOCALES=en bundle exec ruby docs/help/build.rb
```

The generated site stays in `public/docs/` and is served under `/docs/`.
