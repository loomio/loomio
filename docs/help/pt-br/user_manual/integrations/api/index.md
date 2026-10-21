---
title: API
source_revision: c6076258c3438c0dd6dc8fbf1fc0b0df47c0aeb5
source_file: docs/en/user_manual/integrations/api/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: 99e59473b33baba1
  user-api: 8424224e38edf17f
  server-api: f1bf07c1162ff08b
generated:
  introduction: 7cc857ce441976c7
  user-api: c89f2f05fbb2edad
  server-api: d6b796c4f22c88eb
title_source: c8e5998f6a3955c2
title_generated: c8e5998f6a3955c2
---

<!-- translation-section: introduction -->

# API do Loomio

Use a API do Loomio para conectar o Loomio a outros softwares e fluxos de trabalho automatizados.

O [contrato OpenAPI 3.1](openapi.yaml) descreve todas as operações públicas da API de usuário e da API de servidor em um formato legível por máquina. Importe-o em um cliente de API ou use-o para gerar código de cliente com tipos definidos. Os guias abaixo explicam fluxos de trabalho, permissões e comportamentos que não são totalmente expressos pelo contrato.

<!-- translation-section: user-api -->

## API de usuário

A [API de usuário](/en/user_manual/integrations/api/user-api) realiza ações como um usuário do Loomio. Ela pode listar grupos e criar ou gerenciar conversas, comentários, enquetes e vínculos de participação em grupos, de acordo com as permissões desse usuário.

Para integrações que recebem eventos automaticamente, os [webhooks de grupo](/en/user_manual/integrations/api/user-api#webhooks) enviam eventos selecionados do Loomio para um endpoint web em formato JSON. Use os endpoints REST para ler ou alterar dados do Loomio e um webhook quando uma integração precisar receber eventos sem fazer consultas periódicas.

<!-- translation-section: server-api -->

## API de servidor

A [API de servidor](/en/user_manual/integrations/api/server-api) permite que operadores de instalações do Loomio em servidores próprios gerenciem contas de usuário. A autenticação usa um segredo válido para todo o servidor.
