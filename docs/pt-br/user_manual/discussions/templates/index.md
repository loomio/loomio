---
title: Modelos de discussão
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/discussions/templates/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-29'
sections:
  introduction: 9b2b30212a057b4b
  how-templates-are-used: 7d5681170fe9911e
  choose-who-is-notified-by-default: e9fe4c939442f514
  template-settings: 2e71090b3d149213
  example-bottle-trial-review: 20009020c0b68fdf
  create-a-template: 223eee427ebb52bb
  manage-the-template-list: 9a4957687be2b34d
  share-templates-between-groups: 2bff30bad2a0eb4a
  let-members-create-templates: 0cfd990ff48a1a09
  templates-for-non-members: ebaf610bf85e81a9
  related: 6f4cc2ccf8e709d3
generated:
  introduction: 5743d4171cf60ac6
  how-templates-are-used: c7f95b0f995f2007
  choose-who-is-notified-by-default: 43227ef98c972046
  template-settings: fc7cb939bc4cf4ba
  example-bottle-trial-review: 779c10dc6320c84a
  create-a-template: 113e535e8e281d6f
  manage-the-template-list: 3a8f9928d0b9673c
  share-templates-between-groups: 7f456f18a4faba7f
  let-members-create-templates: ce17c10c20b95d8e
  templates-for-non-members: 671afa5f2f746abd
  related: 06dacc2cfeed5658
title_source: 5ac608aa42806d13
title_generated: 8c7c97249e5996da
---

<!-- translation-section: introduction -->

# Modelos de discussão

Os modelos de discussão ajudam seu grupo a iniciar discussões da mesma forma sempre. Um modelo pode fornecer título, contexto, tags e instruções para quem inicia a discussão. Ele também define opções padrão, como a notificação de todo o grupo e as enquetes sugeridas.

Toda nova discussão em um grupo começa com um modelo. Quando alguém seleciona **Iniciar discussão**, o Loomio mostra os modelos do grupo. Até mesmo **Modelo em branco** é um modelo, então seu grupo também pode alterar suas opções padrão.

Os modelos são úteis para processos que seu grupo repete, como avaliações de projetos, processos de consulta, preparação de reuniões, decisões de financiamento ou aprovação de documentos. Quem inicia a discussão pode editar tudo antes de criá-la.

<!-- translation-section: how-templates-are-used -->

## Como os modelos são usados

1. Um membro seleciona **Iniciar discussão** na página do grupo.
2. O Loomio lista os modelos visíveis do grupo. Cada um mostra seu título e sua legenda.
3. O membro seleciona um modelo. O Loomio abre o formulário de nova discussão preenchido com o conteúdo do modelo.
4. A ajuda do modelo aparece no início do formulário como orientação.
5. O membro edita o título, o contexto, as tags e a lista de convidados. Depois, seleciona **Iniciar discussão**.

![](list.png)

A alteração de um modelo afeta apenas as discussões iniciadas depois dela. As discussões já iniciadas com o modelo mantêm seu conteúdo e suas configurações.

<!-- translation-section: choose-who-is-notified-by-default -->

## Escolha quem recebe notificações por padrão

A configuração **Convidar** controla quem o formulário de nova discussão convida por padrão. Há duas opções:

- **Todos no grupo**: o grupo aparece no campo **Convidar** do formulário de discussão, e todos os membros recebem uma notificação quando a discussão começa.
- **Nenhum**: o campo **Convidar** começa vazio. Ninguém recebe uma notificação, a menos que o autor adicione pessoas.

Os modelos incluídos no Loomio, entre eles **Modelo em branco**, usam **Todos no grupo**. Se seu grupo não quiser notificar todos os membros a cada nova discussão, edite os modelos que usa e defina **Convidar** como **Nenhum**.

![](use.png)

O autor sempre pode alterar a lista de convidados antes de iniciar a discussão. Pode remover o grupo para não notificar ninguém ou adicionar pessoas específicas. Essa configuração afeta apenas as notificações. Os membros ainda podem encontrar e ler a discussão no grupo, seja qual for a opção escolhida.

O grupo só é adicionado à lista de convidados quando o autor tem permissão para notificar todo o grupo. Os administradores sempre podem fazer isso. Os membros podem fazer isso quando **Os membros podem notificar todos no grupo** está habilitado nas permissões do grupo.

<!-- translation-section: template-settings -->

## Configurações do modelo

Os administradores do grupo podem editar um modelo pelo menu de ações ao lado dele na lista de modelos. O formulário tem estas configurações:

![](form.png)

