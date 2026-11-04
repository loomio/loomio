---
title: Eleições STV
source_revision: c6076258c3438c0dd6dc8fbf1fc0b0df47c0aeb5
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
  introduction: 20d679a4c85f2464
  when-to-use-stv: 7563e05fb4e9249e
  creating-an-stv-election: 7d57ec8bade8c5f8
  number-of-seats: 218daeb85089b2d4
  counting-method: ae3adbfc16a3807a
  quota-type: d5f6e58498010f69
  how-voting-works: dbf3ab9d58cb934b
  how-counting-works: 0abcb6c8e86928e9
  understanding-results: da4a8eeab1042df6
  method-and-quota: 48b258a8f00b7061
  elected-candidates: 2ffd0fb112dbf922
  round-by-round-details: 8f190cc44dff2a40
  exporting-ballots: 31ac75dca582af77
  share-an-outcome: 075d355e0dc7a4b7
title_source: cd3e1a4cdc2456a6
title_generated: 7f35326f1d4107d5
---

<!-- translation-section: introduction -->

# Eleições STV

O **Voto Único Transferível (STV)** é um método de votação com representação proporcional para eleger vários vencedores entre os candidatos. Ele garante que os candidatos eleitos representem proporcionalmente a diversidade de opiniões dos eleitores.

<!-- translation-section: when-to-use-stv -->

## Quando usar STV

Use uma eleição STV quando você precisar:

- Eleger um **comitê, conselho ou conjunto de delegados** entre as pessoas indicadas
- Garantir **representação proporcional**, em que correntes minoritárias possam conquistar vagas proporcionais ao apoio que recebem
- Realizar eleições em que os eleitores classifiquem os candidatos por preferência

>[!NOTE]
>STV **não** é o mesmo que a [enquete de classificação](/en/user_manual/polls/rank/) do Loomio, que usa uma classificação mais simples baseada em pontuação para escolher uma única opção preferida. STV permite eleições com vários vencedores, transferências de votos e rodadas de eliminação.

<!-- translation-section: creating-an-stv-election -->

## Criar uma eleição STV

Ao iniciar uma enquete, selecione **Eleição STV** como tipo de enquete e adicione os candidatos como opções da enquete. Você pode personalizar a enquete definindo o **número de vagas**, o **método de contagem** e o **tipo de cota**.

Neste exemplo, a Cooperativa Oatmilk está elegendo três pessoas para supervisionar seu teste de embalagens retornáveis. O formulário explica a função, lista cinco candidatos e usa STV escocês com a cota Droop.

![](form.png)

<!-- translation-section: number-of-seats -->

### Número de vagas

Quantos vencedores devem ser eleitos. Deve ser menor que o número de candidatos.

<!-- translation-section: counting-method -->

### Método de contagem

Há dois métodos disponíveis para contar os votos:

STV escocês
  : Recomendado. O Método Gregory Inclusivo Ponderado (WIGM), usado nas eleições locais escocesas desde 2007. Regras bem definidas e simples. Mais adequado para a maioria das organizações.
  
STV Meek
  : Um método mais preciso cuja contagem só pode ser feita por computador. Quando um candidato é eleito, Meek continua transferindo a parte de cada voto de que ele não precisa para as preferências seguintes do eleitor, incluindo os votos que chegam a esse candidato mais tarde na contagem. Quando um candidato é eliminado, os votos são recontados como se ele nunca tivesse concorrido. Menos votos são desperdiçados do que no STV escocês, mas a contagem não pode ser conferida manualmente.

<!-- translation-section: quota-type -->

### Tipo de cota

A cota é o número mínimo de votos que um candidato precisa para conquistar uma vaga. Ela pode ser:

Droop
  : Recomendada. A cota padrão para eleições STV, usada na Irlanda, Austrália e Escócia. É a menor cota que impede que o número de candidatos que a alcançam ultrapasse o número de vagas. Um grupo de eleitores que coloca seus próprios candidatos nas primeiras posições conquista pelo menos tantas vagas quanto o número de cotas que seus votos somam. Ela é calculada assim:
\\[ floor(\frac{votes}{(seats + 1)}) + 1 \\]

Hare
  : Uma cota maior. Grupos com muitos votos usam mais deles em cada vaga conquistada, então grupos menores têm mais chances de conquistar as últimas vagas. Ela é calculada assim:
    \\[ \frac{votes}{seats}\\]

Nas duas fórmulas, *votes* é o número de cédulas que classificam pelo menos um candidato.

O STV Meek calcula a cota sem arredondamento, como votos ÷ (vagas + 1) para Droop. Ele recalcula a cota a cada rodada com base nos votos que ainda estão com os candidatos, e um candidato precisa ultrapassá-la para ser eleito.
  
  >[!TIP]
  > Droop sempre resulta em um número de votos menor que Hare. Por exemplo, em uma eleição com 100 votos e quatro vagas, a cota Droop seria 21 e a cota Hare, 25.

<!-- translation-section: how-voting-works -->

## Como funciona a votação

Neste exemplo, a Cooperativa Oatmilk está elegendo três pessoas para supervisionar o teste de embalagens reutilizáveis. Os eleitores arrastam os candidatos para cima da linha e os classificam em ordem de preferência:

![](stv-vote-in-progress.png)

- **Posição 1** = candidato preferido
- **Posição 2** = segunda opção
- Continue classificando quantos candidatos você desejar

