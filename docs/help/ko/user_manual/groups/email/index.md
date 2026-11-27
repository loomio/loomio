---
sections:
  introduction: 36b06c5b4604ac74
  preventing-unauthorized-emails: f4b8d2eaf0d79f01
generated:
  introduction: 48371821bfdb0c55
  preventing-unauthorized-emails: 59b5ef35d4cfa0d1
title: 이메일 주소
title_source: f2488fd4ef4adbc6
title_generated: e9abda44c42a3a28
source_revision: 6e7aad6a91a50e55dca43a20edcc88d445ee4185
source_file: docs/help/en/user_manual/groups/email/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-26'
---

<!-- translation-section: introduction -->

# 이메일을 보내 그룹에서 스레드 시작하기

각 Loomio 그룹에는 고유한 이메일 주소가 있습니다. 이 주소로 이메일을 보내거나 전달하면 그룹에서 새 스레드를 시작할 수 있습니다.

그룹 페이지의 **설정**에서 그룹의 이메일 주소를 확인할 수 있습니다:

![그룹 페이지의 설정에서 이메일 주소가 표시되는 위치](email_email_button.png)

이 주소로 이메일을 보내면 Loomio가 새 스레드를 생성합니다. 이메일 제목은 스레드 제목이 되고, 본문은 스레드 설명이 되며, 첨부 파일은 스레드에 추가됩니다.

Loomio는 이메일의 "보낸 사람" 주소를 기준으로 발신자와 일치하는 그룹 멤버를 찾아 스레드 작성자로 설정합니다.

<!-- translation-section: preventing-unauthorized-emails -->

## 승인되지 않은 이메일 방지

그룹 멤버가 아닌 사람이 스레드를 시작하지 못하도록, Loomio는 수신 이메일의 "보낸 사람" 주소가 그룹 멤버의 이메일 주소와 일치하는지 확인합니다.

멤버가 인식되지 않은 주소로 이메일을 보내면 Loomio는 이메일을 보류하고 그룹 관리자에게 알립니다. 그룹 관리자는 이메일을 승인하고 해당 주소를 그 멤버의 별칭으로 추가하거나, 해당 주소에서 보내는 이후의 이메일을 거부할 수 있습니다.

별칭이 추가되면 이후 해당 주소에서 보내는 이메일은 즉시 스레드를 생성합니다.

![인식되지 않은 이메일의 승인 및 거부 버튼](email_unreleased_emails.png)
