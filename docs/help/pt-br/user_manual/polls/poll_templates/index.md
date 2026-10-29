---
title: Modelos de enquetes
source_revision: 00d781409c832b216c95759c1369678ad240e246
source_file: docs/help/en/user_manual/polls/poll_templates/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-29'
sections:
  introduction: a535465485cdbc13
  who-can-manage-templates: 6c3d5e693cd1dfdc
  create-a-poll-template: 0fafc6275b6c9153
  template-title-subtitle-and-help: 5a3f6c78e32fb066
  voting-method: c645269a1a17d1c8
  example-title-details-and-tags: 0f0d84a8b9b6ecb2
  response-options: 727afbf0dcea6069
  duration-and-settings: f1f3643e94524af9
  manage-the-template-list: 76e78b8a60f1d08c
  save-a-poll-as-a-template: 36dc7b5d410d0eea
  start-a-new-template: 4f14910d88b22de8
  configure-the-template: bec89f7804dd12f8
  edit-a-default-template: 6f1e7050d20ed373
generated:
  introduction: 3a4a66d9acf40a3d
  who-can-manage-templates: 83e2a396784e1044
  create-a-poll-template: fee35008f18fdd60
  template-title-subtitle-and-help: 89cb319a83033fa1
  voting-method: 8f098612064c12f9
  example-title-details-and-tags: 4af49d802094a864
  response-options: '01239d8e216c72e5'
  duration-and-settings: f801c12b57b3276e
  manage-the-template-list: 154c1395ab809a60
  save-a-poll-as-a-template: a76addad156cf71e
  start-a-new-template: 60083397d1c24ee5
  configure-the-template: 111569685e647766
  edit-a-default-template: d93b133341414a74
title_source: 114cca246e357304
title_generated: 38127cb43d236492
---

<!-- translation-section: introduction -->

# Modelos de enquetes

Modelos de enquetes são pontos de partida reutilizáveis exibidos quando alguém seleciona **Iniciar uma votação** ou **Nova enquete**. Um modelo combina um método de votação com orientações, opções de resposta e configurações predefinidas.

Use esta página para configurar quais modelos estão disponíveis para um grupo ou para criar um modelo para seu próprio processo. Para escolher um modelo para uma votação específica, consulte [Propostas](../proposals/) ou [Enquetes](../proposal_types/). Para facilitar um processo completo de decisão, consulte [Como tomar decisões](/en/guides/making_decisions/).

Ao iniciar uma votação, selecione a aba **Proposta** ou **Enquete** e escolha um dos modelos disponíveis para o grupo.

O modelo fornece uma introdução, conteúdo de exemplo, opções e configurações. Revise e edite esses elementos para a decisão específica antes de iniciar a votação. Editar a nova votação não altera o modelo reutilizável.

<!-- translation-section: create-a-poll-template -->

## Crie um modelo de enquete

<!-- translation-section: save-a-poll-as-a-template -->

### Salve como modelo

Para reutilizar uma proposta ou enquete existente, abra seu menu de ações e selecione **Salvar como modelo**.

![Uma proposta com o menu de ações aberto e Salvar como modelo em destaque](save_as_template.png)

As datas de votação, os eleitores, os votos, os resultados e a conclusão da enquete não são salvos no modelo.

<!-- translation-section: start-a-new-template -->

### Inicie um novo modelo

Abra a lista de modelos e selecione **Novo modelo**. Comece com um exemplo ou um modelo em branco e escolha o grupo que vai usá-lo.

![](proposal_template_setting.png)

<!-- translation-section: edit-a-default-template -->

### Editar um modelo padrão

Para adaptar um modelo padrão como **Consentimento**, abra o menu de ações dele e selecione **Editar modelo**. Essa opção está disponível para admins do grupo. Ao salvar, você cria um modelo personalizado para seu grupo e oculta a versão padrão da lista de modelos dele.

![O modelo padrão Consentimento com a ação Editar modelo visível](edit_default_template.png)

<!-- translation-section: configure-the-template -->

## Configurações do modelo

Dê ao modelo um nome e um subtítulo que descrevam quando usá-lo. Você pode modificar qualquer um dos outros campos para torná-los mais adequados para reutilização. Depois que você selecionar **Salvar modelo**, o modelo será listado quando as pessoas iniciarem uma nova proposta ou enquete.

[![O formulário completo do modelo de processo de consentimento para alteração de política](poll_template_new.png)](poll_template_new.png)

<!-- translation-section: template-title-subtitle-and-help -->

### Título, subtítulo e ajuda do modelo

Use o título e o subtítulo para explicar quando escolher o modelo. Inclua orientações sobre o processo, regras de decisão e links para recursos em **Ajuda de modelo**.

<!-- translation-section: voting-method -->

### Método de votação

Escolha o que os participantes precisam expressar e como o resultado deve ser calculado.

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

Use orientações para o título e os detalhes de exemplo quando cada votação precisar de conteúdo diferente. Adicione tags de categoria padrão apenas quando elas se aplicarem a todos os usos do modelo.

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

Outros padrões podem controlar a visibilidade dos resultados, a votação anônima, a [votação ponderada](../weighted_voting/), a exigência de motivos para os votos, os lembretes, o quórum e o comportamento específico de cada método. Consulte [Configurações de propostas e enquetes](../settings/) para entender seus efeitos.

<!-- translation-section: manage-the-template-list -->

## Gerencie os modelos

Use o menu de ações ao lado de um modelo para:

- **Editar** seu conteúdo reutilizável e seus padrões;
- **Mover** o modelo para outra posição na lista;
- **Esconder** o modelo das pessoas que iniciam votações; ou
- **Deletar** um modelo personalizado que não é mais necessário.

![A lista de modelos do grupo com o menu de ações do processo de consentimento para alteração de política aberto](template_manage.png)

Selecione **Mostrar modelos ocultos** para revisar ou restaurar modelos ocultos. Os modelos padrão podem ser ocultados ou adaptados para o grupo, mas não podem ser deletados.

Alterar um modelo não modifica as propostas ou enquetes que já foram iniciadas a partir dele.

<!-- translation-section: who-can-manage-templates -->

### Quem pode gerenciar modelos

Os administradores do grupo podem criar e gerenciar todos os modelos de enquetes do seu grupo. Eles podem ativar **Os membros podem criar modelos.** em **Configurações do grupo** → **Permissões**. Quando essa opção está ativada, os membros podem criar modelos e gerenciar os modelos que criaram.
