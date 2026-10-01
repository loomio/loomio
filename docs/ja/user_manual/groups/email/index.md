---
title: メールアドレス
source_revision: 924e704b41670a012a16528cf88edf90f8d6b572
source_file: docs/en/user_manual/groups/email/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: bbc0cdb29306b05d
  preventing-unauthorized-emails: 218f730808482c55
generated:
  introduction: e56d399e9da2d469
  preventing-unauthorized-emails: 7a2516a77602db79
title_source: f2488fd4ef4adbc6
title_generated: dd4433300c45394f
---

<!-- translation-section: introduction -->

# メールを送信してグループにスレッドを作成する

Loomioのグループにはメールアドレスがあります。このアドレスにメールを送信または転送すると、グループにスレッドを作成できます。

グループのメールアドレスは、グループページで確認できます。
![グループページのメールアドレスの表示位置](email_email_button.png)

このアドレスにメールを送信すると、新しいスレッドが作成されます。メールの件名がスレッドのタイトルになり、本文が説明になります。添付ファイルもスレッドに添付されます。

メールの差出人（From）アドレスをもとに、スレッドの作成者となるグループのメンバーを特定します。

<!-- translation-section: preventing-unauthorized-emails -->

## 許可されていないメールを防ぐ

グループのメンバー以外がこの機能を利用できないように、Loomioでは受信メールの差出人（From）アドレスがグループのメンバーのメールアドレスと一致することを必須としています。

複数のメールアドレスを使用する場合は、別のメールアドレスをLoomioが認識できるように、エイリアスとして追加できます。

差出人（From）アドレスがグループのメンバーのメールアドレスと一致しない場合は、エイリアスを追加するか、そのアドレスからの今後のメールをすべて拒否するよう求める通知が届きます。

そのため、認識されていないアドレスから初めてメールを送信する際は、エイリアスを追加する必要があります。その後は、メールがすぐに受け付けられます。

![認識されていないメールの承認ボタンと拒否ボタンの位置](email_unreleased_emails.png)
