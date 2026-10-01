---
title: Quórum
source_revision: c6076258c3438c0dd6dc8fbf1fc0b0df47c0aeb5
source_file: docs/en/user_manual/polls/quorum/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: 0bf465006210877b
  example-scenario: 6596ad44e1c046b4
generated:
  introduction: 0abacfeecb1e0e38
  example-scenario: 0eb256030516d265
title_source: 18ed8b6c5ab90343
title_generated: 87368b7c44ece4c1
---

<!-- translation-section: introduction -->

# Quórum

O quórum é a porcentagem mínima de eleitores aptos a votar que devem participar para que uma enquete seja válida. Use esse recurso quando seu processo de governança exigir um determinado nível de participação.

Ao criar uma enquete, abra **Mais configurações** e informe a porcentagem exigida em **Quórum de participação**. Deixe o campo em branco quando não houver exigência de quórum.

![A configuração de quórum com um quórum de participação de 60 por cento](./quorum-section.png)

Você também pode definir um quórum em um [modelo de enquete](/en/user_manual/polls/poll_templates/) para que as enquetes criadas a partir desse modelo usem esse quórum por padrão.

<!-- translation-section: example-scenario -->

## Exemplo de cenário

A Cooperativa Oatmilk está discutindo um teste de seis semanas com garrafas retornáveis. A discussão chegou ao ponto em que a cooperativa precisa aprovar o orçamento do teste.

Jamie seleciona **Iniciar uma votação**, escolhe o modelo de proposta **Consentimento** e preenche o título, os detalhes, as opções, a duração e as configurações dos eleitores.

![O título, os detalhes, as opções, a duração e as configurações dos eleitores da proposta](proposal-options.png)

Jamie limita a votação às cinco pessoas responsáveis pelo orçamento do teste.

A cooperativa exige 60 por cento de participação para decisões importantes, então Jamie informa **60** no campo de quórum de participação e inicia a proposta.

Antes que alguém vote, o painel de resultados mostra que o quórum ainda não foi atingido.

![Nenhum voto registrado e o quórum de 60 por cento ainda não atingido](pie-chart-0.png)

Jamie concorda e Samira discorda. O gráfico é atualizado, mas a participação de dois dos cinco eleitores aptos a votar corresponde a apenas 40 por cento, então o quórum ainda não foi atingido.

![Dois dos cinco votos registrados e o quórum ainda não atingido](pie-chart-40.png)

Alex então concorda. Três dos cinco eleitores aptos a votar participaram, atingindo o quórum de 60 por cento. A exigência agora aparece com uma marca de seleção verde. Jamie pode encerrar a enquete antecipadamente ou aguardar os demais eleitores.

![Três dos cinco votos registrados e o quórum de 60 por cento atingido](pie-chart-60.png)
