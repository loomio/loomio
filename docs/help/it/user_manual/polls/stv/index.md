---
title: Elezioni STV
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
  introduction: c9e2c919c10aedf8
  when-to-use-stv: d9c75f94d7d9e482
  creating-an-stv-election: 92fece1085b5f8dc
  number-of-seats: c78d9cde9a2fd843
  counting-method: 1e567367c1d5be0b
  quota-type: 123a547822a36889
  how-voting-works: d9a410a7718673d3
  how-counting-works: 1b18cc74d52c618c
  understanding-results: 63a6fd6d8033b52b
  method-and-quota: 51433d3e7cc0a9c4
  elected-candidates: e9c91eea9fdae683
  round-by-round-details: 501f97ebed57b7eb
  exporting-ballots: 73ae31297d03a5eb
  share-an-outcome: c0801e969ee1b116
title_source: cd3e1a4cdc2456a6
title_generated: b856531da2becf44
---

<!-- translation-section: introduction -->

# Elezioni STV

Il **voto singolo trasferibile (STV)** è un metodo di voto a rappresentanza proporzionale per eleggere più persone tra un insieme di candidati. Garantisce che i candidati eletti rappresentino proporzionalmente la diversità di opinioni degli elettori.

<!-- translation-section: when-to-use-stv -->

## Quando usare STV

Usa un'elezione STV quando devi:

- Eleggere un **comitato, un consiglio o una delegazione** tra le persone candidate
- Garantire una **rappresentanza proporzionale**, in cui le minoranze possano ottenere seggi in proporzione al sostegno ricevuto
- Organizzare elezioni in cui gli elettori classificano i candidati in ordine di preferenza

>[!NOTE]
>STV **non** è lo stesso del [sondaggio Classifica](/en/user_manual/polls/rank/) di Loomio, che usa una classifica più semplice basata sui punteggi per scegliere una sola opzione migliore. STV gestisce elezioni con più eletti, trasferimenti di voti e turni di eliminazione.

<!-- translation-section: creating-an-stv-election -->

## Creare un'elezione STV

Quando avvii un sondaggio, seleziona **Elezioni STV** come tipo di sondaggio, poi aggiungi i candidati come opzioni del sondaggio. Puoi personalizzare il sondaggio impostando il **numero di seggi**, il **metodo di conteggio** e il **tipo di quota**.

In questo esempio, Oatmilk Cooperative sta eleggendo tre persone per supervisionare la sperimentazione degli imballaggi a rendere. Il modulo spiega il ruolo, elenca cinque candidati e usa Scottish STV con la quota Droop.

![](form.png)

<!-- translation-section: number-of-seats -->

### Numero di seggi

Il numero di persone da eleggere. Deve essere inferiore al numero di candidati.

<!-- translation-section: counting-method -->

### Metodo di conteggio

Sono disponibili due metodi per contare i voti:

Scottish STV
  : Consigliato. Il metodo Gregory inclusivo ponderato (WIGM), usato nelle elezioni locali scozzesi dal 2007. Ha regole ben definite e semplici. È il più adatto alla maggior parte delle organizzazioni.
  
Meek STV
  : Un metodo più preciso, il cui conteggio può essere eseguito solo da un computer. Quando un candidato viene eletto, Meek continua a trasferire la parte di ciascun voto che non gli serve alle preferenze successive dell'elettore, compresi i voti che gli arrivano più avanti nel conteggio. Quando un candidato viene eliminato, i voti vengono ricontati come se quel candidato non si fosse mai presentato. Rispetto a Scottish STV, si disperdono meno voti, ma il conteggio non può essere verificato a mano.

<!-- translation-section: quota-type -->

### Tipo di quota

La quota è il numero minimo di voti necessario a un candidato per ottenere un seggio. Può essere:

Droop
  : Consigliata. La quota standard per le elezioni STV, usata in Irlanda, Australia e Scozia. È la quota più piccola che può essere raggiunta da un numero di candidati non superiore al numero di seggi. Un gruppo di elettori che mette i propri candidati ai primi posti ottiene almeno tanti seggi quante sono le quote di voti di cui dispone. Si calcola così:
\\[ floor(\frac{votes}{(seats + 1)}) + 1 \\]

Hare
  : Una quota più alta. I gruppi con molti voti ne usano di più per ogni seggio che ottengono, quindi i gruppi più piccoli hanno maggiori probabilità di ottenere gli ultimi seggi. Si calcola così:
    \\[ \frac{votes}{seats}\\]

In entrambe le formule, *votes* è il numero di schede che indicano almeno un candidato in ordine di preferenza.

Meek STV calcola la quota senza arrotondamenti, usando votes ÷ (seats + 1) per Droop. Ricalcola la quota a ogni turno in base ai voti ancora attribuiti ai candidati, e un candidato deve superarla per essere eletto.
  
  >[!TIP]
  > La quota Droop corrisponde sempre a un numero di voti inferiore alla quota Hare. Per esempio, in un'elezione con 100 voti e quattro seggi, la quota Droop sarebbe 21 e la quota Hare 25.

<!-- translation-section: how-voting-works -->

## Come si vota

In questo esempio, Oatmilk Cooperative sta eleggendo tre persone per supervisionare la sperimentazione degli imballaggi riutilizzabili. Gli elettori trascinano i candidati sopra la linea e li classificano in ordine di preferenza:

![](stv-vote-in-progress.png)

- **Preferenza 1** = candidato preferito
- **Preferenza 2** = seconda scelta
- Continua a classificare tutti i candidati che desideri

