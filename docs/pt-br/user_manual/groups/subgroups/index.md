---
title: Subgrupos
source_revision: cd2e1e63e611688362e80009f50b8ed25025ba8b
source_file: docs/en/user_manual/groups/subgroups/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-07'
sections:
  introduction: 63e6e23d24e80919
  add-a-subgroup: 0bc0e5f99eb074c3
  subgroup-settings: 737225cc4bebe7e8
  privacy: 5bdd92ce200f197a
  permissions: ee02991523f1ebe4
  find-subgroups: 5e6fc5a5122c1417
  invite-to-a-subgroup: 0af670e1e9b32a5e
  simultaneously-invite-people-to-subgroups-and-parent-group: 1991604900321cd7
  administer-a-subgroup: 58fa95833f79dd01
  delete-a-subgroup: 2c6e76ec78386443
generated:
  introduction: a88e3fa4a86a5335
  add-a-subgroup: 649cc0b103deb2fe
  subgroup-settings: 8cd85ca7ab755581
  privacy: ecccf5440288f0bc
  permissions: cf1a9b0e6e22aa7a
  find-subgroups: 6ea0c3e8f7fba638
  invite-to-a-subgroup: 3a778b646e5c0ebc
  simultaneously-invite-people-to-subgroups-and-parent-group: 5346ce02660bfea7
  administer-a-subgroup: 0e5cbfe90a42f546
  delete-a-subgroup: db2b287cc793c863
title_source: 9f81e728f70cae3e
title_generated: d54ff4541651eb81
---

<!-- translation-section: introduction -->

# Subgrupos

Os subgrupos ajudam você a organizar a comunicação e os membros para que as pessoas certas participem do trabalho em conjunto.

Por exemplo, uma organização pode ter os seguintes subgrupos:
- conselho de governança
- equipe de trabalho ou grupo de trabalho de um projeto
- um tema (como 'estratégia' ou 'aprendizagem')

Os subgrupos funcionam como os grupos, mas ficam dentro do seu grupo principal. A maioria dos recursos e configurações disponíveis é igual à do grupo principal. Isso também significa que uma pessoa pode ser membro do seu subgrupo, como o conselho, sem ser membro do seu grupo principal.

<!-- translation-section: add-a-subgroup -->

## Adicionar um subgrupo

>[!Note]
>A permissão para adicionar novos subgrupos faz parte das [configurações de permissões](/en/user_manual/groups/settings/permissions) do grupo. Por padrão, apenas admins podem iniciar novos subgrupos.

Para adicionar um subgrupo, acesse a página do seu grupo principal e clique em **Novo subgrupo** na barra lateral.  

![Botão Novo subgrupo na barra lateral da Cooperativa Oatmilk](subgroups-sidebar.png)

Clique no botão **Novo subgrupo**, dê um nome ao subgrupo e selecione a configuração de privacidade. Depois, clique em **Iniciar subgrupo**.

![Formulário de novo subgrupo para o Grupo de Trabalho de Embalagens](subgroups_new.png)

Quando estiver pronto, [convide pessoas](/en/user_manual/groups/inviting_people/) para o subgrupo.

Você pode editar as [configurações do grupo](/en/user_manual/groups/settings/) do subgrupo clicando no ícone de engrenagem na página do subgrupo.

![Ação para editar as configurações do grupo no Grupo de Trabalho de Embalagens](subgroups_edit_group_settings.png)

<!-- translation-section: subgroup-settings -->

## Configurações do subgrupo

<!-- translation-section: privacy -->

### Privacidade

Escolha quem pode encontrar o subgrupo separadamente de como as pessoas entram nele:

| Privacidade | Quem pode encontrá-lo | Quem pode ler suas conversas |
| --- | --- | --- |
| **Aberto** | Qualquer pessoa | Qualquer pessoa |
| **Fechado** | Qualquer pessoa | Membros do subgrupo e convidados |
| **Visível para o grupo principal** | Membros do grupo principal e membros do subgrupo | Membros do subgrupo e convidados |
| **Secreto** | Membros convidados para o subgrupo | Membros do subgrupo e convidados |

