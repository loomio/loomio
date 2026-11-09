---
sections:
  introduction: e54de0b6d9ea9ffb
generated:
  introduction: 5aba22f4a6b521c0
title: Matrix
title_source: 76a2171c057b730f
title_generated: 76a2171c057b730f
source_revision: 5d6c305d2dfb5c47f5a90b1c1e6658ca352d88f5
source_file: docs/help/en/user_manual/integrations/matrix/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-09'
---

<!-- translation-section: introduction -->

# Matrix 연동

Loomio는 새 토론, 제안, 댓글, 표, 결론이 등록되면 Matrix 채널로 알림을 보낼 수 있습니다.

Matrix는 채팅방에서 일부 HTML을 허용하며, Loomio는 이 기능을 활용합니다.

Matrix 연동은 다른 채팅 연동과 조금 다릅니다. 웹훅을 사용하지 않고, 이 연동을 위해 개발한 전용 봇 클라이언트를 사용합니다.

봇이 로그인할 때 사용할 Matrix 사용자 계정을 만들어야 합니다.

봇용 사용자 계정을 만든 다음, 해당 계정으로 로그인하여 아래 정보를 확인하세요.

이 가이드에서는 Element를 사용합니다.

---

Loomio 그룹에서 Matrix 채팅 연동을 추가하세요.
![Loomio Matrix 봇 메뉴](loomio-add-matrix-bot.png)

아래 양식을 작성하세요.
![Loomio Matrix 봇 양식](loomio-matrix-bot-form.png)

액세스 토큰을 찾으려면 아래 메뉴에서 시작하세요.
![Matrix 설정 메뉴](matrix-settings-menu.png)

아래는 설정 페이지입니다.
![Matrix 설정](matrix-settings.png)

아래에서 액세스 토큰을 확인할 수 있습니다.
![Matrix 액세스 토큰](matrix-access-token.png)

이제 채팅방 ID를 확인하세요.
![Matrix 채팅방 설정](matrix-room-settings.png)

아래에서 채팅방 ID를 확인할 수 있습니다.
![Matrix 채팅방 ID](matrix-room-id.png)
