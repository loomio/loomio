---
title: Votação anônima
source_revision: 9c60c42fc739483fa23f15d9f34a1e9245518092
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
  introduction: f4c69c7736a64ce5
  how-anonymous-voting-protects-voters: 2105fc4410892f97
  while-voting-is-open: 6806aa8ebfdafe49
  votes-cannot-be-changed: 86021fbd9ebf1673
  why-anonymous-votes-do-not-have-reasons: da0012985265143f
  results-and-exports: 68be993400122d5a
  participation-verification: f4e78ddd01f23348
  reminders: 6b4890f97643bf02
  what-coordinators-and-administrators-can-see: c7ec68e370050e08
  limits-of-anonymous-voting: 1c934ea753544a3d
  questions: '06486bdf6b6b59d1'
  can-a-coordinator-see-how-i-voted: a9716b7bf5a9df2c
  can-i-see-my-vote-after-submitting-it: cfb151b464eebeb6
  can-i-change-or-withdraw-my-vote: cf9d1514dfa12486
  will-i-receive-an-email-confirming-my-vote: 93b98103d481d2da
  does-a-public-poll-reveal-more-information: 8ca8b350136706f7
  is-anonymous-voting-suitable-for-every-election: 5df1d7f7facf7574
title_source: 1bc4567506ad4d51
title_generated: bf95d7870f06a3a3
---

<!-- translation-section: introduction -->

# Votação anônima

A votação anônima, também chamada de votação secreta, mantém separados o registro de quem votou e os votos enviados. Após o encerramento da enquete, qualquer pessoa que possa ver os resultados pode ver quem participou. Ninguém que usa o Loomio pode associar um voto enviado à pessoa que o enviou.

Esta página explica as proteções da votação anônima, as informações mantidas e os limites dessa garantia.

<!-- translation-section: how-anonymous-voting-protects-voters -->

## Como a votação anônima protege quem vota

Uma enquete anônima mantém dois conjuntos separados de registros:

| Registros de participação | Votos enviados |
| --- | --- |
| Quem tem direito a votar | As opções selecionadas ou pontuações atribuídas |
| Quem foi convidado e por quem | A enquete à qual o voto pertence |
| Se cada pessoa com direito a voto votou | Nenhum nome ou conta de usuário |
| Nenhuma opção selecionada ou pontuação atribuída | Nenhuma ligação com um registro de participação |

Não há um identificador compartilhado que conecte esses registros. Os votos enviados também não incluem o horário exato de envio, informações sobre convites, justificativas escritas, anexos ou outros dados que possam ajudar a identificar quem votou.

Essa separação é aplicada quando o voto é armazenado. Ela não depende apenas de ocultar nomes na interface.

<!-- translation-section: while-voting-is-open -->

## Enquanto a votação está aberta

Os resultados ficam ocultos para todas as pessoas até o encerramento da enquete. Isso inclui coordenadores da enquete, administradores do grupo e administradores da instância que usam o aplicativo.

Quando uma pessoa vota:

- o voto enviado é armazenado sem o nome ou uma ligação com o registro de participação da pessoa;
- o registro de participação é marcado para indicar que ela votou;
- nenhum evento de voto, notificação, e-mail, comentário ou registro de atividade é criado;
- nenhuma cópia das opções selecionadas é devolvida após o envio; e
- a interface confirma apenas que o voto foi registrado.

O registro de participação não guarda o horário exato em que a pessoa votou. Os votos enviados não são ordenados pelo horário de envio.

<!-- translation-section: votes-cannot-be-changed -->

## Os votos não podem ser alterados

Cada pessoa com direito a voto pode votar uma vez. Depois de enviado, um voto anônimo não pode ser consultado, alterado, retirado ou substituído, nem mesmo por um coordenador ou administrador.

Para permitir que uma pessoa consultasse ou substituísse seu voto, seria necessária uma ligação permanente entre ela e o voto. A votação anônima não cria essa ligação.

Revise suas escolhas com atenção antes de enviar o voto.

<!-- translation-section: why-anonymous-votes-do-not-have-reasons -->

## Por que os votos anônimos não têm justificativas

Novos votos anônimos não podem incluir uma justificativa escrita nem um anexo. Justificativas podem conter nomes, dados pessoais, padrões de escrita, menções ou outras informações que identifiquem quem votou. Elas também facilitariam distinguir votos individuais do resultado agregado.

As pessoas participantes ainda podem conversar sobre a enquete no tópico, quando a discussão estiver disponível. Esses comentários são contribuições comuns, identificadas pelo nome de quem os escreveu, e não ficam associados a um voto anônimo.

<!-- translation-section: results-and-exports -->

## Resultados e exportações

Após o encerramento da enquete, os resultados são calculados a partir dos votos separados dos registros de participação e exibidos como totais e outros resultados agregados disponíveis para esse tipo de enquete.

O aplicativo não publica identificadores de votos, a ordem de envio nem os horários de envio. As exportações de enquetes contêm resultados agregados, e não uma linha para cada voto anônimo. A exceção é uma eleição STV encerrada, que pode ser exportada no formato BLT. Uma exportação BLT contém a ordem de preferência dos candidatos necessária para recontar a eleição. Votos com a mesma ordem de preferência são agrupados, sem a identidade de quem votou nem outros dados sobre os votos.

Uma enquete anônima não pode ser reaberta após o encerramento.

