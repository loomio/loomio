---
title: Modelos de enquetes
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/polls/poll_templates/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-29'
sections:
  introduction: f11182d62d99dbcc
  voting-methods-and-templates: 24be471686aa2dfd
  use-a-template: 8b19cdf141c41c9b
  who-can-manage-templates: 60218ef791438e19
  create-a-poll-template: c20dd8c57c3deab0
  template-title-subtitle-and-help: 3ad53a8b118aabd3
  voting-method: 761137852812fea8
  example-title-details-and-tags: 9dbbd0510d2d6cc1
  response-options: 727afbf0dcea6069
  duration-and-settings: dc1fb9123eb808df
  save-and-test-the-template: 8c48386c69ea309a
  manage-the-template-list: 0c124d7958c3f80a
generated:
  introduction: aeeccdc5ff2b7203
  voting-methods-and-templates: 399fba4810cf6a50
  use-a-template: 3a09d9f1a0302d79
  who-can-manage-templates: 861c07732eae7118
  create-a-poll-template: 6c8d909de42ac293
  template-title-subtitle-and-help: f28b4195a080cc92
  voting-method: 40f35668a3429458
  example-title-details-and-tags: 1322196ef49e0938
  response-options: e76a6d25700e0abd
  duration-and-settings: 803f5915cd357968
  save-and-test-the-template: e76df2456f3b9ecf
  manage-the-template-list: 06ecaaabb452bd34
title_source: 114cca246e357304
title_generated: 38127cb43d236492
---

<!-- translation-section: introduction -->

# Modelos de enquetes

Os modelos de enquetes são pontos de partida reutilizáveis exibidos quando alguém seleciona **Iniciar uma votação** ou **Nova enquete**. Um modelo combina um método de votação com orientações, opções de resposta e configurações predefinidas.

Use esta página para definir quais modelos estão disponíveis para um grupo ou criar um modelo para seu próprio processo. Para escolher um modelo para uma votação específica, consulte [Propostas](../proposals/) ou [Enquetes](../proposal_types/). Para facilitar um processo completo de decisão, consulte [Tomada de decisões](/en/guides/making_decisions/).

<!-- translation-section: voting-methods-and-templates -->

## Métodos de votação e modelos

O método de votação determina como os participantes respondem e como o Loomio calcula o resultado. Alguns exemplos são Proposta, Escolher, Pontuação, Alocar, Classificação, Enquete de tempo e STV.

Um modelo de enquete usa um desses métodos e acrescenta configurações padrão reutilizáveis. Por exemplo, Verificação de sentido, Conselho, Consentimento e Consenso são modelos diferentes baseados no método de votação Proposta. Suas instruções e opções de resposta variam, embora o Loomio processe os votos da mesma forma.

<!-- translation-section: use-a-template -->

## Usar um modelo

Ao iniciar uma votação, selecione a aba **Proposta** ou **Enquete** e escolha um dos modelos disponíveis para o grupo.

![](proposal_templates_list.png)

O modelo fornece uma introdução, conteúdo de exemplo, opções e configurações. Revise e edite esses elementos para a decisão em questão antes de iniciar a votação. A edição da nova votação não altera o modelo reutilizável.

<!-- translation-section: who-can-manage-templates -->

## Quem pode gerenciar modelos

Os administradores de um grupo podem criar e gerenciar todos os modelos de enquetes do grupo. Eles podem ativar **Os membros podem criar modelos.** em **Configurações do grupo** → **Permissões**. Com essa opção ativada, os membros podem criar modelos e gerenciar os modelos que criaram.

<!-- translation-section: create-a-poll-template -->

## Criar um modelo de enquete

Abra a lista de modelos e selecione **Novo modelo**. Comece com um exemplo ou um modelo em branco. Depois, escolha o grupo que vai usá-lo.

![](proposal_template_setting.png)

O formulário do modelo define as orientações e configurações padrão que as pessoas recebem ao iniciar uma votação.

![](poll_template_new.png)

