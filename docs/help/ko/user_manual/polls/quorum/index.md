---
sections:
  introduction: dbfdebe6e23060db
  example-scenario: d247e0866095c321
  overview-and-examples: 9097cf14e7f9bd68
generated:
  introduction: '038ef13d1764d1d0'
  example-scenario: 46ff6f7aeea0ca09
  overview-and-examples: 3504a8dbb738e877
title: 정족수
title_source: 18ed8b6c5ab90343
title_generated: 0c00db34647264a6
source_revision: 82853c73875ee63265d588fc0dae6eafffa81b41
source_file: docs/help/en/user_manual/polls/quorum/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-12'
---

<!-- translation-section: introduction -->

# 정족수

정족수는 투표가 유효하려면 투표 자격이 있는 사람 중 최소한 참여해야 하는 비율입니다. 운영 절차상 일정 수준의 참여가 필요할 때 사용하세요.

[가중 투표](/en/user_manual/polls/weighted_voting)에서는 투표 가중치를 기준으로 정족수를 계산합니다. 예를 들어 Jamie의 투표 가중치가 `2`, Samira의 투표 가중치가 `1`, Alex의 투표 가중치가 `1`이라고 가정합니다. Jamie만 투표하면 투표 자격이 있는 사람들의 전체 투표 가중치 중 절반이 참여한 것입니다. Samira도 투표하면 참여율이 75퍼센트에 도달하여 60퍼센트 정족수를 충족합니다.

투표를 만들 때 **추가 설정**을 여세요. **정족수**에 필요한 비율을 입력하세요. 정족수가 필요하지 않으면 입력란을 비워 두세요.

![참여율 정족수를 60퍼센트로 설정한 정족수 설정](./quorum-section.png)

[투표 템플릿](/en/user_manual/polls/poll_templates/)에도 정족수를 설정할 수 있습니다. 그러면 해당 템플릿으로 만든 투표에 기본으로 적용됩니다.

<!-- translation-section: example-scenario -->

## 예시 상황

Oatmilk 협동조합은 6주간 진행할 회수용 병 시범 운영을 토론하고 있습니다. 토론이 진행되어 이제 협동조합에서 시범 운영 예산을 승인해야 하는 단계입니다.

Jamie는 **투표 시작**을 선택하고 **이의 없음** 제안 템플릿을 고른 다음 제목, 세부 내용, 선택지, 기간, 투표자 설정을 완료합니다.

![제안의 제목, 세부 내용, 선택지, 기간, 투표자 설정](proposal-options.png)

Jamie는 시범 운영 예산을 담당하는 다섯 명만 투표할 수 있도록 제한합니다.

협동조합은 중요한 결정에 60퍼센트의 참여를 요구하므로 Jamie는 **정족수**에 **60**을 입력하고 제안을 시작합니다.

아직 아무도 투표하지 않은 상태에서는 결과 패널에 정족수가 충족되지 않았다고 표시됩니다.

![아직 아무도 투표하지 않아 60퍼센트 정족수가 충족되지 않은 상태](pie-chart-0.png)

Jamie는 동의에, Samira는 반대에 투표합니다. 차트가 업데이트되지만 투표 자격이 있는 다섯 명 중 두 명만 참여하여 참여율이 40퍼센트이므로 여전히 정족수를 충족하지 못합니다.

![다섯 명 중 두 명이 투표하여 정족수가 아직 충족되지 않은 상태](pie-chart-40.png)

이어서 Alex가 동의에 투표합니다. 투표 자격이 있는 다섯 명 중 세 명이 참여하여 60퍼센트 정족수를 충족합니다. 이제 정족수 요건 옆에 녹색 체크 표시가 나타납니다. Jamie는 투표를 조기에 마감하거나 나머지 투표자들을 기다릴 수 있습니다.

![다섯 명 중 세 명이 투표하여 60퍼센트 정족수가 충족된 상태](pie-chart-60.png)

<!-- translation-section: overview-and-examples -->

## 개요 및 예시

개요와 예시는 [Loomio의 정족수](https://www.loomio.com/features/quorum/)를 참고하세요.