Os eleitores devem classificar pelo menos um candidato, mas não precisam classificar todos. Os candidatos não classificados não receberão nenhuma parcela do apoio desse eleitor.

<!-- translation-section: how-counting-works -->

## Como funciona a contagem
A contagem é realizada da seguinte forma:

1. Uma **cota** é calculada (mínimo de votos necessário para conquistar uma vaga).
2. As **Primeiras preferências** são contadas para cada candidato.
3. Todo candidato que alcança a cota é **eleito**. Seus votos excedentes (acima da cota) são **transferidos** para as preferências seguintes dos eleitores com um valor fracionário, começando pelo maior excedente. Os votos só são transferidos para candidatos que ainda estão na contagem.
4. Se não houver excedente para transferir, o candidato com **menos votos é eliminado**. Seus votos são transferidos para as preferências seguintes dos eleitores com seu valor integral.
5. Quando o número de candidatos restantes é igual ao número de vagas restantes, todos eles são eleitos, mesmo que não tenham alcançado a cota.
6. Caso contrário, a contagem se repete a partir da etapa 3 até que todas as vagas sejam preenchidas.

O valor fracionário distribui apenas os votos de que um vencedor não precisa. Por exemplo, se a cota é 26 e um candidato tem 40 votos, seu excedente é 14. Cada uma de suas 40 cédulas passa para a preferência seguinte com um valor de 14 ÷ 40 = 0,35 de um voto.

No STV escocês, o valor de cada voto transferido é arredondado para baixo com cinco casas decimais, como nas eleições para os conselhos locais escoceses.

Se dois ou mais candidatos estiverem empatados com o menor número de votos, será eliminado aquele que tinha menos votos na rodada anterior mais recente em que houve diferença entre eles.

>[!TIP]
>Uma cédula só conta enquanto inclui na classificação um candidato que ainda está na contagem. Quando não resta nenhum, a cédula fica "esgotada" e deixa de contar.

<!-- translation-section: understanding-results -->

## Entender os resultados

Após o encerramento da enquete, os resultados são exibidos em várias seções. Nesta eleição, Samira Patel, Alex Morgan e Morgan Price preenchem as três vagas do comitê:

![](stv-results-summary.png)

<!-- translation-section: method-and-quota -->

### Método e cota

No topo, você verá o método de contagem (STV escocês ou STV Meek) e o tipo de cota (Droop ou Hare), junto com a cota — o número de votos que um candidato precisava para conquistar uma vaga.

<!-- translation-section: elected-candidates -->

### Candidatos eleitos

Uma tabela de resumo dos vencedores com cinco colunas:

| Coluna | Significado |
|--------|---------|
| **Candidato** | O nome do candidato eleito |
| **Eleito para a rodada** | A rodada de contagem em que o candidato alcançou a cota e conquistou uma vaga. Rodada 1 significa que ele venceu apenas com as primeiras preferências; rodadas posteriores significam que precisou de votos transferidos de candidatos eliminados ou com excedente. |
| **Primeiras preferências** | Quantos eleitores classificaram esse candidato como sua primeira opção. Isso mostra o apoio direto ao candidato antes de qualquer transferência de votos. |
| **Contagem final** | A contagem de votos do candidato no momento em que foi eleito. Devido às transferências de votos, ela costuma ser maior que o número de primeiras preferências. |
| **Excedente** | Quanto a contagem final do candidato ultrapassou a cota (contagem final menos a cota). Um excedente maior significa mais apoio além do necessário para vencer. No STV escocês, esse excedente é redistribuído para as preferências seguintes dos eleitores. |

Às vezes, as rodadas anteriores não permitem desempatar. Se o empate não altera quem é eleito, a contagem continua. Se altera, a contagem para nessa rodada. Os candidatos que vencem independentemente de como o empate é resolvido são exibidos como eleitos. Os candidatos que podem vencer ou perder dependendo do desempate são exibidos em uma tabela separada. O Loomio os mostra como empatados em vez de escolher um deles aleatoriamente.

<!-- translation-section: round-by-round-details -->

### Detalhes rodada a rodada

Expanda **Detalhes rodada a rodada** para ver as transferências de votos e as eliminações. Cada linha representa um candidato e cada coluna representa uma rodada de contagem. Cada número indica os votos que o candidato tinha no início daquela rodada:

![](stv-results.png)

O destaque verde mostra quando um candidato foi eleito, o vermelho mostra quando foi eliminado e o laranja mostra quando ficou empatado.

<!-- translation-section: share-an-outcome -->

## Compartilhe uma conclusão

Quando a eleição for encerrada, compartilhe uma conclusão. Informe os nomes das pessoas eleitas e quando elas assumirão suas funções. Veja [Compartilhe uma conclusão](/en/user_manual/polls/intro_to_decisions#5-share-an-outcome) para saber como as conclusões funcionam.

![Uma conclusão com os nomes dos membros eleitos do comitê](outcome.png)

<!-- translation-section: exporting-ballots -->

## Exportação de cédulas

Após o encerramento da eleição, as pessoas que podem visualizar os resultados podem exportar as cédulas no formato BLT para uma recontagem ou auditoria independente. A exportação contém as classificações dos candidatos por preferência e reúne classificações idênticas em uma única linha com a contagem de cédulas. Em eleições anônimas, ela não contém identidades dos eleitores, identificadores das cédulas, horários de envio nem ordem de envio.