<!-- translation-section: template-title-subtitle-and-help -->

### Título, legenda e ajuda do modelo

- **Título do modelo** é o nome curto exibido na lista de modelos.
- **Modelo de legenda** explica em uma frase quando usar o modelo.
- **Ajuda de modelo** aparece no painel de informações quando alguém usa o modelo. Explique a finalidade do modelo, as regras que os participantes precisam conhecer e inclua links para políticas ou guias relevantes.

![](template_WAAP_intro.png)

Use nomes claros e específicos que diferenciem o modelo dos demais modelos do grupo.

<!-- translation-section: voting-method -->

### Método de votação

Escolha o que os participantes precisam expressar e como o resultado deve ser calculado.

![](poll_type_voting_method.png)

- **Proposta**: responder a uma afirmação usando posições definidas;
- **Escolher**: selecionar uma ou mais opções;
- **Pontuação**: avaliar cada opção em uma escala;
- **Alocar**: distribuir uma quantidade limitada de pontos;
- **Classificação**: ordenar as opções por preferência;
- **Enquete de tempo**: indicar disponibilidade; e
- **STV**: classificar candidatos em uma eleição proporcional com vários vencedores.

Alterar o método de votação muda os campos e o cálculo do resultado disponíveis para o modelo.

<!-- translation-section: example-title-details-and-tags -->

### Exemplo de título, detalhes e tags

Forneça um conteúdo de exemplo que ajude a pessoa a formular a votação. Esses valores são copiados para uma nova proposta ou enquete e podem ser editados antes de seu início.

![](template_WAAP_details.png)

Use sugestões em vez de conteúdo fixo quando cada uso exigir um título ou detalhes diferentes. Adicione tags de categoria padrão apenas quando elas se aplicarem a todos os usos do modelo.

<!-- translation-section: response-options -->

### Opções de resposta

Métodos como Proposta e Escolher permitem configurar as opções de resposta. Selecione o ícone de lápis ao lado de uma opção para editar:

- **Nome da opção**: o rótulo curto da resposta;
- **Ícone**: o marcador visual da opção;
- **Significado**: o que a escolha da opção comunica; e
- **Motivo do prompt**: a pergunta exibida quando alguém explica sua resposta.

![](poll_type_edit_option.png)

Defina as opções de modo que os participantes consigam diferenciá-las com clareza. Os significados devem corresponder às regras de decisão que seu grupo usa.

<!-- translation-section: duration-and-settings -->

### Duração e configurações

Defina uma duração padrão adequada para a maioria dos usos do modelo. A pessoa que cria a votação pode alterar o horário de encerramento de uma votação específica.

![](poll_type_duration.png)

Outras configurações padrão podem controlar a visibilidade dos resultados, o voto anônimo, a exigência de justificativa para o voto, os lembretes, o quórum e o comportamento específico de cada método. Consulte [Configurações de propostas e enquetes](../settings/) para entender seus efeitos.

<!-- translation-section: save-and-test-the-template -->

### Salvar e testar o modelo

Depois de salvar, crie um rascunho de votação a partir do modelo. Verifique se a introdução, as perguntas, as opções e as configurações padrão fazem sentido para quem não criou o modelo. O rascunho também ajuda a confirmar se o método de votação escolhido produz o resultado esperado pelo grupo.

<!-- translation-section: manage-the-template-list -->

## Gerenciar a lista de modelos

Use o menu de ações ao lado de um modelo para:

- **Editar** o conteúdo reutilizável e as configurações padrão;
- **Mover** o modelo para outra posição na lista;
- **Esconder** o modelo das pessoas que iniciam votações; ou
- **Deletar** um modelo personalizado que não é mais necessário.

![](template_manage.png)

Selecione **Mostrar modelos ocultos** para revisar ou restaurar modelos ocultos. Os modelos padrão podem ser ocultados ou adaptados para o grupo, mas não podem ser excluídos.

![](template_manage_settings.png)

Alterar um modelo não modifica propostas ou enquetes já iniciadas a partir dele.
