---
title: Endereço de e-mail
source_revision: 95ce9afd64c99656f67e05a09fa9fc8a77af51d7
source_file: docs/help/en/user_manual/groups/email/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-26'
sections:
  introduction: 36b06c5b4604ac74
  preventing-unauthorized-emails: f4b8d2eaf0d79f01
generated:
  introduction: 6b587aa3247ed665
  preventing-unauthorized-emails: 2f345f4404d7abeb
title_source: f2488fd4ef4adbc6
title_generated: 32c13b636f1f855f
---

<!-- translation-section: introduction -->

# Envie um e-mail para iniciar uma conversa no seu grupo

Cada grupo no Loomio tem seu próprio endereço de e-mail. Você pode enviar ou encaminhar um e-mail para esse endereço para iniciar uma nova conversa no grupo.

Você pode encontrar o endereço de e-mail do grupo em **Configurações** na página do grupo:

![Localização do endereço de e-mail em Configurações na página do grupo](email_email_button.png)

Quando você envia um e-mail para esse endereço, o Loomio cria uma nova conversa. O assunto do e-mail se torna o título da conversa, o corpo se torna a descrição da conversa e todos os arquivos anexados são adicionados à conversa.

O Loomio usa o endereço do campo "De" do e-mail para identificar o remetente como membro do grupo e defini-lo como autor da conversa.

<!-- translation-section: preventing-unauthorized-emails -->

## Como impedir e-mails não autorizados

Para impedir que pessoas que não são membros iniciem conversas, o Loomio exige que o endereço do campo "De" de um e-mail recebido corresponda ao endereço de e-mail de um membro do grupo.

Se um membro enviar um e-mail de um endereço não reconhecido, o Loomio retém o e-mail e notifica os admins do grupo. Um admin do grupo pode aprovar o e-mail e adicionar o endereço como endereço alternativo desse membro ou rejeitar os próximos e-mails desse endereço.

Depois que um endereço alternativo é adicionado, os próximos e-mails desse endereço iniciam conversas imediatamente.

![Botões para aprovar e rejeitar um e-mail não reconhecido](email_unreleased_emails.png)
