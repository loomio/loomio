---
sections:
  introduction: af3f509fd0a87c7d
  what-it-looks-like-in-chat: c425490496cb0ed2
  generate-a-webhook-url: a4a95bf5c61e8e3f
  set-up-a-chat-integration: d9c5b87891a0d747
  invite-to-poll: 70a0e025c79a13f0
  automatic-notifications: 381b622ece95e244
generated:
  introduction: c6b3d05165b50c95
  what-it-looks-like-in-chat: bcb3204117d5060e
  generate-a-webhook-url: 966fd4b5d4e7dfe7
  set-up-a-chat-integration: 3dcb400ae63180ec
  invite-to-poll: 9071d274b1bdd546
  automatic-notifications: 79e50848ea6fbde9
title: 채팅 연동
title_source: 0eca19d30c6d7d3c
title_generated: 58e74bbd88fea4d5
source_revision: 5d6c305d2dfb5c47f5a90b1c1e6658ca352d88f5
source_file: docs/help/en/user_manual/integrations/chatbots/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-09'
---

<!-- translation-section: introduction -->

# 채팅 연동

Loomio는 채팅방에 알림을 보낼 수 있습니다.

채팅 도구와 Loomio를 함께 활용할 수 있습니다. 빠른 대화와 시기적절한 소식 전달에는 채팅을 사용하세요. 사람들이 참여할 시간이 필요하거나, 결정을 내려야 하거나, 그룹에서 오래 보관할 기록이 필요한 경우에는 중요한 주제를 Loomio로 옮기세요.

Loomio는 Slack, Discord, Microsoft Teams, Matrix, Mattermost를 지원합니다.

개별 사람들에게 투표하거나 스레드에 참여하도록 초대할 때와 같은 방식으로 언제든지 채팅방에 알림을 보낼 수 있습니다.

누군가 스레드를 시작하는 등 특정 이벤트가 발생할 때마다 알림을 보내도록 설정할 수도 있습니다.

<!-- translation-section: what-it-looks-like-in-chat -->

## 채팅에 표시되는 모습
![](chatbot_in_slack.png)

<!-- translation-section: generate-a-webhook-url -->

## 웹훅 URL 생성
지원하는 각 서비스의 단계별 안내를 준비했습니다. 사용하는 서비스에 맞는 안내를 따라 Loomio에서 채팅 연동을 추가하는 데 필요한 웹훅 URL을 받으세요.

- [Slack](../slack/)
- [Microsoft Teams](../microsoft_teams/)
- [Discord](../discord/)
- [Matrix](../matrix/)
- [Mattermost](../mattermost/)

Loomio의 웹훅 기반 시스템은 HTML 또는 Markdown 형식의 수신 웹훅을 지원하는 다른 시스템에도 사용할 수 있습니다. Zapier나 Rocketchat 등이 이에 해당합니다. Mattermost 봇을 선택하고 사용자 지정 웹훅 URL을 사용하세요.

<!-- translation-section: set-up-a-chat-integration -->

## 채팅 연동 설정

선택한 서비스의 설정을 마치면(위 내용 참조) 웹훅 URL을 받게 됩니다. 그룹 메뉴에서 **채팅 연동**을 열고 그룹에 새 채팅 연동을 추가하세요.

![](loomio-group-settings.png)
![](loomio-settings-chatbots.png)

지금은 체크박스를 선택하지 않아도 됩니다. 이름(예: "Discord #general")과 URL만 입력한 뒤 양식 하단의 저장 버튼을 클릭하세요.

![](loomio-chatbot-form.png)

나중에 연동을 통해 자동 알림을 받으려면 연동 설정으로 돌아가 해당 이벤트를 선택하세요.

<!-- translation-section: invite-to-poll -->

### 투표에 초대

제안에 투표하도록 사람들을 초대하는 알림을 채팅방에 보내는 방법입니다. 결론 공유, 스레드에 초대, 투표 알림, 투표 수정 등도 같은 방식으로 진행합니다.

![](invite_button_on_proposal.png)

![](invite_to_vote_1.png)

![](invite_to_vote_2.png)

![](chatbot_in_slack.png)

<!-- translation-section: automatic-notifications -->

### 자동 알림
특정 이벤트가 발생할 때마다 알림을 보내려면 채팅 연동을 수정하고 해당 이벤트를 선택하세요.

![](chatbot_enable_automatic_notifications.png)
