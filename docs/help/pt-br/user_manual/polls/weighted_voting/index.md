---
sections:
  introduction: 566ce8dda668a638
  set-members-vote-weights: 2a3d29ebb9840017
  use-weighted-voting-in-a-poll: feddef738da4567d
  results: ab86e178359702a0
generated:
  introduction: 16977f9bd761517a
  set-members-vote-weights: 3cf52eb56e817b15
  use-weighted-voting-in-a-poll: 3184b26c0ac4e5a3
  results: 723e48a147ff32bc
title: Votação ponderada
title_source: 0b971991dfcacbab
title_generated: 217338839311fe74
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/polls/weighted_voting/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
---

<!-- translation-section: introduction -->

# Votação ponderada

A votação ponderada permite que alguns votos contem mais do que outros ao atribuir um peso do voto a cada eleitor. Por exemplo:

- Uma comunidade residencial atribui um voto a cada imóvel. Um membro que representa três imóveis tem um peso do voto de `3`.
- Uma cooperativa de trabalhadores concede o direito de votar após um período definido de participação como membro. Os membros mais recentes recebem um peso do voto de `0`, para que possam participar da discussão e experimentar a votação sem afetar o resultado.
- Uma empresa atribui votos aos acionistas de acordo com sua participação no capital. Uma pessoa que possui 12,5% das ações tem um peso do voto de `12.5`.

<!-- translation-section: set-members-vote-weights -->

## Defina os pesos de voto dos membros

Um admin do grupo pode abrir a página **Membros** do grupo e selecionar **Editar pesos de voto**. Insira os pesos (`0` ou mais, com até três casas decimais) e selecione **Salvar pesos de voto**. Você pode buscar por nome ou email para encontrar alguém ou selecionar **Defina todos os pesos de voto** para atribuir o mesmo peso a todos os membros.

![Pesos de voto dos membros do grupo](member-weights.png)

O peso do voto de um membro é copiado para cada enquete quando ele é adicionado. Alterá-lo depois não afeta as enquetes existentes.

<!-- translation-section: use-weighted-voting-in-a-poll -->

## Use votação ponderada em uma enquete

Abra **Mais configurações** no formulário da enquete e selecione **Usar votação ponderada**. Você pode ativar ou desativar a votação ponderada depois que a votação começar. Desativá-la redefine todos os pesos de voto da enquete como `1`, e quaisquer pesos personalizados dessa enquete são perdidos.

Se seu grupo usa votação ponderada em um processo regular, ative **Usar votação ponderada** em um [modelo de enquete](/en/user_manual/polls/poll_templates). As enquetes iniciadas a partir desse modelo usarão votação ponderada por padrão.

![A configuração Usar votação ponderada em uma enquete](poll-setting.png)

A votação ponderada funciona com estes tipos de enquete: [Proposta](/en/user_manual/polls/proposals), [Escolher](/en/user_manual/polls/choose), [Pontuar](/en/user_manual/polls/score), [Distribuir](/en/user_manual/polls/allocate) e [Classificar](/en/user_manual/polls/rank).

Você não pode usar votação ponderada e [votação anônima](/en/user_manual/polls/anonymous_voting) na mesma enquete.

Para alterar o peso do voto de um eleitor, selecione **Gerenciar eleitores** e depois selecione o peso ao lado do nome dele. Para alterar o peso de todos, selecione **Defina todos os pesos de voto**. Você pode copiar do grupo o peso do voto de cada membro ou atribuir o mesmo valor a todos. Os eleitores que não são membros do grupo recebem um peso de `1`.

![O botão Gerenciar eleitores em uma enquete](poll-manage-voters.png)

![Eleitores em uma enquete com pesos de voto individuais](poll-voter-weights.png)

<!-- translation-section: results -->

## Resultados

Os resultados mostram os totais sem ponderação e os totais ponderados lado a lado:

- As enquetes dos tipos Proposta e Escolher mostram **Votos** e **Votos ponderados**.
- As enquetes dos tipos Pontuar, Distribuir e Classificar mostram **Pontos** e **Pontos ponderados**.

O gráfico mostra o resultado ponderado. Selecione o cabeçalho de uma coluna para mostrar os dados dessa coluna no gráfico. Qualquer pessoa que possa ver os votos pode ver o peso do voto de cada eleitor.

Nas enquetes dos tipos Proposta e Escolher, **Não votou** mostra o número de eleitores que ainda não votaram em **Votos** e a soma dos pesos dos votos desses eleitores em **Votos ponderados**. Essas colunas e **% do peso dos votos elegíveis** incluem no gráfico quem ainda não votou. **% do peso dos votos emitidos** deixa **Não votou** em branco e exclui essa categoria do gráfico.

Os pesos de voto também se aplicam ao [quórum](/en/user_manual/polls/quorum) e aos [requisitos de proporção de votos](/en/user_manual/polls/vote_share_requirements).

No exemplo abaixo, Jamie vota **Concordar** com peso `2`. Três pessoas votam **Discordo**, com pesos `1`, `0` e `0`. Duas pessoas, com pesos `2` e `1`, ainda não votaram.

Concordo tem um dos quatro votos emitidos, mas dois terços do peso dos votos emitidos. Metade do peso dos votos elegíveis participou, portanto o quórum de 60 por cento não foi atingido.

![Resultado de uma proposta com votos e votos ponderados](weighted-proposal-result.png)
