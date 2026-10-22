---
title: API
source_revision: 2d360988a87765e6a1345dd06155bc988154178e
source_file: docs/help/en/user_manual/integrations/api/index.md
translated:
  provider: codex/gpt-6.1-sol
  'on': '2026-10-23'
sections:
  introduction: 99e59473b33baba1
  user-api: 8424224e38edf17f
  server-api: 42859c6715b7a994
generated:
  introduction: 4ccca833495ffc6b
  user-api: 1abdd8a22164de1a
  server-api: 4e083356d18fba7a
title_source: c8e5998f6a3955c2
title_generated: c8e5998f6a3955c2
---

<!-- translation-section: introduction -->

# API Loomio

Utilisez l’API Loomio pour connecter Loomio à d’autres logiciels et à des processus automatisés.

Le [contrat OpenAPI 3.1](openapi.yaml) décrit toutes les opérations publiques de l’API utilisateur et de l’API serveur dans un format lisible par machine. Importez-le dans un client API ou utilisez-le pour générer du code client typé. Les guides ci-dessous expliquent les processus, les permissions et les comportements qui ne sont pas entièrement décrits par le contrat.

<!-- translation-section: user-api -->

## API utilisateur

L’[API utilisateur](/en/user_manual/integrations/api/user-api) effectue des actions au nom d’un utilisateur Loomio. Elle permet de lister les groupes et de créer ou de gérer des fils, des commentaires, des sondages et des adhésions aux groupes selon les permissions de cet utilisateur.

Pour les intégrations recevant des événements, les [webhooks de groupe](/en/user_manual/integrations/api/user-api#webhooks) envoient une sélection d’événements Loomio à un point de terminaison web au format JSON. Utilisez les points de terminaison REST pour lire ou modifier les données Loomio et un webhook lorsqu’une intégration doit recevoir des événements sans interroger régulièrement l’API.

<!-- translation-section: server-api -->

## API serveur

L’[API serveur](/en/user_manual/integrations/api/server-api) permet aux opérateurs d’installations Loomio autohébergées de créer et de gérer les comptes utilisateurs, de découvrir les groupes et de gérer les adhésions aux groupes et les rôles. Elle utilise un secret commun à l’ensemble du serveur et ne nécessite ni compte de bot ni adhésion à chaque groupe.
