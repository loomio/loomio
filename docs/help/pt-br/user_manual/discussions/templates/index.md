---
title: Modelos de discussão
source_revision: c6076258c3438c0dd6dc8fbf1fc0b0df47c0aeb5
source_file: docs/en/user_manual/discussions/templates/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
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
  introduction: e825802bcd936f98
  how-templates-are-used: '055373488d5af188'
  choose-who-is-notified-by-default: c02e91360e1545c6
  template-settings: 4add25daa1171109
  example-bottle-trial-review: 688608fa0862fd8b
  create-a-template: 88d7f3326812d313
  manage-the-template-list: 725d150f0e537276
  share-templates-between-groups: 7ca58085cbc6e17c
  let-members-create-templates: 647e6d4cd4055f96
  templates-for-non-members: c86a480a0e890115
  related: 11038cb6350e41bc
title_source: 5ac608aa42806d13
title_generated: 8c7c97249e5996da
---

<!-- translation-section: introduction -->

# Modelos de discussão

Os modelos de discussão ajudam seu grupo a iniciar discussões da mesma maneira a cada vez. Um modelo pode fornecer um título, contexto, tags e instruções para a pessoa que inicia a discussão. Ele também define configurações padrão, como notificar ou não todo o grupo e quais enquetes sugerir.

Toda nova discussão em um grupo começa a partir de um modelo. Quando alguém seleciona **Iniciar discussão**, o Loomio mostra os modelos do grupo. Até o **Modelo em branco** é um modelo, então seu grupo também pode alterar suas configurações padrão.

Os modelos funcionam bem para processos que seu grupo repete, como revisões de projetos, processos de aconselhamento, preparação de reuniões, decisões de financiamento ou aprovações de documentos. A pessoa que inicia a discussão ainda pode editar tudo antes de iniciá-la.

<!-- translation-section: how-templates-are-used -->

## Como os modelos são usados

1. Um membro seleciona **Iniciar discussão** na página do grupo.
2. O Loomio lista os modelos visíveis do grupo. Cada um mostra seu título e subtítulo.
3. O membro seleciona um modelo. O Loomio abre o formulário de nova discussão, preenchido com os dados do modelo.
4. A ajuda do modelo aparece no topo do formulário como orientação.
5. O membro edita o título, contexto, tags e lista de convidados e, em seguida, seleciona **Iniciar discussão**.

![](list.png)

Alterar um modelo afeta apenas as discussões iniciadas após a alteração. As discussões já iniciadas a partir dele mantêm seu conteúdo e suas configurações.

<!-- translation-section: choose-who-is-notified-by-default -->

## Escolha quem recebe notificações por padrão

A configuração **Convidar** controla quem o formulário de nova discussão convida por padrão. Ela tem duas opções:

- **Todos no grupo**: o grupo aparece no campo **Convidar** do formulário de discussão, e todos os membros recebem uma notificação quando a discussão começa.
- **Nenhum**: o campo **Convidar** começa vazio. Ninguém recebe uma notificação, a menos que o autor adicione pessoas.

Os modelos incluídos no Loomio, inclusive o **Modelo em branco**, usam **Todos no grupo**. Se seu grupo não quiser que toda nova discussão notifique todos os membros, edite os modelos que seu grupo usa e defina **Convidar** como **Nenhum**.

![](use.png)

O autor sempre pode alterar a lista de convidados antes de iniciar a discussão. Ele pode remover o grupo para não notificar ninguém ou adicionar pessoas específicas. Essa configuração afeta apenas as notificações. Os membros do grupo ainda podem encontrar e ler a discussão no grupo, independentemente da opção que você escolher.

O grupo só é adicionado à lista de convidados quando o autor tem permissão para notificar todo o grupo. Os admins sempre podem fazer isso. Os membros podem fazer isso quando **Os membros podem notificar todos no grupo** está ativado nas permissões do grupo.

<!-- translation-section: template-settings -->

## Configurações do modelo

Os admins do grupo podem editar um modelo pelo menu de ações ao lado dele na lista de modelos. O formulário tem estas configurações:

![](form.png)

