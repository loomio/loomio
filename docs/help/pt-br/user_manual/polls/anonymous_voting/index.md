---
title: Votação anônima
source_revision: c6076258c3438c0dd6dc8fbf1fc0b0df47c0aeb5
source_file: docs/en/user_manual/polls/anonymous_voting/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: 2b9b7da01da020b3
  how-anonymous-voting-protects-voters: f2be8477636489af
  while-voting-is-open: dda23e517269b9cf
  votes-cannot-be-changed: 1e317297688ba902
  why-anonymous-votes-do-not-have-reasons: 39c1a8362550ae40
  results-and-exports: eb2429afd442dad2
  participation-verification: 87bc3647be4bbfb8
  reminders: 0afad473c90f2f03
  what-coordinators-and-administrators-can-see: 07faa9f646665b64
  limits-of-anonymous-voting: 912141560342d073
  questions: 60cc6f1a0163ec5d
  can-a-coordinator-see-how-i-voted: 574fc18f3a9871c3
  can-i-see-my-vote-after-submitting-it: c558e29729aed45f
  can-i-change-or-withdraw-my-vote: dd1a385fa8d225a5
  will-i-receive-an-email-confirming-my-vote: 8616fc9a0b9809ac
  does-a-public-poll-reveal-more-information: 27acfa7744a0790d
  is-anonymous-voting-suitable-for-every-election: d1b723178449c0da
generated:
  introduction: c06d5643691d9e83
  how-anonymous-voting-protects-voters: dd4dd7be3461c342
  while-voting-is-open: f698e6a83cc22b38
  votes-cannot-be-changed: 7deff56b56084e5c
  why-anonymous-votes-do-not-have-reasons: 484e7fe1658e8ed0
  results-and-exports: e18594c1007a7f89
  participation-verification: 108e769b81a008c1
  reminders: 39ca7d6a4518da86
  what-coordinators-and-administrators-can-see: 4f9bdbc765f107f4
  limits-of-anonymous-voting: a07b7527c62bf523
  questions: '06486bdf6b6b59d1'
  can-a-coordinator-see-how-i-voted: 64a34745b8ba62be
  can-i-see-my-vote-after-submitting-it: a887454c134c6c09
  can-i-change-or-withdraw-my-vote: 30e04dd7d983905f
  will-i-receive-an-email-confirming-my-vote: bc6ff80276cf3abc
  does-a-public-poll-reveal-more-information: 7b1b89ed96806003
  is-anonymous-voting-suitable-for-every-election: bc9e0f483eb92e00
title_source: 1bc4567506ad4d51
title_generated: bf95d7870f06a3a3
---

<!-- translation-section: introduction -->

# Votação anônima

A votação anônima, também conhecida como votação às cegas, separa o registro de quem votou dos votos em si. Depois que a enquete é encerrada, qualquer pessoa que possa ver os resultados pode ver quem participou. Ninguém que usa o Loomio pode vincular um voto enviado à pessoa que o enviou.

Esta página explica as proteções oferecidas pela votação anônima, as informações que são mantidas e os limites dessa garantia.

<!-- translation-section: how-anonymous-voting-protects-voters -->

## Como a votação anônima protege os eleitores

Uma enquete anônima mantém dois conjuntos separados de registros:

| Registros de participação | Votos enviados |
| --- | --- |
| Quem pode votar | As opções ou pontuações selecionadas |
| Quem recebeu um convite e de quem | A enquete à qual o voto pertence |
| Se cada pessoa apta a votar já votou | Nenhum nome ou conta de usuário |
| Nenhuma opção ou pontuação selecionada | Nenhum vínculo com um registro de participação |

Não há um identificador compartilhado que conecte esses registros. Os votos enviados também não incluem o horário real de envio, informações sobre convites, motivos por escrito, anexos e outros metadados que poderiam ajudar a identificar um eleitor.

Essa separação é garantida quando o voto é armazenado. Ela não depende apenas de ocultar nomes na interface.

<!-- translation-section: while-voting-is-open -->

