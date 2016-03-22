# Summary

## Deploying
* [Deploying Loomio](setup_loomio_production.md)
  1. [Basic VPS setup](basic_vps_setup.md)
  2. [Setup Loomio with Dokku](install_loomio_with_dokku.md)
  3. [Environment Variables](environment_variables.md)
  4. [Setup PostgreSQL](setup_postgresql.md)
  5. [Setup reply by email](setup_reply_by_email.md)
  6. [Setup Faye for live updating](setup_faye.md)
  7. [Setup SMTP server](setup_smtp_server.md)
  8. [Setup third party integrations](setup_loomio_integrations.md)
  9. [Setup Slack integration](setup_slack.md)
  9. [Setup SSL/TLS](setup_ssl.md)

* [Reporting a bug](reporting_a_bug.md)

## Translating
* [Translation guide](translation.md) (targeting Rails translations)
* [Translation for developers](translation_for_developers.md)

## Developing
* [Accessibility](accessibility.md)
* Contributing code
  * [How to squash](how_to_squash.md)
  * Making a pull request
* [Setting up your development environment](setup_development_environment.md)
* [Using the development environment](using_development.md)
* [Debugging steps](debugging.md)

### Front end
  * [Useful notes in an unuseful format](code_guidelines.md)
  * Tech used
  * Accessiblity notes
  * Services
    * ScrollService
  * Components
    * [dropdowns](ui_dropdowns.md)
    * file layout
    * naming
      what kind of thing is it?
        card
        accordian
        panel
        page
    Markup
      use butons not a's
    Styling
      BEM

  Lineman
    How to run it..
    other commands it provides
    running specs and e2es
  Recordstore
    is how records have behaviour and relate to each other

### Rails backend
- [Services](ruby_services.md)
  Argument format
  Return values and raising exceptions on permissions error

Tests
  how to run cucumber, rspec
  dont bother with isolation tests here.
API Controllers

Services
  general format
