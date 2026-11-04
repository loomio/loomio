---
title: API
source_revision: 2d360988a87765e6a1345dd06155bc988154178e
source_file: docs/help/en/user_manual/integrations/api/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-23'
sections:
  introduction: 99e59473b33baba1
  user-api: 8424224e38edf17f
  server-api: 42859c6715b7a994
generated:
  introduction: 7cc857ce441976c7
  user-api: c89f2f05fbb2edad
  server-api: beb822aca42fdd53
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

A [API de servidor](/en/user_manual/integrations/api/server-api) permite que operadores de instalações do Loomio em servidores próprios criem e gerenciem contas de usuário, encontrem grupos e gerenciem a participação e as funções dos membros nos grupos. Ela usa um segredo válido para todo o servidor e não exige uma conta de bot nem a participação em cada grupo.
