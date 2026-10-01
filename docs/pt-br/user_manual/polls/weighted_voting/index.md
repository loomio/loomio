---
sections:
  introduction: 301b7440aa148d0b
  set-members-vote-weights: 47b8d7c9222794d8
  use-weighted-voting-in-a-poll: d8af319ed1e38e4d
  results: 3cd10f104ced0ed5
generated:
  introduction: fd27ba4fac4bc54e
  set-members-vote-weights: f94ec00f2d3266dd
  use-weighted-voting-in-a-poll: 54fedb127a3c2676
  results: ad8a3e01df327144
title: Votação ponderada
title_source: 0b971991dfcacbab
title_generated: 217338839311fe74
source_revision: c6076258c3438c0dd6dc8fbf1fc0b0df47c0aeb5
source_file: docs/en/user_manual/polls/weighted_voting/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
---

<!-- translation-section: introduction -->

# Votação ponderada

A votação ponderada permite que alguns votos contem mais do que outros. Cada eleitor tem um peso do voto. Por exemplo:

- Uma comunidade residencial atribui um voto a cada imóvel. Um membro que representa três imóveis tem um peso do voto de `3`.
- O conselho de uma cooperativa toma a decisão, mas a equipe de operações participa da conversa. Os membros do conselho têm um peso do voto de `1`. As pessoas da equipe de operações têm um peso do voto de `0`, portanto seus votos são registrados, mas não alteram o resultado.
- Uma empresa atribui votos aos acionistas de acordo com sua participação no capital. Uma pessoa que possui 12,5% das ações tem um peso do voto de `12.5`.

<!-- translation-section: set-members-vote-weights -->

## Defina os pesos de voto dos membros

Um admin do grupo pode abrir a página **Membros** do grupo e selecionar **Editar pesos de voto**. Insira os pesos de voto e selecione **Salvar pesos de voto**. Os pesos de voto podem ser `0` ou mais, com até três casas decimais. Busque por nome ou email para encontrar alguém. Para atribuir o mesmo peso do voto a todos os membros, selecione **Defina todos os pesos de voto**.

![Pesos de voto dos membros do grupo](member-weights.png)

O peso do voto de um membro é copiado para cada enquete à qual ele é adicionado. Alterá-lo depois não altera as enquetes que já receberam esse peso.

<!-- translation-section: use-weighted-voting-in-a-poll -->

## Use votação ponderada em uma enquete

Selecione **Usar votação ponderada** nas configurações avançadas da enquete. Você pode ativar ou desativar essa opção depois que a votação começar. Desativá-la define todos os pesos de voto da enquete como `1`, e quaisquer pesos de voto que você tenha alterado nessa enquete são perdidos.

Se seu grupo usa votação ponderada em um processo estabelecido, selecione **Usar votação ponderada** em um [modelo de enquete](/en/user_manual/polls/poll_templates). As enquetes iniciadas a partir desse modelo usam votação ponderada.

![A configuração Usar votação ponderada em uma enquete](poll-setting.png)

A votação ponderada funciona com estes tipos de enquete: [Proposta](/en/user_manual/polls/proposals), [Escolher](/en/user_manual/polls/choose), [Pontuar](/en/user_manual/polls/score), [Distribuir](/en/user_manual/polls/allocate) e [Classificar](/en/user_manual/polls/rank).

Você não pode usar votação ponderada e [votação anônima](/en/user_manual/polls/anonymous_voting) na mesma enquete.

Para alterar o peso do voto de um eleitor, selecione **Gerenciar eleitores** e depois selecione o peso do voto ao lado do nome dele. Para alterar o peso de todos, selecione **Defina todos os pesos de voto**. Você pode copiar do grupo o peso do voto de cada membro ou atribuir o mesmo valor a todos. Os eleitores que não são membros do grupo recebem um peso do voto de `1`.

![O botão Gerenciar eleitores em uma enquete](poll-manage-voters.png)

![Eleitores em uma enquete com pesos de voto individuais](poll-voter-weights.png)

<!-- translation-section: results -->

## Resultados

Os resultados mostram os totais sem ponderação e os totais ponderados lado a lado:

- As enquetes dos tipos Proposta e Escolher mostram **Votos** e **Votos ponderados**.
- As enquetes dos tipos Pontuar, Distribuir e Classificar mostram **Pontos** e **Pontos ponderados**.

O gráfico mostra o resultado ponderado. Selecione o cabeçalho de uma coluna para mostrar os dados dessa coluna no gráfico. A contagem de eleitores aptos a votar e o quórum consideram pessoas, não pesos de voto. Qualquer pessoa que possa ver os votos pode ver o peso do voto de cada eleitor.

![Resultado de uma proposta com votos e votos ponderados](weighted-proposal-result.png)
