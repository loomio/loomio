---
title: API
source_revision: 924e704b41670a012a16528cf88edf90f8d6b572
source_file: docs/en/user_manual/integrations/api/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: 99e59473b33baba1
  user-api: 8424224e38edf17f
  server-api: f1bf07c1162ff08b
generated:
  introduction: 89741a13cf2c61d6
  user-api: a1adf5122430de41
  server-api: ef4455c17a4f3be1
title_source: c8e5998f6a3955c2
title_generated: c8e5998f6a3955c2
---

<!-- translation-section: introduction -->

# API Loomio

Выкарыстоўвайце API Loomio, каб злучыць Loomio з іншым праграмным забеспячэннем і аўтаматызаванымі працоўнымі працэсамі.

[Кантракт OpenAPI 3.1](openapi.yaml) апісвае кожную публічную аперацыю карыстальніцкага API і сервернага API ў машыначытальным фармаце. Імпартуйце яго ў API-кліент або выкарыстоўвайце для стварэння тыпізаванага кліенцкага кода. Прыведзеныя ніжэй інструкцыі тлумачаць працоўныя працэсы, правы доступу і паводзіны, якія не цалкам апісаны ў кантракце.

<!-- translation-section: user-api -->

## Карыстальніцкі API

[Карыстальніцкі API](/en/user_manual/integrations/api/user-api) выконвае дзеянні ад імя карыстальнікаў Loomio. Ён дазваляе атрымліваць спіс груп, ствараць тэмы, каментарыі, апытанні і запісы пра сяброўства ў групах, а таксама кіраваць імі ў адпаведнасці з правамі доступу адпаведнага ўліковага запісу.

Для інтэграцый з аўтаматычнай адпраўкай падзей [вэбхукі групы](/en/user_manual/integrations/api/user-api#webhooks) адпраўляюць выбраныя падзеі Loomio на вэб-канцавы пункт у фармаце JSON. Выкарыстоўвайце канцавыя пункты REST, каб чытаць або змяняць даныя Loomio, і вэбхук, калі інтэграцыя павінна атрымліваць падзеі без перыядычных запытаў.

<!-- translation-section: server-api -->

## Серверны API

[Серверны API](/en/user_manual/integrations/api/server-api) дазваляе тым, хто абслугоўвае ўласныя ўстаноўкі Loomio, кіраваць уліковымі запісамі карыстальнікаў. Для аўтэнтыфікацыі выкарыстоўваецца агульны для ўсяго сервера сакрэт.
