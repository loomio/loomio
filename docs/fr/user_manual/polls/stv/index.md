---
title: Élections STV
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
  introduction: 749978ca37a49376
  when-to-use-stv: abb6b52b99484ecb
  creating-an-stv-election: 288487013b15b206
  number-of-seats: e365ba38ab90b66e
  counting-method: 621f134fdfa6842a
  quota-type: f9702c72b87a5095
  how-voting-works: 12f8ce42b03d6725
  how-counting-works: 9d5707ffd37b2ede
  understanding-results: c98bfbe4a192f568
  method-and-quota: 8eba6401ab70f8a3
  elected-candidates: 183c17fbe9e455fc
  round-by-round-details: c8ac6900da61e545
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

Scottish STV
  : Recommandé. Cette méthode de Gregory inclusive pondérée (WIGM) est utilisée dans les élections locales écossaises depuis 2007. Ses règles sont claires et simples. Elle convient à la plupart des organisations.
  
Meek STV
  : Une méthode plus précise dont le décompte nécessite un ordinateur. Lorsqu'un candidat est élu, Meek continue de transférer la part de chaque voix dont il n'a pas besoin aux préférences suivantes du votant, y compris pour les voix qui lui parviennent plus tard dans le décompte. Lorsqu'un candidat est éliminé, les voix sont recomptées comme s'il n'avait jamais participé à l'élection. Moins de voix sont perdues qu'avec Scottish STV, mais le décompte ne peut pas être vérifié à la main.

<!-- translation-section: quota-type -->

### Type de quota

Le quota est le nombre minimal de voix dont un candidat a besoin pour obtenir un siège. Vous pouvez choisir :

Droop
  : Recommandé. C'est le quota habituel pour les élections STV, utilisé en Irlande, en Australie et en Écosse. C'est le plus petit quota que ne peuvent pas atteindre plus de candidats qu'il n'y a de sièges à pourvoir. Un groupe de votants qui classe ses propres candidats en premier obtient au moins autant de sièges qu'il dispose de quotas de voix. Il se calcule ainsi :
\\[ floor(\frac{votes}{(seats + 1)}) + 1 \\]

Hare
  : Un quota plus élevé. Les groupes disposant de nombreuses voix en utilisent davantage pour chaque siège obtenu, ce qui augmente les chances des petits groupes d'obtenir les derniers sièges. Il se calcule ainsi :
    \\[ \frac{votes}{seats}\\]

Dans les deux formules, *votes* désigne le nombre de bulletins qui classent au moins un candidat.

Meek STV calcule le quota sans arrondi, soit votes ÷ (seats + 1) pour Droop. Le quota est recalculé à chaque tour à partir des voix encore détenues par les candidats, et un candidat doit le dépasser pour être élu.
  
  >[!TIP]
  > Le quota de Droop correspond toujours à moins de voix que celui de Hare. Par exemple, pour une élection avec 100 voix et quatre sièges, le quota de Droop est de 21 voix et celui de Hare de 25 voix.

<!-- translation-section: how-voting-works -->

## Comment voter

Dans cet exemple, la coopérative Oatmilk élit trois personnes pour superviser son essai d'emballages réutilisables. Les votants font glisser les candidats au-dessus de la ligne et les classent par ordre de préférence :

![](stv-vote-in-progress.png)

- **Rang 1** = candidat préféré
- **Rang 2** = deuxième choix
- Continuez à classer autant de candidats que vous le souhaitez

Les votants doivent classer au moins un candidat, mais ne sont pas tenus de les classer tous. Les candidats non classés ne recevront aucune part de la voix de ce votant.

<!-- translation-section: how-counting-works -->

## Comment fonctionne le décompte
Le décompte se déroule ainsi :

1. Un **quota** est calculé (le nombre minimal de voix nécessaires pour obtenir un siège).
2. Les **Premières préférences** sont comptées pour chaque candidat.
3. Chaque candidat qui atteint le quota est **élu**. Ses voix excédentaires (au-delà du quota) sont **transférées** aux préférences suivantes des votants, à une valeur fractionnaire, en commençant par le surplus le plus élevé. Les voix sont transférées uniquement aux candidats encore en lice.
4. S'il ne reste aucun surplus à transférer, le candidat qui a **le moins de voix est éliminé**. Ses voix sont transférées aux préférences suivantes des votants, à leur pleine valeur.
5. Lorsque le nombre de candidats encore en lice est égal au nombre de sièges restant à pourvoir, ils sont tous élus, même s'ils n'ont pas atteint le quota.
6. Sinon, le décompte reprend à l'étape 3 jusqu'à ce que tous les sièges soient pourvus.

La valeur fractionnaire permet de répartir uniquement les voix dont un candidat élu n'a pas besoin. Par exemple, si le quota est de 26 et qu'un candidat a 40 voix, son surplus est de 14. Chacun de ses 40 bulletins est transféré à sa préférence suivante avec une valeur de 14 ÷ 40 = 0,35 voix.

Avec Scottish STV, la valeur de chaque voix transférée est arrondie à cinq décimales par défaut, comme dans les élections municipales écossaises.

Si plusieurs candidats ont le même nombre minimal de voix, celui qui avait le moins de voix au tour précédent le plus récent permettant de les départager est éliminé.

>[!TIP]
>Un bulletin compte uniquement tant qu'il classe un candidat encore en lice. Lorsqu'il n'en reste aucun, le bulletin est « épuisé » et ne compte plus.

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
| **Surplus** | Le nombre de voix par lequel le bilan final du candidat dépasse le quota (bilan final moins quota). Plus le surplus est élevé, plus le soutien dépasse ce qui était nécessaire pour gagner. Avec Scottish STV, ce surplus est redistribué aux préférences suivantes des votants. |

Parfois, les tours précédents ne permettent pas de départager des candidats à égalité. Si cette égalité ne change pas les personnes élues, le décompte continue. Si elle les change, le décompte s'arrête à ce tour. Les candidats qui gagnent quelle que soit la manière de départager l'égalité sont affichés comme élus. Ceux qui pourraient gagner ou perdre selon la manière de les départager apparaissent dans un tableau distinct. Loomio les affiche à égalité plutôt que d'en choisir un au hasard.

<!-- translation-section: round-by-round-details -->

### Détails tour par tour

Développez **Détails tour par tour** pour voir les transferts de voix et les éliminations. Chaque ligne représente un candidat et chaque colonne un tour de décompte. Chaque nombre indique les voix détenues par le candidat au début de ce tour :

![](stv-results.png)

Le vert indique le tour où un candidat a été élu, le rouge celui où il a été éliminé et l'orange celui où il est arrivé à égalité.

<!-- translation-section: share-an-outcome -->

## Partager une conclusion

Lorsque l’élection est close, partagez une conclusion. Nommez les personnes élues et indiquez quand leur mandat commence. Consultez [Partager une conclusion](/en/user_manual/polls/intro_to_decisions#5-share-an-outcome) pour comprendre le fonctionnement des conclusions.

![Une conclusion nommant les membres élus du comité](outcome.png)

<!-- translation-section: exporting-ballots -->

## Exporter les bulletins

Après la clôture de l'élection, les personnes autorisées à voir les résultats peuvent exporter les bulletins au format BLT pour effectuer un recomptage ou un audit indépendant. L'export contient les classements des candidats et regroupe les classements identiques sur une seule ligne, avec le nombre de bulletins correspondant. Pour les élections anonymes, il ne contient ni l'identité des votants, ni les identifiants des bulletins, ni les heures ou l'ordre de soumission.
