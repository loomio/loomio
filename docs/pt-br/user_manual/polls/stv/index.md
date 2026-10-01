---
title: Eleições STV
source_revision: cf8da02f691349beecf6ac6444971fad130d4ddd
source_file: docs/en/user_manual/polls/stv/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
sections:
  introduction: 6c43a75f60922bb6
  when-to-use-stv: e37de389c27f7d87
  creating-an-stv-election: 2d475191d922803f
  number-of-seats: 9463d911f230eea0
  counting-method: b7ff2dce779d15c1
  quota-type: f9ab31d93916bf24
  how-voting-works: bace7c735dbb39f1
  how-counting-works: 794084f981b2cf3f
  understanding-results: 8442813a9c097112
  method-and-quota: 90113296c3d59816
  elected-candidates: 7ac0bae756fa5608
  round-by-round-details: c0ccc83e51dcaa1a
  exporting-ballots: 582555dd13633bf0
  share-an-outcome: 6a02aed173b368b9
generated:
  introduction: ffaa7834c110b93e
  when-to-use-stv: ac9014d57bc0198c
  creating-an-stv-election: 54bdd8fabf5cca03
  number-of-seats: dca6e6de6c6c4d79
  counting-method: 7792da5473e10746
  quota-type: e7bfa46ef5a6f333
  how-voting-works: 2cb7681c14aa7aea
  how-counting-works: 2f0dbae8de0a7a5e
  understanding-results: 0b9964cf95c957d7
  method-and-quota: cdafe084248b8b44
  elected-candidates: 6d51253ab75f04d3
  round-by-round-details: 73934e0d07e66ff6
  exporting-ballots: bb3cc17bec388535
  share-an-outcome: 4654cdef95ea0235
title_source: cd3e1a4cdc2456a6
title_generated: 7f35326f1d4107d5
---

<!-- translation-section: introduction -->

# Eleições STV

O **Voto Único Transferível (STV)** é um método de representação proporcional para eleger várias pessoas entre os candidatos. Ele permite que os eleitos representem proporcionalmente a diversidade de opiniões dos eleitores.

<!-- translation-section: when-to-use-stv -->

## Quando usar STV

Use uma Eleição STV quando você precisar:

- Eleger um **comitê, conselho ou grupo de delegados** entre os candidatos
- Garantir **representação proporcional**, para que grupos minoritários possam conquistar vagas conforme seu apoio
- Realizar eleições em que os eleitores classifiquem os candidatos por ordem de preferência

>[!NOTE]
>STV **não** é a mesma coisa que a [enquete de classificação](/en/user_manual/polls/rank/) do Loomio, que usa uma pontuação mais simples para escolher uma única opção. STV permite eleger várias pessoas por meio da transferência de votos e de rodadas de eliminação.

<!-- translation-section: creating-an-stv-election -->

## Como criar uma Eleição STV

Ao iniciar uma enquete, selecione **Eleição STV** como tipo de enquete e adicione os candidatos como opções. Você pode definir o **número de lugares a preencher**, o **método de contagem** e o **tipo de cota**.

Neste exemplo, a Cooperativa Oatmilk está elegendo três pessoas para supervisionar um teste de embalagens retornáveis. O formulário explica a função, apresenta cinco candidatos e usa o método Scottish STV com a cota Droop.

![](form.png)

<!-- translation-section: number-of-seats -->

### Número de lugares a preencher

Quantas pessoas serão eleitas. Esse número deve ser menor que o número de candidatos.

<!-- translation-section: counting-method -->

### Método de contagem

Há dois métodos disponíveis para contar os votos:

Scottish STV
  : Recomendado. Usa o Método de Gregory Inclusivo Ponderado (WIGM), adotado nas eleições locais da Escócia desde 2007. Tem regras claras e simples. É adequado para a maioria das organizações.
  
