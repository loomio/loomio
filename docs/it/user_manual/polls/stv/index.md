---
title: Elezioni STV
source_revision: 9c60c42fc739483fa23f15d9f34a1e9245518092
source_file: docs/en/user_manual/polls/stv/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-01'
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
  share-an-outcome: 6a02aed173b368b9
generated:
  introduction: b2d37950d665f119
  when-to-use-stv: 8cbe86b4e1d4f7bf
  creating-an-stv-election: a5204aa2a793a5a5
  number-of-seats: c78d9cde9a2fd843
  counting-method: 95636dc27ddbf0eb
  quota-type: 7c67e1f7ca485923
  how-voting-works: b5d90998bd85075b
  how-counting-works: 7123dfc534ae9c2c
  understanding-results: f4940f19156d2308
  method-and-quota: 98fdcd0bb8deba93
  elected-candidates: 80c6aab852822c8a
  round-by-round-details: b57045f9caf239b3
  exporting-ballots: 471a006656893f8a
  share-an-outcome: 25ad51a1ccf4b980
title_source: cd3e1a4cdc2456a6
title_generated: b856531da2becf44
---

<!-- translation-section: introduction -->

# Elezioni STV

Il **voto singolo trasferibile (STV)** è un metodo di voto proporzionale per eleggere più persone tra un gruppo di candidati. Permette di rappresentare tra gli eletti la diversità delle opinioni di chi vota.

<!-- translation-section: when-to-use-stv -->

## Quando usare STV

Usa un'elezione STV quando vuoi:

- Eleggere un **comitato, un consiglio o un gruppo di delegati** tra più candidati
- Garantire una **rappresentanza proporzionale**, in cui anche i gruppi minoritari possono ottenere seggi in proporzione al sostegno ricevuto
- Organizzare elezioni in cui chi vota ordina i candidati secondo le proprie preferenze

>[!NOTE]
>STV è diverso dal [sondaggio con classifica](/en/user_manual/polls/rank/) di Loomio, che usa un sistema di punteggi più semplice per scegliere un'unica opzione. STV permette di eleggere più persone attraverso trasferimenti di voti e turni di eliminazione.

<!-- translation-section: creating-an-stv-election -->

## Creare un'elezione STV

Quando avvii un sondaggio, seleziona **Elezioni STV** come tipo di sondaggio, poi aggiungi i candidati come opzioni. Puoi configurare il **numero di seggi**, il **metodo di conteggio** e il **tipo di quota**.

In questo esempio, la cooperativa Oatmilk elegge tre persone che seguiranno la sperimentazione degli imballaggi a rendere. Il modulo descrive il ruolo, elenca cinque candidati e usa il metodo Scottish STV con la quota Droop.

![](form.png)

<!-- translation-section: number-of-seats -->

### Numero di seggi

Il numero di persone da eleggere. Deve essere inferiore al numero di candidati.

<!-- translation-section: counting-method -->

### Metodo di conteggio

Sono disponibili due metodi per contare i voti:

Scottish STV : Consigliato. Usa il metodo Weighted Inclusive Gregory (WIGM), adottato nelle elezioni locali scozzesi dal 2007. Ha regole chiare e semplici. È adatto alla maggior parte delle organizzazioni.

Meek STV : Un metodo iterativo matematicamente più preciso. Quando un candidato viene eliminato, i voti vengono ricalcolati come se non avesse mai partecipato all'elezione.

<!-- translation-section: quota-type -->

### Tipo di quota

La quota è il numero minimo di voti necessario a un candidato per ottenere un seggio. Può essere:

Droop : Consigliata. È la quota standard per la maggior parte delle elezioni STV ed è usata in Irlanda, Australia e Scozia. Garantisce che una coalizione con la maggioranza dei voti ottenga la maggioranza dei seggi. Si calcola così: \\[ floor(\frac{votes}{(seats + 1)}) + 1 \\]

Hare
  : Una soglia minima più alta, che offre una rappresentanza più proporzionale ai gruppi più piccoli.
    Le sezioni DSA la preferiscono per tutelare la rappresentanza delle minoranze.
   Si calcola così:
    \\[ \frac{votes}{seats}\\]

>[!TIP]
  > La quota Droop richiede sempre meno voti della quota Hare. Per esempio, in un'elezione con 100 voti e quattro seggi, la quota Droop è 21 e la quota Hare è 25.

<!-- translation-section: how-voting-works -->

## Come si vota

In questo esempio, la cooperativa Oatmilk elegge tre persone che seguiranno la sperimentazione degli imballaggi riutilizzabili. Chi vota trascina i candidati sopra la linea e li ordina secondo le proprie preferenze:

