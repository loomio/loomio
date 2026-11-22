---
title: Matrix
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/integrations/matrix/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
sections:
  introduction: 114ab8c916ca5fba
generated:
  introduction: 7f464dcf3dc335f2
title_source: 76a2171c057b730f
title_generated: 76a2171c057b730f
---

<!-- translation-section: introduction -->

# Integração com o Matrix

O Loomio pode enviar notificações para uma sala do Matrix quando houver novas discussões, enquetes, comentários, votos e conclusões. Você precisa ser admin do grupo para adicionar uma integração de bate-papo.

Diferentemente das outras integrações de bate-papo do Loomio, o Matrix não usa um webhook. O Loomio se conecta por meio de uma conta de usuário do Matrix que atua como bot e publica mensagens formatadas na sua sala.

Neste guia, usamos o Element.

---

1. Crie uma conta de usuário no Matrix para o Loomio, entre com essa conta no Element e convide essa conta para a sala do Matrix onde você quer receber notificações. Mantenha essa sessão conectada — sair da conta invalida o token de acesso.

2. No seu grupo do Loomio, abra o menu do grupo, selecione **Integrações de bate-papo** e adicione uma integração de bate-papo com o **Matrix**.

   ![menu do bot do Matrix no Loomio](loomio-add-matrix-bot.png)

   ![formulário do bot do Matrix no Loomio](loomio-matrix-bot-form.png)

3. No Element, abra o menu da conta do bot e selecione **Todas as configurações**.

   ![menu de configurações do Matrix](matrix-settings-menu.png)

4. Abra **Ajuda e sobre** e role até a seção **Avançado**.

   ![configurações do Matrix](matrix-settings.png)

5. Copie o **Token de acesso** e cole no formulário do Loomio.

   ![token de acesso do Matrix](matrix-access-token.png)

6. Abra o menu **Configurações** da sala e vá para **Avançado**.

   ![configurações da sala do Matrix](matrix-room-settings.png)

7. Copie o **ID interno da sala**, cole no formulário do Loomio e salve a integração.

   ![ID da sala do Matrix](matrix-room-id.png)
