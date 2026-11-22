---
title: Quórum
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/polls/quorum/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
sections:
  introduction: 885a154beca10592
  example-scenario: 2c4be2012a2bcba4
generated:
  introduction: f097a054398fae54
  example-scenario: f078ed0ff3efab0d
title_source: 18ed8b6c5ab90343
title_generated: 87368b7c44ece4c1
---

<!-- translation-section: introduction -->

# Quórum

O quórum é a porcentagem mínima de eleitores aptos a votar que devem participar para que uma enquete seja aprovada. Use esse recurso quando seu processo de decisão exigir um nível mínimo de participação.

Com a [votação ponderada](/en/user_manual/polls/weighted_voting), o quórum usa os pesos dos votos. Por exemplo, Jamie tem peso `2`, Samira tem peso `1` e Alex tem peso `1`. Se apenas Jamie votar, a participação corresponde à metade do peso total dos votos dos eleitores aptos a votar. Se Samira também votar, a participação chega a 75 por cento, atingindo um quórum de 60 por cento.

Ao criar uma enquete, abra **Mais configurações** e informe a porcentagem exigida em **Quorum**. Deixe o campo em branco quando não houver exigência de quórum.

![A configuração de quórum com um quórum de participação de 60 por cento](./quorum-section.png)

Você também pode definir um quórum em um [modelo de enquete](/en/user_manual/polls/poll_templates/) para que as enquetes criadas a partir desse modelo usem esse quórum por padrão.

Se uma enquete for encerrada sem atingir o quórum, o Loomio mostra que o quórum não foi atingido. A enquete não é prorrogada nem cancelada automaticamente. Um admin da conversa pode reabrir a enquete (se permitido) ou compartilhar uma conclusão explicando o que acontece a seguir.

<!-- translation-section: example-scenario -->

## Exemplo de cenário

A Cooperativa Oatmilk está discutindo um teste de seis semanas com garrafas retornáveis e precisa aprovar o orçamento do teste.

Jamie seleciona **Iniciar uma votação**, escolhe um modelo de proposta e preenche o título, os detalhes, as opções, a duração e as configurações dos eleitores.

![O título, os detalhes, as opções, a duração e as configurações dos eleitores da proposta](proposal-options.png)

Jamie limita a votação às cinco pessoas responsáveis pelo orçamento do teste. Como a cooperativa exige 60 por cento de participação para decisões importantes, Jamie informa **60** em **Quorum** e inicia a proposta.

Antes que alguém vote, o painel de resultados mostra que o quórum ainda não foi atingido.

![Nenhum voto registrado e o quórum de 60 por cento ainda não atingido](pie-chart-0.png)

Jamie concorda e Samira discorda. O gráfico é atualizado, mas a participação de dois dos cinco eleitores aptos a votar corresponde a apenas 40 por cento, então o quórum ainda não foi atingido.

![Dois dos cinco votos registrados e o quórum ainda não atingido](pie-chart-40.png)

Alex então concorda. Três dos cinco eleitores aptos a votar participaram, atingindo o quórum de 60 por cento. A exigência agora aparece com uma marca de seleção verde. Jamie pode encerrar a enquete antecipadamente ou aguardar os demais eleitores.

![Três dos cinco votos registrados e o quórum de 60 por cento atingido](pie-chart-60.png)
