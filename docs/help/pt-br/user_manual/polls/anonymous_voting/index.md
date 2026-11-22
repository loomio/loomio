---
title: Votação anônima
source_revision: ad97f553685def918a7d6e47ac5b66773de2dba8
source_file: docs/help/en/user_manual/polls/anonymous_voting/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-22'
sections:
  introduction: ffcecd2f4297c47d
  how-anonymous-voting-protects-voters: 3b757a1b4a7bda96
  while-voting-is-open: aafc698ee8108194
  votes-cannot-be-changed: 3a99e6c3f48e10ee
  why-anonymous-votes-do-not-have-reasons: 4027d6c1fbf4d29c
  results-and-exports: 5c10ab43a5f890b4
  participation-verification: e77ece0fc0d6cd73
  reminders: f711a180ae7c948f
  what-coordinators-and-administrators-can-see: d873cd48677fc324
  limits-of-anonymous-voting: 9ab54b74a4716e19
  questions: 60cc6f1a0163ec5d
  can-a-coordinator-see-how-i-voted: bfa1baf48f41cdd1
  can-i-see-my-vote-after-submitting-it: 435010e0c2ecf488
  can-i-change-or-withdraw-my-vote: 676d5401bf4d73cc
  will-i-receive-an-email-confirming-my-vote: 9660f10e8ffb9f9c
  does-a-public-poll-reveal-more-information: '087defb00bb8b99f'
  is-anonymous-voting-suitable-for-every-election: 9fae56c0661f0ec9
generated:
  introduction: 6f5ee8edd522bfaa
  how-anonymous-voting-protects-voters: 47e40c2b41edac2e
  while-voting-is-open: 388b06052f63b44e
  votes-cannot-be-changed: 97fa04673984f568
  why-anonymous-votes-do-not-have-reasons: fc238d0dac7e4ec3
  results-and-exports: 026ad75a5db529d7
  participation-verification: 399f953f61ffc542
  reminders: 7b48bf435c4c43db
  what-coordinators-and-administrators-can-see: 0bee61e9947d9c44
  limits-of-anonymous-voting: d9e1ffad7f0c594d
  questions: '06486bdf6b6b59d1'
  can-a-coordinator-see-how-i-voted: 3e16cb94dcf53c8b
  can-i-see-my-vote-after-submitting-it: f0c36b840fd465c6
  can-i-change-or-withdraw-my-vote: c0cb7aed3cdcff78
  will-i-receive-an-email-confirming-my-vote: 901fea33963932dc
  does-a-public-poll-reveal-more-information: 7b1b89ed96806003
  is-anonymous-voting-suitable-for-every-election: 6e19f490505f515e
title_source: 1bc4567506ad4d51
title_generated: bf95d7870f06a3a3
---

<!-- translation-section: introduction -->

# Votação anônima

A votação anônima, também conhecida como votação às cegas, separa o registro de quem votou dos votos em si. Depois que a enquete é encerrada, qualquer pessoa que possa ver os resultados pode ver quem participou, mas ninguém que usa o Loomio pode vincular um voto à pessoa que o enviou.

Esta página explica como a votação anônima funciona, quais informações são mantidas e os limites dessa proteção.

<!-- translation-section: how-anonymous-voting-protects-voters -->

## Como a votação anônima protege os eleitores

Uma enquete anônima mantém dois conjuntos separados de registros:

| Registros de participação | Votos enviados |
| --- | --- |
| Quem pode votar | As opções ou pontuações selecionadas |
| Quem recebeu um convite e de quem | A enquete à qual o voto pertence |
| Se cada pessoa apta a votar já votou | Nenhum nome ou conta de usuário |
| Nenhuma opção ou pontuação selecionada | Nenhum vínculo com um registro de participação |

Nenhum identificador compartilhado conecta esses registros. Os votos enviados também não incluem horários de envio, detalhes dos convites, motivos dos votos, anexos e outros metadados que poderiam identificar um eleitor.

Essa separação acontece quando o voto é salvo — ela não depende apenas de ocultar nomes na interface.

<!-- translation-section: while-voting-is-open -->

## Enquanto a votação estiver aberta

Os resultados permanecem ocultos para todos até que a enquete seja encerrada, incluindo admins da conversa, admins do grupo e admins da instância.

Quando alguém vota:

- seu voto é armazenado sem seu nome ou registro de participação;
- seu registro de participação é marcado para indicar que a pessoa votou;
- nenhum evento de voto, notificação, e-mail, comentário ou registro de atividade é criado;
- nenhuma cópia de suas escolhas é retornada após o envio; e
- a tela confirma apenas que seu voto foi registrado.

O registro de participação não armazena o horário exato em que uma pessoa votou, e os votos enviados não são ordenados pelo horário de envio.

<!-- translation-section: votes-cannot-be-changed -->

## Os votos não podem ser alterados

Cada pessoa apta a votar pode votar uma vez. Um voto anônimo enviado não pode ser consultado, alterado, retirado ou substituído, nem mesmo por um admin.

Permitir que alguém recupere ou substitua seu voto exigiria um vínculo entre essa pessoa e seu voto, algo que a votação anônima evita intencionalmente.

Confira suas escolhas com atenção antes de enviar.

<!-- translation-section: why-anonymous-votes-do-not-have-reasons -->

## Por que os votos anônimos não têm motivos

Os votos anônimos não podem incluir um motivo ou um anexo. Os motivos podem conter nomes, detalhes pessoais, padrões de escrita ou menções que identifiquem o eleitor e poderiam facilitar a identificação de votos individuais nos resultados.

Os participantes ainda podem discutir a enquete em sua conversa. Esses comentários são contribuições comuns, com identificação de quem os escreveu, e não estão vinculados a um voto anônimo.

