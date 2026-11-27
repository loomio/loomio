---
title: Exportation des données
source_revision: 95ce9afd64c99656f67e05a09fa9fc8a77af51d7
source_file: docs/help/en/user_manual/groups/data_export/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-11-26'
sections:
  introduction: 988679ffd3d29834
  export-data: '024783a0614721d2'
  export-group-data-as-csv: c0845f09bff828f2
  export-group-data-as-html: 659fd5e14956b00e
  export-group-data-as-json: 4c2131f4518b7469
  print-thread-to-pdf: 1a1d0598f4277ba1
  import-your-group-data-on-another-loomio-server: 33d49c6c25be163b
generated:
  introduction: 1aafc394f80052d8
  export-data: 406ae732f6e4d716
  export-group-data-as-csv: f3d6f4b47c70e451
  export-group-data-as-html: 99026634c4d6b86a
  export-group-data-as-json: 01ce8a7bdeac82c2
  print-thread-to-pdf: f8599de97c28e855
  import-your-group-data-on-another-loomio-server: 4e51f699094f70f8
title_source: 29049648f87b87f5
title_generated: 0221a14f9fad8a33
---

<!-- translation-section: introduction -->

# Sauvegarde ou exportation des données du groupe

L’exportation des données du groupe vous permet de :

- Télécharger les données des membres pour vérifier la composition du groupe.
- Archiver ou analyser les fils, les commentaires et les sondages de votre groupe.
- Ouvrir les résultats des sondages dans un tableur ou un script.
- [Imprimer un fil ou un sondage, ou l’enregistrer au format PDF, pour vos archives.](#print-thread-to-pdf)
- Transférer votre groupe, y compris ses utilisateurs, fils, sondages et fichiers, vers un autre serveur Loomio.

Vous pouvez utiliser cette fonctionnalité pour passer du service d’hébergement de Loomio à un [serveur auto-hébergé](https://github.com/loomio/loomio). Si vous gérez votre propre serveur et souhaitez passer à l’hébergement géré de Loomio aux États-Unis, dans l’Union européenne ou en Australie, [contactez-nous](/contact).

[Contactez-nous](/contact) si vous souhaitez transférer un groupe de loomio.com vers un service régional (loomio.eu pour l’Europe ou loomio.nz pour l’Australie et la Nouvelle-Zélande).

<!-- translation-section: export-data -->

## Exporter les données

Seul un administrateur du groupe peut exporter les données du groupe. Ouvrez **Paramètres** sur la page du groupe et sélectionnez **Exporter les données de votre groupe**.

![Action d’exportation des données du groupe sur la page des paramètres d’Oatmilk Cooperative](group_export_group_data.png)

Loomio prépare l’exportation en arrière-plan et vous envoie un lien de téléchargement par e-mail lorsqu’elle est prête. Le lien reste actif pendant une semaine.

<!-- translation-section: export-group-data-as-csv -->

### Exporter les données du groupe au format CSV

Utilisez le format CSV pour examiner les données du groupe, notamment les informations sur les membres et leur activité, dans un tableur comme Microsoft Excel ou Google Sheets.

<!-- translation-section: export-group-data-as-html -->

### Exporter les données du groupe au format HTML

Utilisez le format HTML pour conserver une copie lisible des discussions et des sondages de votre groupe à des fins d’archivage.

<!-- translation-section: export-group-data-as-json -->

### Exporter les données du groupe au format JSON

Utilisez le format JSON pour transférer les données de votre groupe vers un serveur Loomio auto-hébergé.

L’exportation JSON comprend :

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

<!-- translation-section: print-thread-to-pdf -->

## Imprimer un fil au format PDF

Pour conserver une copie d’un fil dans vos archives, ouvrez son menu des actions et sélectionnez **Imprimer**. Loomio génère une page HTML contenant les commentaires, les sondages, les votes, les conclusions et la mise en forme du fil. Utilisez l’outil d’impression de votre navigateur pour l’imprimer ou l’enregistrer au format PDF, ou copiez le contenu dans un autre document.

![Action d’impression de la discussion sur les bouteilles consignées](discussion_print_discussion.png#width-90)

<!-- translation-section: import-your-group-data-on-another-loomio-server -->

## Importer les données de votre groupe sur un autre serveur Loomio

Cette section s’adresse aux administrateurs qui gèrent un serveur Loomio auto-hébergé. Pour les instructions d’installation, consultez le [dépôt Loomio](https://github.com/loomio/loomio).

1. Copiez le fichier `.json` dans le dossier `import` du conteneur :

```sh
scp your-group-data.json username@some-domain.org:loomio-deploy/import
```

2. Ouvrez la console Rails dans le conteneur en cours d’exécution :

```sh
docker exec -ti loomio-app rails console
```

3. Exécutez le service d’importation :

```ruby
GroupExportService.import('/import/your-group-data.json')
```
