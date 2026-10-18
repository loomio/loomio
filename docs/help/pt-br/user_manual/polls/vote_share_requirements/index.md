---
title: Requisitos de percentual de votos
source_revision: c6076258c3438c0dd6dc8fbf1fc0b0df47c0aeb5
source_file: docs/en/user_manual/polls/vote_share_requirements/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: 57d7127721bebf93
  eligible-voters-and-votes-cast: 930bbc475f734396
  different-vote-share-requirements: cfdfd13a0a6a8b38
  detailed-example: 395dbccb0e6427fc
generated:
  introduction: 1fe00d5014b7f234
  eligible-voters-and-votes-cast: c586a145a40e8c35
  different-vote-share-requirements: 732924676a1cb15a
  detailed-example: 223a7a2e2eb8d822
title_source: a654891ca817844e
title_generated: 4b196ba8657cc416
---

<!-- translation-section: introduction -->

# Requisitos de percentual de votos

Defina um requisito de percentual de votos para uma opção quando uma proposta precisar receber um determinado percentual de apoio, ou ficar abaixo de um determinado percentual de oposição, para ser aprovada.

Os requisitos de percentual de votos podem ser combinados com um [quórum](/en/user_manual/polls/quorum/) para exigir tanto uma participação suficiente quanto uma determinada distribuição dos votos.

No formulário da proposta, selecione o ícone de edição ao lado de uma opção.

![O ícone de edição ao lado da opção Concordo](edit-highlight-on-option.png)

<!-- translation-section: eligible-voters-and-votes-cast -->

## Eleitores elegíveis e votos lançados

O percentual pode se basear em **Votos lançados** ou **Eleitores elegíveis**.

![Escolha entre votos lançados e eleitores elegíveis como base para um requisito de percentual de votos](./eligible-vs-cast.png)

**Eleitores elegíveis** são todas as pessoas que podem votar na proposta. **Votos lançados** são apenas os votos que foram enviados.

Uma proposta com um requisito de 75 por cento de concordância entre os eleitores elegíveis só pode ser aprovada quando pelo menos 75 por cento de todos os eleitores elegíveis votarem nessa opção.

Uma proposta com um requisito de 60 por cento de concordância entre os votos lançados pode ser aprovada quando 60 por cento dos votos enviados apoiarem a opção, independentemente da participação total. Adicione um quórum quando seu processo também exigir um nível mínimo de participação.

<!-- translation-section: different-vote-share-requirements -->

## Diferentes requisitos de percentual de votos

Uma proposta pode ter requisitos para mais de uma opção. Por exemplo:

- A concordância deve corresponder a pelo menos 75 por cento dos eleitores elegíveis
- A abstenção deve corresponder a no máximo 30 por cento dos votos lançados
- O bloqueio deve corresponder a no máximo 0 por cento dos votos lançados

Definir uma opção como **No máximo 0%** é uma prática comum. Isso significa que a proposta não pode ser aprovada se alguém escolher essa opção. Use esse requisito em **Bloqueio** para que um único bloqueio impeça a aprovação da proposta.

Você também pode adicionar requisitos a um [modelo de enquete](/en/user_manual/polls/poll_templates/) para que novas propostas criadas a partir do modelo os usem por padrão.

<!-- translation-section: detailed-example -->

## Exemplo detalhado

A Cooperativa Oatmilk está decidindo se deve realizar um teste de seis semanas com garrafas retornáveis. Cinco pessoas podem votar.

O processo da cooperativa exige que pelo menos 75 por cento dos eleitores elegíveis concordem. Jamie edita a opção **Concordar** da proposta, ativa seu requisito de percentual de votos e o define como **Pelo menos 75% dos Eleitores elegíveis**.

![A opção Concordo exigindo pelo menos 75 por cento dos eleitores elegíveis](./agree-vote-option.png)

Jamie também define um quórum de 60 por cento. Jamie e Samira votam em Concordo. Todos os votos enviados apoiam a proposta, mas representam apenas 40 por cento dos eleitores elegíveis, então nenhum dos requisitos foi atendido.

![Duas das cinco pessoas votaram em Concordo e nenhum dos requisitos foi atendido](./first-vote-breakdown.png)

Alex e Morgan também votam em Concordo, enquanto Taylor vota em Discordo. Todas as cinco pessoas votaram, atingindo o quórum, e quatro dos cinco eleitores elegíveis concordam. A concordância de 80 por cento supera o requisito de percentual de votos de 75 por cento, então os dois requisitos exibem marcas de verificação verdes.

![Todas as cinco pessoas votaram e os dois requisitos foram atendidos](./final-vote-breakdown.png)
