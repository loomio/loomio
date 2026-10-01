---
sections:
  introduction: 301b7440aa148d0b
  set-members-vote-weights: 47b8d7c9222794d8
  use-weighted-voting-in-a-poll: d8af319ed1e38e4d
  results: 3cd10f104ced0ed5
generated:
  introduction: e72130c08876d6ba
  set-members-vote-weights: '09adb080dd403485'
  use-weighted-voting-in-a-poll: 8b38429f09a39a32
  results: 72089c6580984bfb
title: Votação ponderada
title_source: 0b971991dfcacbab
title_generated: 217338839311fe74
source_revision: 9c60c42fc739483fa23f15d9f34a1e9245518092
source_file: docs/en/user_manual/polls/weighted_voting/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
---

<!-- translation-section: introduction -->

# Votação ponderada

A votação ponderada permite que alguns votos contem mais do que outros. Cada eleitor tem um peso de voto. Por exemplo:

- Uma comunidade habitacional atribui um voto a cada imóvel. Um membro que representa três imóveis tem um peso de voto de `3`.
- O conselho de uma cooperativa toma a decisão, mas a equipe operacional participa da conversa. Os membros do conselho têm um peso de voto de `1`. As pessoas da equipe operacional têm um peso de voto de `0`, então seus votos são registrados, mas não alteram o resultado.
- Uma empresa atribui votos aos acionistas de acordo com sua participação acionária. Uma pessoa que possui 12,5% das ações tem um peso de voto de `12.5`.

<!-- translation-section: set-members-vote-weights -->

## Defina os pesos de voto dos membros

Um administrador do grupo pode abrir a página **Membros** do grupo e selecionar **Editar pesos de voto**. Insira os pesos de voto e selecione **Salvar pesos de voto**. Os pesos de voto podem ser `0` ou mais, com até três casas decimais. Pesquise por nome ou e-mail para encontrar alguém. Para atribuir o mesmo peso de voto a todos os membros, selecione **Defina todos os pesos de voto**.

![Pesos de voto dos membros do grupo](member-weights.png)

O peso de voto de um membro é copiado para cada enquete à qual ele é adicionado. Alterá-lo depois não modifica as enquetes que já receberam esse peso.

<!-- translation-section: use-weighted-voting-in-a-poll -->

## Use votação ponderada em uma enquete

Selecione **Usar votação ponderada** nas configurações avançadas da enquete. Você pode ativar ou desativar essa opção após o início da votação. Desativá-la define todos os pesos de voto da enquete como `1`, e quaisquer pesos de voto que você tenha alterado nessa enquete são perdidos.

Se seu grupo usa votação ponderada em um processo estabelecido, selecione **Usar votação ponderada** em um [modelo de enquete](/en/user_manual/polls/poll_templates). As enquetes iniciadas a partir desse modelo usam votação ponderada.

![A configuração Usar votação ponderada em uma enquete](poll-setting.png)

A votação ponderada funciona com estes tipos de enquete: [Proposta](/en/user_manual/polls/proposals), [Escolher](/en/user_manual/polls/choose), [Pontuação](/en/user_manual/polls/score), [Alocar](/en/user_manual/polls/allocate) e [Classificação](/en/user_manual/polls/rank).

Você não pode usar votação ponderada e [votação anônima](/en/user_manual/polls/anonymous_voting) na mesma enquete.

Para alterar o peso de voto de um eleitor, selecione **Gerenciar eleitores** e depois selecione o peso de voto ao lado do nome dele. Para alterar os pesos de todos, selecione **Defina todos os pesos de voto**. Você pode copiar o peso de voto de cada membro do grupo ou atribuir o mesmo valor a todos. Eleitores que não são membros do grupo recebem um peso de voto de `1`.

![O botão Gerenciar eleitores em uma enquete](poll-manage-voters.png)

![Eleitores em uma enquete com pesos de voto individuais](poll-voter-weights.png)

<!-- translation-section: results -->

## Resultados

Os resultados mostram os totais sem ponderação e os totais ponderados lado a lado:

- Enquetes dos tipos Proposta e Escolher mostram **Votos** e **Votos ponderados**.
- Enquetes dos tipos Pontuação, Alocar e Classificação mostram **Pontos** e **Pontos ponderados**.

O gráfico mostra o resultado ponderado. Selecione o cabeçalho de uma coluna para mostrar os dados dessa coluna no gráfico. A contagem de eleitores elegíveis e o quórum consideram pessoas, não pesos de voto. Qualquer pessoa que possa ver os votos pode ver o peso de voto de cada eleitor.

![O resultado de uma proposta com votos e votos ponderados](weighted-proposal-result.png)
