---
title: Tags de categoria
source_revision: 95ce9afd64c99656f67e05a09fa9fc8a77af51d7
source_file: docs/help/en/user_manual/discussions/tags/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-26'
sections:
  introduction: 6cccb1690d444dd2
  apply-tags: dfa06440d6c97396
  create-tags: 97aa7a1a0f420951
  edit-tags: bb9dfb8a5abe7a27
  edit-tag-in-thread-or-poll: b71467aa1248d110
  template-tags: 3ddcc6c204aa843f
  tag-contributions: b42bdd723f9d5ddc
  find-tagged-contributions: 98ec0cbfdec75f7f
  global-search: 5a7777699988e006
generated:
  introduction: 0b467964702ed2e8
  apply-tags: 1e78c439f57bfcb0
  create-tags: fa79bd5cb647d506
  edit-tags: f72245cad3e240cb
  edit-tag-in-thread-or-poll: 4893f3b614fe93a9
  template-tags: ee496375e1c3a263
  tag-contributions: bdfd4a5853fb37cb
  find-tagged-contributions: f1b54c149c4c6489
  global-search: 925891755789061d
title_source: c86f6830bf302394
title_generated: '04853111899cd0c4'
needs_review:
  global-search: use "enquete" instead of "pesquisa" for "poll"
---

<!-- translation-section: introduction -->

# Tags de categoria

As tags de categoria ajudam você a encontrar discussões, enquetes, conclusões e comentários sobre um assunto ou área de trabalho.

As tags pertencem a toda a organização. Uma tag criada em um grupo principal é compartilhada com seus subgrupos, para que você possa acompanhar trabalhos relacionados entre os grupos. O Loomio lista as tags em ordem alfabética, com um ponto colorido ao lado de cada nome.

Em **Todos os grupos** ou na página de um grupo, selecione **Tags** acima da lista de conversas, enquetes ou tarefas e escolha uma tag para mostrar itens com essa tag. Digite no campo de filtro para pesquisar em uma lista longa.

![](tags_view.png)

<!-- translation-section: apply-tags -->

## Aplicar tags

Você pode aplicar tags às suas próprias discussões, enquetes, conclusões e comentários. Admins de grupo, admins de conversa e pessoas com permissão para editar o contexto da discussão podem aplicar tags a qualquer item em uma conversa desbloqueada. Em conversas diretas, todos os participantes podem aplicar tags a qualquer item.

Ao iniciar uma conversa ou enquete, selecione o campo **Tags** e escolha uma ou mais tags.

![](tags_add_new.png)

Comece a digitar para filtrar a lista. Selecione uma tag novamente ou selecione **×** na tag para removê-la.

<!-- translation-section: create-tags -->

## Criar tags

Quem pode criar tags depende das funções e permissões no grupo:

- **Admins do grupo principal** sempre podem criar tags para o grupo principal e seus subgrupos.
- **Admins de subgrupos** podem criar tags ao aplicar tags ao conteúdo do seu subgrupo.
- **Membros do Grupo** que podem aplicar tags ao conteúdo também podem criar tags enquanto a permissão **Os membros podem criar etiquetas.** estiver ativada (ativada por padrão). Se um admin do grupo desativá-la, os membros só poderão usar tags existentes da organização e tags padrão de modelos desse grupo.

Para criar uma tag ao iniciar uma conversa ou enquete, digite seu nome no campo **Tags** e pressione Enter.

![criar nova tag](tags_create_new.png)

![nova tag criada](tags_created_new.png)

Use nomes curtos e reconhecíveis, como Finanças, Governança, Embalagens ou Parcerias com cafeterias.

<!-- translation-section: template-tags -->

## Tags em modelos

Os modelos de discussão e enquete armazenam nomes de tags padrão. Qualquer pessoa que possa criar ou editar um modelo pode alterar suas tags padrão. Salvar um modelo não adiciona esses nomes à lista de tags da organização, e renomear ou deletar uma tag da organização não altera os padrões dos modelos.

