---
title: Privacidade
source_revision: cd2e1e63e611688362e80009f50b8ed25025ba8b
source_file: docs/en/user_manual/groups/settings/privacy.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-07'
sections:
  introduction: 72b58ba22851f914
  open: 1727e8f20fe92fb2
  follow-an-open-group: e4a1b3ce35a974d0
  closed: 53c3d50151a2115b
  secret: fcb55fcb64d44881
  how-people-join: f61d4f7e0f88106a
  group-directory: 4ef3023e3cf4efdf
  visible-to-parent-group: a9a3ece6458f080e
generated:
  introduction: 14c9627d9e88758c
  open: 2e65a7ac5f47fef4
  follow-an-open-group: 50424edf05d5252e
  closed: b39a8fa3c9e1cb77
  secret: f8324ba4c9c824be
  how-people-join: 36aaf0c7c21c7224
  group-directory: '096d5cc0df912a1f'
  visible-to-parent-group: b50bd32b412657c2
title_source: 54a57c3147c49f33
title_generated: 2bb2d8436a5c0668
---

<!-- translation-section: introduction -->

# Privacidade do grupo

A privacidade controla quem pode encontrar um grupo e quem pode ler seu conteúdo. Na página do grupo, abra **Editar configurações do grupo** e selecione **Privacidade**.

![Configurações de privacidade do grupo](group_privacy_settings.png#width-90)

Alterar a privacidade pode expor ou ocultar o conteúdo existente do grupo, não apenas o conteúdo criado depois. Escolha a configuração mais restritiva que ainda atenda ao propósito do grupo.

<!-- translation-section: open -->

## Aberto

Grupos abertos são espaços públicos. Qualquer pessoa pode encontrar o grupo e ler suas discussões, enquetes e arquivos. A lista de membros permanece visível apenas para os membros.

Grupos abertos podem permitir a entrada imediata de pessoas, exigir aprovação ou aceitar apenas pessoas convidadas.

<!-- translation-section: follow-an-open-group -->

### Acompanhar um grupo aberto

As pessoas podem acompanhar as novidades de um grupo aberto sem entrar nele. Ao acompanhar o grupo, suas atividades não lidas são incluídas no e-mail de resumo, para que cada pessoa possa consultá-las quando quiser. Acompanhar o grupo não torna a pessoa um membro, não concede os direitos de voto dos membros nem gera notificações imediatas por si só.

Ative **Acompanhe as atualizações** na página do grupo para incluir discussões, comentários, enquetes e outras atividades não lidas das conversas no seu e-mail de resumo. Desative a configuração para deixar de incluir o grupo.

![Acompanhar as atualizações de um grupo aberto](group_follow_updates.png)

<!-- translation-section: closed -->

## Fechado

Qualquer pessoa pode encontrar um grupo fechado e ler seu nome e sua descrição. Discussões, enquetes, arquivos e a lista de membros são acessíveis apenas aos membros e convidados.

Grupos principais fechados podem permitir que as pessoas solicitem a entrada ou aceitar apenas pessoas convidadas. Não podem permitir a entrada imediata sem aprovação.

Subgrupos fechados também podem permitir que qualquer pessoa entre sem aprovação. Para limitar a descoberta do subgrupo e a entrada imediata aos membros do grupo principal, selecione **Visível para o grupo principal**.

Um subgrupo fechado pode permitir que membros do grupo principal leiam suas discussões sem entrar no subgrupo.

<!-- translation-section: visible-to-parent-group -->

## Visível para o grupo principal

Esta configuração permite que membros do grupo principal encontrem o subgrupo, mantendo suas conversas acessíveis apenas aos membros do subgrupo e convidados. Pessoas que não pertencem a nenhum dos dois grupos não podem encontrá-lo, mesmo quando o grupo principal é público.

Selecione **Visível para o grupo principal** e depois **Membros de [grupo principal] podem entrar sem aprovação** para permitir que membros do grupo principal entrem por conta própria. Ao entrar, a pessoa se torna um membro comum do subgrupo, com acesso às suas conversas privadas. Também estão disponíveis as opções de entrada mediante aprovação ou apenas por convite.

O subgrupo mantém essa visibilidade quando o grupo principal se torna público. Se o grupo principal se tornar privado, seus subgrupos públicos passam a ser **Visíveis para o grupo principal** e suas conversas se tornam privadas. Subgrupos secretos continuam secretos. Subgrupos existentes que antes eram identificados como fechados em um grupo principal privado agora aparecem como **Visíveis para o grupo principal**, sem alteração no acesso existente.

Para permitir que membros do grupo principal leiam conversas privadas antes de entrar, ative **Membros de [grupo principal] podem ver conversas privadas** em **Permissões**. Isso concede acesso de leitura, sem tornar essas pessoas membros do subgrupo nem conceder direitos de voto.

<!-- translation-section: secret -->

## Secreto

Grupos secretos e seu conteúdo são visíveis apenas para pessoas que foram convidadas ou adicionadas. A entrada no grupo é feita apenas por convite. Grupos secretos não aparecem no diretório público de grupos.

Um grupo principal secreto permite apenas subgrupos com a configuração **Visível para o grupo principal** ou **Secreto**. Seus subgrupos não podem ser abertos ou fechados.

<!-- translation-section: how-people-join -->

## Como as pessoas entram

A privacidade determina quais opções de entrada estão disponíveis:

| Privacidade do grupo | Opções de entrada disponíveis |
| --- | --- |
| **Aberto** | Entrada livre, mediante aprovação ou apenas por convite |
| **Grupo principal fechado** | Mediante aprovação ou apenas por convite |
| **Subgrupo fechado** | Entrada livre, mediante aprovação ou apenas por convite |
| **Visível para o grupo principal** | Entrada de membros do grupo principal, mediante aprovação ou apenas por convite |
| **Secreto** | Apenas por convite |

A entrada imediata segue a visibilidade do grupo. Em um subgrupo público, qualquer pessoa pode entrar. Em um subgrupo **Visível para o grupo principal**, membros do grupo principal podem entrar. Os membros podem sair e entrar novamente enquanto continuarem atendendo aos critérios de entrada. Alterar como as pessoas entram não muda quem pode ler conversas privadas antes de entrar.

Quando a aprovação é necessária, as pessoas selecionam **Entrar no grupo**, respondem à pergunta de entrada do grupo e enviam uma solicitação para entrar. Consulte [Convidar pessoas](/en/user_manual/groups/inviting_people#request-to-join-group) para obter instruções sobre como configurar a pergunta, analisar solicitações e convidar pessoas diretamente.

<!-- translation-section: group-directory -->

## Diretório de grupos

Grupos principais abertos e fechados podem ser listados no diretório público de grupos para que as pessoas possam encontrá-los. A inclusão no diretório não altera quem pode ler o conteúdo do grupo ou se tornar membro. Subgrupos e grupos secretos não podem ser listados.
