---
title: Modelos de enquetes
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/polls/poll_templates/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
sections:
  introduction: 227665c7b66356be
  who-can-manage-templates: 2f0ab3bdaf9d093a
  create-a-poll-template: 0fafc6275b6c9153
  template-title-subtitle-and-help: 5a3f6c78e32fb066
  voting-method: 3ad5838dfcb67da0
  example-title-details-and-tags: 0f0d84a8b9b6ecb2
  response-options: e6ef2fb08eb66840
  duration-and-settings: 9b3c78d3c0d4986a
  manage-the-template-list: a58617ec50baf468
  save-a-poll-as-a-template: 36dc7b5d410d0eea
  start-a-new-template: 4f14910d88b22de8
  configure-the-template: 5fdb36299dd771b8
  edit-a-default-template: 6f1e7050d20ed373
generated:
  introduction: 175a8edf75d8041b
  who-can-manage-templates: 156bfa0d0c5d84ed
  create-a-poll-template: fee35008f18fdd60
  template-title-subtitle-and-help: 89cb319a83033fa1
  voting-method: e8a0b0484c8155a7
  example-title-details-and-tags: 4af49d802094a864
  response-options: a558dcbf4e02580c
  duration-and-settings: b5e8e04013c64882
  manage-the-template-list: eced87f1121ecad2
  save-a-poll-as-a-template: a76addad156cf71e
  start-a-new-template: 60083397d1c24ee5
  configure-the-template: 915347799f5023e8
  edit-a-default-template: d93b133341414a74
title_source: 114cca246e357304
title_generated: 38127cb43d236492
---

<!-- translation-section: introduction -->

# Modelos de enquetes

Modelos de enquetes são pontos de partida reutilizáveis exibidos quando alguém seleciona **Iniciar uma votação** ou **Nova enquete**. Um modelo combina um método de votação com orientações, opções de resposta e configurações predefinidas.

Use esta página para configurar quais modelos estão disponíveis para um grupo ou criar um modelo para seu próprio processo. Para escolher um modelo para uma votação específica, consulte [Propostas](../proposals/) ou [Enquetes](../proposal_types/). Para facilitar um processo completo de decisão, consulte [Como tomar decisões](/en/guides/making_decisions/).

Ao iniciar uma votação, selecione a aba **Proposta** ou **Enquete** e escolha um modelo disponível para o grupo.

O modelo preenche uma introdução, conteúdo de exemplo, opções e configurações. Revise e edite esses elementos para sua decisão antes de iniciar a votação. Editar uma nova votação não altera o modelo.

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

Dê ao modelo um nome e um subtítulo que descrevam quando usá-lo. Ajuste os outros campos para que o modelo esteja pronto para reutilização e selecione **Salvar modelo**. O modelo aparecerá quando as pessoas iniciarem uma nova proposta ou enquete.

[![O formulário completo do modelo de processo de consentimento para alteração de política](poll_template_new.png)](poll_template_new.png)

Para enquetes independentes, **Só admins podem adicionar anexos** restringe a adição de novos arquivos e imagens no corpo do texto (inclusive em respostas à enquete e a comentários) aos admins da conversa e aos admins do grupo. Enquetes dentro de uma conversa existente seguem a configuração de anexos dessa conversa. Alterar um modelo afeta apenas enquetes futuras.

<!-- translation-section: template-title-subtitle-and-help -->

### Título, subtítulo e ajuda do modelo

Use o título e o subtítulo para explicar quando escolher o modelo. Inclua orientações sobre o processo, regras de decisão e links para recursos em **Ajuda de modelo**.

<!-- translation-section: voting-method -->

### Método de votação

Escolha o que os participantes precisam expressar e como o resultado deve ser calculado:

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
- **Motivo do prompt**: a pergunta exibida quando alguém explica seu voto.

![](poll_type_edit_option.png)

Defina as opções para que os participantes possam distinguir umas das outras sem precisar adivinhar. Os significados devem corresponder às regras de decisão que seu grupo usa.

<!-- translation-section: duration-and-settings -->

### Duração e configurações

Defina uma duração padrão adequada para a maioria dos usos do modelo. O autor pode alterar o horário de encerramento de uma votação específica.

Outras configurações padrão controlam a visibilidade dos resultados, a votação anônima, a [votação ponderada](../weighted_voting/), a exigência de motivos para os votos, os lembretes, o quórum e o comportamento específico de cada método. Consulte [Configurações de propostas e enquetes](../settings/) para mais detalhes.

<!-- translation-section: manage-the-template-list -->

## Gerencie os modelos

Use o menu de ações ao lado de um modelo para:

- **Editar** seu conteúdo reutilizável e suas configurações padrão;
- **Mover** o modelo para outra posição na lista;
- **Esconder** o modelo das pessoas que iniciam votações; ou
- **Deletar** um modelo personalizado que não é mais necessário.

![A lista de modelos do grupo com o menu de ações do processo de consentimento para alteração de política aberto](template_manage.png)

Selecione **Mostrar modelos ocultos** para revisar ou restaurar modelos ocultos. Você pode ocultar ou adaptar modelos padrão para seu grupo, mas não pode deletá-los.

Alterar um modelo não modifica as propostas ou enquetes que já foram iniciadas a partir dele.

<!-- translation-section: who-can-manage-templates -->

### Quem pode gerenciar modelos

Os admins do grupo podem criar e gerenciar todos os modelos de enquetes do seu grupo. Eles podem ativar **Os membros podem criar modelos.** em **Configurações do grupo** → **Permissões**. Quando essa opção está ativada, os membros podem criar modelos e gerenciar os modelos que criaram.
