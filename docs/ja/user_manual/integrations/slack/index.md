---
title: Slack
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/integrations/slack/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-30'
sections:
  introduction: 4eb9618f0efb62d7
generated:
  introduction: ac6c319c860881ac
title_source: b27fb38ba323745c
title_generated: b27fb38ba323745c
---

<!-- translation-section: introduction -->

# Slackとの連携
_Loomioグループの通知をSlackに送信します。_

Loomioでは、新しいディスカッション、提案、コメント、投票、結論があると、Slackのチャンネルに通知を送信できます。重要なディスカッションや意思決定の更新を、適切なタイミングで確認できます。

---

まず[https://api.slack.com](https://api.slack.com)にアクセスします。ログインしていない場合はログインし、「Create New App」をクリックします。

![](s1.png)

Slackアプリに名前を付けます。

![](s2.png)

Incoming Webhooksのサポートを追加します。

![](s3.png)

次に、この機能を有効にします。

![](s4.png)

新しいWebhookを追加します。

![](s5.png)

チャンネルを選択します。

![](s6.png)

Webhook URLをクリップボードにコピーします。

![](s7.png)

Webhook URLを取得したら、チャット連携の設定を続けます。

[Loomioでチャット連携を設定する](../chatbots/#set-up-a-chat-integration)

_LoomioはSlackが開発、提携、サポートしているサービスではありません。_
