---
title: Requisitos de percentual de votos
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/polls/vote_share_requirements/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-29'
sections:
  introduction: c97281f29d615dea
  eligible-voters-and-votes-cast: 930bbc475f734396
  different-vote-share-requirements: 0d25794ec996d42c
  detailed-example: dc765c43a22a28a1
generated:
  introduction: 978b88fc6391b499
  eligible-voters-and-votes-cast: aa986b010f360479
  different-vote-share-requirements: 221a726a06f22841
  detailed-example: fbdf42d001a44d5d
title_source: a654891ca817844e
title_generated: 4b196ba8657cc416
---

<!-- translation-section: introduction -->

# Requisitos de percentual de votos

Defina um requisito de percentual de votos para uma opção quando uma proposta precisar receber uma porcentagem específica de apoio, ou ficar abaixo de uma porcentagem específica de oposição, para ser aprovada.

Você pode combinar requisitos de percentual de votos com um [quórum](/en/user_manual/polls/quorum/) para exigir tanto uma participação suficiente quanto uma distribuição específica dos votos.

Ao criar uma proposta, selecione o ícone de edição ao lado de uma opção.

![O ícone de edição ao lado da opção Consentimento](edit-highlight-on-option.png)

<!-- translation-section: eligible-voters-and-votes-cast -->

## Eleitores elegíveis e votos lançados

A porcentagem pode ser calculada com base em **Votos lançados** ou **Eleitores elegíveis**.

![Escolha entre votos lançados e eleitores elegíveis para calcular o requisito de percentual de votos](./eligible-vs-cast.png)

**Eleitores elegíveis** são todas as pessoas que podem votar na proposta. **Votos lançados** são apenas os votos enviados.

Um requisito de apoio de 75% dos eleitores elegíveis só é atendido quando pelo menos 75% de todas as pessoas aptas a votar escolhem essa opção.

Um requisito de apoio de 60% dos votos lançados pode ser atendido quando 60% dos votos enviados apoiam a opção, independentemente da participação total. Adicione um quórum se o seu processo também exigir um nível mínimo de participação.

<!-- translation-section: different-vote-share-requirements -->

## Requisitos diferentes de percentual de votos

Uma proposta pode ter requisitos para mais de uma opção. Por exemplo:

- A concordância deve alcançar pelo menos 75% dos eleitores elegíveis
- A abstenção não deve ultrapassar 30% dos votos lançados
- O bloqueio não deve ultrapassar 0% dos votos lançados

Você também pode adicionar requisitos a um [modelo de enquete](/en/user_manual/polls/poll_templates/) para que novas propostas criadas a partir dele usem esses requisitos por padrão.

<!-- translation-section: detailed-example -->

## Exemplo detalhado

A Cooperativa Oatmilk está decidindo se aprova o orçamento de um teste de seis semanas com garrafas retornáveis. Cinco pessoas podem votar.

Jamie usa o modelo de proposta **Consentimento**, edita a opção Consentimento e ativa o requisito de percentual de votos dessa opção.

O processo da cooperativa exige o apoio de pelo menos 75% dos eleitores elegíveis para aprovar a proposta. Jamie define o requisito como **Pelo menos 75% dos Eleitores elegíveis**.

![A opção Consentimento exige o apoio de pelo menos 75% dos eleitores elegíveis](./consent-vote-option.png)

Jamie também define um quórum de 60%. Jamie e Samira votam a favor. Todos os votos enviados apoiam a proposta, mas representam apenas 40% dos eleitores elegíveis. Portanto, nenhum dos dois requisitos foi atendido.

![Duas das cinco pessoas votaram a favor e nenhum dos requisitos foi atendido](./first-vote-breakdown.png)

Em seguida, Alex e Morgan votam a favor, enquanto Taylor vota contra. As cinco pessoas votaram, atingindo o quórum, e quatro dos cinco eleitores elegíveis apoiam a proposta. Esse apoio de 80% supera o requisito de 75%, então os dois requisitos exibem marcas de verificação verdes.

![As cinco pessoas votaram e os dois requisitos foram atendidos](./final-vote-breakdown.png)
