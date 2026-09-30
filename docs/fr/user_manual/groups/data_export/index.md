---
title: Exportation des données
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/groups/data_export/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-29'
sections:
  introduction: 5e29f67f9a2084ec
  export-data: 58b5e1d4e6f0b917
  export-group-data-as-csv: 53286ec33e7300d6
  export-group-data-as-html: 101671937dcd6f36
  export-group-data-as-json: 4ec883363fb166ee
  print-thread-to-pdf: 39c48383953f9fd5
  import-your-group-data-on-another-loomio-server: 910ee8af48049e82
generated:
  introduction: 4e00f158f313dcdc
  export-data: dde9fc9a98a0d23c
  export-group-data-as-csv: b0990d523cb0d41f
  export-group-data-as-html: e085a1ae32ec70f2
  export-group-data-as-json: 4f52b377f9e4d84e
  print-thread-to-pdf: 6624bb5ab513c67a
  import-your-group-data-on-another-loomio-server: f8110807f488250b
title_source: 29049648f87b87f5
title_generated: 0221a14f9fad8a33
---

<!-- translation-section: introduction -->

# Sauvegarder ou exporter les données d’un groupe

La fonction d’exportation des données d’un groupe vous permet de :

- Télécharger un fichier contenant les données des membres pour vérifier la composition du groupe.
- Télécharger le contenu de votre groupe, notamment le texte des discussions et des sondages, pour l’archiver ou l’analyser.
- Ouvrir les résultats des sondages dans un tableur ou les traiter avec un langage de script.
- [Imprimer une discussion ou un sondage, ou l’enregistrer au format PDF pour l’archiver.](#print-thread-to-pdf)
- Transférer votre groupe, avec tous ses utilisateurs, discussions, sondages et fichiers, vers un autre serveur Loomio.

Vous pouvez utiliser cette fonction si vous souhaitez quitter les serveurs gérés par Loomio pour passer [à votre propre serveur](https://github.com/loomio/loomio).

Si vous gérez votre propre serveur Loomio et souhaitez passer à un hébergement géré, Loomio propose des serveurs aux États-Unis, dans l’Union européenne et en Australie. Pour y transférer votre groupe, [contactez-nous](/contact).

[Contactez-nous](/contact) si vous souhaitez transférer votre groupe du service mondial hébergé par Loomio sur loomio.com vers l’un de nos services régionaux : loomio.eu pour l’Europe ou loomio.nz pour l’Australie et la Nouvelle-Zélande.

<!-- translation-section: export-data -->

## Exporter les données

Ouvrez le menu du groupe en cliquant sur les trois points, puis sélectionnez **Exporter les données de ton groupe**.

![Option d’exportation des données du groupe dans le menu d’Oatmilk Cooperative](group_export_group_data.png)

<!-- translation-section: export-group-data-as-csv -->

### Exporter les données du groupe au format CSV

*Pour utiliser les données du groupe dans un tableur comme MS Excel ou Google Sheets.*

Loomio prépare le fichier CSV en arrière-plan et vous envoie un lien de téléchargement par courriel lorsqu’il est prêt. Le lien reste disponible pendant une semaine.

<!-- translation-section: export-group-data-as-html -->

### Exporter les données du groupe au format HTML

*Pour conserver les données dans des archives.*

Loomio prépare le fichier HTML en arrière-plan et vous envoie un lien de téléchargement par courriel lorsqu’il est prêt. Le lien reste disponible pendant une semaine.

<!-- translation-section: export-group-data-as-json -->

### Exporter les données du groupe au format JSON

*Pour transférer les données de votre groupe vers une instance Loomio que vous hébergez vous-même.*

Vous devez être administrateur du groupe pour l’exporter. L’exportation JSON comprend :

- Le groupe, ses membres et les demandes d’adhésion
- Les discussions, commentaires, réactions, étiquettes, modèles, notifications et données associées des groupes inclus
- Les sondages, options, votes et conclusions ; un sondage anonyme n’est inclus qu’après sa clôture
- Les sous-groupes dont vous faites partie
- Les sous-groupes ouverts et fermés lorsque vous exportez leur groupe parent en tant qu’administrateur de ce groupe, même si vous ne faites pas partie de ces sous-groupes
- Les références aux fichiers et images joints au contenu inclus

L’exportation JSON ne comprend pas :

- Les sous-groupes secrets dont vous ne faites pas partie, ainsi que leurs membres et leur contenu
- Les sous-groupes en attente de suppression
- Les sondages anonymes qui ne sont pas encore clos
- Les discussions et sondages directs qui n’appartiennent pas au groupe

Vous recevrez bientôt un courriel contenant un lien pour télécharger le fichier JSON.

<!-- translation-section: print-thread-to-pdf -->

## Imprimer une discussion au format PDF

Vous pouvez extraire une copie d’une discussion pour la conserver dans des archives distinctes.

L’option **Imprimer** conserve tous les commentaires, sondages, votes et conclusions, ainsi que la mise en forme de la discussion.

Dans le menu de la discussion, cliquez sur les trois points (⋯), puis choisissez **Imprimer**. Loomio génère une page HTML que vous pouvez imprimer ou enregistrer au format PDF avec la fonction d’impression de votre navigateur.

Vous pouvez copier la page et la coller dans un éditeur de documents, un fichier ou un dépôt de données.

![Option Imprimer pour la discussion sur les bouteilles consignées](discussion_print_discussion.png#width-90)

<!-- translation-section: import-your-group-data-on-another-loomio-server -->

## Importer les données de votre groupe sur un autre serveur Loomio

Pour savoir comment configurer votre propre serveur Loomio, consultez : https://github.com/loomio/loomio

Si vous hébergez votre propre instance Loomio et souhaitez importer les données exportées :

Copiez le fichier .json dans le dossier `import` de l’instance du conteneur :

`scp your-group-data.json username@some-domain.org:loomio-deploy/import`

Accédez à la console Rails de l’instance en cours d’exécution :

`docker exec -ti loomio-app rails console`

Appelez le service :

`GroupExportService.import('/import/your-group-data.json')`
