---
title: Exportation des données
source_revision: cd2e1e63e611688362e80009f50b8ed25025ba8b
source_file: docs/en/user_manual/groups/data_export/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-07'
sections:
  introduction: 5e29f67f9a2084ec
  export-data: 58b5e1d4e6f0b917
  export-group-data-as-csv: 53286ec33e7300d6
  export-group-data-as-html: 101671937dcd6f36
  export-group-data-as-json: aa310889d0854550
  print-thread-to-pdf: 39c48383953f9fd5
  import-your-group-data-on-another-loomio-server: 910ee8af48049e82
generated:
  introduction: 6061911e71d1350e
  export-data: 3d70ea95e8be960c
  export-group-data-as-csv: b58368aa8a3c8d7f
  export-group-data-as-html: cef1c9713a716ad6
  export-group-data-as-json: d5468a0a0f2632ba
  print-thread-to-pdf: b33a8f4cad276066
  import-your-group-data-on-another-loomio-server: fd60f1bf9307db2a
title_source: 29049648f87b87f5
title_generated: 0221a14f9fad8a33
---

<!-- translation-section: introduction -->

# Sauvegarde ou exportation des données du groupe

La fonctionnalité d’exportation des données du groupe vous permet de :

- Télécharger un fichier contenant les données des membres pour vérifier la composition du groupe.
- Télécharger le contenu de votre groupe, y compris le texte des fils et des sondages, pour l’archiver ou l’analyser.
- Ouvrir les résultats des sondages dans un tableur ou un langage de script.
- [Imprimer un fil ou un sondage, ou l’enregistrer au format PDF, pour l’archiver.](#print-thread-to-pdf)
- Transférer votre groupe, y compris tous les utilisateurs, fils, sondages et fichiers, vers un autre serveur Loomio.

Si vous souhaitez passer des serveurs gérés par Loomio [à votre propre serveur](https://github.com/loomio/loomio), vous pouvez utiliser cette fonctionnalité.

Si vous gérez votre propre serveur Loomio et souhaitez cesser de le faire, Loomio propose un hébergement géré aux États-Unis, dans l’Union européenne et en Australie. Pour transférer votre groupe vers l’un de ces serveurs, [contactez-nous](/contact).

[Contactez-nous](/contact) si vous souhaitez transférer votre groupe Loomio du service d’hébergement mondial de Loomio sur loomio.com vers l’un de nos services régionaux : loomio.eu pour l’Europe ou loomio.nz pour l’Australie et la Nouvelle-Zélande.

<!-- translation-section: export-data -->

## Exporter les données

Ouvrez le menu déroulant du groupe en cliquant sur les trois points, puis sélectionnez **Exporter les données de votre groupe**.

![Action d’exportation des données du groupe dans le menu d’Oatmilk Cooperative](group_export_group_data.png)

<!-- translation-section: export-group-data-as-csv -->

### Exporter les données du groupe au format CSV

*Pour travailler sur les données du groupe dans un tableur, comme MS Excel ou Google Sheets.*

Loomio prépare le fichier CSV en arrière-plan et vous envoie un lien de téléchargement par e-mail lorsqu’il est prêt. Le lien est disponible pendant une semaine.

<!-- translation-section: export-group-data-as-html -->

### Exporter les données du groupe au format HTML

*Pour enregistrer les données à des fins d’archivage.*

Loomio prépare le fichier HTML en arrière-plan et vous envoie un lien de téléchargement par e-mail lorsqu’il est prêt. Le lien est disponible pendant une semaine.

<!-- translation-section: export-group-data-as-json -->

### Exporter les données du groupe au format JSON

*Pour transférer les données de votre groupe vers une instance Loomio auto-hébergée.*

Vous devez être administrateur du groupe pour l’exporter. L’exportation JSON comprend :

- Le groupe, ses membres et les demandes d’adhésion
- Les fils, commentaires, réactions, tags, modèles, notifications et enregistrements associés des groupes inclus
- Les sondages, options, votes et conclusions ; un sondage anonyme n’est inclus qu’après sa clôture
- Les sous-groupes auxquels vous appartenez
- Les sous-groupes ouverts, fermés et visibles par le groupe parent lorsque vous exportez leur groupe parent en tant qu’administrateur de celui-ci, même si vous n’appartenez pas à ces sous-groupes
- Les références aux fichiers et images joints au contenu inclus

L’exportation JSON ne comprend pas :

- Les sous-groupes secrets auxquels vous n’appartenez pas, y compris leurs membres et leur contenu
- Les sous-groupes en attente de suppression
- Les sondages anonymes qui ne sont pas encore clôturés
- Les fils directs et les sondages qui n’appartiennent pas au groupe

Vous recevrez sous peu un e-mail contenant un lien pour télécharger le fichier JSON.

<!-- translation-section: print-thread-to-pdf -->

## Imprimer un fil au format PDF

Vous pouvez avoir besoin d’extraire une copie d’un fil pour la conserver dans une archive de fichiers distincte.

La fonction **Imprimer** conserve tous les commentaires, sondages, votes et conclusions, ainsi que la mise en forme du fil.

Dans le fil, cliquez sur le menu à trois points (⋯) et choisissez **Imprimer**. Loomio génère une page HTML que vous pouvez ensuite imprimer ou « enregistrer au format PDF » à l’aide de l’outil d’impression de votre navigateur.

Vous pouvez copier la page pour la coller dans un éditeur de documents, un fichier ou un dépôt de données.

![Action d’impression de la discussion sur les bouteilles consignées](discussion_print_discussion.png#width-90)

<!-- translation-section: import-your-group-data-on-another-loomio-server -->

## Importer les données de votre groupe sur un autre serveur Loomio

Pour obtenir les instructions d’installation de votre propre serveur Loomio, consultez : https://github.com/loomio/loomio

Si vous hébergez votre propre instance Loomio et souhaitez importer vos données exportées :

Copiez le fichier .json dans le dossier `import` de l’instance du conteneur :

`scp your-group-data.json username@some-domain.org:loomio-deploy/import`

Accédez à la console Rails en cours d’exécution :

`docker exec -ti loomio-app rails console`

Appelez le service :

`GroupExportService.import('/import/your-group-data.json')`
