---
title: Gestão de membros
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/groups/member_management/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
sections:
  introduction: bc7d2de9abc2ea86
  administering-your-group: 7ae1b105c20977fc
  managing-subgroups: 2e4bdee3283e8ef8
  removing-members: d70807bdd968d594
  leaving-group: 268f0c735b8e46d7
  set-title: eb9a52e3d6c21d43
  member-email-addresses: 0e800419a7bdacc6
generated:
  introduction: 40569bd8c705e801
  administering-your-group: 1dd3c7b80e9f9a0d
  managing-subgroups: 115711aea17202e9
  removing-members: dcd913321cdfe87b
  leaving-group: 66470ad479c1dead
  set-title: 5a665487a9e8f7d8
  member-email-addresses: 9428295fb6e1655d
title_source: 23ac3a7fe9ee72a2
title_generated: 01e14267068e4466
needs_review:
  managing-subgroups: check the interface label "**Secreto**" for "**Secret**"
---

<!-- translation-section: introduction -->

# Gestão de membros

Os admins do grupo gerenciam os membros na aba **Membros** da página do grupo. Abra o menu de ações ao lado de um membro para definir seu cargo, torná-lo admin do grupo, torná-lo delegado ou removê-lo do grupo.

![Menu de ações de um membro na página de membros da Oatmilk Cooperative](member_management.png)

<!-- translation-section: administering-your-group -->

## Administração do seu grupo

Um grupo do Loomio tem duas funções: **membro** e **admin do grupo**.

Os admins do grupo podem adicionar e remover membros, gerenciar as permissões dos membros, alterar as configurações de privacidade do grupo, gerenciar assinaturas, ver os endereços de email dos membros e exportar os dados do grupo.

A pessoa que cria um grupo se torna admin do grupo por padrão. Recomendamos ter pelo menos dois admins do grupo para que sempre haja alguém que possa gerenciar o grupo. Um grupo pode ter quantos admins você precisar.

Para promover um membro, abra o menu de ações ao lado do nome dele na aba **Membros** e selecione **Tornar Admin**.

![Ação Tornar Admin no menu de um membro](member_make_admin.png)

<!-- translation-section: managing-subgroups -->

## Gestão de subgrupos

Admins do grupo principal podem entrar em qualquer subgrupo não secreto e depois se tornar admins desse subgrupo.

Selecione **Entrar no grupo** na página do subgrupo.

![Botão Entrar no grupo em um subgrupo fechado da Oatmilk Cooperative](member_join_subgroup.png)

Depois que você se tornar membro do subgrupo, abra o menu de ações ao lado do seu nome na aba **Membros** e selecione **Tornar Admin**.

>[!Note]
>Isso não se aplica a [subgrupos **Secretos**](/en/user_manual/groups/subgroups#permissions).

<!-- translation-section: removing-members -->

## Remoção de membros

Para remover alguém, abra o menu de ações ao lado do nome da pessoa e selecione **Eliminar do grupo**.

![Ação Eliminar do grupo no menu de um membro](member_remove.png)

Quando uma pessoa é removida de um grupo:

- Ela perde o acesso ao grupo e aos seus subgrupos e deixa de receber notificações do grupo.
- Seus comentários e votos existentes permanecem intactos.
- As enquetes privadas desaparecem do painel e da lista de votação da pessoa. As enquetes públicas continuam disponíveis para leitura, mas ela só pode votar se for convidada a voltar. Sair enquanto uma enquete está encerrada não preserva o direito de votar caso ela seja reaberta.

Você pode adicionar os membros removidos novamente mais tarde. Ao retornar ao grupo, eles recuperam o acesso e seus votos existentes nas enquetes ativas.

<!-- translation-section: leaving-group -->

## Sair do grupo

Para sair de um grupo, abra o menu de ações do grupo e selecione **Sair do grupo**.

Sair do grupo tem o mesmo efeito sobre o acesso ao grupo e aos subgrupos que a remoção por um admin do grupo.

![Ação Sair do grupo no menu de configurações da Oatmilk Cooperative](member_leave_group.png)

<!-- translation-section: set-title -->

## Configurar o título

O cargo de um membro indica sua função no grupo ou a organização que ele representa. Você ou um admin do grupo pode definir ou alterar seu cargo selecionando **Configurar o título** no menu de ações ao lado do seu nome na aba **Membros**.

![Ação Configurar o título no menu de um membro](member_set_title.png)

Você pode ter cargos diferentes em subgrupos diferentes.

<!-- translation-section: member-email-addresses -->

## Endereços de email dos membros

Somente os admins do grupo podem ver os endereços de email dos membros.

Para conferir todos os endereços de email dos membros do grupo e dos seus subgrupos, [exporte os dados do grupo](/en/user_manual/groups/data_export) como um arquivo CSV e abra o arquivo no Microsoft Excel ou no Google Sheets.

Você também pode buscar membros pelo endereço de email na aba **Membros** para encontrar e gerenciar uma pessoa específica.
