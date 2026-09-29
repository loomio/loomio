---
title: API
source_revision: 7a01b0fd7d7df0c4bca327a916b01b12e62b967f
source_file: docs/user_manual/integrations/api/index.md
translated:
  provider: codex/gpt-6-sol
  'on': '2026-09-30'
sections:
  introduction: 99e59473b33baba1
  user-api: 8424224e38edf17f
  server-api: f1bf07c1162ff08b
generated:
  introduction: 3393ff9ad21d2e80
  user-api: ea82d2234b26af4c
  server-api: 14cc26bbb89423e0
title_source: c8e5998f6a3955c2
title_generated: c8e5998f6a3955c2
---

<!-- translation-section: introduction -->

# API Loomio

Utilisez l’API Loomio pour connecter Loomio à d’autres logiciels et à des flux de travail automatisés.

Le [contrat OpenAPI 3.1](openapi.yaml) décrit toutes les opérations publiques de l’API utilisateur et de l’API serveur dans un format lisible par machine. Importez-le dans un client API ou utilisez-le pour générer du code client typé. Les guides ci-dessous expliquent les flux de travail, les autorisations et les comportements que le contrat ne décrit pas entièrement.

<!-- translation-section: user-api -->

## API utilisateur

L’[API utilisateur](/en/user_manual/integrations/api/user-api) permet d’effectuer des actions en tant qu’utilisateur de Loomio. Selon les autorisations de cet utilisateur, elle peut lister les groupes et créer ou gérer des fils de discussion, des commentaires, des sondages et des adhésions aux groupes.

Pour les intégrations qui reçoivent des événements, les [webhooks de groupe](/en/user_manual/integrations/api/user-api#webhooks) envoient certains événements Loomio à un point de terminaison web au format JSON. Utilisez les points de terminaison REST pour lire ou modifier les données de Loomio, et un webhook pour recevoir les événements sans interroger régulièrement l’API.

<!-- translation-section: server-api -->

## API serveur

L’[API serveur](/en/user_manual/integrations/api/server-api) permet aux personnes qui exploitent une installation Loomio auto-hébergée de gérer les comptes utilisateurs. L’authentification repose sur un secret commun à tout le serveur.