Para permitir que membros do grupo principal entrem por conta própria, selecione **Visível para o grupo principal** e depois **Membros de [grupo principal] podem entrar sem aprovação** em **Como as pessoas participam?** ao criar o subgrupo, ou em **Editar configurações do grupo → Privacidade**. Pessoas de fora do grupo principal precisam de um convite. Os membros podem sair do subgrupo e entrar novamente enquanto ainda fizerem parte do grupo principal.

![Configurações de privacidade do subgrupo com visibilidade para o grupo principal e entrada sem aprovação](subgroups_privacy_settings.png)

Ao entrar, a pessoa se torna um membro comum do subgrupo. Isso não a torna admin nem altera a privacidade das conversas existentes.

Subgrupos públicos também podem permitir entrada imediata; qualquer pessoa pode entrar quando essa opção está selecionada. Quando o grupo principal é privado, as configurações disponíveis para o subgrupo são **Visível para o grupo principal** e **Secreto**.

Um subgrupo **Visível para o grupo principal** permanece privado quando seu grupo principal se torna público. Tornar um grupo principal privado restringe o acesso aos seus subgrupos públicos aos membros do grupo principal e torna as conversas desses subgrupos privadas, mantendo os subgrupos secretos como estão.

[Leia sobre a privacidade dos grupos aqui](/en/user_manual/groups/settings/privacy).

<!-- translation-section: permissions -->

### Permissões

Os subgrupos funcionam de forma independente do grupo principal. Por exemplo, se a configuração de privacidade do subgrupo for **Secreto**, apenas os membros convidados poderão encontrar esse subgrupo, ver quem faz parte dele e ver as conversas.

Subgrupos **Fechados** e subgrupos com a configuração **Visível para o grupo principal** podem permitir que membros do grupo principal leiam conversas privadas antes de entrar no subgrupo. Ative **Membros de [grupo principal] podem ver conversas privadas** em **Permissões**. Esses leitores não ganham direito a voto nem se tornam membros do subgrupo.

![Configuração que permite aos membros do grupo principal ver conversas privadas do subgrupo](subgroups_private_threads_settings.png)

<!-- translation-section: find-subgroups -->

## Encontrar subgrupos

Abra o menu lateral e clique no nome do seu grupo para ver os subgrupos dele.

![Subgrupos da Cooperativa Oatmilk listados na barra lateral](subgroups_find_subgroups.png)

<!-- translation-section: invite-to-a-subgroup -->

## Convidar para um subgrupo

Convide pessoas para um subgrupo da mesma forma que você as convida para um grupo. Se elas já fizerem parte de um grupo principal ou de outro subgrupo da mesma organização da qual você também faz parte, você pode digitar o nome delas ou selecionar esse grupo como público. Selecione o marcador do público para expandi-lo em pessoas individuais e remova quem você não deseja convidar.

<!-- translation-section: simultaneously-invite-people-to-subgroups-and-parent-group -->

### Convidar pessoas para subgrupos e para o grupo principal ao mesmo tempo

Se você usar o botão **Convidar pessoas** na aba **Membros** do seu grupo principal, poderá convidar pessoas para vários subgrupos ao mesmo tempo, marcando as caixas dos subgrupos nos quais deseja que elas entrem imediatamente.

![Seleção do grupo principal e do subgrupo no formulário de convite](group_invite_email_subgroups.png)

<!-- translation-section: administer-a-subgroup -->

## Administrar um subgrupo

Os subgrupos podem ter seus próprios admins, que podem ser diferentes dos admins do grupo principal.

No entanto, um admin do grupo principal pode se tornar admin de qualquer subgrupo. Isso ajuda os administradores do grupo principal a administrar os subgrupos conforme necessário.

Acesse a aba Subgrupos, encontre o subgrupo e clique em **Entrar no grupo**.

![Botão Entrar no grupo em um subgrupo fechado](member_join_subgroup.png)

Depois de entrar no subgrupo como membro, um admin do grupo principal pode se tornar admin do subgrupo.

![Ação para tornar admin um admin do grupo principal](member_make_admin.png)

<!-- translation-section: delete-a-subgroup -->

## Excluir um subgrupo

Admins podem excluir um subgrupo da mesma forma que você exclui um grupo. Ao excluir um subgrupo, tome cuidado para não excluir o grupo principal.

Saiba [como excluir grupos](/en/user_manual/groups/deleting_your_group/).