![](stv-vote-in-progress.png)

- **Posizione 1** = candidato preferito
- **Posizione 2** = seconda scelta
- Continua a ordinare tutti i candidati che desideri

Non è necessario ordinare tutti i candidati. I candidati non classificati non ricevono alcuna parte del sostegno di chi ha espresso quel voto.

<!-- translation-section: how-counting-works -->

## Come funziona il conteggio
Il conteggio si svolge così:

1. Si calcola una **quota** (il numero minimo di voti necessario per ottenere un seggio).
2. Si contano le **Prime preferenze** di ogni candidato.
3. Se un candidato raggiunge la quota, viene **eletto**. I suoi voti in eccedenza rispetto alla quota vengono **trasferiti** alle preferenze successive di chi lo ha votato, con un valore frazionario.
4. Se nessun candidato raggiunge la quota, viene **eliminato il candidato con meno voti**. I suoi voti vengono trasferiti alle preferenze successive di chi lo ha votato, mantenendo il loro intero valore.
5. Il processo si ripete finché tutti i seggi sono assegnati.

>[!TIP]
>Se una scheda non indica preferenze per nessuno dei candidati rimasti, è «esaurita» e quel voto non viene più conteggiato. Per questo, in genere conviene ordinare più candidati.

<!-- translation-section: understanding-results -->

## Capire i risultati

Dopo la chiusura del sondaggio, i risultati sono mostrati in diverse sezioni. In questa elezione, Samira Patel, Alex Morgan e Morgan Price occupano i tre seggi del comitato:

![](stv-results-summary.png)

<!-- translation-section: method-and-quota -->

### Metodo e quota

In alto trovi il metodo di conteggio (Scottish STV o Meek STV), il tipo di quota (Droop o Hare) e la quota stessa: il numero di voti necessario a un candidato per ottenere un seggio.

<!-- translation-section: elected-candidates -->

### Candidati eletti

Una tabella riassume i vincitori in cinque colonne:

| Colonna | Significato |
|--------|---------|
| **Candidato** | Il nome del candidato eletto |
| **Round eletto** | Il turno di conteggio in cui ha raggiunto la quota e ottenuto un seggio. Il turno 1 indica che sono bastate le prime preferenze; nei turni successivi sono serviti voti trasferiti da candidati eliminati o con voti in eccedenza. |
| **Prime preferenze** | Quante persone hanno indicato questo candidato come prima scelta. Mostra il sostegno diretto ricevuto prima di qualsiasi trasferimento di voti. |
| **Conteggio finale** | I voti del candidato nel momento in cui è stato eletto. Grazie ai trasferimenti, spesso sono più delle sue prime preferenze. |
| **Surplus** | Di quanto i voti del candidato al momento dell'elezione superavano la quota (conteggio finale meno quota). Un surplus maggiore indica un sostegno superiore a quello necessario per vincere. Nel metodo Scottish STV, questo surplus viene ridistribuito alle preferenze successive di chi ha votato il candidato. |

Se il conteggio produce un pareggio in cui eliminare uno qualsiasi dei candidati rimasti cambierebbe il risultato, quei candidati vengono mostrati in una tabella separata, senza scegliere arbitrariamente un vincitore.

<!-- translation-section: round-by-round-details -->

### Dettagli round per round

Espandi **Dettagli round per round** per vedere i trasferimenti di voti e le eliminazioni. Ogni riga rappresenta un candidato e ogni colonna un turno di conteggio:

![](stv-results.png)

Il verde indica quando un candidato è stato eletto, il rosso quando è stato eliminato e l'arancione quando si è verificato un pareggio.

<!-- translation-section: share-an-outcome -->

## Condividi una conclusione

Quando l'elezione si chiude, condividi una conclusione. Indica i nomi delle persone elette e quando inizia il loro incarico. Consulta [Condividi una conclusione](/en/user_manual/polls/intro_to_decisions#5-share-an-outcome) per sapere come funzionano le conclusioni.

![Una conclusione che indica i nomi dei membri eletti del comitato](outcome.png)

<!-- translation-section: exporting-ballots -->

## Esportare le schede

Dopo la chiusura dell'elezione, chi può vedere i risultati può esportare le schede in formato BLT per un riconteggio o una verifica indipendente. L'esportazione contiene le classifiche dei candidati e riunisce quelle identiche in un'unica riga, indicando il numero di schede. Per le elezioni anonime, non contiene le identità di chi ha votato, gli identificativi delle schede, gli orari di invio né l'ordine di invio.