Meek STV
  : Um método mais preciso cuja contagem só pode ser feita por computador. Quando um candidato é eleito, o método Meek continua transferindo a parte de cada voto de que ele não precisa para as preferências seguintes do eleitor, inclusive dos votos que chegam ao candidato mais tarde na contagem. Quando um candidato é eliminado, os votos são recontados como se ele nunca tivesse participado da eleição. Menos votos são desperdiçados do que no Scottish STV, mas a contagem não pode ser conferida à mão.

<!-- translation-section: quota-type -->

### Tipo de cota

A cota é o número mínimo de votos de que um candidato precisa para conquistar uma vaga. Há duas opções:

Droop
  : Recomendada. É a cota padrão para eleições STV, usada na Irlanda, na Austrália e na Escócia. É a menor cota que impede que o número de candidatos que a atingem seja maior que o número de vagas. Um grupo de eleitores que coloca seus próprios candidatos em primeiro lugar conquista pelo menos tantas vagas quanto o número de cotas que seus votos somam. Seu cálculo é:
\\[ floor(\frac{votes}{(seats + 1)}) + 1 \\]

Hare
  : Uma cota maior. Grupos com muitos votos usam uma parte maior deles em cada vaga que conquistam, aumentando a chance de grupos menores conquistarem as últimas vagas. Seu cálculo é:
    \\[ \frac{votes}{seats}\\]

Nas duas fórmulas, *votes* é o número de cédulas que classificam pelo menos um candidato.

O Meek STV calcula a cota sem arredondamento, usando votes ÷ (seats + 1) para Droop. Ele recalcula a cota a cada rodada com base nos votos que os candidatos ainda têm, e um candidato precisa ultrapassá-la para ser eleito.
  
  >[!TIP]
  > A cota Droop sempre resulta em um número de votos menor que a cota Hare. Por exemplo, em uma eleição com 100 votos e quatro vagas, a cota Droop seria 21 e a cota Hare seria 25.

<!-- translation-section: how-voting-works -->

## Como funciona a votação

Neste exemplo, a Cooperativa Oatmilk está elegendo três pessoas para supervisionar um teste de embalagens reutilizáveis. Os eleitores arrastam os candidatos para cima da linha e os classificam por ordem de preferência:

![](stv-vote-in-progress.png)

- **Classificação 1** = candidato de maior preferência
- **Classificação 2** = segunda escolha
- Continue classificando quantos candidatos quiser

Os eleitores precisam classificar pelo menos um candidato, mas não precisam classificar todos os candidatos. Os candidatos não classificados não recebem parte alguma do apoio daquele eleitor.

<!-- translation-section: how-counting-works -->

## Como funciona a contagem
A contagem segue estas etapas:

1. Calcula-se uma **cota** (o número mínimo de votos necessário para conquistar uma vaga).
2. Contam-se as **Primeiras preferências** de cada candidato.
3. Todo candidato que atingir a cota é **eleito**. Seus votos excedentes (acima da cota) são **transferidos** para as próximas preferências dos eleitores com valor fracionário, começando pelo maior excedente. Os votos só são transferidos para candidatos que continuam na contagem.
4. Se não houver excedentes a transferir, o candidato com **menos votos é eliminado**. Seus votos são transferidos para as próximas preferências dos eleitores com valor integral.
5. Quando o número de candidatos restantes é igual ao número de vagas restantes, todos eles são eleitos, mesmo que não tenham atingido a cota.
6. Caso contrário, a contagem se repete a partir da etapa 3 até que todas as vagas sejam preenchidas.

O valor fracionário distribui apenas os votos de que um candidato eleito não precisa. Por exemplo, se a cota é 26 e um candidato tem 40 votos, seu excedente é 14. Cada uma de suas 40 cédulas é transferida para a próxima preferência com o valor de 14 ÷ 40 = 0,35 de um voto.

No Scottish STV, o valor de cada voto transferido é arredondado para baixo com cinco casas decimais, como nas eleições municipais da Escócia.

