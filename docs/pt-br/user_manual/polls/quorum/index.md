---
title: Quórum
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/polls/quorum/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-29'
sections:
  introduction: 0bf465006210877b
  example-scenario: 6596ad44e1c046b4
generated:
  introduction: dac7b848a5af6d4b
  example-scenario: 2827d2aa72141877
title_source: 18ed8b6c5ab90343
title_generated: 87368b7c44ece4c1
---

<!-- translation-section: introduction -->

# Quórum

O quórum é a porcentagem mínima de pessoas aptas a votar que precisam participar para que uma votação seja válida. Use-o quando o processo de decisão do seu grupo exigir um nível específico de participação.

Ao criar uma votação, abra **Mais configurações** e informe a porcentagem exigida em **Quórum de participação**. Deixe o campo em branco se não houver quórum obrigatório.

![A configuração de quórum com 60% de participação exigida](./quorum-section.png)

Você também pode definir um quórum em um [modelo de votação](/en/user_manual/polls/poll_templates/) para que as votações criadas a partir dele usem esse valor por padrão.

<!-- translation-section: example-scenario -->

## Exemplo

A Cooperativa Oatmilk está discutindo um teste de seis semanas com garrafas retornáveis. A discussão chegou ao ponto em que a cooperativa precisa aprovar o orçamento do teste.

Jamie seleciona **Iniciar uma votação**, escolhe o modelo de proposta **Consentimento** e preenche o título, os detalhes, as opções, a duração e as configurações de quem pode votar.

![O título, os detalhes, as opções, a duração e as configurações de quem pode votar na proposta](proposal-options.png)

Jamie limita a votação às cinco pessoas responsáveis pelo orçamento do teste.

A cooperativa exige 60% de participação em decisões importantes. Por isso, Jamie informa **60** no campo de quórum de participação e inicia a proposta.

Antes de qualquer pessoa votar, o painel de resultados mostra que o quórum ainda não foi atingido.

![Nenhum voto registrado e o quórum de 60% ainda não atingido](pie-chart-0.png)

Jamie concorda e Samira discorda. O gráfico é atualizado, mas duas das cinco pessoas aptas a votar representam apenas 40% de participação. O quórum ainda não foi atingido.

![Duas das cinco pessoas votaram e o quórum ainda não foi atingido](pie-chart-40.png)

Alex então concorda. Três das cinco pessoas aptas a votar participaram, atingindo o quórum de 60%. Uma marca de seleção verde indica que a exigência foi atendida. Jamie pode encerrar a votação antes do prazo ou esperar pelas demais pessoas.

![Três das cinco pessoas votaram e o quórum de 60% foi atingido](pie-chart-60.png)