<!-- translation-section: participation-verification -->

## Quem participou

Após o encerramento de uma enquete anônima, qualquer pessoa que possa ver seus resultados pode ver quem participou. Ninguém pode ver essa informação enquanto a votação estiver aberta.

Selecione **Ver votos** para ver a lista. Ela sempre mostra quem tinha direito a votar. Só mostra se cada pessoa votou quando houver votos suficientes. Isso significa atingir o quórum da enquete, se houver um; caso contrário, metade das pessoas com direito a voto, e nunca menos de três votos. A lista nunca mostra como alguém votou, nem quando.

Os membros do grupo e as pessoas com direito a voto na enquete também podem ver quando cada pessoa entrou no grupo e quem a convidou. Os administradores do grupo também podem ver os endereços de e-mail, para distinguir pessoas com o mesmo nome.

Como qualquer pessoa que possa ver os resultados pode ver quem votou, um resultado em que todos os votos sejam na mesma opção pode revelar como as pessoas votaram. Por exemplo, se todos os votos forem na opção Concordar, todas as pessoas que votaram concordaram.

Os coordenadores podem adicionar pessoas com direito a voto enquanto a votação estiver aberta, mesmo depois que outras pessoas tiverem votado. As pessoas que já têm direito a voto não podem ser removidas de uma enquete anônima.

<!-- translation-section: reminders -->

## Lembretes

Em uma enquete anônima com duração de pelo menos 24 horas, as pessoas com direito a voto que ainda não votaram recebem um lembrete automático nas últimas 24 horas.

O lembrete é definido apenas com base nos registros de participação. Ele não consulta os votos enviados nem cria uma ligação com eles. Se o prazo mudar, a verificação feita a cada hora usa o prazo atual, sem manter um lembrete agendado separadamente para a enquete.

Enquetes cujo período total de votação é inferior a 24 horas não enviam esse lembrete automático.

<!-- translation-section: what-coordinators-and-administrators-can-see -->

## O que coordenadores e administradores podem ver

Pelo aplicativo, um coordenador da enquete, administrador do grupo ou administrador da instância pode ter acesso a:

- a enquete e as pessoas com direito a voto;
- a informação sobre se cada pessoa com direito a voto votou, caso sua função permita esse acesso e haja votos suficientes; e
- os resultados agregados após o encerramento da enquete.

Eles não podem usar os recursos do aplicativo para ver:

- quais opções uma pessoa selecionou;
- votos individuais ou padrões de votação;
- quando um voto específico foi enviado; ou
- uma justificativa, anexo, evento ou notificação associados a um voto enviado.

<!-- translation-section: limits-of-anonymous-voting -->

## Limites da votação anônima

Essas proteções impedem que usuários do aplicativo associem um voto enviado à pessoa que votou. Elas não oferecem proteção criptográfica contra um operador que possa examinar o banco de dados, cópias de segurança, registros do servidor, memória dos processos, tráfego de rede ou uma versão modificada do aplicativo.

O próprio resultado também pode revelar informações. Quando poucas pessoas têm direito a voto, o resultado é unânime, há uma combinação incomum de escolhas ou informações são compartilhadas fora da enquete, pode ser mais fácil deduzir as escolhas de uma pessoa. Quem votou também pode optar por se identificar em uma discussão fora do voto enviado.

Considere o número de pessoas aptas a votar e a sensibilidade da decisão ao avaliar se a votação anônima oferecida pelo aplicativo é adequada.

<!-- translation-section: questions -->

## Perguntas

<!-- translation-section: can-a-coordinator-see-how-i-voted -->

### Alguém pode ver como votei?

Não. Depois que houver votos suficientes, as pessoas que podem ver os resultados podem ver se você votou. Ninguém pode associar você a um voto enviado por meio do aplicativo. Até lá, a informação sobre se você votou permanece oculta.

<!-- translation-section: can-i-see-my-vote-after-submitting-it -->

### Posso ver meu voto depois de enviá-lo?

Não. O aplicativo confirma que seu voto foi registrado e, em seguida, remove suas escolhas da interface de votação. Ele não pode recuperar seu voto sem criar a ligação que a votação anônima procura evitar.

<!-- translation-section: can-i-change-or-withdraw-my-vote -->

### Posso alterar ou retirar meu voto?

Não. Não existe uma ligação que permita ao aplicativo identificar qual voto enviado deve ser alterado ou removido.

<!-- translation-section: will-i-receive-an-email-confirming-my-vote -->

### Vou receber um e-mail confirmando meu voto?

Não. A votação apenas exibe uma confirmação na tela e atualiza seu registro de participação. Ela não envia um e-mail de confirmação nem cria uma notificação ou um registro de atividade.

<!-- translation-section: does-a-public-poll-reveal-more-information -->

### Uma enquete pública revela mais informações?

Após o encerramento de uma enquete pública, qualquer pessoa pode ver seus resultados e quem participou. Não é possível ver votos individuais nem detalhes sobre a participação no grupo e os convites.

<!-- translation-section: is-anonymous-voting-suitable-for-every-election -->

### A votação anônima é adequada para todas as eleições?

Não. Ela separa as identidades dos votos dentro do aplicativo. Decisões que exigem proteção contra operadores do sistema ou eleições criptográficas verificáveis de forma independente precisam de um sistema projetado para esses requisitos.
