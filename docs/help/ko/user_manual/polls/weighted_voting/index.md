---
sections:
  introduction: d1b37bf68148b2a5
  set-members-vote-weights: 47b8d7c9222794d8
  use-weighted-voting-in-a-poll: 1cc0b5130642217b
  results: a0eeeda5a9e70a97
generated:
  introduction: c16e364748c49214
  set-members-vote-weights: a773e944a6a1f22c
  use-weighted-voting-in-a-poll: 8a771d5d5bf153ed
  results: c6071db573adc469
title: 가중 투표
title_source: 0b971991dfcacbab
title_generated: 2f10f1e6de83dcd5
source_revision: 5d6c305d2dfb5c47f5a90b1c1e6658ca352d88f5
source_file: docs/help/en/user_manual/polls/weighted_voting/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-09'
---

<!-- translation-section: introduction -->

# 가중 투표

가중 투표에서는 일부 표가 다른 표보다 더 크게 반영됩니다. 각 투표자에게는 투표 가중치가 있습니다. 예를 들면 다음과 같습니다.

- 주거 공동체에서 각 주택에 한 표씩 부여합니다. 주택 세 채를 대표하는 멤버의 투표 가중치는 `3`입니다.
- 노동자 협동조합에서 가입 후 정해진 기간이 지나면 투표권을 부여합니다. 신규 멤버에게는 투표 가중치 `0`을 부여하여, 결과에 영향을 주지 않으면서 토론에 참여하고 투표 과정을 경험할 수 있도록 합니다.
- 회사에서 주주의 지분에 따라 표를 부여합니다. 주식의 12.5%를 보유한 사람의 투표 가중치는 `12.5`입니다.

<!-- translation-section: set-members-vote-weights -->

## 멤버의 투표 가중치 설정

그룹 관리자는 그룹의 **멤버** 페이지에서 **표 가중치 편집**을 선택할 수 있습니다. 투표 가중치를 입력하고 **표 가중치 저장**을 선택하세요. 투표 가중치는 `0` 이상이어야 하며 소수점 이하 세 자리까지 입력할 수 있습니다. 이름이나 이메일로 멤버를 검색하세요. 모든 멤버에게 같은 투표 가중치를 부여하려면 **전체 표 가중치 설정**을 선택하세요.

![그룹 멤버의 투표 가중치](member-weights.png)

멤버의 투표 가중치는 해당 멤버가 추가되는 각 투표에 복사됩니다. 나중에 가중치를 변경해도 이미 복사된 투표의 가중치는 변경되지 않습니다.

<!-- translation-section: use-weighted-voting-in-a-poll -->

## 투표에서 가중 투표 사용

투표 양식에서 **추가 설정**을 열고 **가중 투표 사용**을 선택하세요. 투표가 시작된 후에도 가중 투표를 켜거나 끌 수 있습니다. 가중 투표를 끄면 해당 투표의 모든 투표 가중치가 `1`로 설정되며, 해당 투표에서 변경한 투표 가중치는 사라집니다.

그룹에서 정해진 절차에 가중 투표를 사용한다면 [투표 템플릿](/en/user_manual/polls/poll_templates)에서 **가중 투표 사용**을 선택하세요. 해당 템플릿으로 시작한 투표에는 가중 투표가 적용됩니다.

![투표의 가중 투표 사용 설정](poll-setting.png)

가중 투표는 다음 투표 유형에서 사용할 수 있습니다. [제안](/en/user_manual/polls/proposals), [선택](/en/user_manual/polls/choose), [점수](/en/user_manual/polls/score), [배분](/en/user_manual/polls/allocate), [순위](/en/user_manual/polls/rank).

같은 투표에서 가중 투표와 [익명 투표](/en/user_manual/polls/anonymous_voting)를 함께 사용할 수는 없습니다.

한 투표자의 투표 가중치를 변경하려면 **투표자 관리**를 선택한 다음 이름 옆의 투표 가중치를 선택하세요. 모든 투표자의 가중치를 변경하려면 **전체 표 가중치 설정**을 선택하세요. 그룹에서 각 멤버의 투표 가중치를 복사하거나 모두에게 같은 값을 부여할 수 있습니다. 그룹 멤버가 아닌 투표자에게는 투표 가중치 `1`이 부여됩니다.

![투표의 투표자 관리 버튼](poll-manage-voters.png)

![개별 투표 가중치가 설정된 투표자](poll-voter-weights.png)

<!-- translation-section: results -->

## 결과

결과에는 가중치를 적용하지 않은 합계와 가중치를 적용한 합계가 나란히 표시됩니다.

- 제안 및 선택 투표에는 **표 수**와 **가중 표**가 표시됩니다.
- 점수, 배분 및 순위 투표에는 **점수**와 **가중 점수**가 표시됩니다.

차트에는 가중치를 적용한 결과가 표시됩니다. 다른 열의 내용을 차트로 보려면 해당 열의 제목을 선택하세요. 표를 볼 수 있는 사람은 각 투표자의 투표 가중치도 볼 수 있습니다.

제안 및 선택 투표에서 **미투표** 항목은 **표 수** 열에 아직 투표하지 않은 투표자 수를, **가중 표** 열에 아직 행사되지 않은 투표 가중치를 표시합니다. 이 두 열과 **투표 가능한 가중치 대비 비율(%)**을 선택하면 아직 투표하지 않은 사람도 차트에 포함됩니다. **행사된 투표 가중치 대비 비율(%)**을 선택하면 **미투표** 항목이 빈칸으로 표시되며 차트에서도 제외됩니다.

투표 가중치는 [정족수](/en/user_manual/polls/quorum)와 [득표율 요건](/en/user_manual/polls/vote_share_requirements)에도 적용됩니다.

아래 예시에서 Jamie는 가중치 `2`로 **동의**에 투표합니다. 세 명은 각각 가중치 `1`, `0`, `0`으로 **반대**에 투표합니다. 가중치가 각각 `2`와 `1`인 두 명은 아직 투표하지 않았습니다.

동의는 행사된 네 표 중 한 표를 얻었지만, 행사된 투표 가중치의 3분의 2를 차지합니다. 투표 가능한 전체 가중치의 절반이 참여했으므로 정족수 60%에는 도달하지 못했습니다.

![표 수와 가중 표가 표시된 제안 결과](weighted-proposal-result.png)
