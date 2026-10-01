---
title: Élections STV
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
  introduction: 6a0ecdf5501a7a52
  when-to-use-stv: 8926b0dfb0383c49
  creating-an-stv-election: 35888bcebff0beba
  number-of-seats: e365ba38ab90b66e
  counting-method: 869065671aae17b0
  quota-type: 790f54f203878754
  how-voting-works: b67dd79f79840822
  how-counting-works: 7c479d213ae971b9
  understanding-results: 655c39888745be9e
  method-and-quota: ad11d0360bf905bf
  elected-candidates: a00f41a1bc356c17
  round-by-round-details: 805148b929d66947
  exporting-ballots: 6498997f3f958bd0
  share-an-outcome: 66899b4d714a2c2f
title_source: cd3e1a4cdc2456a6
title_generated: b63ff19253676749
---

<!-- translation-section: introduction -->

# Élections STV

Le **vote unique transférable (STV)** est une méthode de vote à représentation proportionnelle permettant d’élire plusieurs personnes parmi un ensemble de candidats. Il garantit que les candidats élus représentent proportionnellement la diversité des points de vue des électeurs.

<!-- translation-section: when-to-use-stv -->

## Quand utiliser le STV

Utilisez une élection STV lorsque vous souhaitez :

- Élire un **comité, un conseil d’administration ou une délégation** parmi un ensemble de candidats
- Assurer une **représentation proportionnelle**, permettant aux courants minoritaires de remporter des sièges proportionnellement à leur soutien
- Organiser des élections où les électeurs classent les candidats par ordre de préférence

>[!NOTE]
>Le STV est **différent** du [sondage Classer](/en/user_manual/polls/rank/) de Loomio, qui utilise un classement plus simple fondé sur des scores pour choisir une seule option préférée. Le STV permet d’élire plusieurs personnes, avec des transferts de votes et des tours d’élimination.

<!-- translation-section: creating-an-stv-election -->

## Créer une élection STV

Lorsque vous lancez un sondage, choisissez **Élection STV** comme type de sondage, puis ajoutez les candidats comme options du sondage. Vous pouvez personnaliser le sondage en définissant le **nombre de sièges**, la **méthode de dépouillement** et le **type de quota**.

Dans cet exemple, Oatmilk Cooperative élit trois personnes pour superviser son essai d’emballages consignés. Le formulaire explique le rôle, présente cinq candidats et utilise le STV écossais avec le quota de Droop.

![](form.png)

<!-- translation-section: number-of-seats -->

### Nombre de sièges

Le nombre de personnes à élire. Il doit être inférieur au nombre de candidats.

<!-- translation-section: counting-method -->

### Méthode de dépouillement

Deux méthodes de dépouillement des votes sont disponibles :

STV écossais
  : Recommandé. La méthode Gregory inclusive pondérée (WIGM), utilisée lors des élections locales écossaises depuis 2007. Ses règles sont bien définies et simples. Elle convient à la plupart des organisations.
  
STV de Meek
  : Une méthode plus précise, dont le dépouillement nécessite un ordinateur. Lorsqu’un candidat est élu, la méthode de Meek continue de transférer la part de chaque vote dont il n’a pas besoin vers les préférences suivantes de l’électeur, y compris pour les votes qui lui parviennent plus tard dans le dépouillement. Lorsqu’un candidat est éliminé, les votes sont recomptés comme s’il ne s’était jamais présenté. Moins de votes sont perdus qu’avec le STV écossais, mais le dépouillement ne peut pas être vérifié à la main.

<!-- translation-section: quota-type -->

### Type de quota

Le quota est le nombre minimum de votes dont un candidat a besoin pour obtenir un siège. Deux types de quota sont disponibles :

Droop
  : Recommandé. Le quota standard des élections STV, utilisé en Irlande, en Australie et en Écosse. C’est le plus petit quota que ne peuvent atteindre plus de candidats qu’il n’y a de sièges à pourvoir. Un ensemble d’électeurs qui classent leurs propres candidats en premier obtient au moins autant de sièges que le nombre de quotas que représentent leurs votes. Il se calcule ainsi :
\\[ floor(\frac{votes}{(seats + 1)}) + 1 \\]

Hare
  : Un quota plus élevé. Les ensembles d’électeurs disposant de nombreux votes en utilisent davantage pour chaque siège obtenu, ce qui donne aux ensembles plus petits davantage de chances d’obtenir les derniers sièges. Il se calcule ainsi :
    \\[ \frac{votes}{seats}\\]

Dans les deux formules, *votes* désigne le nombre de bulletins qui classent au moins un candidat.

La méthode STV de Meek calcule le quota sans arrondir, selon la formule votes ÷ (seats + 1) pour Droop. Elle recalcule le quota à chaque tour à partir des votes encore détenus par les candidats, et un candidat doit le dépasser pour être élu.
  
  >[!TIP]
  > Le quota de Droop correspond toujours à un nombre de votes inférieur à celui de Hare. Par exemple, dans une élection avec 100 votes et quatre sièges, le quota de Droop serait de 21 et celui de Hare de 25.

<!-- translation-section: how-voting-works -->

## Comment voter

Dans cet exemple, Oatmilk Cooperative élit trois personnes pour superviser l’essai d’emballages réutilisables. Les électeurs font glisser les candidats au-dessus de la ligne et les classent par ordre de préférence :

![](stv-vote-in-progress.png)

- **Classer en position 1** = candidat préféré
- **Classer en position 2** = deuxième choix
- Continuez à classer autant de candidats que vous le souhaitez

