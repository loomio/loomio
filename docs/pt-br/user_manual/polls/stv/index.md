---
title: Eleições STV
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/polls/stv/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-29'
sections:
  introduction: 6c43a75f60922bb6
  when-to-use-stv: e37de389c27f7d87
  creating-an-stv-election: 2d475191d922803f
  number-of-seats: 9463d911f230eea0
  counting-method: 31e83bb5bc08829c
  quota-type: 12d5c4b5fe2abb1d
  how-voting-works: b9a7df3cedbe4d50
  how-counting-works: 50ba0a7800bc5667
  understanding-results: 8442813a9c097112
  method-and-quota: 90113296c3d59816
  elected-candidates: a6c3dbb5548c7d41
  round-by-round-details: e4a8789dae29d49e
  exporting-ballots: 582555dd13633bf0
generated:
  introduction: ffaa7834c110b93e
  when-to-use-stv: ac9014d57bc0198c
  creating-an-stv-election: 54bdd8fabf5cca03
  number-of-seats: dca6e6de6c6c4d79
  counting-method: 8336748a8972b0f7
  quota-type: e5001d9151d02470
  how-voting-works: 9c96a08545392078
  how-counting-works: 9758bfef881e19ec
  understanding-results: 0b9964cf95c957d7
  method-and-quota: cdafe084248b8b44
  elected-candidates: e34039157ab8eb29
  round-by-round-details: f8a8293afc087eb3
  exporting-ballots: bb3cc17bec388535
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

Scottish STV : Recomendado. Usa o Método de Gregory Inclusivo Ponderado (WIGM), adotado nas eleições locais da Escócia desde 2007. Tem regras claras e simples. É adequado para a maioria das organizações.

Meek STV : Método iterativo com maior precisão matemática. Quando um candidato é eliminado, os votos são recontados como se ele nunca tivesse participado da eleição.

<!-- translation-section: quota-type -->

### Tipo de cota

A cota é o número mínimo de votos de que um candidato precisa para conquistar uma vaga. Há duas opções:

Droop : Recomendada. É a cota padrão na maioria das eleições STV e é usada na Irlanda, na Austrália e na Escócia. A cota Droop garante que uma coalizão com a maioria dos votos conquiste a maioria das vagas. Seu cálculo é: \\[ floor(\frac{votes}{(seats + 1)}) + 1 \\]

Hare
  : Exige um número mínimo de votos maior e oferece mais proporcionalidade a grupos menores.
    É a opção preferida por capítulos da DSA para proteger a representação de minorias.
   Seu cálculo é:
    \\[ \frac{votes}{seats}\\]

>[!TIP]
  > A cota Droop sempre resulta em um número de votos menor que a cota Hare. Por exemplo, em uma eleição com 100 votos e quatro vagas, a cota Droop seria 21 e a cota Hare seria 25.

<!-- translation-section: how-voting-works -->

## Como funciona a votação

Neste exemplo, a Cooperativa Oatmilk está elegendo três pessoas para supervisionar um teste de embalagens reutilizáveis. Os eleitores arrastam os candidatos para cima da linha e os classificam por ordem de preferência:

![](stv-vote-in-progress.png)

- **Classificação 1** = candidato de maior preferência
- **Classificação 2** = segunda escolha
- Continue classificando quantos candidatos quiser

Os eleitores não precisam classificar todos os candidatos. Os candidatos não classificados não recebem parte alguma do apoio daquele eleitor.

<!-- translation-section: how-counting-works -->

## Como funciona a contagem
A contagem segue estas etapas:

1. Calcula-se uma **cota** (o número mínimo de votos necessário para conquistar uma vaga).
2. Contam-se as **Primeiras preferências** de cada candidato.
3. Se um candidato atingir a cota, ele é **eleito**. Seus votos excedentes (acima da cota) são **transferidos** para as próximas preferências dos eleitores com valor fracionário.
4. Se nenhum candidato atingir a cota, o candidato com **menos votos é eliminado**. Seus votos são transferidos para as próximas preferências dos eleitores com valor integral.
5. O processo se repete até que todas as vagas sejam preenchidas.

>[!TIP]
>Se um eleitor não classificou nenhum dos candidatos que continuam na disputa, sua cédula fica "esgotada" e esse voto deixa de ser contado. Por isso, em geral, é melhor classificar mais candidatos.

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

Se a contagem terminar em empate — quando eliminar qualquer um dos candidatos restantes mudaria o resultado — esses candidatos aparecem em uma tabela separada, sem que um vencedor seja escolhido arbitrariamente.

<!-- translation-section: round-by-round-details -->

### Detalhes rodada a rodada

Expanda **Detalhes rodada a rodada** para ver as transferências de votos e as eliminações. Cada linha representa um candidato e cada coluna, uma rodada da contagem:

![](stv-results.png)

O destaque verde indica quando um candidato foi eleito; o vermelho, quando foi eliminado; e o laranja, quando houve empate.

<!-- translation-section: exporting-ballots -->

## Como exportar as cédulas

Após o encerramento da eleição, as pessoas que podem ver os resultados podem exportar as cédulas no formato BLT para uma recontagem independente ou auditoria. A exportação contém a classificação dos candidatos e reúne classificações idênticas em uma única linha com a quantidade de cédulas. Em eleições anônimas, ela não contém a identidade dos eleitores, identificadores das cédulas, horários de envio nem a ordem de envio.
