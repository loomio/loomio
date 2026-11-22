---
sections:
  introduction: ffcecd2f4297c47d
  how-anonymous-voting-protects-voters: 3b757a1b4a7bda96
  while-voting-is-open: aafc698ee8108194
  votes-cannot-be-changed: 3a99e6c3f48e10ee
  why-anonymous-votes-do-not-have-reasons: 4027d6c1fbf4d29c
  results-and-exports: 5c10ab43a5f890b4
  participation-verification: e77ece0fc0d6cd73
  reminders: f711a180ae7c948f
  what-coordinators-and-administrators-can-see: d873cd48677fc324
  limits-of-anonymous-voting: 9ab54b74a4716e19
  questions: 60cc6f1a0163ec5d
  can-a-coordinator-see-how-i-voted: bfa1baf48f41cdd1
  can-i-see-my-vote-after-submitting-it: 435010e0c2ecf488
  can-i-change-or-withdraw-my-vote: 676d5401bf4d73cc
  will-i-receive-an-email-confirming-my-vote: 9660f10e8ffb9f9c
  does-a-public-poll-reveal-more-information: '087defb00bb8b99f'
  is-anonymous-voting-suitable-for-every-election: 9fae56c0661f0ec9
generated:
  introduction: 1b6cb7fbf82cd8d9
  how-anonymous-voting-protects-voters: 78aea02493fdfd25
  while-voting-is-open: f2069edb0b5a7590
  votes-cannot-be-changed: 4e735f220657e877
  why-anonymous-votes-do-not-have-reasons: 4ab5dbde015fef23
  results-and-exports: 32dd10aab87ea995
  participation-verification: 6fcc69b60baf1e90
  reminders: eb4b0576d62ead45
  what-coordinators-and-administrators-can-see: 3ea357f846329b0b
  limits-of-anonymous-voting: 1235dc8aeb5733f8
  questions: 5f2c4011a8bebb6c
  can-a-coordinator-see-how-i-voted: 38ce18fdf902a2ad
  can-i-see-my-vote-after-submitting-it: e4517b80b8688a79
  can-i-change-or-withdraw-my-vote: d4bbba6c711e61a3
  will-i-receive-an-email-confirming-my-vote: 783b40e560cd20e9
  does-a-public-poll-reveal-more-information: '0878f7b9474247ae'
  is-anonymous-voting-suitable-for-every-election: 3d83b3d339d57d19
title: 익명 투표
title_source: 1bc4567506ad4d51
title_generated: 3e2363e2c990f607
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/polls/anonymous_voting/index.md
---

<!-- translation-section: introduction -->

# 익명 투표

블라인드 투표라고도 하는 익명 투표는 누가 투표했는지에 대한 기록을 표 자체와 분리합니다. 투표가 마감되면 결과를 볼 수 있는 사람은 누구나 누가 참여했는지 확인할 수 있지만, Loomio를 사용하는 누구도 표를 투표한 사람과 연결할 수 없습니다.

이 페이지에서는 익명 투표의 작동 방식, 보관되는 정보, 이러한 보호의 한계를 설명합니다.

<!-- translation-section: how-anonymous-voting-protects-voters -->

## 익명 투표가 투표자를 보호하는 방식

익명 투표는 다음 두 종류의 기록을 별도로 보관합니다.

| 참여 기록 | 제출된 표 |
| --- | --- |
| 투표 자격이 있는 사람 | 선택한 선택지 또는 점수 |
| 초대받은 사람과 초대한 사람 | 표가 속한 투표 |
| 투표 자격이 있는 각 사람의 투표 여부 | 이름이나 사용자 계정 없음 |
| 선택한 선택지나 점수 없음 | 참여 기록과의 연결 없음 |

이 기록들을 연결하는 공통 ID는 없습니다. 제출된 표에는 제출 시각, 초대 정보, 투표 이유, 첨부 파일, 그 밖에 투표자를 식별할 수 있는 메타데이터도 포함되지 않습니다.

이러한 분리는 표를 저장할 때 적용됩니다. 화면에서 이름을 숨기는 것에만 의존하지 않습니다.

<!-- translation-section: while-voting-is-open -->

## 투표가 진행 중일 때

투표가 마감될 때까지 결과는 스레드 관리자, 그룹 관리자, 인스턴스 관리자를 포함한 모든 사람에게 숨겨집니다.

