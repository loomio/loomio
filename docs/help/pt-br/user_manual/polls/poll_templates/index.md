---
title: Modelos de enquetes
source_revision: c6076258c3438c0dd6dc8fbf1fc0b0df47c0aeb5
source_file: docs/en/user_manual/polls/poll_templates/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
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
  duration-and-settings: a364411a3bebb3ae
  save-and-test-the-template: 8c48386c69ea309a
  manage-the-template-list: 0c124d7958c3f80a
generated:
  introduction: d52e61a641d86304
  voting-methods-and-templates: 281dc3f57002e13d
  use-a-template: 4b62a6860f706368
  who-can-manage-templates: 68b6bb940a9b7e47
  create-a-poll-template: 9cbff815d96d2c67
  template-title-subtitle-and-help: be074b1beff3db7d
  voting-method: a80ed623a6611169
  example-title-details-and-tags: e4d9711ec1d02862
  response-options: '01239d8e216c72e5'
  duration-and-settings: f5d38860c91f5a1c
  save-and-test-the-template: e882508f51a8cee7
  manage-the-template-list: 80e396788168944b
title_source: 114cca246e357304
title_generated: 38127cb43d236492
---

<!-- translation-section: introduction -->

# Modelos de enquetes

Modelos de enquetes são pontos de partida reutilizáveis exibidos quando alguém seleciona **Iniciar uma votação** ou **Nova enquete**. Um modelo combina um método de votação com orientações, opções de resposta e configurações predefinidas.

Use esta página para configurar quais modelos estão disponíveis para um grupo ou para criar um modelo para seu próprio processo. Para escolher um modelo para uma votação específica, consulte [Propostas](../proposals/) ou [Enquetes](../proposal_types/). Para facilitar um processo completo de decisão, consulte [Como tomar decisões](/en/guides/making_decisions/).

<!-- translation-section: voting-methods-and-templates -->

## Métodos de votação e modelos

Um método de votação determina como os participantes respondem e como o Loomio calcula o resultado. Alguns exemplos são Proposta, Escolher, Pontuar, Distribuir, Classificar, Enquete de horário e STV.

Um modelo de enquete usa um desses métodos e acrescenta padrões reutilizáveis. Por exemplo, Verificação de opinião, Aconselhamento, Consentimento e Consenso são modelos diferentes baseados no método de votação Proposta. Suas instruções e opções de resposta são diferentes, embora o Loomio processe seus votos da mesma maneira.

<!-- translation-section: use-a-template -->

## Use um modelo

Ao iniciar uma votação, selecione a aba **Proposta** ou **Enquete** e escolha um dos modelos disponíveis para o grupo.

![](proposal_templates_list.png)

O modelo fornece uma introdução, conteúdo de exemplo, opções e configurações. Revise e edite esses elementos para a decisão específica antes de iniciar a votação. Editar a nova votação não altera o modelo reutilizável.

<!-- translation-section: who-can-manage-templates -->

## Quem pode gerenciar modelos

Os administradores do grupo podem criar e gerenciar todos os modelos de enquetes do seu grupo. Eles podem ativar **Os membros podem criar modelos.** em **Configurações do grupo** → **Permissões**. Quando essa opção está ativada, os membros podem criar modelos e gerenciar os modelos que criaram.

<!-- translation-section: create-a-poll-template -->

## Crie um modelo de enquete

Abra a lista de modelos e selecione **Novo modelo**. Comece com um exemplo ou um modelo em branco e escolha o grupo que vai usá-lo.

![](proposal_template_setting.png)

O formulário do modelo define as orientações e os padrões que as pessoas recebem ao iniciar uma votação.

![](poll_template_new.png)

<!-- translation-section: template-title-subtitle-and-help -->

### Título, subtítulo e ajuda do modelo

- **Título do modelo** é o nome curto exibido na lista de modelos.
- **Modelo de legenda** explica em uma frase quando usar o modelo.
- **Ajuda de modelo** aparece no painel de informações quando alguém usa o modelo. Explique sua finalidade e as regras que os participantes precisam conhecer, e inclua links para políticas ou guias relevantes.

![](template_WAAP_intro.png)

Use nomes simples e específicos que diferenciem o modelo dos demais no grupo.

<!-- translation-section: voting-method -->

### Método de votação

Escolha o que os participantes precisam expressar e como o resultado deve ser calculado.

![](poll_type_voting_method.png)

- **Proposta**: responder a uma afirmação usando posicionamentos definidos;
- **Escolher**: selecionar uma ou mais opções;
- **Pontuação**: avaliar cada opção em uma escala;
- **Distribuir**: distribuir uma quantidade limitada de pontos;
- **Classificar**: ordenar as opções por preferência;
- **Enquete de horário**: indicar disponibilidade; e
- **STV**: classificar candidatos em uma eleição proporcional com vários eleitos.

Alterar o método de votação muda os campos e o cálculo do resultado disponíveis no modelo.

<!-- translation-section: example-title-details-and-tags -->

### Título, detalhes e tags de exemplo

Forneça conteúdo de exemplo que ajude o autor a estruturar a votação. Esses valores são copiados para uma nova proposta ou enquete e podem ser editados antes de ela começar.

![](template_WAAP_details.png)

Use orientações em vez de conteúdo fixo quando cada uso exigir um título ou detalhes diferentes. Adicione tags de categoria padrão apenas quando elas se aplicarem a todos os usos do modelo.

<!-- translation-section: response-options -->

### Opções de resposta

Métodos como Proposta e Escolher permitem configurar opções de resposta. Selecione o ícone de lápis ao lado de uma opção para editar:

- **Nome da opção**: o rótulo curto da resposta;
- **Ícone**: seu marcador visual;
- **Significado**: o que a seleção da opção comunica; e
- **Motivo do prompt**: a pergunta exibida quando alguém explica sua resposta.

![](poll_type_edit_option.png)

Defina as opções para que os participantes possam distinguir umas das outras sem precisar adivinhar. Os significados devem corresponder às regras de decisão que seu grupo usa.

<!-- translation-section: duration-and-settings -->

### Duração e configurações

Defina uma duração padrão adequada para a maioria dos usos do modelo. O autor pode alterar o horário de encerramento de uma votação específica.

![](poll_type_duration.png)

Outros padrões podem controlar a visibilidade dos resultados, a votação anônima, a [votação ponderada](../weighted_voting/), a exigência de motivos para os votos, os lembretes, o quórum e o comportamento específico de cada método. Consulte [Configurações de propostas e enquetes](../settings/) para entender seus efeitos.

<!-- translation-section: save-and-test-the-template -->

### Salve e teste o modelo

Depois de salvar, crie um rascunho de votação a partir do modelo. Verifique se a introdução, as orientações, as opções e os padrões fazem sentido para alguém que não criou o modelo. Criar um rascunho também ajuda a confirmar que o método de votação escolhido produz o resultado que o grupo espera.

<!-- translation-section: manage-the-template-list -->

## Gerencie a lista de modelos

Use o menu de ações ao lado de um modelo para:

- **Editar** seu conteúdo reutilizável e seus padrões;
- **Mover** o modelo para outra posição na lista;
- **Esconder** o modelo das pessoas que iniciam votações; ou
- **Deletar** um modelo personalizado que não é mais necessário.

![](template_manage.png)

Selecione **Mostrar modelos ocultos** para revisar ou restaurar modelos ocultos. Os modelos padrão podem ser ocultados ou adaptados para o grupo, mas não podem ser deletados.

![](template_manage_settings.png)

Alterar um modelo não modifica as propostas ou enquetes que já foram iniciadas a partir dele.
