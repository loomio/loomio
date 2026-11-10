---
sections:
  introduction: 57d7127721bebf93
  eligible-voters-and-votes-cast: 2cf6ad55d557c189
  different-vote-share-requirements: 0e81fb881e5c113e
  detailed-example: 395dbccb0e6427fc
generated:
  introduction: 7614791dbc39b7f8
  eligible-voters-and-votes-cast: d8f0f97bed36fbc1
  different-vote-share-requirements: 34c0cc7e71eeda5c
  detailed-example: c85a6fb8eac8b3b9
title: 득표율 요건
title_source: a654891ca817844e
title_generated: bf76eecf7222a9ec
source_revision: 5d6c305d2dfb5c47f5a90b1c1e6658ca352d88f5
source_file: docs/help/en/user_manual/polls/vote_share_requirements/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-09'
---

<!-- translation-section: introduction -->

# 득표율 요건

제안이 통과하려면 지지 비율이 일정 수준 이상이거나 반대 비율이 일정 수준 이하여야 하는 경우, 선택지에 득표율 요건을 설정하세요.

득표율 요건을 [정족수](/en/user_manual/polls/quorum/)와 함께 사용하면 충분한 참여와 특정한 표 분포를 모두 요구할 수 있습니다.

제안 양식에서 선택지 옆의 편집 아이콘을 선택하세요.

![동의 선택지 옆의 편집 아이콘](edit-highlight-on-option.png)

<!-- translation-section: eligible-voters-and-votes-cast -->

## 투표권이 있는 투표자와 투표한 표

비율은 **투표한 표** 또는 **투표권이 있는 투표자**를 기준으로 정할 수 있습니다.

![득표율 요건의 기준으로 투표한 표 또는 투표권이 있는 투표자 선택](./eligible-vs-cast.png)

**투표권이 있는 투표자**는 해당 제안에 투표할 수 있는 모든 사람을 뜻합니다. **투표한 표**는 제출된 표만을 뜻합니다.

투표권이 있는 투표자의 75%가 동의해야 한다는 요건은 전체 투표권이 있는 투표자 중 최소 75%가 해당 선택지에 투표해야 충족됩니다.

투표한 표의 60%가 동의해야 한다는 요건은 전체 참여율과 관계없이 제출된 표의 60%가 해당 선택지를 지지하면 충족됩니다. 절차상 최소 참여율도 필요하다면 정족수를 추가하세요.

[가중 투표](/en/user_manual/polls/weighted_voting)에서는 두 기준 모두 가중치를 사용합니다. **투표한 표의 가중치**는 투표한 모든 표의 가중치 합계를 기준으로 해당 선택지에 투표한 표의 가중치 합계가 차지하는 비율을 계산합니다. **투표 가능한 표의 가중치**는 아직 투표하지 않은 사람을 포함하여 투표권이 있는 모든 투표자의 가중치 합계를 기준으로 해당 선택지를 고른 투표자의 가중치 합계가 차지하는 비율을 계산합니다. 예를 들어 투표 가능한 표의 가중치 합계가 100이고 한 사람의 투표 가중치가 70이면, 그 한 사람만으로도 투표 가능한 표의 가중치를 기준으로 한 60% 동의 요건을 충족할 수 있습니다.

<!-- translation-section: different-vote-share-requirements -->

## 선택지별 득표율 요건

하나의 제안에서 여러 선택지에 요건을 설정할 수 있습니다. 예를 들면 다음과 같습니다.

- 동의는 투표권이 있는 투표자의 75% 이상이어야 합니다.
- 기권은 투표한 표의 30% 이하여야 합니다.
- 거부는 투표한 표의 0% 이하여야 합니다.

선택지에 **0% 이하**를 설정하는 방식이 흔히 사용됩니다. 누구든 해당 선택지를 고르면 제안이 통과할 수 없다는 뜻입니다. **거부**에 이 요건을 적용하면 거부가 한 표만 있어도 제안이 통과하지 못합니다.

가중 투표에서는 투표 가중치가 양수인 거부 표만 0% 요건을 초과합니다. 가중치가 `0`인 거부 표는 결과에 가중치를 더하지 않습니다.

[투표 템플릿](/en/user_manual/polls/poll_templates/)에도 요건을 추가할 수 있습니다. 그러면 해당 템플릿으로 만든 새 제안에 이 요건이 기본으로 적용됩니다.

<!-- translation-section: detailed-example -->

## 자세한 예시

Oatmilk 협동조합은 6주 동안 회수형 병을 시범 운영할지 결정하고 있습니다. 투표권이 있는 사람은 다섯 명입니다.

협동조합의 절차에 따르면 투표권이 있는 투표자의 최소 75%가 동의해야 합니다. Jamie는 제안의 **동의** 선택지를 편집하여 득표율 요건을 활성화하고 **투표권이 있는 투표자의 75% 이상**으로 설정합니다.

![투표권이 있는 투표자의 최소 75%를 요구하는 동의 선택지](./agree-vote-option.png)

Jamie는 정족수도 60%로 설정합니다. Jamie와 Samira가 동의에 투표합니다. 제출된 표는 모두 제안을 지지하지만, 투표권이 있는 투표자의 40%에 불과하므로 두 요건 모두 충족되지 않았습니다.

![다섯 명 중 두 명이 동의에 투표했으며 두 요건 모두 충족되지 않은 상태](./first-vote-breakdown.png)

이후 Alex와 Morgan은 동의에, Taylor는 반대에 투표합니다. 다섯 명 모두 투표하여 정족수를 충족했고, 투표권이 있는 다섯 명 중 네 명이 동의했습니다. 동의 비율 80%가 득표율 요건인 75%를 초과하므로 두 요건 모두에 초록색 확인 표시가 나타납니다.

![다섯 명 모두 투표했으며 두 요건 모두 충족된 상태](./final-vote-breakdown.png)