누군가 투표하면 다음과 같이 처리됩니다.

- 표는 이름이나 참여 기록 없이 저장됩니다.
- 참여 기록에 투표를 완료했다고 표시됩니다.
- 투표 이벤트, 알림, 이메일, 댓글, 활동 기록은 생성되지 않습니다.
- 제출 후에는 선택한 내용의 사본이 반환되지 않습니다.
- 화면에는 표가 기록되었다는 사실만 표시됩니다.

참여 기록에는 투표한 정확한 시각이 저장되지 않으며, 제출된 표는 제출 시각순으로 정렬되지 않습니다.

<!-- translation-section: votes-cannot-be-changed -->

## 제출된 표는 변경할 수 없습니다

투표 자격이 있는 사람은 각자 한 번만 투표할 수 있습니다. 제출된 익명 표는 관리자도 다시 확인하거나 변경, 철회, 교체할 수 없습니다.

자신의 표를 조회하거나 교체할 수 있게 하려면 해당 사람과 표 사이에 연결이 필요합니다. 익명 투표는 의도적으로 이러한 연결을 만들지 않습니다.

제출하기 전에 선택한 내용을 꼼꼼히 확인하세요.

<!-- translation-section: why-anonymous-votes-do-not-have-reasons -->

## 익명 표에 이유가 없는 까닭

익명 표에는 투표 이유나 첨부 파일을 포함할 수 없습니다. 이유에는 이름, 개인 정보, 문체, 멘션 등 투표자를 식별할 수 있는 정보가 포함될 수 있으며, 결과에서 개별 표를 구별하기 쉽게 만들 수 있습니다.

참여자는 해당 스레드에서 계속 투표에 관해 토론할 수 있습니다. 이러한 댓글은 이름이 표시되는 일반적인 게시물이며 익명 표와 연결되지 않습니다.

<!-- translation-section: results-and-exports -->

## 결과 및 내보내기

투표가 마감되면 Loomio는 참여 기록과 분리된 표를 바탕으로 결과를 계산하고 해당 투표 유형의 합계를 표시합니다.

Loomio는 표의 ID, 제출 순서, 제출 시각을 공개하지 않습니다. 투표 내보내기에는 표마다 개별 행을 제공하는 대신 집계 결과만 포함합니다. 유일한 예외는 마감된 단기이양식 선거로, 재집계를 위해 BLT 형식으로 내보낼 수 있습니다. BLT 내보내기에는 후보자 선호 순위가 나열되며, 여러 표의 순위가 같으면 하나로 묶습니다. 투표자의 신원이나 표의 메타데이터는 포함되지 않습니다.

익명 투표는 마감 후 다시 열 수 없습니다.

<!-- translation-section: participation-verification -->

## 참여자 확인

익명 투표가 마감되면 결과를 볼 수 있는 사람은 누구나 누가 참여했는지 확인할 수 있습니다. 투표가 진행 중일 때는 누구도 이를 확인할 수 없습니다.

목록을 보려면 **표 보기**를 선택하세요. 목록에는 투표 자격이 있었던 사람이 항상 표시되며, 각 사람이 어떻게 투표했는지 또는 언제 투표했는지는 표시되지 않습니다. 각 사람의 투표 여부는 충분한 인원이 참여한 경우에만 표시됩니다. 정족수가 설정되어 있으면 정족수를 충족해야 하고, 그렇지 않으면 투표 자격이 있는 사람의 절반 이상이 투표해야 합니다. 어느 경우든 최소 3표가 필요합니다.

그룹 멤버와 해당 투표의 투표자는 각 사람이 그룹에 가입한 시점과 초대한 사람도 확인할 수 있습니다. 그룹 관리자는 이름이 같은 사람을 구별할 수 있도록 이메일 주소도 확인할 수 있습니다.

결과를 볼 수 있는 모든 사람이 누가 투표했는지도 확인할 수 있으므로, 결과가 한쪽으로만 나오면 각 사람이 어떻게 투표했는지 드러날 수 있습니다. 예를 들어 모든 표가 동의라면 투표한 모든 사람이 동의한 것입니다.

관리자는 투표가 진행 중인 동안 투표 자격이 있는 사람을 추가할 수 있습니다. 다른 사람이 이미 투표한 후에도 추가할 수 있습니다. 익명 투표에서 기존 투표자를 삭제할 수는 없습니다.

<!-- translation-section: reminders -->

