---
sections:
  introduction: f216b18771a2c2a9
  administering-your-group: 27aed40959adef57
  managing-subgroups: 915e13a928a8f4aa
  removing-members: f40c25fd90ab1ce2
  leaving-group: 11b09b4af23b4e7e
  set-title: 835b25d246477b4a
  member-email-addresses: cae570f30b671275
generated:
  introduction: 6800aa7a10f66d02
  administering-your-group: 703ab93028472f1e
  managing-subgroups: 5f4f6f78c1ac15e1
  removing-members: 8cd61b2f7721384c
  leaving-group: e582e71dfa14a043
  set-title: 9bbba09f4a703515
  member-email-addresses: d476ac0d60f9b4bd
title: 멤버 관리
title_source: 23ac3a7fe9ee72a2
title_generated: 18362c237b482d80
source_revision: 5d6c305d2dfb5c47f5a90b1c1e6658ca352d88f5
source_file: docs/help/en/user_manual/groups/member_management/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-09'
---

<!-- translation-section: introduction -->

# 멤버 관리

그룹 관리자는 그룹 페이지의 **멤버** 탭에서 멤버를 관리할 수 있습니다.

그룹 멤버 오른쪽에 있는 점 세 개(**⋮**)를 클릭하면 직함을 설정하거나, 그룹 관리자 또는 대리인으로 지정하거나, 그룹에서 제외할 수 있습니다.

![Oatmilk Cooperative 멤버 페이지의 멤버 작업 메뉴](member_management.png)

<!-- translation-section: administering-your-group -->

## 그룹 관리
Loomio 그룹에는 **멤버**와 **그룹 관리자**, 두 가지 사용자 유형만 있습니다.

그룹 관리자는 멤버 추가 및 제외, 멤버 권한 관리, 그룹 공개 범위 설정, 구독 요금제 관리 등의 관리 업무를 수행합니다. 또한 멤버의 이메일 주소를 확인하고 그룹 데이터를 내보낼 수 있습니다.

새 Loomio 그룹을 만든 사람은 기본적으로 그룹 관리자가 됩니다. 항상 그룹을 관리할 사람이 있도록 그룹 내에서 신뢰할 수 있는 다른 사람을 한 명 이상 그룹 관리자로 지정하는 것을 권장합니다. 그룹 관리자 수에는 제한이 없습니다.

멤버를 **그룹 관리자**로 지정하려면 멤버 탭에서 해당 멤버를 찾아 이름 옆의 점 세 개(**⋮**)를 클릭하세요. **관리자 지정**을 선택하세요. 이름 옆에 `Admin` 태그가 표시됩니다.

![멤버 메뉴의 관리자 지정 항목](member_make_admin.png)

<!-- translation-section: managing-subgroups -->

## 하위 그룹 관리
상위 그룹의 그룹 관리자는 비밀 하위 그룹을 제외한 모든 하위 그룹에 가입한 후 자신을 해당 하위 그룹의 그룹 관리자로 지정할 수 있습니다.

하위 그룹 페이지에서 **그룹 가입**을 선택하세요.

![Oatmilk Cooperative 비공개 하위 그룹의 그룹 가입 버튼](member_join_subgroup.png)

하위 그룹에 가입하면 다른 사람을 그룹 관리자로 지정할 때와 같은 방법으로 자신을 해당 하위 그룹의 그룹 관리자로 지정할 수 있습니다.

>[!Note]
>이 권한은 [**비밀** 하위 그룹](/en/user_manual/groups/subgroups/?highlight=secret#permissions)에는 적용되지 않습니다.

<!-- translation-section: removing-members -->

## 멤버 제외
**그룹에서 제외**를 클릭하면 제외 여부를 확인하는 메시지가 표시됩니다. 제외된 사용자는 더 이상 그룹 페이지, 스레드, 투표 또는 제안에 접근할 수 없습니다. 그룹 활동에 관한 이메일이나 알림도 더 이상 받지 않습니다. 다만 해당 사용자가 작성한 댓글과 행사한 표는 그대로 유지됩니다.

![멤버 메뉴의 그룹에서 제외 항목](member_remove.png)

그룹에서 제외되면 해당 그룹의 하위 그룹에서도 제외됩니다. 비공개 투표는 해당 사용자의 대시보드와 투표 목록에서 사라집니다. 공개 투표는 계속 읽을 수 있지만, 이전 멤버는 다시 초대받기 전까지 투표할 수 없습니다. 투표가 마감된 상태에서 그룹을 탈퇴한 경우에도 해당 투표를 다시 열면 투표 권한이 유지되지 않습니다.

제외한 멤버는 나중에 그룹에 다시 추가할 수 있습니다. 다시 가입하면 페이지를 새로고침하지 않아도 접근 권한과 진행 중인 투표에서 행사한 기존 표가 복원됩니다.

<!-- translation-section: leaving-group -->

## 그룹 탈퇴
그룹에서 탈퇴하려면 그룹 페이지에서 점 세 개 메뉴를 열고 **그룹 탈퇴**를 클릭하세요.

탈퇴하면 그룹 관리자가 그룹에서 제외했을 때와 마찬가지로 그룹 및 하위 그룹 접근 권한이 사라지며, 대시보드와 투표 목록에서 비공개 투표가 제거됩니다.

![Oatmilk Cooperative 설정 메뉴의 그룹 탈퇴 항목](member_leave_group.png)

<!-- translation-section: set-title -->

## 직함 설정
멤버 탭에서 **직함**을 사용해 그룹 내 역할이나 대표하는 조직을 표시할 수 있습니다. 본인이나 그룹 관리자는 이름 옆의 점 세 개 메뉴에서 **직함 설정**을 선택해 직함을 변경할 수 있습니다.

![멤버 메뉴의 직함 설정 항목](member_set_title.png)

하위 그룹마다 서로 다른 직함을 사용할 수 있습니다.

<!-- translation-section: member-email-addresses -->

## 멤버 이메일 주소

그룹 관리자만 그룹 멤버의 이메일 주소를 볼 수 있습니다. 그룹의 멤버 현황을 점검할 때 이메일 주소 확인이 필요한 경우가 있습니다.

멤버의 이메일 주소를 보려면 [데이터 내보내기](/en/user_manual/groups/data_export/)를 사용해 CSV 파일을 다운로드한 다음 Excel이나 Google 스프레드시트에서 파일을 여세요.

내보낸 그룹 데이터 파일에는 모든 하위 그룹에 속한 각 멤버와 해당 이메일 주소가 표시됩니다.

멤버 탭에서 이메일 주소로 멤버를 검색할 수도 있습니다. 제외하려는 멤버가 있으면 이메일 주소로 검색해 제외할 수 있습니다.
