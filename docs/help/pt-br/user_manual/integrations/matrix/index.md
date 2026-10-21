---
title: Matrix
source_revision: c6076258c3438c0dd6dc8fbf1fc0b0df47c0aeb5
source_file: docs/en/user_manual/integrations/matrix/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: e54de0b6d9ea9ffb
generated:
  introduction: 4c0a2d56483ffef2
title_source: 76a2171c057b730f
title_generated: 76a2171c057b730f
---

<!-- translation-section: introduction -->

# Integração com o Matrix

O Loomio pode enviar notificações para seus canais do Matrix quando houver novas discussões, propostas, comentários, votos e conclusões.

O Matrix permite usar alguns elementos HTML na sala de bate-papo, e o Loomio aproveita esse recurso.

Nossa integração com o Matrix é um pouco diferente das nossas outras integrações de bate-papo: ela não usa um webhook. Criamos um cliente de bot específico para essa integração.

Você precisará criar uma conta de usuário no Matrix para o bot usar ao entrar.

Depois de criar a conta para o bot, entre com essa conta para obter as informações a seguir.

Neste guia, usamos o Element.

---

No seu grupo do Loomio, adicione uma integração de bate-papo com o Matrix
![menu do bot do Matrix no Loomio](loomio-add-matrix-bot.png)

Este é o formulário que você deve preencher
![formulário do bot do Matrix no Loomio](loomio-matrix-bot-form.png)

Comece por aqui para encontrar seu token de acesso
![menu de configurações do Matrix](matrix-settings-menu.png)

Esta é a página de configurações
![configurações do Matrix](matrix-settings.png)

Este é o token de acesso
![token de acesso do Matrix](matrix-access-token.png)

Agora você precisa do ID da sala
![configurações da sala do Matrix](matrix-room-settings.png)

Ele está aqui.
![ID da sala do Matrix](matrix-room-id.png)