Gli elettori devono classificare almeno un candidato, ma non devono necessariamente classificarli tutti. I candidati non classificati non ricevono alcun sostegno da quell'elettore.

<!-- translation-section: how-counting-works -->

## Come funziona il conteggio
Il conteggio si svolge così:

1. Viene calcolata una **quota** (il numero minimo di voti necessario per ottenere un seggio).
2. Vengono contate le **Prime preferenze** per ciascun candidato.
3. Ogni candidato che raggiunge la quota viene **eletto**. I suoi voti in eccesso (oltre la quota) vengono **trasferiti** alle preferenze successive degli elettori con un valore frazionario, partendo dal surplus più grande. I voti vengono trasferiti solo ai candidati ancora in conteggio.
4. Se non rimane alcun surplus da trasferire, il candidato con il **minor numero di voti viene eliminato**. I suoi voti vengono trasferiti alle preferenze successive degli elettori con il loro valore intero.
5. Quando il numero di candidati rimasti è uguale al numero di seggi ancora da assegnare, vengono tutti eletti, anche se non hanno raggiunto la quota.
6. Altrimenti, il conteggio riprende dal punto 3 finché tutti i seggi sono assegnati.

Il valore frazionario distribuisce solo i voti che non servono a un candidato eletto. Per esempio, se la quota è 26 e un candidato ha 40 voti, il suo surplus è 14. Ciascuna delle sue 40 schede passa alla preferenza successiva con un valore di 14 ÷ 40 = 0,35 voti.

In Scottish STV, il valore di ogni voto trasferito viene arrotondato per difetto a cinque cifre decimali, come nelle elezioni dei consigli locali scozzesi.

Se due o più candidati hanno il minor numero di voti, viene eliminato quello che aveva meno voti nel turno precedente più recente in cui i loro conteggi erano diversi.

>[!TIP]
>Una scheda conta solo finché indica una preferenza per un candidato ancora in conteggio. Quando non ne rimane nessuno, la scheda è "esaurita" e non conta più.

<!-- translation-section: understanding-results -->

## Comprendere i risultati

Dopo la chiusura del sondaggio, i risultati vengono visualizzati in diverse sezioni. In questa elezione, Samira Patel, Alex Morgan e Morgan Price ottengono i tre seggi del comitato:

![](stv-results-summary.png)

<!-- translation-section: method-and-quota -->

### Metodo e quota

In alto vedrai il metodo di conteggio (Scottish STV o Meek STV) e il tipo di quota (Droop o Hare), insieme alla quota: il numero di voti necessario a un candidato per ottenere un seggio.

<!-- translation-section: elected-candidates -->

### Candidati eletti

Una tabella riepilogativa degli eletti con cinque colonne:

| Colonna | Significato |
|--------|---------|
| **Candidato** | Il nome del candidato eletto |
| **Round eletto** | Il turno di conteggio in cui il candidato ha raggiunto la quota e ottenuto un seggio. Il turno 1 indica che è stato eletto con le sole prime preferenze; i turni successivi indicano che ha avuto bisogno di voti trasferiti da candidati eliminati o con un surplus. |
| **Prime preferenze** | Il numero di elettori che hanno indicato questo candidato come prima scelta. Mostra il sostegno diretto al candidato prima di qualsiasi trasferimento di voti. |
| **Conteggio finale** | Il conteggio dei voti del candidato al momento della sua elezione. A causa dei trasferimenti di voti, è spesso superiore al numero delle sue prime preferenze. |
| **Surplus** | Di quanto il conteggio finale del candidato ha superato la quota (conteggio finale meno quota). Un surplus maggiore indica un sostegno più forte rispetto a quello necessario per essere eletto. In Scottish STV, questo surplus viene ridistribuito alle preferenze successive degli elettori. |

A volte i turni precedenti non permettono di risolvere una parità. Se la parità non cambia chi viene eletto, il conteggio prosegue. Se invece lo cambia, il conteggio si ferma a quel turno. I candidati che vengono eletti comunque si risolva la parità sono indicati come eletti. I candidati che potrebbero essere eletti o meno a seconda di come si risolve la parità sono mostrati in una tabella separata. Loomio li indica come a pari merito anziché sceglierne uno a caso.

<!-- translation-section: round-by-round-details -->

### Dettagli turno per turno

Espandi **Dettagli round per round** per vedere i trasferimenti di voti e le eliminazioni. Ogni riga rappresenta un candidato e ogni colonna un turno di conteggio. Ogni numero indica i voti attribuiti al candidato all'inizio di quel turno:

![](stv-results.png)

L'evidenziazione verde indica quando un candidato è stato eletto, quella rossa quando è stato eliminato e quella arancione quando si è trovato a pari merito.

<!-- translation-section: share-an-outcome -->

## Condividi una conclusione

Quando le elezioni si chiudono, condividi una conclusione. Indica i nomi delle persone elette e quando inizia il loro incarico. Consulta [Condividi una conclusione](/en/user_manual/polls/intro_to_decisions#5-share-an-outcome) per sapere come funzionano le conclusioni.

![Una conclusione che indica i nomi dei membri eletti del comitato](outcome.png)

<!-- translation-section: exporting-ballots -->

## Esportare le schede

Dopo la chiusura delle elezioni, le persone che possono visualizzare i risultati possono esportare le schede in formato BLT per un riconteggio o una verifica indipendente. L'esportazione contiene le preferenze ordinate per i candidati e raggruppa gli ordinamenti identici in un'unica riga con il numero di schede corrispondenti. Per le elezioni anonime, non contiene le identità degli elettori, gli identificativi delle schede, gli orari di invio o l'ordine di invio.
