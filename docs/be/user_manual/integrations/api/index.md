---
title: API
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/integrations/api/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-30'
sections:
  introduction: 99e59473b33baba1
  user-api: 8424224e38edf17f
  server-api: f1bf07c1162ff08b
generated:
  introduction: f8e9b0f6615b4dc3
  user-api: c6e5267304aa2e51
  server-api: 4b6b64ec72d67590
title_source: c8e5998f6a3955c2
title_generated: c8e5998f6a3955c2
---

<!-- translation-section: introduction -->

# API Loomio

Выкарыстоўвайце API Loomio, каб злучыць Loomio з іншым праграмным забеспячэннем і аўтаматызаванымі працэсамі.

[Спецыфікацыя OpenAPI 3.1](openapi.yaml) апісвае ўсе агульнадаступныя аперацыі API карыстальніка і сервернага API ў фармаце, які могуць апрацоўваць праграмы. Імпартуйце яе ў кліент API або выкарыстоўвайце для стварэння кліенцкага кода з тыпамі. Кіраўніцтвы ніжэй тлумачаць працэсы, правы доступу і паводзіны, якія спецыфікацыя апісвае не цалкам.

<!-- translation-section: user-api -->

## API карыстальніка

[API карыстальніка](/en/user_manual/integrations/api/user-api) дазваляе выконваць дзеянні ад імя карыстальніка Loomio. Праз яго можна праглядаць спіс груп, ствараць абмеркаванні і кіраваць імі, а таксама каментарыямі, апытаннямі і ўдзелам у групах у межах правоў гэтага карыстальніка.

Для інтэграцый, якія атрымліваюць падзеі аўтаматычна, [вэбхукі групы](/en/user_manual/integrations/api/user-api#webhooks) адпраўляюць выбраныя падзеі Loomio на вэб-адрас у фармаце JSON. Выкарыстоўвайце канчатковыя пункты REST, каб чытаць або змяняць даныя Loomio, а вэбхук — каб атрымліваць падзеі без перыядычных запытаў.

<!-- translation-section: server-api -->

## Серверны API

[Серверны API](/en/user_manual/integrations/api/server-api) дазваляе адміністратарам самастойна размешчаных установак Loomio кіраваць уліковымі запісамі карыстальнікаў. Для аўтэнтыфікацыі выкарыстоўваецца сакрэтны ключ, агульны для ўсяго сервера.