Se dois ou mais candidatos estiverem empatados com o menor número de votos, é eliminado aquele que tinha menos votos na rodada anterior mais recente em que houve diferença entre eles.

>[!TIP]
>Uma cédula só conta enquanto inclui na classificação algum candidato que continua na contagem. Quando nenhum deles resta, a cédula fica "esgotada" e deixa de ser contada.

<!-- translation-section: understanding-results -->

## Como entender os resultados

Após o encerramento da enquete, os resultados aparecem em várias seções. Nesta eleição, Samira Patel, Alex Morgan e Morgan Price ocupam as três vagas do comitê:

![](stv-results-summary.png)

<!-- translation-section: method-and-quota -->

### Método e cota

Na parte superior, você verá o método de contagem (Scottish STV ou Meek STV), o tipo de cota (Droop ou Hare) e a cota: o número de votos de que um candidato precisava para conquistar uma vaga.

<!-- translation-section: elected-candidates -->

### Candidatos eleitos

Uma tabela resume os eleitos em cinco colunas:

| Coluna | Significado |
|--------|---------|
| **Candidato** | Nome do candidato eleito |
| **Eleito para a rodada** | Rodada da contagem em que o candidato atingiu a cota e conquistou uma vaga. A rodada 1 indica que ele venceu apenas com as primeiras preferências; rodadas posteriores indicam que precisou receber votos transferidos de candidatos eliminados ou com votos excedentes. |
| **Primeiras preferências** | Número de eleitores que classificaram esse candidato como primeira escolha. Mostra seu apoio direto antes de qualquer transferência de votos. |
| **Contagem final** | Total de votos do candidato no momento em que foi eleito. Devido às transferências, esse total costuma ser maior que o número de primeiras preferências. |
| **Excedente** | Quanto a contagem final do candidato ultrapassou a cota (contagem final menos cota). Um excedente maior indica mais apoio além do necessário para vencer. No Scottish STV, esse excedente é redistribuído para as próximas preferências dos eleitores. |

Às vezes, as rodadas anteriores não permitem resolver um empate. Se o empate não mudar quem é eleito, a contagem continua. Se mudar, a contagem para nessa rodada. Os candidatos que vencem independentemente de como o empate seja resolvido aparecem como eleitos. Os candidatos que podem vencer ou perder dependendo da resolução do empate aparecem em uma tabela separada. O Loomio os mostra como empatados em vez de escolher um deles aleatoriamente.

<!-- translation-section: round-by-round-details -->

### Detalhes rodada a rodada

Expanda **Detalhes rodada a rodada** para ver as transferências de votos e as eliminações. Cada linha representa um candidato e cada coluna, uma rodada da contagem. Cada número indica quantos votos o candidato tinha no início daquela rodada:

![](stv-results.png)

O destaque verde indica quando um candidato foi eleito; o vermelho, quando foi eliminado; e o laranja, quando houve empate.

<!-- translation-section: share-an-outcome -->

## Compartilhe uma conclusão

Quando a eleição for encerrada, compartilhe uma conclusão. Informe os nomes das pessoas eleitas e quando elas começarão a exercer suas funções. Veja [Compartilhe uma conclusão](/en/user_manual/polls/intro_to_decisions#5-share-an-outcome) para entender como as conclusões funcionam.

![Uma conclusão com os nomes dos membros eleitos para o comitê](outcome.png)

<!-- translation-section: exporting-ballots -->

## Como exportar as cédulas

Após o encerramento da eleição, as pessoas que podem ver os resultados podem exportar as cédulas no formato BLT para uma recontagem independente ou auditoria. A exportação contém a classificação dos candidatos e reúne classificações idênticas em uma única linha com a quantidade de cédulas. Em eleições anônimas, ela não contém a identidade dos eleitores, identificadores das cédulas, horários de envio nem a ordem de envio.
