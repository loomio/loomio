---
title: Exportação de dados
source_revision: 95ce9afd64c99656f67e05a09fa9fc8a77af51d7
source_file: docs/help/en/user_manual/groups/data_export/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-26'
sections:
  introduction: 988679ffd3d29834
  export-data: '024783a0614721d2'
  export-group-data-as-csv: c0845f09bff828f2
  export-group-data-as-html: 659fd5e14956b00e
  export-group-data-as-json: 4c2131f4518b7469
  print-thread-to-pdf: 1a1d0598f4277ba1
  import-your-group-data-on-another-loomio-server: 33d49c6c25be163b
generated:
  introduction: d3faeee70c213e87
  export-data: aafe9c5942ff6a38
  export-group-data-as-csv: ecde53b7893e8872
  export-group-data-as-html: 826424b8a5f3b5c3
  export-group-data-as-json: 6908e3bc33785f9b
  print-thread-to-pdf: 89db8ad3f48c8145
  import-your-group-data-on-another-loomio-server: b69f9d45e7d523d1
title_source: 29049648f87b87f5
title_generated: cceaafbceacf5faf
---

<!-- translation-section: introduction -->

# Backup ou exportação dos dados do grupo

Com a exportação dos dados do grupo, você pode:

- Baixar dados dos membros para auditar a composição do grupo.
- Arquivar ou analisar as conversas, os comentários e as enquetes do seu grupo.
- Abrir os resultados das enquetes em uma planilha ou script.
- [Imprimir ou salvar uma conversa ou enquete em PDF para seus registros.](#print-thread-to-pdf)
- Transferir seu grupo, incluindo seus usuários, conversas, enquetes e arquivos, para outro servidor Loomio.

Você pode usar esse recurso para migrar do serviço de hospedagem do Loomio para um [servidor hospedado por você](https://github.com/loomio/loomio). Se você administra seu próprio servidor e quer migrar para a hospedagem gerenciada do Loomio nos EUA, na União Europeia ou na Austrália, [entre em contato conosco](/contact).

[Entre em contato conosco](/contact) se quiser transferir um grupo de loomio.com para um serviço regional (loomio.eu para a Europa ou loomio.nz para a Austrália e a Nova Zelândia).

<!-- translation-section: export-data -->

## Exportar dados

Somente um admin do grupo pode exportar os dados do grupo. Abra **Configurações** na página do grupo e selecione **Exportar data do grupo**.

![Ação de exportar dados do grupo na página de configurações da Oatmilk Cooperative](group_export_group_data.png)

O Loomio prepara a exportação em segundo plano e envia a você um link para download por e-mail quando ela estiver pronta. O link fica ativo por uma semana.

<!-- translation-section: export-group-data-as-csv -->

### Exportar dados do grupo em CSV

Use CSV para examinar os dados do grupo, incluindo detalhes e atividades dos membros, em uma planilha como Microsoft Excel ou Google Sheets.

<!-- translation-section: export-group-data-as-html -->

### Exportar dados do grupo em HTML

Use HTML para salvar uma cópia legível das discussões e enquetes do seu grupo para arquivamento.

<!-- translation-section: export-group-data-as-json -->

### Exportar dados do grupo em JSON

Use JSON para transferir os dados do seu grupo para um servidor Loomio hospedado por você.

A exportação em JSON inclui:

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

<!-- translation-section: print-thread-to-pdf -->

## Imprimir conversa em PDF

Para salvar uma única conversa para seus registros, abra o menu de ações da conversa e selecione **Imprimir**. O Loomio gera uma página HTML com os comentários, enquetes, votos, conclusões e a formatação da conversa. Use a ferramenta de impressão do seu navegador para imprimir a página ou salvá-la como PDF, ou copie o conteúdo para outro documento.

![Ação de imprimir a discussão sobre garrafas retornáveis](discussion_print_discussion.png#width-90)

<!-- translation-section: import-your-group-data-on-another-loomio-server -->

## Importar os dados do seu grupo em outro servidor Loomio

Esta seção é para administradores que mantêm um servidor Loomio com hospedagem própria. Para obter instruções de configuração, consulte o [repositório do Loomio](https://github.com/loomio/loomio).

1. Copie o arquivo `.json` para a pasta `import` do contêiner:

```sh
scp your-group-data.json username@some-domain.org:loomio-deploy/import
```

2. Abra o console Rails no contêiner em execução:

```sh
docker exec -ti loomio-app rails console
```

3. Execute o serviço de importação:

```ruby
GroupExportService.import('/import/your-group-data.json')
```