## 알림

진행 기간이 24시간 이상인 익명 투표에서는 투표 자격이 있지만 아직 투표하지 않은 사람에게 마감 전 마지막 24시간 동안 자동 알림이 한 번 전송됩니다.

Loomio는 제출된 표를 확인하지 않고 참여 기록만으로 알림 대상을 선정합니다.

투표 기간이 24시간 미만인 투표에서는 이 자동 알림을 보내지 않습니다.

<!-- translation-section: what-coordinators-and-administrators-can-see -->

## 관리자가 볼 수 있는 정보

스레드 관리자, 그룹 관리자, 인스턴스 관리자는 애플리케이션을 통해 다음 정보를 볼 수 있습니다.

- 투표 및 투표 자격이 있는 사람
- 각 사람의 투표 여부(역할에 따른 접근 권한이 있고 충분한 인원이 투표한 경우)
- 투표 마감 후 집계 결과

애플리케이션으로는 다음 정보를 볼 수 없습니다.

- 특정 사람이 선택한 내용
- 개별 표 또는 투표 양상
- 표가 제출된 시각
- 표와 연결된 투표 이유, 첨부 파일, 이벤트 또는 알림

<!-- translation-section: limits-of-anonymous-voting -->

## 익명 투표의 한계

익명 투표는 Loomio 사용자가 표를 투표자와 연결하지 못하도록 합니다. 데이터베이스, 백업, 서버 로그, 프로세스 메모리, 네트워크 트래픽 또는 수정된 코드를 살펴볼 수 있는 서버 운영자를 상대로 암호학적 보호를 제공하지는 않습니다.

결과 자체에서도 단서를 얻을 수 있습니다. 그룹 규모가 작거나, 투표가 만장일치이거나, 선택지 조합이 독특하거나, 투표 외부에서 댓글이 공유되면 특정 사람이 어떻게 투표했는지 추론하기 쉬워질 수 있습니다.

애플리케이션 수준의 익명 투표에 의존하기 전에 그룹의 규모와 결정의 민감도를 고려하세요.

<!-- translation-section: questions -->

## 질문

<!-- translation-section: can-a-coordinator-see-how-i-voted -->

### 제가 어떻게 투표했는지 다른 사람이 볼 수 있나요?

아니요. Loomio를 사용하는 누구도 표를 투표한 사람과 연결할 수 없습니다. 충분한 인원이 투표하면 결과를 볼 수 있는 사람은 누구나 참여 여부를 확인할 수 있습니다. 그 기준에 도달하기 전까지는 투표 여부도 숨겨집니다.

<!-- translation-section: can-i-see-my-vote-after-submitting-it -->

### 제출한 뒤에 내 표를 확인할 수 있나요?

아니요. Loomio는 표가 기록되었음을 확인한 다음 화면에서 선택 내용을 삭제합니다. 제출한 표를 다시 불러오려면 투표자와 표를 연결해야 하지만, 익명 투표는 이러한 연결이 생기지 않도록 설계되어 있습니다.

<!-- translation-section: can-i-change-or-withdraw-my-vote -->

### 내 표를 변경하거나 철회할 수 있나요?

아니요. 투표자와 제출한 표 사이에 연결이 없으므로 Loomio는 어떤 표를 변경하거나 삭제해야 하는지 식별할 수 없습니다.

<!-- translation-section: will-i-receive-an-email-confirming-my-vote -->

### 투표 확인 이메일을 받게 되나요?

아니요. 투표하면 화면에 확인 메시지만 표시되고 참여 기록이 갱신됩니다. 이메일을 보내거나 알림 또는 활동 기록을 생성하지 않습니다.

<!-- translation-section: does-a-public-poll-reveal-more-information -->

### 공개 투표에서는 더 많은 정보가 공개되나요?

공개 투표가 마감되면 누구나 결과와 참여자를 볼 수 있습니다. 개별 표나 그룹 가입 및 초대에 관한 세부 정보는 볼 수 없습니다.

<!-- translation-section: is-anonymous-voting-suitable-for-every-election -->

### 익명 투표는 모든 선거에 적합한가요?

아니요. 익명 투표는 애플리케이션 수준에서 투표자와 표를 분리합니다. 서버 운영자로부터의 보호나 독립적인 암호학적 검증이 필요한 선거에는 해당 요구 사항에 맞게 설계된 시스템이 필요합니다.
