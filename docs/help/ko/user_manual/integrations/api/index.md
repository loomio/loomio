---
sections:
  introduction: 99e59473b33baba1
  user-api: 8424224e38edf17f
  server-api: 42859c6715b7a994
generated:
  introduction: d9f6a6fcb678920b
  user-api: ff23d600ca600a87
  server-api: 3c52b87a0f97a3ed
title: API
title_source: c8e5998f6a3955c2
title_generated: c8e5998f6a3955c2
source_revision: 5d6c305d2dfb5c47f5a90b1c1e6658ca352d88f5
source_file: docs/help/en/user_manual/integrations/api/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-09'
---

<!-- translation-section: introduction -->

# Loomio API

Loomio API를 사용하여 Loomio를 다른 소프트웨어 및 자동화된 워크플로와 연결하세요.

[OpenAPI 3.1 명세](openapi.yaml)는 공개된 모든 사용자 API 및 서버 API 작업을 기계가 읽을 수 있는 형식으로 설명합니다. API 클라이언트로 가져오거나 타입이 지정된 클라이언트 코드를 생성하는 데 사용하세요. 아래 가이드에서는 명세에 충분히 표현되지 않은 워크플로, 권한 및 동작을 설명합니다.

<!-- translation-section: user-api -->

## 사용자 API

[사용자 API](/en/user_manual/integrations/api/user-api)는 Loomio 사용자로서 작업을 수행합니다. 해당 사용자의 권한에 따라 그룹 목록을 조회하고 스레드, 댓글, 투표 및 그룹 멤버십을 생성하거나 관리할 수 있습니다.

푸시 기반 연동에서는 [그룹 웹훅](/en/user_manual/integrations/api/user-api#webhooks)이 선택한 Loomio 이벤트를 JSON 형식으로 웹 엔드포인트에 전송합니다. Loomio 데이터를 읽거나 변경하려면 REST 엔드포인트를 사용하고, 연동된 시스템이 폴링 없이 이벤트를 수신해야 할 때는 웹훅을 사용하세요.

<!-- translation-section: server-api -->

## 서버 API

[서버 API](/en/user_manual/integrations/api/server-api)를 사용하면 자체 호스팅 Loomio 인스턴스 운영자가 사용자 계정을 생성하고 관리하며, 그룹을 조회하고 그룹 멤버십과 역할을 관리할 수 있습니다. 서버 전체에 적용되는 비밀 키를 사용하며, 봇 계정이나 각 그룹의 멤버십이 필요하지 않습니다.