Quando alguém inicia uma discussão ou enquete a partir de um modelo, o Loomio aplica as tags correspondentes da organização ou cria novas tags se o autor tiver permissão:

- **Membros que podem criar tags** mantêm todas as tags padrão do modelo.
- **Membros sem permissão para criar tags** mantêm as tags existentes da organização e quaisquer tags padrão definidas por modelos no grupo de destino. Os nomes de tags de um modelo de outro grupo que não correspondam a essas tags são descartados.

<!-- translation-section: edit-tags -->

## Editar tags

Somente admins do grupo principal podem renomear, alterar as cores, mesclar ou deletar tags. As alterações se aplicam a toda a organização, incluindo todos os subgrupos.

Na página do grupo, abra **Tags** e selecione **Editar tags**, ou abra **Configurações** e selecione **Categorização por tags**.

![editar tags de categoria](tags_edit_new.png)

Selecione o ícone de lápis ao lado de uma tag para editá-la.

![editar tags de categoria](tags_edit_new_pencil.png)

Altere o nome da tag ou escolha uma cor e selecione **Salvar**.

![editar cor da tag](tags_edit_name.png)

Para mesclar uma tag com outra, selecione o ícone de mesclagem ao lado dela e escolha a tag que deseja manter. Todos os itens com a tag antiga passam a usar a tag escolhida.

Para deletar uma tag, selecione **Deletar** (ou o ícone de lixeira). Isso remove a tag de todas as discussões, enquetes, conclusões e comentários da organização.

![deletar tag](tags_delete.png)

<!-- translation-section: edit-tag-in-thread-or-poll -->

### Editar tags em uma conversa ou enquete

Para alterar as tags de uma conversa ou enquete existente, abra a conversa ou enquete e selecione o botão de tags ao lado das tags atuais, perto do título.

Selecione tags para adicioná-las ou removê-las. As alterações são salvas imediatamente.

O seletor lista as tags usadas no grupo atual, as tags da organização que não estão em uso e as tags selecionadas para o item. Em uma organização com vários grupos, selecione **Mostre tags de outros grupos** para incluir tags usadas apenas em outros grupos ou **Mostrar etiquetas usadas neste grupo** para restringir a lista novamente.

![editar tags na conversa](tags_thread_edit.png)

<!-- translation-section: tag-contributions -->

## Aplicar tags a contribuições

Abra o menu de três pontos (**⋯**) de uma enquete, conclusão ou comentário e selecione **Aplicar tags**. Adicione ou remova tags no seletor; as alterações são salvas imediatamente. Quando uma contribuição tem tags, elas e o botão de tags aparecem à direita da linha de identificação do autor.

As tags se aplicam ao item que você seleciona. Não é possível aplicar tags a votos ou cédulas de votação.

<!-- translation-section: find-tagged-contributions -->

## Encontrar contribuições com tags

Quando um comentário, enquete ou conclusão dentro de uma conversa tem uma tag, uma seção **Tags** aparece na barra lateral da conversa (ou no painel de navegação no celular).

Selecione uma tag para filtrar a conversa e mostrar os itens correspondentes e os itens aos quais eles respondem. Para voltar à conversa completa, selecione **×** na barra de filtro, selecione a tag novamente ou selecione **Limpar** na barra lateral.

![Tags na barra lateral da conversa](tags_thread_sidebar.png)

<!-- translation-section: global-search -->

## Pesquisar por tag

Abra **Pesquisar** na navegação superior e selecione seu grupo principal para exibir o menu de tags. Escolha uma tag para encontrar discussões, enquetes, conclusões e comentários com essa tag.

Deixe o campo de pesquisa vazio para navegar por tag ou digite palavras-chave para pesquisar nos itens com essa tag. Selecione **Qualquer etiqueta** para limpar o filtro.

![Seleção de uma tag na pesquisa global após escolher o grupo principal](tags_global_search.png)