Les électeurs doivent classer au moins un candidat, mais ne sont pas obligés de tous les classer. Les candidats non classés ne recevront aucune part du vote de cet électeur.

<!-- translation-section: how-counting-works -->

## Comment se déroule le dépouillement
Le dépouillement se déroule comme suit :

1. Un **quota** est calculé (le nombre minimum de votes nécessaire pour remporter un siège).
2. Les **Premières préférences** sont comptées pour chaque candidat.
3. Chaque candidat qui atteint le quota est **élu**. Ses votes excédentaires (au-delà du quota) sont **transférés** vers les préférences suivantes des électeurs avec une valeur fractionnaire, en commençant par le surplus le plus élevé. Les votes ne sont transférés qu’aux candidats encore en lice.
4. S’il ne reste aucun surplus à transférer, le candidat ayant le **moins de votes est éliminé**. Ses votes sont transférés vers les préférences suivantes des électeurs à leur pleine valeur.
5. Lorsque le nombre de candidats restants est égal au nombre de sièges restant à pourvoir, ils sont tous élus, même s’ils n’ont pas atteint le quota.
6. Sinon, le dépouillement reprend à l’étape 3 jusqu’à ce que tous les sièges soient pourvus.

La valeur fractionnaire permet de répartir uniquement les votes dont un candidat élu n’a pas besoin. Par exemple, si le quota est de 26 et qu’un candidat dispose de 40 votes, son surplus est de 14. Chacun de ses 40 bulletins est transféré à la préférence suivante avec une valeur de 14 ÷ 40 = 0,35 vote.

Avec le STV écossais, la valeur de chaque vote transféré est arrondie à la baisse à cinq décimales, comme lors des élections municipales écossaises.

Si plusieurs candidats ont le plus petit nombre de votes, celui qui avait le moins de votes au tour précédent le plus récent permettant de les départager est éliminé.

>[!TIP]
>Un bulletin ne compte que tant qu’il classe un candidat encore en lice. Lorsqu’il n’en reste aucun, le bulletin est « épuisé » et ne compte plus.

<!-- translation-section: understanding-results -->

## Comprendre les résultats

Après la clôture du sondage, les résultats sont affichés dans plusieurs sections. Dans cette élection, Samira Patel, Alex Morgan et Morgan Price occupent les trois sièges du comité :

![](stv-results-summary.png)

<!-- translation-section: method-and-quota -->

### Méthode et quota

En haut, vous verrez la méthode de dépouillement (STV écossais ou STV de Meek) et le type de quota (Droop ou Hare), ainsi que le quota, c’est-à-dire le nombre de votes dont un candidat avait besoin pour remporter un siège.

<!-- translation-section: elected-candidates -->

### Candidats élus

Un tableau récapitulatif des personnes élues comporte cinq colonnes :

| Colonne | Signification |
|--------|---------|
| **Candidat** | Le nom du candidat élu |
| **Tour élu** | Le tour de dépouillement au cours duquel le candidat a atteint le quota et remporté un siège. Le tour 1 signifie qu’il a été élu grâce aux seules premières préférences ; les tours suivants signifient qu’il a eu besoin de votes transférés depuis des candidats éliminés ou disposant d’un surplus. |
| **Premières préférences** | Le nombre d’électeurs qui ont classé ce candidat comme premier choix. Il indique le soutien direct du candidat avant tout transfert de votes. |
| **Bilan final** | Le total des votes du candidat au moment de son élection. En raison des transferts de votes, ce total est souvent supérieur au nombre de premières préférences. |
| **Surplus** | La différence entre le bilan final du candidat et le quota (bilan final moins quota). Un surplus plus élevé indique un soutien plus important au-delà de ce qui était nécessaire pour être élu. Avec le STV écossais, ce surplus est redistribué vers les préférences suivantes des électeurs. |

Les tours précédents ne permettent pas toujours de départager une égalité. Si l’égalité ne change pas les personnes élues, le dépouillement continue. Si elle les change, le dépouillement s’arrête à ce tour. Les candidats qui remportent un siège quelle que soit la manière de départager l’égalité sont affichés comme élus. Les candidats qui pourraient être élus ou non selon la manière de départager l’égalité sont affichés dans un tableau distinct. Loomio les affiche à égalité au lieu d’en choisir un au hasard.

<!-- translation-section: round-by-round-details -->

### Détails tour par tour

Développez **Détails tour par tour** pour consulter les transferts de votes et les éliminations. Chaque ligne correspond à un candidat et chaque colonne à un tour de dépouillement. Chaque nombre indique les votes détenus par le candidat au début de ce tour :

![](stv-results.png)

Le surlignage vert indique le tour où un candidat a été élu, le rouge celui où il a été éliminé et l’orange celui où il était à égalité.

<!-- translation-section: share-an-outcome -->

## Partager une conclusion

Lorsque l’élection est clôturée, partagez une conclusion. Nommez les personnes élues et indiquez quand leur mandat commence. Consultez [Partager une conclusion](/en/user_manual/polls/intro_to_decisions#5-share-an-outcome) pour comprendre le fonctionnement des conclusions.

![Une conclusion nommant les membres élus du comité](outcome.png)

<!-- translation-section: exporting-ballots -->

## Exporter les bulletins

Une fois l’élection clôturée, les personnes qui peuvent consulter les résultats peuvent exporter les bulletins au format BLT pour un recomptage ou un audit indépendant. L’export contient les classements des candidats et regroupe les classements identiques sur une seule ligne en indiquant le nombre de bulletins. Pour les élections anonymes, il ne contient ni l’identité des électeurs, ni les identifiants des bulletins, ni les heures de soumission, ni l’ordre de soumission.