- **Título do modelo**: o nome curto mostrado na lista de modelos.
- **Modelo de legenda**: uma linha explicando quando usar o modelo.
- **Ajuda de modelo**: instruções mostradas no topo do formulário de nova discussão. Use esse campo para explicar o processo e incluir links para recursos. Ele não faz parte da discussão.
- **Grupo**: define se o modelo inicia uma discussão no grupo ou uma discussão direta. Uma discussão direta fica visível apenas para as pessoas convidadas.
- **Título padrão**: um título preenchido em cada nova discussão. O autor pode editá-lo.
- **Título de exemplo**: um exemplo mostrado em um campo de título vazio. Use esse campo quando um título padrão não for adequado para todas as discussões.
- **Tags**: tags aplicadas a cada nova discussão. O autor pode removê-las.
- **Contexto**: o texto inicial da discussão. Use títulos, perguntas ou links para orientar o que as pessoas escrevem.
- **Convidar**: define se todos no grupo são convidados por padrão. Veja [Escolha quem recebe notificações por padrão](#choose-who-is-notified-by-default).
- **Modelos de enquete**: enquetes sugeridas para esse processo. Elas são listadas no formulário de nova discussão. Também aparecem primeiro quando alguém inicia uma enquete na discussão. Elas não começam automaticamente.
- **Permitir votações simultâneas**: define se mais de uma enquete pode ficar aberta na discussão ao mesmo tempo.
- **Limite de comprimento do comentário**: um limite máximo opcional para o comprimento dos comentários.

Use um título padrão apenas quando ele continuar sendo adequado. Caso contrário, escreva um título de exemplo que incentive o autor a identificar a revisão, o período, o documento ou a decisão em questão.

<!-- translation-section: example-bottle-trial-review -->

## Exemplo: avaliação do teste de garrafas

A Oatmilk Cooperative avalia seu teste de garrafas retornáveis após cada ciclo. Seu modelo se chama "Avaliação do teste de garrafas" e tem um título padrão. Ele adiciona a tag "Teste de garrafas". Seu contexto pede aos membros que leiam o relatório semanal e considerem as taxas de devolução, os registros de lavagem, os comentários das cafeterias e os custos de transporte. Ele recomenda uma verificação de opinião seguida de Consentimento.

Isso funciona como modelo porque o objetivo e as evidências permanecem os mesmos em cada ciclo. Apenas as observações e decisões mudam.

<!-- translation-section: create-a-template -->

## Crie um modelo

Os admins do grupo podem selecionar **Novo modelo** na lista de modelos. Escolha um exemplo da galeria do Loomio ou comece com um modelo em branco, depois adapte-o e salve-o.

Você pode pesquisar ou filtrar a galeria. Um exemplo só é adicionado ao seu grupo quando você o salva.

<!-- translation-section: manage-the-template-list -->

## Gerencie a lista de modelos

Quando um grupo é criado, o Loomio adiciona um conjunto de modelos adequado ao tipo de grupo. Apenas **Modelo em branco** e **Discussão prática** ficam visíveis inicialmente. Os outros ficam ocultos, e os admins podem torná-los visíveis.

Os admins do grupo podem usar o menu de ações ao lado de um modelo para:

- editar seu conteúdo e suas configurações;
- ocultá-lo da lista de modelos;
- torná-lo visível a partir de **Modelos ocultos**;
- reorganizar a ordem dos modelos visíveis;
- exportá-lo como um arquivo JSON; ou
- excluí-lo.

Ocultar um modelo mantém o modelo disponível para uso posterior. Excluir um modelo não exclui as discussões iniciadas a partir dele.

<!-- translation-section: share-templates-between-groups -->

## Compartilhe modelos entre grupos

Selecione **Exportar JSON** no menu de ações de um modelo para baixá-lo como arquivo. Para usá-lo em outro grupo, selecione **Novo modelo** e depois **Importar JSON**. O formulário abre com o conteúdo importado para que você possa revisá-lo antes de salvar.

Os links para modelos de enquete personalizados não são incluídos no arquivo. Exporte e importe esses modelos de enquete separadamente.

<!-- translation-section: let-members-create-templates -->

## Permita que os membros criem modelos

Por padrão, apenas os admins do grupo podem criar e editar modelos. Um admin pode ativar **Os membros podem criar modelos.** em **Configurações do grupo** → **Permissões**.

Quando essa permissão está ativada, os membros podem criar modelos de discussão e de enquete e editar os modelos que criaram. Os admins podem editar todos os modelos do grupo. O modelo de um membro aparece na lista de modelos do grupo assim que é salvo, então combine práticas de nomeação e revisão antes de ativar essa permissão.

<!-- translation-section: templates-for-non-members -->

## Modelos para quem não é membro

Se **Quem não é membro pode iniciar discussões.** estiver ativado, as pessoas de fora do grupo escolhem na mesma lista de modelos. O formulário de discussão dessas pessoas nunca convida o grupo por padrão. Veja [Receba contribuições privadas](/en/user_manual/discussions/private_submissions).

<!-- translation-section: related -->

## Veja também

- [Modelos de enquete](/en/user_manual/polls/poll_templates)