- **Título do modelo**: o nome curto exibido na lista de modelos.
- **Modelo de legenda**: uma linha que explica quando usar o modelo.
- **Ajuda de modelo**: instruções exibidas no início do formulário de nova discussão. Use esse campo para explicar o processo e incluir links para recursos. Esse conteúdo não faz parte da discussão.
- **Grupo**: define se o modelo inicia uma discussão no grupo ou uma discussão direta. Uma discussão direta só é visível para as pessoas convidadas.
- **Título padrão**: um título preenchido em cada nova discussão. O autor pode editá-lo.
- **Título de exemplo**: um exemplo exibido quando o campo de título está vazio. Use essa opção quando um título padrão não servir para todas as discussões.
- **Tags**: tags aplicadas a cada nova discussão. O autor pode removê-las.
- **Contexto**: o texto inicial da discussão. Use títulos, perguntas ou links para orientar as contribuições das pessoas.
- **Convidar**: define se todos no grupo são convidados por padrão. Consulte [Escolha quem recebe notificações por padrão](#choose-who-is-notified-by-default).
- **Modelos de enquetes**: enquetes sugeridas para esse processo. Elas aparecem no formulário de nova discussão e no início da lista quando alguém cria uma enquete na discussão. Elas não começam automaticamente.
- **Permitir votações simultâneas**: define se mais de uma enquete pode ficar aberta na discussão ao mesmo tempo.
- **Limite de comprimento do comentário**: um limite máximo opcional para comentários.

Use um título padrão apenas quando ele continuar correto em todas as discussões. Caso contrário, escreva um título de exemplo que incentive o autor a identificar a avaliação, o período, o documento ou a decisão específica.

<!-- translation-section: example-bottle-trial-review -->

## Exemplo: avaliação do teste de garrafas

A Cooperativa Leite de Aveia avalia seu teste de garrafas retornáveis após cada ciclo. Seu modelo se chama "Avaliação do teste de garrafas" e tem um título padrão. Ele adiciona a tag "Teste de garrafas". O contexto pede aos membros que leiam o relatório semanal e considerem as taxas de retorno, os registros de lavagem, os comentários das cafeterias e os custos de transporte. O modelo recomenda uma verificação de entendimento seguida de uma decisão por consentimento.

Esse processo funciona como modelo porque o objetivo e as informações analisadas são os mesmos em cada ciclo. Apenas as observações e as decisões mudam.

<!-- translation-section: create-a-template -->

## Crie um modelo

Os administradores do grupo podem selecionar **Novo modelo** na lista de modelos. Escolha um exemplo da galeria do Loomio ou comece com um modelo em branco. Depois, adapte e salve o modelo.

Você pode pesquisar ou filtrar a galeria. Um exemplo só é adicionado ao seu grupo quando você o salva.

<!-- translation-section: manage-the-template-list -->

## Gerencie a lista de modelos

Quando um grupo é criado, o Loomio adiciona modelos adequados ao tipo de grupo. No início, apenas **Modelo em branco** e **Discussão prática** ficam visíveis. Os outros ficam ocultos, e os administradores podem torná-los visíveis.

Os administradores do grupo podem usar o menu de ações ao lado de um modelo para:

- editar seu conteúdo e suas configurações;
- ocultá-lo da lista de modelos;
- torná-lo visível em **Modelos ocultos**;
- reorganizar a ordem dos modelos visíveis;
- exportá-lo como arquivo JSON; ou
- excluí-lo.

Um modelo oculto continua disponível para uso futuro. Excluir um modelo não exclui as discussões iniciadas com ele.

<!-- translation-section: share-templates-between-groups -->

## Compartilhe modelos entre grupos

Selecione **Exportar JSON** no menu de ações de um modelo para baixá-lo como arquivo. Para usá-lo em outro grupo, selecione **Novo modelo** e depois **Importar JSON**. O formulário abre com o conteúdo importado para que você possa revisá-lo antes de salvar.

Os links para modelos personalizados de enquetes não são incluídos no arquivo. Exporte e importe esses modelos de enquetes separadamente.

<!-- translation-section: let-members-create-templates -->

## Permita que membros criem modelos

Por padrão, apenas os administradores do grupo podem criar e editar modelos. Um administrador pode habilitar **Os membros podem criar modelos.** em **Configurações do grupo** → **Permissões**.

Quando essa permissão está habilitada, os membros podem criar modelos de discussão e de enquetes e editar os modelos que criaram. Os administradores podem editar todos os modelos do grupo. O modelo de um membro aparece na lista do grupo assim que é salvo. Por isso, combine como os modelos serão nomeados e revisados antes de habilitar essa permissão.

<!-- translation-section: templates-for-non-members -->

## Modelos para quem não é membro

Se **Quem não é membro pode iniciar discussões.** está habilitado, pessoas de fora do grupo escolhem entre os mesmos modelos. O formulário de discussão delas nunca convida o grupo por padrão. Consulte [Receba contribuições privadas](/en/user_manual/discussions/private_submissions).

<!-- translation-section: related -->

## Páginas relacionadas

- [Modelos de enquetes](/en/user_manual/polls/poll_templates)
