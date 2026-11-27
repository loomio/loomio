---
title: Subgrupos
source_revision: 95ce9afd64c99656f67e05a09fa9fc8a77af51d7
source_file: docs/help/en/user_manual/groups/subgroups/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-26'
sections:
  introduction: c656e4398a0d0fef
  add-a-subgroup: d59b74cbe0493d41
  subgroup-settings: 737225cc4bebe7e8
  privacy: d66210a7ca87eb23
  permissions: b6dfa2fbf71913f7
  find-subgroups: 92ec11a817df2b5a
  invite-to-a-subgroup: 9c672e9470b07ca1
  simultaneously-invite-people-to-subgroups-and-parent-group: 34753576900578d3
  administer-a-subgroup: 20d279d47f1f0b49
  delete-a-subgroup: 4cc93cd908d342b9
  how-people-join: 4ea34789d1a261fd
generated:
  introduction: 3ae078e3e901a8b1
  add-a-subgroup: dfcd16d5e472e21f
  subgroup-settings: 8cd85ca7ab755581
  privacy: 7dfa0da7b40bc8a0
  permissions: b24d5289ce2031c1
  find-subgroups: 5c0dbb68069dd7e1
  invite-to-a-subgroup: 2be63922c96a7839
  simultaneously-invite-people-to-subgroups-and-parent-group: 373ea6168c5980f5
  administer-a-subgroup: 52ca98178e60c9b0
  delete-a-subgroup: 5ca9f2796a69c741
  how-people-join: 6aadfe3ad593eaa1
title_source: 9f81e728f70cae3e
title_generated: d54ff4541651eb81
---

<!-- translation-section: introduction -->

# Subgrupos

Os subgrupos ajudam você a organizar discussões e membros em torno de equipes ou temas específicos dentro de um grupo principal. Por exemplo, uma organização pode criar subgrupos para:

- Um conselho de governança
- Uma equipe de trabalho ou grupo de projeto
- Um tema como estratégia ou aprendizagem

Os subgrupos funcionam como os grupos comuns e têm a maioria dos mesmos recursos e configurações. Uma pessoa pode fazer parte de um subgrupo, como um conselho, sem fazer parte do grupo principal.

<!-- translation-section: add-a-subgroup -->

## Adicionar um subgrupo

>[!Note]
>Quem pode adicionar subgrupos é definido pelas [configurações de permissões](/en/user_manual/groups/settings/permissions) do grupo principal. Por padrão, apenas admins do grupo podem criar subgrupos.

Para criar um subgrupo, abra a página do seu grupo principal, selecione **Novo subgrupo** na barra lateral, digite um nome, escolha uma configuração de privacidade e selecione **Iniciar subgrupo**.

![Botão Novo subgrupo na barra lateral da Cooperativa Oatmilk](subgroups-sidebar.png)

![Formulário de novo subgrupo para o Grupo de Trabalho de Embalagens](subgroups_new.png)

Quando o subgrupo estiver pronto, [convide pessoas](/en/user_manual/groups/inviting_people) para entrar nele. Você pode alterar as [configurações do grupo](/en/user_manual/groups/settings) do subgrupo em **Configurações** na página do subgrupo.

![Ação para editar as configurações do grupo no Grupo de Trabalho de Embalagens](subgroups_edit_group_settings.png)

<!-- translation-section: subgroup-settings -->

## Configurações do subgrupo

<!-- translation-section: privacy -->

### Privacidade

Escolha quem pode encontrar o subgrupo e ler suas conversas:

| Privacidade | Quem pode encontrá-lo | Quem pode ler suas conversas |
| --- | --- | --- |
| **Aberto** | Qualquer pessoa | Qualquer pessoa |
| **Fechado** | Qualquer pessoa | Membros do subgrupo e convidados |
| **Visível para o grupo principal** | Membros do grupo principal e membros do subgrupo | Membros do subgrupo e convidados |
| **Secreto** | Membros convidados para o subgrupo | Membros do subgrupo e convidados |

A permissão **Membros do grupo principal podem ver conversas privadas** também permite que membros do grupo principal leiam as conversas do subgrupo sem entrar nele.

Quando o grupo principal é privado, os subgrupos só podem ser **Visíveis para o grupo principal** ou **Secretos**. Consulte [Privacidade dos grupos](/en/user_manual/groups/settings/privacy) para mais detalhes.

<!-- translation-section: how-people-join -->

### Como as pessoas entram

Escolha [como as pessoas entram](/en/user_manual/groups/settings/privacy#how-people-join) ao criar o subgrupo ou em **Configurações** > **Editar configurações do grupo** > **Privacidade**.

![Configurações de privacidade e entrada no subgrupo](subgroups_privacy_settings.png)

<!-- translation-section: permissions -->

### Permissões

Ative **Membros do grupo principal podem ver conversas privadas** em **Permissões** para permitir que membros do grupo principal leiam as conversas do subgrupo sem entrar nele. Esses leitores não ganham direito a voto nem se tornam membros do subgrupo.

![Configuração que permite aos membros do grupo principal ver conversas privadas do subgrupo](subgroups_private_threads_settings.png)

<!-- translation-section: find-subgroups -->

## Encontrar subgrupos

Selecione o nome do seu grupo principal na barra lateral para ver os subgrupos dele. Nas páginas **Conversas**, **Enquetes**, **Membros**, **Arquivos**, **Tarefas** e **Favoritos** do grupo principal, use o filtro **Subgrupos** para alternar entre **Só este grupo**, **Meus subgrupos** e **Todos os subgrupos**, ou acesse diretamente um subgrupo.

![Subgrupos da Cooperativa Oatmilk listados na barra lateral](subgroups_find_subgroups.png)

<!-- translation-section: invite-to-a-subgroup -->

## Convidar para um subgrupo

Você pode [convidar pessoas para um subgrupo](/en/user_manual/groups/inviting_people) da mesma forma que as convida para um grupo principal. Se elas já fizerem parte do grupo principal ou de outro subgrupo do qual você também faz parte, digite o nome delas ou selecione esse grupo. Depois, expanda o grupo em pessoas individuais e remova quem você não deseja convidar.

<!-- translation-section: simultaneously-invite-people-to-subgroups-and-parent-group -->

### Convidar pessoas para subgrupos e para o grupo principal ao mesmo tempo

Ao selecionar **Convidar** na aba **Membros** do seu grupo principal, marque os subgrupos nos quais você deseja que as pessoas convidadas entrem ao mesmo tempo.

![Seleção do grupo principal e do subgrupo no formulário de convite](group_invite_email_subgroups.png)

<!-- translation-section: administer-a-subgroup -->

## Administrar um subgrupo

Os subgrupos podem ter seus próprios admins de grupo, diferentes dos admins do grupo principal.

Um admin do grupo principal pode entrar em qualquer subgrupo que não seja secreto e se tornar admin desse subgrupo. Isso não se aplica a subgrupos secretos. Consulte [Gerenciar subgrupos](/en/user_manual/groups/member_management#managing-subgroups) para mais detalhes.

![Botão Entrar no grupo em um subgrupo fechado](member_join_subgroup.png)

![Ação para tornar admin um admin do grupo principal](member_make_admin.png)

<!-- translation-section: delete-a-subgroup -->

## Excluir um subgrupo

Admins do grupo podem excluir um subgrupo da mesma forma que [excluem um grupo](/en/user_manual/groups/deleting_your_group). Antes de excluir, certifique-se de que você está na página do subgrupo, e não na página do grupo principal.