## Enquanto a votação estiver aberta

Os resultados permanecem ocultos para todos até que a enquete seja encerrada. Isso inclui coordenadores da enquete, administradores do grupo e administradores da instância que usam o aplicativo.

Quando alguém vota:

- o voto enviado é armazenado sem o nome ou o registro de participação da pessoa;
- o registro de participação da pessoa é marcado para indicar que ela votou;
- nenhum evento de voto, notificação, e-mail, comentário ou registro de atividade é criado;
- nenhuma cópia das escolhas da pessoa é retornada após o envio; e
- a interface confirma apenas que o voto foi registrado.

O registro de participação não armazena o horário preciso em que a pessoa votou. Os votos enviados não são ordenados pelo horário de envio.

<!-- translation-section: votes-cannot-be-changed -->

## Os votos não podem ser alterados

Cada pessoa apta a votar pode votar uma vez. Um voto anônimo enviado não pode ser consultado, alterado, retirado ou substituído, nem mesmo por um coordenador ou administrador.

Permitir que uma pessoa recupere ou substitua seu voto exigiria um vínculo persistente entre essa pessoa e o voto. A votação anônima não cria esse vínculo por escolha deliberada.

Confira suas escolhas com atenção antes de enviar.

<!-- translation-section: why-anonymous-votes-do-not-have-reasons -->

## Por que os votos anônimos não têm motivos

Novos votos anônimos não podem incluir um motivo por escrito ou um anexo. Os motivos podem conter nomes, detalhes pessoais, padrões de escrita, menções ou outras informações que identifiquem o eleitor. Eles também tornariam mais fácil distinguir votos individuais do resultado agregado.

Os participantes ainda podem discutir a enquete em sua conversa, quando a discussão estiver disponível. Esses comentários são contribuições comuns à discussão, com identificação de quem os escreveu, e não estão vinculados a um voto anônimo.

<!-- translation-section: results-and-exports -->

## Resultados e exportações

Depois que a enquete é encerrada, os resultados são calculados a partir dos votos sem vínculo com os eleitores e exibidos como totais e outros resultados agregados compatíveis com o tipo de enquete.

O aplicativo não publica identificadores dos votos, a ordem de envio ou os horários de envio. As exportações de enquetes contêm resultados agregados em vez de uma linha para cada voto anônimo, com a exceção de que uma eleição STV encerrada pode ser exportada no formato BLT. Uma exportação BLT contém as classificações dos candidatos necessárias para recontar a eleição, agrupadas quando várias cédulas têm a mesma classificação, sem a identidade dos eleitores ou metadados das cédulas.

Uma enquete anônima não pode ser reaberta depois de encerrada.

<!-- translation-section: participation-verification -->

## Quem participou

Depois que uma enquete anônima é encerrada, qualquer pessoa que possa ver seus resultados pode ver quem participou. Ninguém pode ver isso enquanto a votação estiver aberta.

Selecione **Ver votos** para ver a lista. Ela sempre mostra quem estava apto a votar. Ela só mostra se cada pessoa votou quando houver votos suficientes. Isso significa atingir o quórum da enquete, se houver, ou metade dos eleitores aptos a votar, caso contrário, e nunca menos de três votos. A lista nunca mostra como alguém votou ou quando.

Os membros do grupo e os eleitores da enquete também veem quando cada pessoa entrou no grupo e quem a convidou. Os admins do grupo também veem os endereços de e-mail para distinguir pessoas com o mesmo nome.

Como todos que podem ver os resultados podem ver quem votou, um resultado em que todos os votos são para a mesma opção pode revelar como as pessoas votaram. Por exemplo, se todos os votos forem Concordo, todas as pessoas que votaram concordaram.

Os coordenadores podem adicionar pessoas aptas a votar enquanto a votação estiver aberta, inclusive depois que outras pessoas já tiverem votado. Os eleitores existentes não podem ser removidos de uma enquete anônima.

<!-- translation-section: reminders -->

## Lembretes

