---
sections:
  introduction: 46c095b75ad63f90
  what-it-looks-like-in-chat: f317dcdbffe349dc
  generate-a-webhook-url: ededdedfffbe6bcb
  set-up-a-chat-integration: d671b54fe6ae3cd1
  invite-to-poll: ffa06cde4354b243
  automatic-notifications: 21e1f83202af63e1
generated:
  introduction: ca42843940ba72b2
  what-it-looks-like-in-chat: 3627363de5fd8225
  generate-a-webhook-url: 4a06b427e5652b20
  set-up-a-chat-integration: ccb359ca867b5b8e
  invite-to-poll: b3101799bfa11ecd
  automatic-notifications: c8e83f2ef431591f
title: 채팅 연동
title_source: 0eca19d30c6d7d3c
title_generated: 58e74bbd88fea4d5
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/integrations/chatbots/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
---

<!-- translation-section: introduction -->

# 채팅 연동

Loomio는 채팅방에 알림을 보낼 수 있습니다.

채팅 도구와 Loomio를 함께 활용할 수 있습니다. 빠른 대화와 시기적절한 소식 전달에는 채팅을 사용하세요. 사람들이 참여할 시간이 필요하거나, 결정을 내려야 하거나, 그룹에서 오래 보관할 기록이 필요한 경우에는 중요한 주제를 Loomio로 옮기세요.

Loomio는 Slack, Discord, Microsoft Teams, Matrix, Mattermost를 지원합니다.

사람들을 스레드나 투표에 초대할 때마다 채팅방에 알림을 수동으로 보낼 수 있습니다. 누군가 토론을 시작하는 등 특정 이벤트가 발생할 때 자동으로 알림을 보내도록 설정할 수도 있습니다.

<!-- translation-section: what-it-looks-like-in-chat -->

## 채팅에 표시되는 모습

![](chatbot_in_slack.png)

<!-- translation-section: generate-a-webhook-url -->

## 채팅 서비스 연결

사용하는 채팅 서비스의 안내에 따라 웹훅 URL을 받으세요(Matrix의 경우 봇 액세스 토큰과 방 ID를 받으세요).

- [Slack](../slack/)
- [Microsoft Teams](../microsoft_teams/)
- [Discord](../discord/)
- [Matrix](../matrix/)
- [Mattermost](../mattermost/)

Zapier나 Rocket.Chat처럼 HTML 또는 Markdown 형식의 수신 웹훅을 지원하는 다른 서비스도 연결할 수 있습니다. Loomio에서 **Mattermost** 채팅 연동을 선택하고 사용자 지정 웹훅 URL을 입력하세요.

<!-- translation-section: set-up-a-chat-integration -->

## 채팅 연동 설정

채팅 연동을 추가하거나 수정하려면 그룹 관리자여야 합니다.

1. 채팅 서비스 설정을 마친 뒤(위 내용 참조), Loomio에서 그룹 메뉴를 열고 **채팅 연동**을 선택하세요.

   ![](loomio-group-settings.png)

   ![](loomio-settings-chatbots.png)

2. 사용하는 서비스에 맞는 새 채팅 연동을 추가하고, 이름(예: "Discord #general")을 입력한 다음 웹훅 URL을 붙여넣으세요.

   ![](loomio-chatbot-form.png)

3. 자동으로 알림을 보낼 이벤트를 선택하거나, 알림을 수동으로만 보내려면 아무 이벤트도 선택하지 않은 상태로 저장하세요. 이 설정은 언제든지 변경할 수 있습니다.

<!-- translation-section: invite-to-poll -->

### 수동으로 알림 보내기

채팅방에 투표나 토론에 관한 알림을 보내려면 해당 항목을 열고 **초대**를 선택하세요(또는 **결론 공유**, **투표 독려**, **투표 수정** 같은 다른 알림 작업을 선택하세요). 수신자 목록에서 채팅 연동을 선택하고 알림을 보내세요.

![](invite_button_on_proposal.png)

![](invite_to_vote_1.png)

![](invite_to_vote_2.png)

![](chatbot_in_slack.png)

<!-- translation-section: automatic-notifications -->

### 자동 알림

특정 이벤트가 발생할 때마다 알림을 보내려면 채팅 연동을 수정하고 해당 이벤트를 선택하세요.

![](chatbot_enable_automatic_notifications.png)
