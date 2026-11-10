---
sections:
  introduction: bbc0cdb29306b05d
  preventing-unauthorized-emails: 218f730808482c55
generated:
  introduction: 4098d7f6c4c74f24
  preventing-unauthorized-emails: 99e25aabacc0da1f
title: 이메일 주소
title_source: f2488fd4ef4adbc6
title_generated: e9abda44c42a3a28
source_revision: 5d6c305d2dfb5c47f5a90b1c1e6658ca352d88f5
source_file: docs/help/en/user_manual/groups/email/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-09'
---

<!-- translation-section: introduction -->

# 이메일을 보내 그룹에서 스레드 시작하기

Loomio 그룹에는 이메일 주소가 있습니다. 이 주소로 이메일을 보내거나 전달하면 그룹에서 스레드를 시작할 수 있습니다.

그룹 페이지에서 그룹의 이메일 주소를 확인할 수 있습니다:
![그룹 페이지에서 이메일 주소가 표시되는 위치](email_email_button.png)

이 주소로 이메일을 보내면 새 스레드가 생성됩니다. 이메일 제목은 스레드 제목이 되고, 이메일 본문은 설명이 되며, 첨부 파일은 스레드에 첨부됩니다.

이메일의 "보낸 사람" 주소를 기준으로 스레드 작성자가 될 그룹 멤버를 찾습니다.

<!-- translation-section: preventing-unauthorized-emails -->

## 승인되지 않은 이메일 방지

그룹 멤버가 아닌 사람이 이 기능을 사용할 수 없도록, Loomio는 수신 이메일의 "보낸 사람" 주소가 그룹 멤버의 이메일 주소와 일치하는지 확인합니다.

여러 이메일 주소를 사용하는 경우 별칭을 추가하여 Loomio가 다른 이메일 주소도 인식하도록 할 수 있습니다.

"보낸 사람" 주소가 그룹 멤버의 이메일 주소와 일치하지 않으면, 별칭을 추가하거나 해당 주소에서 보내는 이후의 모든 이메일을 거부하도록 요청하는 알림을 받습니다.

따라서 인식되지 않은 주소에서 처음 이메일을 보낼 때는 별칭을 추가해야 합니다. 그다음부터는 이메일이 즉시 수락됩니다.

![인식되지 않은 이메일의 승인 및 거부 버튼 위치](email_unreleased_emails.png)