Em uma enquete anônima com duração de pelo menos 24 horas, as pessoas aptas a votar que ainda não votaram recebem um lembrete automático durante as últimas 24 horas.

Os destinatários do lembrete são selecionados apenas com base nos registros de participação. Essa seleção não consulta os votos enviados nem cria um vínculo com eles. Se o prazo mudar, a verificação de lembretes feita a cada hora usa o prazo atual, sem manter um lembrete agendado separado para a enquete.

Enquetes com um período total de votação inferior a 24 horas não enviam esse lembrete automático.

<!-- translation-section: what-coordinators-and-administrators-can-see -->

## O que coordenadores e administradores podem ver

Pelo aplicativo, um coordenador da enquete, administrador do grupo ou administrador da instância pode ter acesso a:

- a enquete e seus eleitores aptos a votar;
- a informação de que cada pessoa apta a votar votou ou não, quando sua função permitir esse acesso e houver votos suficientes; e
- os resultados agregados depois que a enquete for encerrada.

Eles não podem usar os recursos do aplicativo para ver:

- quais escolhas pertencem a uma pessoa;
- votos individuais ou padrões de votação;
- quando um voto específico foi enviado; ou
- um motivo, anexo, evento ou notificação associado a um voto enviado.

<!-- translation-section: limits-of-anonymous-voting -->

## Limites da votação anônima

Essas proteções impedem que usuários do aplicativo vinculem um voto enviado ao seu eleitor. Elas não oferecem proteção criptográfica contra um operador que possa inspecionar o banco de dados, backups, logs do servidor, memória de processos, tráfego de rede ou uma versão modificada do aplicativo.

O próprio resultado também pode revelar informações. Um eleitorado pequeno, um resultado unânime, uma combinação característica de escolhas ou informações compartilhadas fora da enquete podem facilitar a dedução das escolhas de uma pessoa. Os eleitores também podem escolher se identificar na discussão, fora do voto enviado.

Considere o tamanho do eleitorado e a sensibilidade da decisão ao avaliar se a votação anônima oferecida pelo aplicativo é adequada.

<!-- translation-section: questions -->

## Perguntas

<!-- translation-section: can-a-coordinator-see-how-i-voted -->

### Alguém pode ver como eu votei?

Não. Quando houver votos suficientes, as pessoas que podem ver os resultados poderão ver se você votou. Ninguém pode vincular você a um voto enviado pelo aplicativo. Até lá, a informação de que você votou ou não permanece oculta.

<!-- translation-section: can-i-see-my-vote-after-submitting-it -->

### Posso ver meu voto depois de enviá-lo?

Não. O aplicativo confirma que seu voto foi registrado e depois descarta as opções selecionadas da interface de votação. Ele não pode recuperar seu voto sem criar o vínculo que a votação anônima foi projetada para evitar.

<!-- translation-section: can-i-change-or-withdraw-my-vote -->

### Posso alterar ou retirar meu voto?

Não. Não existe um vínculo que permita ao aplicativo identificar qual voto enviado deve ser alterado ou removido.

<!-- translation-section: will-i-receive-an-email-confirming-my-vote -->

### Vou receber um e-mail confirmando meu voto?

Não. Ao votar, você recebe apenas uma confirmação na tela, e seu registro de participação é atualizado. Isso não envia um e-mail de confirmação nem cria uma notificação ou um evento de atividade.

<!-- translation-section: does-a-public-poll-reveal-more-information -->

### Uma enquete pública revela mais informações?

Depois que uma enquete pública é encerrada, qualquer pessoa pode ver seus resultados e quem participou. Não é possível ver votos individuais nem detalhes sobre a participação no grupo e os convites.

<!-- translation-section: is-anonymous-voting-suitable-for-every-election -->

### A votação anônima é adequada para todas as eleições?

Não. Ela separa as identidades dos votos no aplicativo. Decisões que exigem proteção contra operadores do sistema ou eleições criptográficas verificáveis de forma independente precisam de um sistema projetado para atender a esses requisitos.
