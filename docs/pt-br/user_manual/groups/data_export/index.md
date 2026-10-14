---
title: Exportação de dados
source_revision: cd2e1e63e611688362e80009f50b8ed25025ba8b
source_file: docs/en/user_manual/groups/data_export/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-07'
sections:
  introduction: 5e29f67f9a2084ec
  export-data: 58b5e1d4e6f0b917
  export-group-data-as-csv: 53286ec33e7300d6
  export-group-data-as-html: 101671937dcd6f36
  export-group-data-as-json: aa310889d0854550
  print-thread-to-pdf: 39c48383953f9fd5
  import-your-group-data-on-another-loomio-server: 910ee8af48049e82
generated:
  introduction: ca44757b6cc9d1e4
  export-data: 5b9738813e11e368
  export-group-data-as-csv: ffdf2041e8863ce2
  export-group-data-as-html: b7e9c982cb1b8400
  export-group-data-as-json: 6aa2f813094505c0
  print-thread-to-pdf: 87ca555dec234e42
  import-your-group-data-on-another-loomio-server: fa20a91916815515
title_source: 29049648f87b87f5
title_generated: cceaafbceacf5faf
---

<!-- translation-section: introduction -->

# Backup ou exportação dos dados do grupo

Com o recurso de exportação dos dados do grupo, você pode:

- Baixar um arquivo com os dados dos membros para auditar a composição do grupo.
- Baixar o conteúdo do seu grupo, incluindo o texto das conversas e enquetes, para arquivamento ou análise.
- Abrir os resultados das enquetes em uma planilha ou linguagem de script.
- [Imprimir ou salvar uma conversa ou enquete em PDF para arquivamento.](#print-thread-to-pdf)
- Transferir seu grupo, incluindo todos os usuários, conversas, enquetes e arquivos, para outro servidor Loomio.

Se você quiser migrar dos servidores gerenciados pelo Loomio [para seu próprio servidor](https://github.com/loomio/loomio), pode usar esse recurso.

Se você administra seu próprio servidor Loomio e prefere deixar de fazê-lo, o Loomio oferece hospedagem gerenciada nos EUA, na União Europeia e na Austrália. Se quiser migrar seu grupo para um desses servidores, [entre em contato conosco](/contact).

[Entre em contato conosco](/contact) se quiser transferir seu grupo do serviço global de hospedagem do Loomio em loomio.com para um dos nossos serviços regionais: loomio.eu para a Europa ou loomio.nz para a Austrália e a Nova Zelândia.

<!-- translation-section: export-data -->

## Exportar dados

Abra o menu suspenso do grupo clicando nos três pontos e selecione **Exportar data do grupo**.

![Ação de exportar dados do grupo no menu da Oatmilk Cooperative](group_export_group_data.png)

<!-- translation-section: export-group-data-as-csv -->

### Exportar dados do grupo em CSV

*Para trabalhar com os dados do grupo em uma planilha, como no MS Excel ou no Google Sheets.*

O Loomio prepara o arquivo CSV em segundo plano e envia a você um link para download por e-mail quando ele estiver pronto. O link fica disponível por uma semana.

<!-- translation-section: export-group-data-as-html -->

### Exportar dados do grupo em HTML

*Para salvar os dados para arquivamento.*

O Loomio prepara o arquivo HTML em segundo plano e envia a você um link para download por e-mail quando ele estiver pronto. O link fica disponível por uma semana.

<!-- translation-section: export-group-data-as-json -->

### Exportar dados do grupo em JSON

*Para transferir os dados do seu grupo para uma instância do Loomio hospedada por você.*

Você precisa ser admin do grupo para exportá-lo. A exportação em JSON inclui:

- O grupo, seus membros e pedidos de adesão
- Conversas, comentários, reações, tags, modelos, notificações e registros relacionados dos grupos incluídos
- Enquetes, opções, votos e conclusões; uma enquete anônima só é incluída depois de encerrada
- Subgrupos dos quais você faz parte
- Subgrupos abertos, fechados e visíveis para o grupo principal quando você exporta o grupo principal como admin desse grupo, mesmo que você não faça parte desses subgrupos
- Referências a arquivos e imagens anexados ao conteúdo incluído

A exportação em JSON não inclui:

- Subgrupos secretos dos quais você não faz parte, incluindo seus membros e conteúdo
- Subgrupos aguardando exclusão
- Enquetes anônimas que ainda não foram encerradas
- Conversas diretas e enquetes que não pertencem ao grupo

Em breve, você receberá um e-mail com um link para baixar o arquivo JSON.

<!-- translation-section: print-thread-to-pdf -->

## Imprimir conversa em PDF

Você pode precisar extrair uma cópia de uma conversa para armazená-la em um arquivo separado.

A opção **Imprimir** preserva todos os comentários, enquetes, votos e conclusões, além da formatação da conversa.

No menu da conversa, clique no menu de três pontos (⋯) e escolha **Imprimir**. O Loomio gera uma página HTML que você pode imprimir ou "salvar em PDF" usando a ferramenta de impressão do seu navegador.

Você pode copiar a página e colá-la em um editor de documentos, arquivo ou repositório de dados.

![Ação de imprimir a discussão sobre garrafas retornáveis](discussion_print_discussion.png#width-90)

<!-- translation-section: import-your-group-data-on-another-loomio-server -->

## Importar os dados do seu grupo em outro servidor Loomio

Para obter instruções sobre como configurar seu próprio servidor Loomio, acesse: https://github.com/loomio/loomio

Se você hospeda sua própria instalação do Loomio e quer importar seus dados exportados:

Copie o arquivo .json para a pasta `import` da instância do contêiner:

`scp your-group-data.json username@some-domain.org:loomio-deploy/import`

Acesse o console Rails em execução:

`docker exec -ti loomio-app rails console`

Chame o serviço:

`GroupExportService.import('/import/your-group-data.json')`
