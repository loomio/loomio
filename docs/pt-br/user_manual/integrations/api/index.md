---
title: API
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/integrations/api/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-30'
sections:
  introduction: 99e59473b33baba1
  user-api: 8424224e38edf17f
  server-api: f1bf07c1162ff08b
generated:
  introduction: 475b08c9fc624ae2
  user-api: 853c69d310ada63c
  server-api: a64ca47ff5b1f2d6
title_source: c8e5998f6a3955c2
title_generated: c8e5998f6a3955c2
---

<!-- translation-section: introduction -->

# API do Loomio

Use a API do Loomio para conectar o Loomio a outros programas e fluxos de trabalho automatizados.

O [contrato OpenAPI 3.1](openapi.yaml) descreve todas as operações públicas da API do usuário e da API do servidor em um formato legível por máquina. Importe-o para um cliente de API ou use-o para gerar código de cliente com tipos definidos. Os guias abaixo explicam fluxos de trabalho, permissões e comportamentos que o contrato não descreve por completo.

<!-- translation-section: user-api -->

## API do usuário

A [API do usuário](/en/user_manual/integrations/api/user-api) executa ações em nome de um usuário do Loomio. Ela pode listar grupos e criar ou gerenciar discussões, comentários, enquetes e participações em grupos, conforme as permissões desse usuário.

Para integrações que recebem eventos automaticamente, os [webhooks de grupo](/en/user_manual/integrations/api/user-api#webhooks) enviam eventos selecionados do Loomio a um endpoint na web em formato JSON. Use os endpoints REST para ler ou alterar dados do Loomio e um webhook quando a integração precisar receber eventos sem fazer consultas periódicas.

<!-- translation-section: server-api -->

## API do servidor

A [API do servidor](/en/user_manual/integrations/api/server-api) permite que operadores de instalações do Loomio hospedadas por conta própria gerenciem contas de usuários. A autenticação usa uma chave secreta válida para todo o servidor.
