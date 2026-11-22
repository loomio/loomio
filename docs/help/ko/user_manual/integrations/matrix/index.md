---
sections:
  introduction: 114ab8c916ca5fba
generated:
  introduction: 00d94b0f0d32e864
title: Matrix
title_source: 76a2171c057b730f
title_generated: 76a2171c057b730f
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/integrations/matrix/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
---

<!-- translation-section: introduction -->

# Matrix 연동

Loomio는 새 토론, 투표, 댓글, 표, 결론이 등록되면 Matrix 채팅방으로 알림을 보낼 수 있습니다. 채팅 연동을 추가하려면 그룹 관리자여야 합니다.

Matrix는 Loomio의 다른 채팅 연동과 달리 웹훅을 사용하지 않습니다. 대신 Loomio는 봇 역할을 하는 Matrix 사용자 계정으로 연결하여 채팅방에 서식이 적용된 메시지를 게시합니다.

이 가이드에서는 Element 클라이언트를 사용합니다.

---

1. Loomio용 Matrix 사용자 계정을 만들고, Element에서 해당 계정으로 로그인한 다음, 알림을 받을 Matrix 채팅방에 해당 계정을 초대하세요. 이 세션의 로그인 상태를 유지하세요. 로그아웃하면 액세스 토큰이 무효화됩니다.

2. Loomio 그룹에서 그룹 메뉴를 열고 **채팅 연동**을 선택한 다음 **Matrix** 채팅 연동을 추가하세요.

   ![Loomio Matrix 봇 메뉴](loomio-add-matrix-bot.png)

   ![Loomio Matrix 봇 양식](loomio-matrix-bot-form.png)

3. Element에서 봇 계정 메뉴를 열고 **모든 설정**을 선택하세요.

   ![Matrix 설정 메뉴](matrix-settings-menu.png)

4. **도움말 및 정보**를 열고 **고급** 섹션까지 스크롤하세요.

   ![Matrix 설정](matrix-settings.png)

5. **액세스 토큰**을 복사하여 Loomio 양식에 붙여넣으세요.

   ![Matrix 액세스 토큰](matrix-access-token.png)

6. 채팅방의 **설정** 메뉴를 열고 **고급**으로 이동하세요.

   ![Matrix 채팅방 설정](matrix-room-settings.png)

7. **내부 채팅방 ID**를 복사하여 Loomio 양식에 붙여넣고 연동을 저장하세요.

   ![Matrix 채팅방 ID](matrix-room-id.png)
