---
title: Exportação de dados
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/groups/data_export/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-29'
sections:
  introduction: 5e29f67f9a2084ec
  export-data: 58b5e1d4e6f0b917
  export-group-data-as-csv: 53286ec33e7300d6
  export-group-data-as-html: 101671937dcd6f36
  export-group-data-as-json: 4ec883363fb166ee
  print-thread-to-pdf: 39c48383953f9fd5
  import-your-group-data-on-another-loomio-server: 910ee8af48049e82
generated:
  introduction: 06fc1cdd76df02ab
  export-data: 54b1cbe556bfb0ce
  export-group-data-as-csv: 1f2605900609374b
  export-group-data-as-html: ed6a752e4e774fd5
  export-group-data-as-json: 7e29f1565f2dbfec
  print-thread-to-pdf: e1726924617b8591
  import-your-group-data-on-another-loomio-server: 3a51a47ac51d536f
title_source: 29049648f87b87f5
title_generated: cceaafbceacf5faf
---

<!-- translation-section: introduction -->

# Backup ou exportação dos dados do grupo

Com o recurso de exportação dos dados do grupo, você pode:

- Baixar um arquivo com os dados dos membros para conferir quem faz parte do grupo.
- Baixar o conteúdo do seu grupo, incluindo o texto das discussões e enquetes, para arquivar ou analisar.
- Abrir os resultados das enquetes em uma planilha ou linguagem de programação.
- [Imprimir ou salvar PDFs de uma discussão ou enquete para arquivamento.](#print-thread-to-pdf)
- Transferir seu grupo, incluindo todos os usuários, discussões, enquetes e arquivos, para outro servidor Loomio.

Se você quiser sair dos servidores gerenciados pelo Loomio e passar [para um servidor próprio](https://github.com/loomio/loomio), poderá usar esse recurso.

Se você mantém seu próprio servidor Loomio e prefere deixar de fazê-lo, o Loomio oferece hospedagem gerenciada nos EUA, na UE e na Austrália. Para migrar seu grupo para um desses servidores, [entre em contato conosco](/contact).

[Entre em contato conosco](/contact) se quiser transferir seu grupo do serviço global hospedado pelo Loomio em loomio.com para um de nossos serviços regionais: loomio.eu, para a Europa, ou loomio.nz, para a Austrália e a Nova Zelândia.

<!-- translation-section: export-data -->

## Exportar dados

Abra o menu do grupo clicando nos três pontos e selecione **Exportar data do grupo**.

![Ação Exportar data do grupo no menu da Cooperativa Oatmilk](group_export_group_data.png)

<!-- translation-section: export-group-data-as-csv -->

### Exportar dados do grupo como CSV

*Para trabalhar com os dados do grupo em uma planilha, como o MS Excel ou o Google Sheets.*

O Loomio prepara o arquivo CSV em segundo plano e envia um link para download por e-mail quando ele estiver pronto. O link fica disponível por uma semana.

<!-- translation-section: export-group-data-as-html -->

### Exportar dados do grupo como HTML

*Para guardar os dados em um arquivo.*

O Loomio prepara o arquivo HTML em segundo plano e envia um link para download por e-mail quando ele estiver pronto. O link fica disponível por uma semana.

<!-- translation-section: export-group-data-as-json -->

### Exportar dados do grupo como JSON

*Para transferir os dados do seu grupo para uma instância do Loomio hospedada por você.*

Você precisa ser administrador do grupo para exportá-lo. A exportação em JSON inclui:

- O grupo, seus membros e as solicitações de entrada
- Discussões, comentários, reações, etiquetas, modelos, notificações e registros relacionados dos grupos incluídos
- Enquetes, opções, votos e conclusões; uma enquete anônima só é incluída depois de encerrada
- Subgrupos dos quais você faz parte
- Subgrupos abertos e fechados quando você exporta o grupo principal como administrador dele, mesmo que não faça parte desses subgrupos
- Referências a arquivos e imagens anexados ao conteúdo incluído

A exportação em JSON não inclui:

- Subgrupos secretos dos quais você não faz parte, incluindo seus membros e conteúdo
- Subgrupos aguardando exclusão
- Enquetes anônimas que ainda não foram encerradas
- Discussões diretas e enquetes que não pertencem ao grupo

Em breve, você receberá um e-mail com um link para baixar o arquivo JSON.

<!-- translation-section: print-thread-to-pdf -->

## Imprimir uma discussão em PDF

Você pode extrair uma cópia de uma discussão para guardá-la em um arquivo separado.

A opção **Imprimir** preserva todos os comentários, enquetes, votos e conclusões, além da formatação da discussão.

No menu da discussão, clique nos três pontos (⋯) e escolha **Imprimir**. O Loomio gerará uma página HTML que você poderá imprimir ou salvar como PDF usando a ferramenta de impressão do navegador.

Você pode copiar a página e colá-la em um editor de documentos, arquivo ou repositório de dados.

![Ação Imprimir para a discussão sobre garrafas retornáveis](discussion_print_discussion.png#width-90)

<!-- translation-section: import-your-group-data-on-another-loomio-server -->

## Importar os dados do seu grupo em outro servidor Loomio

Para saber como configurar seu próprio servidor Loomio, acesse: https://github.com/loomio/loomio

Se você hospeda sua própria instalação do Loomio e quer importar os dados exportados:

Copie o arquivo .json para a pasta `import` da instância do contêiner:

`scp your-group-data.json username@some-domain.org:loomio-deploy/import`

Acesse o console Rails da instância em execução:

`docker exec -ti loomio-app rails console`

Execute o serviço:

`GroupExportService.import('/import/your-group-data.json')`
