---
sections:
  introduction: bc7d2de9abc2ea86
  administering-your-group: 7ae1b105c20977fc
  managing-subgroups: 2e4bdee3283e8ef8
  removing-members: d70807bdd968d594
  leaving-group: 69332aeda981c679
  set-title: eb9a52e3d6c21d43
  member-email-addresses: 0e800419a7bdacc6
generated:
  introduction: c09dfe6ecc9cd4d8
  administering-your-group: 77f072611d506c89
  managing-subgroups: f82d456449cdd0cb
  removing-members: f6fb7bf2cb2a63fa
  leaving-group: 03b4f713b1ec1248
  set-title: d0af8f9d496c2dcf
  member-email-addresses: 656ec59383c0b084
title: 멤버 관리
title_source: 23ac3a7fe9ee72a2
title_generated: 18362c237b482d80
source_revision: 6e7aad6a91a50e55dca43a20edcc88d445ee4185
source_file: docs/help/en/user_manual/groups/member_management/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-26'
---

<!-- translation-section: introduction -->

# 멤버 관리

그룹 관리자는 그룹 페이지의 **멤버** 탭에서 멤버를 관리합니다. 멤버 옆의 작업 메뉴를 열어 직함을 설정하거나, 그룹 관리자 또는 대리인으로 지정하거나, 그룹에서 제외하세요.

![Oatmilk Cooperative 멤버 페이지의 멤버 작업 메뉴](member_management.png)

<!-- translation-section: administering-your-group -->

## 그룹 관리

Loomio 그룹에는 **멤버**와 **그룹 관리자**, 두 가지 역할이 있습니다.

그룹 관리자는 멤버를 추가하거나 제외하고, 멤버 권한을 관리하고, 그룹 공개 범위 설정을 변경하고, 구독을 관리하고, 멤버의 이메일 주소를 확인하고, 그룹 데이터를 내보낼 수 있습니다.

그룹을 만든 사람은 기본적으로 그룹 관리자가 됩니다. 항상 그룹을 관리할 사람이 있도록 그룹 관리자를 두 명 이상 두는 것을 권장합니다. 그룹 관리자 수에는 제한이 없습니다.

멤버를 그룹 관리자로 지정하려면 **멤버** 탭에서 해당 멤버의 이름 옆에 있는 작업 메뉴를 열고 **관리자 지정**을 선택하세요.

![멤버 메뉴의 관리자 지정 항목](member_make_admin.png)

<!-- translation-section: managing-subgroups -->

## 하위 그룹 관리

상위 그룹의 그룹 관리자는 비밀 하위 그룹을 제외한 모든 하위 그룹에 가입한 후 자신을 해당 하위 그룹의 그룹 관리자로 지정할 수 있습니다.

하위 그룹 페이지에서 **그룹 가입**을 선택하세요.

![Oatmilk Cooperative 비공개 하위 그룹의 그룹 가입 버튼](member_join_subgroup.png)

하위 그룹의 멤버가 되면 해당 하위 그룹의 **멤버** 탭에서 본인의 이름 옆에 있는 작업 메뉴를 열고 **관리자 지정**을 선택하세요.

>[!Note]
>이 권한은 [**비밀** 하위 그룹](/en/user_manual/groups/subgroups#permissions)에는 적용되지 않습니다.

<!-- translation-section: removing-members -->

## 멤버 제외

멤버를 제외하려면 해당 멤버의 이름 옆에 있는 작업 메뉴를 열고 **그룹에서 제외**를 선택하세요.

![멤버 메뉴의 그룹에서 제외 항목](member_remove.png)

그룹에서 제외되면 다음과 같은 변화가 생깁니다.

- 해당 멤버는 그룹과 하위 그룹에 접근할 수 없으며, 그룹 알림을 더 이상 받지 않습니다.
- 기존 댓글과 행사한 표는 그대로 유지됩니다.
- 비공개 투표는 해당 멤버의 대시보드와 투표 목록에서 사라집니다. 공개 투표는 계속 읽을 수 있지만, 다시 초대받기 전까지 투표할 수 없습니다. 투표가 마감된 상태에서 그룹을 탈퇴한 경우에도 해당 투표를 다시 열면 투표 권한이 유지되지 않습니다.

제외한 멤버는 나중에 다시 추가할 수 있습니다. 다시 가입하면 접근 권한과 진행 중인 투표에서 행사한 기존 표가 복원됩니다.

<!-- translation-section: leaving-group -->

## 그룹 탈퇴

그룹에서 탈퇴하려면 그룹 페이지에서 **설정**을 열고 **그룹 탈퇴**를 선택하세요.

탈퇴하면 그룹 관리자가 그룹에서 제외했을 때와 마찬가지로 그룹 및 하위 그룹 접근 권한이 사라집니다.

![Oatmilk Cooperative 설정 페이지의 그룹 탈퇴 항목](member_leave_group.png)

<!-- translation-section: set-title -->

## 직함 설정

멤버의 직함은 그룹 내 역할이나 대표하는 조직을 나타냅니다. 본인이나 그룹 관리자는 **멤버** 탭에서 본인의 이름 옆에 있는 작업 메뉴의 **직함 설정**을 선택해 직함을 설정하거나 변경할 수 있습니다.

![멤버 메뉴의 직함 설정 항목](member_set_title.png)

하위 그룹마다 서로 다른 직함을 사용할 수 있습니다.

<!-- translation-section: member-email-addresses -->

## 멤버 이메일 주소

그룹 관리자만 멤버의 이메일 주소를 볼 수 있습니다.

그룹과 하위 그룹에 속한 모든 멤버의 이메일 주소를 확인하려면 [그룹 데이터를 내보내어](/en/user_manual/groups/data_export) CSV 파일로 저장한 다음 Microsoft Excel이나 Google 스프레드시트에서 여세요.

**멤버** 탭에서 이메일 주소로 멤버를 검색하여 특정 멤버를 찾고 관리할 수도 있습니다.