<!-- translation-section: results-and-exports -->

## Resultados e exportações

Depois que a enquete é encerrada, o Loomio calcula os resultados a partir dos votos sem vínculo com os eleitores e exibe os totais para aquele tipo de enquete.

O Loomio não publica identificadores dos votos, a ordem de envio ou os horários de envio. As exportações de enquetes contêm apenas resultados agregados em vez de uma linha para cada voto. A única exceção é uma eleição STV encerrada, que pode ser exportada no formato BLT para recontagem. Uma exportação BLT lista as classificações dos candidatos (agrupadas quando várias cédulas têm a mesma classificação), sem a identidade dos eleitores ou metadados das cédulas.

Uma enquete anônima não pode ser reaberta depois de encerrada.

<!-- translation-section: participation-verification -->

## Quem participou

Depois que uma enquete anônima é encerrada, qualquer pessoa que possa ver seus resultados pode ver quem participou. Ninguém pode ver isso enquanto a votação estiver aberta.

Selecione **Ver votos** para ver a lista. Ela sempre mostra quem estava apto a votar e nunca mostra como ou quando alguém votou. A informação de que cada pessoa votou ou não só aparece se houver participação suficiente: pelo menos o quórum da enquete (se definido) ou, caso contrário, pelo menos metade dos eleitores aptos a votar, e nunca menos de três votos.

Os membros do grupo e os eleitores da enquete também veem quando cada pessoa entrou no grupo e quem a convidou. Os admins do grupo também veem os endereços de e-mail para distinguir pessoas com o mesmo nome.

Como todos que podem ver os resultados podem ver quem votou, um resultado em que todos os votos são para a mesma opção pode revelar como as pessoas votaram. Por exemplo, se todos os votos forem Concordo, todas as pessoas que votaram concordaram.

Os admins podem adicionar eleitores aptos a votar enquanto a votação estiver aberta, inclusive depois que outras pessoas já tiverem votado. Os eleitores existentes não podem ser removidos de uma enquete anônima.

<!-- translation-section: reminders -->

## Lembretes

Em uma enquete anônima com duração de pelo menos 24 horas, as pessoas aptas a votar que ainda não votaram recebem um lembrete automático durante as últimas 24 horas.

O Loomio seleciona os destinatários apenas com base nos registros de participação, sem consultar os votos enviados.

Enquetes com um período de votação inferior a 24 horas não enviam esse lembrete automático.

<!-- translation-section: what-coordinators-and-administrators-can-see -->

## O que os admins podem ver

Pelo aplicativo, um admin da conversa, admin do grupo ou admin da instância pode ter acesso a:

- a enquete e seus eleitores aptos a votar;
- a informação de que cada pessoa apta a votar votou ou não (quando sua função permitir esse acesso e houver votos suficientes); e
- os resultados agregados depois que a enquete for encerrada.

Eles não podem usar o aplicativo para ver:

- quais escolhas pertencem a uma pessoa;
- votos individuais ou padrões de votação;
- quando um voto foi enviado; ou
- um motivo, anexo, evento ou notificação vinculado a um voto.

<!-- translation-section: limits-of-anonymous-voting -->

## Limites da votação anônima

A votação anônima impede que usuários do Loomio vinculem um voto a um eleitor. Ela não oferece proteção criptográfica contra um operador do servidor que possa inspecionar o banco de dados, backups, logs do servidor, memória de processos, tráfego de rede ou código modificado.

Os próprios resultados também podem dar pistas. Um grupo pequeno, uma votação unânime, uma combinação única de escolhas ou comentários compartilhados fora da enquete podem facilitar a dedução do voto de uma pessoa.

Considere o tamanho do grupo e a sensibilidade da decisão antes de confiar na votação anônima oferecida pelo aplicativo.

<!-- translation-section: questions -->

## Perguntas

<!-- translation-section: can-a-coordinator-see-how-i-voted -->

### Alguém pode ver como eu votei?

Não. Ninguém que usa o Loomio pode vincular você ao seu voto. Quando houver votos suficientes, qualquer pessoa que possa ver os resultados poderá ver se você participou. Antes de atingir esse limite, até a informação de que você votou ou não permanece oculta.

<!-- translation-section: can-i-see-my-vote-after-submitting-it -->

### Posso ver meu voto depois de enviá-lo?

Não. O Loomio confirma que seu voto foi registrado e limpa suas seleções da tela. Ele não pode recuperar seu voto sem criar o vínculo que a votação anônima evita.

<!-- translation-section: can-i-change-or-withdraw-my-vote -->

### Posso alterar ou retirar meu voto?

Não. Como não existe um vínculo entre você e seu voto, o Loomio não consegue identificar qual voto alterar ou remover.

<!-- translation-section: will-i-receive-an-email-confirming-my-vote -->

### Vou receber um e-mail confirmando meu voto?

Não. Ao votar, você recebe apenas uma confirmação na tela, e seu registro de participação é atualizado. Isso não envia um e-mail nem cria uma notificação ou um registro de atividade.

<!-- translation-section: does-a-public-poll-reveal-more-information -->

### Uma enquete pública revela mais informações?

Depois que uma enquete pública é encerrada, qualquer pessoa pode ver seus resultados e quem participou. Não é possível ver votos individuais nem detalhes sobre a participação no grupo e os convites.

<!-- translation-section: is-anonymous-voting-suitable-for-every-election -->

### A votação anônima é adequada para todas as eleições?

Não. Ela separa os eleitores dos votos no aplicativo. Eleições que exigem proteção contra operadores do servidor ou verificação criptográfica independente precisam de um sistema projetado para atender a esses requisitos.
