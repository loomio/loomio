---
title: Élections STV
source_revision: 3a315412c646d254c8426be5c436a4e593f6011f
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
  introduction: 749978ca37a49376
  when-to-use-stv: abb6b52b99484ecb
  creating-an-stv-election: 288487013b15b206
  number-of-seats: e365ba38ab90b66e
  counting-method: 128edaa64c73a78b
  quota-type: 68caf2859061a52b
  how-voting-works: bc7cf3bbc6725448
  how-counting-works: '0084047ca8f3bcb9'
  understanding-results: c98bfbe4a192f568
  method-and-quota: 8eba6401ab70f8a3
  elected-candidates: 8c1fee0ff4736c0a
  round-by-round-details: d4acf2401e38b0ba
  exporting-ballots: d2698851f0c190aa
  share-an-outcome: d131558a237e10c0
title_source: cd3e1a4cdc2456a6
title_generated: b63ff19253676749
---

<!-- translation-section: introduction -->

# Élections STV

Le **vote unique transférable (STV)** est un mode de scrutin proportionnel qui permet d'élire plusieurs personnes parmi les candidats. Les personnes élues représentent ainsi la diversité des opinions des votants dans des proportions proches de leur soutien.

<!-- translation-section: when-to-use-stv -->

## Quand utiliser le STV

Utilisez une élection STV lorsque vous souhaitez :

- Élire un **comité, un conseil d'administration ou une liste de délégués** parmi plusieurs personnes candidates
- Assurer une **représentation proportionnelle**, afin que les groupes minoritaires obtiennent des sièges à la mesure de leur soutien
- Organiser une élection où les votants classent les candidats par ordre de préférence

>[!NOTE]
>Le STV est différent du [sondage par classement](/en/user_manual/polls/rank/) de Loomio. Ce dernier utilise un classement par points pour choisir une seule option. Le STV permet d'élire plusieurs personnes grâce aux transferts de voix et aux tours d'élimination.

<!-- translation-section: creating-an-stv-election -->

## Créer une élection STV

Lorsque vous créez un sondage, choisissez **Élection STV** comme type de sondage, puis ajoutez les candidats comme options. Vous pouvez définir le **nombre de sièges**, la **méthode de décompte** et le **type de quota**.

Dans cet exemple, la coopérative Oatmilk élit trois personnes pour superviser son essai d'emballages consignés. Le formulaire décrit leur rôle, présente cinq candidats et utilise la méthode STV écossaise avec le quota de Droop.

![](form.png)

<!-- translation-section: number-of-seats -->

### Nombre de sièges

Le nombre de personnes à élire. Il doit être inférieur au nombre de candidats.

<!-- translation-section: counting-method -->

### Méthode de décompte

Deux méthodes de décompte sont disponibles :

STV écossais : Recommandé. Cette méthode de Gregory inclusive pondérée (WIGM) est utilisée dans les élections locales écossaises depuis 2007. Ses règles sont claires et simples. Elle convient à la plupart des organisations.

STV de Meek : Une méthode itérative plus précise sur le plan mathématique. Lorsqu'un candidat est éliminé, les voix sont recomptées comme s'il n'avait jamais participé à l'élection.

<!-- translation-section: quota-type -->

### Type de quota

Le quota est le nombre minimal de voix dont un candidat a besoin pour obtenir un siège. Vous pouvez choisir :

Droop : Recommandé. C'est le quota habituel pour la plupart des élections STV. Il est utilisé en Irlande, en Australie et en Écosse. Il garantit qu'une coalition majoritaire obtient la majorité des sièges. Il se calcule ainsi : \\[ floor(\frac{votes}{(seats + 1)}) + 1 \\]

Hare
  : Un seuil minimal plus élevé, qui offre une représentation plus proportionnelle aux petits groupes.
    Les sections de DSA privilégient le quota de Hare pour protéger la représentation des minorités.
   Il se calcule ainsi :
    \\[ \frac{votes}{seats}\\]

>[!TIP]
  > Le quota de Droop correspond toujours à moins de voix que celui de Hare. Par exemple, pour une élection avec 100 voix et quatre sièges, le quota de Droop est de 21 voix et celui de Hare de 25 voix.

<!-- translation-section: how-voting-works -->

## Comment voter

Dans cet exemple, la coopérative Oatmilk élit trois personnes pour superviser son essai d'emballages réutilisables. Les votants font glisser les candidats au-dessus de la ligne et les classent par ordre de préférence :

![](stv-vote-in-progress.png)

