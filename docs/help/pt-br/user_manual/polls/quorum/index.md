---
title: Quórum
source_revision: ad60e7728a4b8d578ec70fa26577556ee051c09d
source_file: docs/help/en/user_manual/polls/quorum/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-23'
sections:
  introduction: dbfdebe6e23060db
  example-scenario: d247e0866095c321
generated:
  introduction: 4c4e0d8b3186bc9b
  example-scenario: 533de60935affe7c
title_source: 18ed8b6c5ab90343
title_generated: 87368b7c44ece4c1
---

<!-- translation-section: introduction -->

# Quórum

O quórum é a porcentagem mínima de eleitores aptos a votar que devem participar para que uma enquete seja válida. Use esse recurso quando seu processo de governança exigir um determinado nível de participação.

Com a [votação ponderada](/en/user_manual/polls/weighted_voting), o quórum usa os pesos dos votos. Por exemplo, Jamie tem peso `2`, Samira tem peso `1` e Alex tem peso `1`. Se apenas Jamie votar, a participação corresponde à metade do peso total dos votos dos eleitores aptos a votar. Se Samira também votar, a participação chega a 75 por cento, atingindo um quórum de 60 por cento.

Ao criar uma enquete, abra **Mais configurações**. Informe a porcentagem exigida em **Quorum**. Deixe o campo em branco quando não houver exigência de quórum.

![A configuração de quórum com um quórum de participação de 60 por cento](./quorum-section.png)

Você também pode definir um quórum em um [modelo de enquete](/en/user_manual/polls/poll_templates/) para que as enquetes criadas a partir desse modelo usem esse quórum por padrão.

<!-- translation-section: example-scenario -->

## Exemplo de cenário

A Cooperativa Oatmilk está discutindo um teste de seis semanas com garrafas retornáveis. A discussão chegou ao ponto em que a cooperativa precisa aprovar o orçamento do teste.

Jamie seleciona **Iniciar uma votação**, escolhe o modelo de proposta **Consentimento** e preenche o título, os detalhes, as opções, a duração e as configurações dos eleitores.

![O título, os detalhes, as opções, a duração e as configurações dos eleitores da proposta](proposal-options.png)

Jamie limita a votação às cinco pessoas responsáveis pelo orçamento do teste.

A cooperativa exige 60 por cento de participação para decisões importantes, então Jamie informa **60** em **Quorum** e inicia a proposta.

Antes que alguém vote, o painel de resultados mostra que o quórum ainda não foi atingido.

![Nenhum voto registrado e o quórum de 60 por cento ainda não atingido](pie-chart-0.png)

Jamie concorda e Samira discorda. O gráfico é atualizado, mas a participação de dois dos cinco eleitores aptos a votar corresponde a apenas 40 por cento, então o quórum ainda não foi atingido.

![Dois dos cinco votos registrados e o quórum ainda não atingido](pie-chart-40.png)

Alex então concorda. Três dos cinco eleitores aptos a votar participaram, atingindo o quórum de 60 por cento. A exigência agora aparece com uma marca de seleção verde. Jamie pode encerrar a enquete antecipadamente ou aguardar os demais eleitores.

![Três dos cinco votos registrados e o quórum de 60 por cento atingido](pie-chart-60.png)
