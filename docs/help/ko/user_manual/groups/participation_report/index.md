---
sections:
  introduction: f5759e9db8130be6
  what-s-in-the-report: a857f9d955851358
  actions-per-month: 4b2aebb7a8d1ecae
  tag-usage: c05217a052bc0da0
  actions-per-user: '09a02dafc160037a'
  voting-record-per-user: e878e48f58f98b54
  users-per-country: 03111e1b5f9a6697
  actions-per-country: d47acd62f17f41e7
generated:
  introduction: e48478c75f2ea916
  what-s-in-the-report: a553b0f4c95f0968
  actions-per-month: ec30351f50e2672d
  tag-usage: cf72c36931f61b27
  actions-per-user: a5b513fa6034516d
  voting-record-per-user: 9e56f8d516ce38ec
  users-per-country: b3e86e600f68b249
  actions-per-country: 8d1335d181405fa2
title: 참여 보고서
title_source: ee140bf2af2bcf29
title_generated: e4082227753fba26
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/groups/participation_report/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
---

<!-- translation-section: introduction -->

# 참여 보고서

참여 보고서는 Loomio 그룹과 하위 그룹의 활동 현황을 보여줍니다.

포함할 그룹을 선택하고, 시작일과 종료일을 설정하고, 결과를 연도별, 월별, 주별 또는 일별로 집계할 수 있습니다.

그룹의 모든 멤버가 보고서를 볼 수 있지만, 각 멤버는 자신이 속한 그룹의 결과만 볼 수 있습니다. 따라서 멤버마다 합계가 다르게 표시될 수 있습니다.

보고서를 열려면 그룹의 작업 메뉴를 열고 **참여 보고서**를 선택하세요. 보고서의 모든 표에서 열 제목을 선택하면 해당 열을 기준으로 정렬할 수 있습니다.

![Oatmilk Cooperative 메뉴의 참여 보고서 항목](group_participation_report.png)

<!-- translation-section: what-s-in-the-report -->

## 보고서 내용

<!-- translation-section: actions-per-month -->

### 시간에 따른 활동

이 그래프는 선택한 각 시간 간격에 생성된 스레드, 댓글, 투표의 수와 행사된 표, 남긴 반응의 수를 보여주어 활동의 변화를 파악할 수 있습니다. 그래프에서 레이블을 선택하면 해당 지표를 숨기거나 표시할 수 있습니다.

![Oatmilk Cooperative의 참여 보고서 설정, 합계 및 활동 그래프](group_participation_report_graph.png)

<!-- translation-section: tag-usage -->

### 태그 사용 현황

이 차트는 선택한 기간 동안 태그가 얼마나 자주 적용되었는지 보여줍니다. 예를 들어 특정 결정 절차나 템플릿을 사용한 토론의 수를 확인할 수 있습니다.

![생산, 카페 협력 및 운영 태그의 시간에 따른 사용 현황](group_participation_report_tags.png)

<!-- translation-section: actions-per-user -->

### 사용자별 활동

이 표는 선택한 기간 동안 각 멤버가 생성한 스레드, 댓글, 투표의 수와 행사한 표, 남긴 반응의 수를 보여줍니다.

**대의원만**을 켜면 선택한 그룹 중 하나 이상에서 현재 대의원인 사람들만 표에 표시됩니다. 이들의 활동은 선택한 그룹 전체에 걸쳐 합산되며, 활동이 없는 대의원도 표시됩니다. CSV 다운로드에도 같은 필터가 적용됩니다.

![세 가지 참여 수준을 보여주는 대의원별 활동](group_participation_report_actions_per_user.png)

<!-- translation-section: voting-record-per-user -->

### 사용자별 투표 기록

이 표는 각 사람에게 부여된 표 수와 행사한 표 수를 비교하고, 행사하지 않은 표를 보여주며, 부여된 표를 모두 행사한 사람을 강조 표시합니다. 부여된 표가 없는 사람은 모든 표를 행사한 것으로 표시되지 않습니다. 익명 표는 개별 투표자와 연결되지 않으므로 익명 투표는 제외됩니다.

**대의원만**을 켜면 현재 대의원들의 투표 기록을 확인할 수 있습니다. CSV 다운로드에도 같은 이름 및 대의원 필터가 적용됩니다.

![부여된 표, 행사한 표 및 행사하지 않은 표를 보여주는 대의원 투표 기록](group_participation_report_voting_record.png)

<!-- translation-section: users-per-country -->

### 국가별 사용자 수

이 표는 현재 IP 주소를 기준으로 선택한 그룹의 멤버가 각 국가에 몇 명 있는지 보여줍니다.

![선택한 그룹의 국가별 사용자 수](group_participation_report_users_per_country.png)

<!-- translation-section: actions-per-country -->

### 국가별 활동

이 표는 각 멤버의 위치로 감지된 국가를 기준으로 스레드, 댓글, 투표, 표, 반응을 집계합니다.

![국가별로 집계한 활동](group_participation_report_actions_per_country.png)