- **Rang 1** = candidat préféré
- **Rang 2** = deuxième choix
- Continuez à classer autant de candidats que vous le souhaitez

Les votants ne sont pas tenus de classer tous les candidats. Ceux qui ne sont pas classés ne recevront aucune de leurs voix.

<!-- translation-section: how-counting-works -->

## Comment fonctionne le décompte
Le décompte se déroule ainsi :

1. Un **quota** est calculé (le nombre minimal de voix nécessaires pour obtenir un siège).
2. Les **Premières préférences** sont comptées pour chaque candidat.
3. Si un candidat atteint le quota, il est **élu**. Ses voix excédentaires (au-delà du quota) sont **transférées** aux candidats suivants dans l’ordre de préférence des électeurs, à une valeur fractionnaire.
4. Si aucun candidat n’atteint le quota, celui qui a **le moins de voix est éliminé**. Ses voix sont transférées aux candidats suivants dans l’ordre de préférence des électeurs, à leur pleine valeur.
5. Le processus se répète jusqu’à ce que tous les sièges soient pourvus.

>[!TIP]
>Si un votant n'a classé aucun des candidats encore en lice, son bulletin est « épuisé » et sa voix ne peut plus être comptée. Il est donc généralement préférable de classer davantage de candidats.

<!-- translation-section: understanding-results -->

## Comprendre les résultats

Après la clôture du sondage, les résultats apparaissent dans plusieurs sections. Dans cet exemple, Samira Patel, Alex Morgan et Morgan Price obtiennent les trois sièges du comité :

![](stv-results-summary.png)

<!-- translation-section: method-and-quota -->

### Méthode et quota

En haut de la page figurent la méthode de décompte (STV écossais ou STV de Meek), le type de quota (Droop ou Hare) et le quota lui-même, c'est-à-dire le nombre de voix nécessaire pour obtenir un siège.

<!-- translation-section: elected-candidates -->

### Candidats élus

Un tableau récapitule les personnes élues en cinq colonnes :

| Colonne | Signification |
|--------|---------|
| **Candidat** | Le nom du candidat élu |
| **Tour élu** | Le tour de décompte auquel le candidat a atteint le quota et obtenu un siège. Au premier tour, il a gagné grâce aux seules premières préférences. Aux tours suivants, il lui a fallu des voix transférées depuis des candidats éliminés ou élus avec un surplus. |
| **Premières préférences** | Le nombre de votants qui ont placé ce candidat en premier. Ce chiffre indique son soutien direct avant tout transfert de voix. |
| **Bilan final** | Le total des voix du candidat au moment de son élection. Les transferts de voix font souvent monter ce total au-dessus de ses premières préférences. |
| **Surplus** | Le nombre de voix par lequel le bilan final du candidat dépasse le quota (bilan final moins quota). Plus le surplus est élevé, plus le soutien dépasse ce qui était nécessaire pour gagner. Avec la méthode STV écossaise, ce surplus est redistribué aux préférences suivantes des votants. |

Si le décompte aboutit à une égalité dans laquelle l'élimination de l'un ou l'autre des candidats encore en lice changerait le résultat, ces candidats apparaissent dans un tableau distinct. Aucun gagnant n'est alors choisi arbitrairement.

<!-- translation-section: round-by-round-details -->

### Détails tour par tour

Développez **Détails tour par tour** pour voir les transferts de voix et les éliminations. Chaque ligne représente un candidat et chaque colonne un tour de décompte :

![](stv-results.png)

Le vert indique le tour où un candidat a été élu, le rouge celui où il a été éliminé et l'orange celui où il est arrivé à égalité.

<!-- translation-section: share-an-outcome -->

## Partager une conclusion

Lorsque l’élection est close, partagez une conclusion. Nommez les personnes élues et indiquez quand leur mandat commence. Consultez [Partager une conclusion](/en/user_manual/polls/intro_to_decisions#5-share-an-outcome) pour comprendre le fonctionnement des conclusions.

![Une conclusion nommant les membres élus du comité](outcome.png)

<!-- translation-section: exporting-ballots -->

## Exporter les bulletins

Après la clôture de l'élection, les personnes autorisées à voir les résultats peuvent exporter les bulletins au format BLT pour effectuer un recomptage ou un audit indépendant. L'export contient les classements des candidats et regroupe les classements identiques sur une seule ligne, avec le nombre de bulletins correspondant. Pour les élections anonymes, il ne contient ni l'identité des votants, ni les identifiants des bulletins, ni les heures ou l'ordre de soumission.
